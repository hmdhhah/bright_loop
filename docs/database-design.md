# Database design

Phase 1 supplies connection configuration only. There are no tables, migrations or seed data yet. PostgreSQL is optional for the health smoke test; use the explicit checks to verify a provisioned database.

Phase 2 will normalize users, sessions, password_reset_tokens, customers, products, product_variants, plans, plan_products, quotation_templates, quotation_template_lines, quotations, quotation_lines, subscriptions, subscription_lines, invoices, invoice_lines, payments, payment_allocations, tax_rules, discount_rules, discount_redemptions, billing_runs and audit_logs.

Design requirements: UUID keys, numeric money, foreign keys, business identifier uniqueness, indexed access paths, case-insensitive email uniqueness, UTC timestamptz values and transactional financial changes. Billing periods need a unique constraint per subscription and period. Versioned migrations must use a ledger, lock concurrent migration attempts and wrap compatible DDL in transactions. Document nontransactional migrations separately. Future APIs must paginate and enforce ownership in SQL.
