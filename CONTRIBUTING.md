# Contributing

Use one protected `main` branch, small pull requests and at least one review from the affected owner. Configure branch protection in GitHub after publishing; it is not enabled by files alone. CODEOWNERS contains illustrative teams that must be replaced with real accounts.

Branch conventions: `feature/backend-*`, `feature/billing-*`, `feature/frontend-*`; use `fix/<area>-<description>` for fixes. Automated Codex branches may use `codex/`.

Developer 1 owns backend, identity, RBAC, SQL schema/migrations and domain APIs. Developer 2 owns Python scheduling, invoice calculation, reconciliation, overdue detection and report calculations. Developer 3 owns React, accessibility, dashboards, customer portal and API integration.

Shared changes to contracts, financial fixtures, schema consumed by the worker, or deployment behavior need review by affected owners. Python is the future authority for financial calculations; Node must not independently recreate formulas. Agree on versioned decimal-string fixtures before implementing billing.

Run `npm run typecheck`, `npm run build`, and `npm test` before review. Never commit real credentials or customer information. Document behavioral changes and migration rollback limitations. See docs/developer-guide.md for setup.
