-- Phase 1 placeholder only. No domain tables exist yet.
-- Phase 2 will introduce reviewed, versioned transactional migrations and schema snapshot.
-- ============================================================================
-- 1. EXTENSIONS & ENUMS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE user_role AS ENUM ('admin', 'staff', 'customer');
CREATE TYPE plan_interval AS ENUM ('daily', 'weekly', 'monthly', 'yearly');
CREATE TYPE sub_status AS ENUM ('draft', 'quotation', 'confirmed', 'active', 'closed');
CREATE TYPE inv_status AS ENUM ('draft', 'confirmed', 'paid');

-- ============================================================================
-- 2. CORE SYSTEM TABLES
-- ============================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'customer',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(155) NOT NULL,
    type VARCHAR(50) NOT NULL, 
    base_sales_price NUMERIC(12, 2) NOT NULL CHECK (base_sales_price >= 0),
    cost_price NUMERIC(12, 2) NOT NULL CHECK (cost_price >= 0),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    variant_name VARCHAR(100) NOT NULL, 
    price_surcharge NUMERIC(12, 2) DEFAULT 0.00, 
    UNIQUE(product_id, variant_name)
);

CREATE TABLE billing_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(155) NOT NULL,
    cost_amount NUMERIC(12, 2) NOT NULL CHECK (cost_amount >= 0),
    billing_cycle plan_interval NOT NULL,
    min_quantity INT DEFAULT 1 CHECK (min_quantity >= 1),
    start_date DATE NOT NULL,
    end_date DATE,
    auto_close BOOLEAN DEFAULT TRUE,
    is_paused BOOLEAN DEFAULT FALSE,
    CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE quotation_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(155) NOT NULL,
    plan_id UUID REFERENCES billing_plans(id) ON DELETE SET NULL,
    valid_days INT NOT NULL CHECK (valid_days > 0)
);

-- ============================================================================
-- 3. SUBSCRIPTIONS & OPERATIONS
-- ============================================================================
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_number SERIAL UNIQUE,
    customer_id UUID NOT NULL REFERENCES users(id),
    plan_id UUID REFERENCES billing_plans(id),
    status sub_status NOT NULL DEFAULT 'draft',
    start_date DATE NOT NULL,
    expiry_date DATE,
    payment_terms TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (expiry_date IS NULL OR expiry_date >= start_date)
);

CREATE TABLE subscription_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID REFERENCES subscriptions(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    variant_id UUID REFERENCES product_variants(id),
    quantity INT NOT NULL CHECK (quantity >= 1),
    unit_price NUMERIC(12, 2) NOT NULL,
    tax_rate NUMERIC(5, 2) DEFAULT 0.00, 
    amount NUMERIC(12, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

CREATE TABLE discount_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    discount_type VARCHAR(20) CHECK (discount_type IN ('fixed', 'percentage')),
    value NUMERIC(12, 2) NOT NULL CHECK (value > 0),
    min_purchase NUMERIC(12, 2) DEFAULT 0.00,
    min_quantity INT DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE,
    max_usage_limit INT,
    current_usage_count INT DEFAULT 0,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL, 
    subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL 
);

-- ============================================================================
-- 4. BILLING & PAYMENTS
-- ============================================================================
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES users(id),
    status inv_status NOT NULL DEFAULT 'draft',
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    subtotal_amount NUMERIC(12, 2) NOT NULL,
    tax_amount NUMERIC(12, 2) NOT NULL,
    discount_amount NUMERIC(12, 2) DEFAULT 0.00,
    total_amount NUMERIC(12, 2) GENERATED ALWAYS AS (subtotal_amount + tax_amount - discount_amount) STORED,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES invoices(id) ON DELETE RESTRICT, -- Fixed constraint syntax
    payment_method VARCHAR(50) NOT NULL, 
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- ============================================================================
-- 5. PERFORMANCE INDEXES
-- ============================================================================
CREATE INDEX idx_subscriptions_customer ON subscriptions(customer_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
CREATE INDEX idx_discount_dates ON discount_rules(start_date, end_date);

-- ============================================================================
-- 6. AUTOMATED STORED PROCEDURES (Moved to bottom)
-- ============================================================================
CREATE OR REPLACE PROCEDURE generate_billing_day_invoices()
LANGUAGE plpgsql AS $$
DECLARE
    sub_record RECORD;
    calculated_subtotal NUMERIC(12,2);
    calculated_tax NUMERIC(12,2);
    final_discount NUMERIC(12,2);
    new_invoice_id UUID;
BEGIN
    FOR sub_record IN 
        SELECT s.id, s.customer_id, s.payment_terms FROM subscriptions s 
        WHERE s.status = 'active'
    LOOP
        SELECT COALESCE(SUM(amount), 0), COALESCE(SUM(amount * (tax_rate/100)), 0)
        INTO calculated_subtotal, calculated_tax
        FROM subscription_lines 
        WHERE subscription_id = sub_record.id;

        IF calculated_subtotal = 0 THEN
            CONTINUE;
        END IF;

        SELECT COALESCE(SUM(
            CASE 
                WHEN discount_type = 'percentage' THEN calculated_subtotal * (value / 100)
                ELSE value 
            END
        ), 0) INTO final_discount
        FROM discount_rules
        WHERE (subscription_id = sub_record.id OR product_id IS NULL)
          AND CURRENT_DATE BETWEEN start_date AND COALESCE(end_date, CURRENT_DATE)
          AND (max_usage_limit IS NULL OR current_usage_count < max_usage_limit);

        INSERT INTO invoices (subscription_id, customer_id, status, issue_date, due_date, subtotal_amount, tax_amount, discount_amount)
        VALUES (sub_record.id, sub_record.customer_id, 'draft', CURRENT_DATE, CURRENT_DATE + INTERVAL '15 days', calculated_subtotal, calculated_tax, final_discount)
        RETURNING id INTO new_invoice_id;
        
        UPDATE discount_rules 
        SET current_usage_count = current_usage_count + 1
        WHERE (subscription_id = sub_record.id OR product_id IS NULL)
          AND CURRENT_DATE BETWEEN start_date AND COALESCE(end_date, CURRENT_DATE);

    END LOOP;
END;
$$;
