# Developer guide

Follow the root README setup. Node >=22.13 and Python >=3.10 are required. Node 22 LTS is the recommended baseline. PostgreSQL 16+ is the intended database target; no database-dependent functionality is needed to render Phase 1.

Run the frontend and backend in separate terminals. Frontend binds 127.0.0.1:5173 with strict port selection; backend defaults to 127.0.0.1:5000. Both localhost and 127.0.0.1 browser origins are allowed by the example backend config. After changing environment files restart the corresponding process. Backend scripts load backend/.env; Vite loads frontend/.env. Python uses exported environment variables, not automatic dotenv loading.

Build output lands in each JS package's dist directory. Run the compiled API with `npm start --workspace backend`. `npm run preview --workspace frontend` serves a local build preview, not a production server; add its origin to CORS_ORIGINS when testing connectivity. Future static hosting must rewrite SPA routes to index.html and provide HTTPS. VITE_API_URL is compiled into frontend builds.

Troubleshooting: connection refused means the API is stopped or URL/port is wrong; ORIGIN_NOT_ALLOWED means the browser origin is missing from the exact allowlist. Health success does not verify PostgreSQL. Run db:check separately. No production deployment or authentication readiness is claimed.
