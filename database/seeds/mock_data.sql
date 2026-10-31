-- ============================================================================
-- TEST DATA FOR BRIGHTLOOP SYSTEMS
-- ============================================================================

-- 1. Insert Initial User Profiles (Password hashes are mock strings for now)
INSERT INTO users (id, email, password_hash, role) VALUES 
('a1111111-1111-4111-a111-111111111111', 'admin@brightloop.com', 'hash_admin_pass_123!', 'admin'),
('b2222222-2222-4222-b222-222222222222', 'staff_sarah@brightloop.com', 'hash_staff_pass_123!', 'staff'),
('c3333333-3333-4333-c333-333333333333', 'shop_owner@smallbiz.com', 'hash_cust_pass_123!', 'customer');

-- 2. Insert Core Products
INSERT INTO products (id, name, type, base_sales_price, cost_price, notes) VALUES
('p1111111-1111-4111-9111-111111111111', 'Enterprise Core CRM Software', 'software', 1200.00, 300.00, 'Main system application license.'),
('p2222222-2222-4222-9222-222222222222', 'Advanced Analytics Extension', 'add-on', 250.00, 50.00, 'Provides real-time dashboards.');

-- 3. Insert Product Variant (Surcharge matching requirements page 3)
INSERT INTO product_variants (id, product_id, variant_name, price_surcharge) VALUES
('v1111111-1111-4111-8111-111111111111', 'p1111111-1111-4111-9111-111111111111', 'Odoo Branded Variant', 560.00);

-- 4. Insert Billing Plan Configurations
INSERT INTO billing_plans (id, name, cost_amount, billing_cycle, min_quantity, start_date, auto_close) VALUES
('pl111111-1111-4111-7111-111111111111', 'Standard Monthly Contract', 1200.00, 'monthly', 1, '2026-01-01', FALSE),
('pl222222-2222-4222-7222-222222222222', 'Enterprise Yearly Partnership', 11000.00, 'yearly', 1, '2026-01-01', FALSE);

-- 5. Insert Active Subscription
INSERT INTO subscriptions (id, customer_id, plan_id, status, start_date, expiry_date, payment_terms) VALUES
('s1111111-1111-4111-6111-111111111111', 'c3333333-3333-4333-c333-333333333333', 'pl111111-1111-4111-7111-111111111111', 'active', '2026-10-01', '2027-10-01', 'Net 15 Days');

-- 6. Attach Production Items to Subscription
INSERT INTO subscription_lines (subscription_id, product_id, variant_id, quantity, unit_price, tax_rate) VALUES
('s1111111-1111-4111-6111-111111111111', 'p1111111-1111-4111-9111-111111111111', 'v1111111-1111-4111-8111-111111111111', 2, 1760.00, 15.00);

-- 7. Add Active Automatic Promo Discount Code
INSERT INTO discount_rules (name, discount_type, value, min_quantity, start_date, end_date, max_usage_limit) VALUES
('Volume Tier Promotion', 'fixed', 100.00, 1, '2026-10-01', '2027-01-01', 500);
