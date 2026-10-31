# Brightloop Software · Subscription Management

Phase 1 monorepo foundation. Includes a React/TypeScript/Vite workspace, native Node HTTP API, PostgreSQL connection helpers and a Python worker skeleton. Business modules and authentication are intentionally deferred.

## Install and run

Requirements: Node >=22.13, npm, Python >=3.10; PostgreSQL 16+ only for optional connection checks.

From the workspace:
```sh
cd subscription-management
npm install
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
cp billing-worker/.env.example billing-worker/.env
npm run dev:backend
```
In another terminal, from subscription-management:
```sh
npm run dev:frontend
```
Open http://localhost:5173. The overview and System status pages call GET http://localhost:5000/api/health and show a live connection result. Stop the backend and click Check connection to verify the error state; restart it and retry.

Python setup (separate terminal, repository root):
```sh
python3 -m venv billing-worker/.venv
billing-worker/.venv/bin/python -m pip install -r billing-worker/requirements.txt
billing-worker/.venv/bin/python billing-worker/main.py
```
The skeleton prints its status and exits. It does not start a scheduler or modify a database. Running it without --check-db does not require psycopg installed.

## Optional PostgreSQL check

Provision a local `brightloop` database and update DATABASE_URL in both backend/.env and billing-worker/.env. Never use example passwords in production. No schema exists yet.
```sh
npm run db:check --workspace backend
# Load the trusted local worker environment in this shell:
set -a
. billing-worker/.env
set +a
billing-worker/.venv/bin/python billing-worker/main.py --check-db
```
Backend DB_SSL=true uses certificate verification; configure database trust as required. Worker TLS settings use PostgreSQL connection URL parameters such as sslmode=verify-full.

## Verify

```sh
npm run typecheck
npm run build
npm test
curl -i http://localhost:5000/api/health
```
Expected JSON data: status=ok, service=brightloop-api, database=not_checked, timestamp in UTC. Backend tests use a real ephemeral HTTP listener to cover health, CORS, preflight and route errors; frontend tests cover Fetch envelopes/errors/credentials; Python tests cover configuration and the no-billing entrypoint. Build output can run with `npm start --workspace backend`.

## Repository map

```text
subscription-management/
├── frontend/                 # React, router, Context, Fetch, CSS Modules
│   └── src/{app,components,pages,layouts,hooks,contexts,services,styles,types}
├── backend/                  # Native HTTP server, configuration, pg
│   └── src/{server,routes,controllers,services,repositories,middleware,validators,utils,config,types}
├── billing-worker/           # main.py, requirements.txt, .env.example
│   └── {billing,scheduler,repositories,tests}
├── database/{migrations,seeds,schema.sql}
├── contracts/openapi.yaml
├── docs/                     # Architecture, API, database, billing, guide, roadmap
├── .github/pull_request_template.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── .gitignore
└── package.json
```
See FILES.md for the complete tracked source-file inventory. Each JS package has its own scripts, TypeScript configuration and environment example.

## Ownership and next work

Developer 1: backend/database, next Phase 2 schema and migrations. Developer 2: Python/financial logic, next shared decimal and billing-period specifications. Developer 3: frontend, next authentication integration contract and UI planning. Shared contract/schema changes require cross-owner review. See CONTRIBUTING.md and docs/development-roadmap.md. CODEOWNERS teams are placeholders until actual GitHub teams are configured.

## Phase 1 limitations

There are no domain tables, login/session flows, billing jobs, invoices, payments, customer portal or financial reports. Health is API liveness, not database readiness. No production deployment, performance benchmark or security certification is implied. See docs/validation.md for checks actually run.
