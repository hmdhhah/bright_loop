# Development roadmap

1. Foundation: implemented; see README for validation and limitations.
2. Database: Developer 1 creates reviewed constraints, indexed tables, migration runner and seeds; Developer 2 reviews billing locking and decimal fields.
3. Backend/auth: Developer 1 implements sessions, registration, password reset, role enforcement, CSRF and audit logging with integration tests.
4. Frontend/auth: Developer 3 implements login, registration, protected navigation and session expiry handling against the agreed API.
5. Products/plans: Developers 1 and 3 implement CRUD, variants, availability and rule validation.
6. Customers/quotations/subscriptions: Developers 1 and 3 implement scoped access and documented transitions.
7. Billing: Developer 2 adds transactional scheduling, invoice generation, retry handling and idempotency tests.
8. Taxes/discounts/payments: all owners integrate shared calculation fixtures, permissions and allocation constraints.
9. Portal/reporting: Developer 3 builds customer views; Developer 2 owns financial aggregation; Developer 1 serves scoped APIs.
10. Hardening/deployment: all owners verify security, observability, accessibility, backups and documented load tests.

Next handoff: Developer 1 leads Phase 2; Developer 2 specifies billing period and monetary fixtures before worker code; Developer 3 reviews the API envelope and plans authentication UI. Avoid parallel schema assumptions.

The under-two-second target is not benchmarked in Phase 1. Before release, document hardware, PostgreSQL version, dataset (at least 10,000 subscriptions), concurrent clients, query mix and p95 response/page timings; add regression thresholds based on measured results.
