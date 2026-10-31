# Architecture

Phase 1 establishes npm workspaces for React/Vite and native Node HTTP/TypeScript, alongside an independent Python process. The browser calls Node through native Fetch with credentials included; only Node and Python may connect to PostgreSQL. SQL will use `pg` and `psycopg`, with no ORM.

The only API is public, read-only GET /api/health. No authentication, billing, customer records or financial operations exist. CORS uses an exact origin allowlist and rejects disallowed origins; it is not an authorization mechanism. Phase 3 must add scrypt password hashing, expiring/revocable HttpOnly cookies, single-use hashed reset tokens, rate limiting, role/ownership enforcement and CSRF protection before introducing protected routes.

Node owns domain APIs, identity and state transitions. Python will own transactional billing calculations and scheduling. Both share database constraints and reviewed contracts. Health is liveness only, never a claim of database readiness. Database pools are created lazily, bounded, timeout-limited and closed at shutdown. Production TLS must validate certificates.

No major structure changes: npm workspaces coordinate JS packages; tests and GitHub metadata supplement the requested directories. Empty module directories contain .gitkeep until their phase begins.
