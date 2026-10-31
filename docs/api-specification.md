# API conventions

Base URL: http://localhost:5000. Contract: contracts/openapi.yaml.

Success: `{ "data": { ... }, "meta": { "requestId": "uuid" } }`.
Error: `{ "error": { "code": "NOT_FOUND", "message": "Route not found" }, "meta": { "requestId": "uuid" } }`.
Every response includes X-Request-ID. JSON responses are UTF-8 and no-store. Future paginated lists will extend meta with page, pageSize and total. Sensitive diagnostics must never appear in client errors.

GET /api/health returns 200 with status=ok, service=brightloop-api, an ISO UTC timestamp, and database=not_checked. No credentials required. OPTIONS /api/health returns 204. Unknown routes return 404, unsupported health methods 405, malformed URL 400 and disallowed Origin 403. Exact allowed origins are configured through CORS_ORIGINS. Requests without Origin are permitted; this public endpoint provides no authentication.

Fetch uses credentials: include. VITE_API_URL is public configuration and must never contain secrets. Frontend connection attempts time out after eight seconds and offer a retry. Session and CSRF handling arrive in Phase 3/4 before state-changing endpoints.
