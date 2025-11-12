## GitHub Copilot Instructions — SPLANTS: Quick Reference Guide

SPLANTS is an AI marketing engine with a “core + optional enhancements” pattern. Work fast by following these repo-specific rules and examples.

Architecture map
- Backend: FastAPI in single file `main.py` (intentionally monolithic). App listens on 8080, proxied by `web` to http://localhost:3000.
- Frontend: React/TypeScript in `web/` using Spark + shadcn/ui. Pages live in `web/src/components/pages/`.
- Database: PostgreSQL. Tracking tables: `api_usage`, `analytics_events`, `ab_tests`, `webhook_logs` (all time-indexed).
- Orchestration: Docker Compose services `db`, `app`, `web` with health checks (see `docker-compose.yml`).

Core conventions (do these every time)
- Categorize features explicitly in code comments: CORE | FREE OPTIONAL ENHANCEMENT | PAID OPTIONAL ENHANCEMENT.
- Gate optional features with env vars and safe defaults in `main.py` startup. Example:
  ```python
  # FREE OPTIONAL ENHANCEMENT: Cost Control
  MONTHLY_AI_BUDGET = float(os.getenv("MONTHLY_AI_BUDGET", "0"))  # 0 = unlimited
  ```
- Auth: Protect endpoints with `Depends(verify_api_key)`. Do not add unguarded protected routes.
- Startup logging: Log whether each enhancement is enabled (mirrors existing logs for Anthropic, budget, webhooks).
- Database: For new time-series data, add `created_at` and an index: `CREATE INDEX IF NOT EXISTS idx_<table>_created_at ON <table>(created_at DESC)`.

AI model pattern
- Default OpenAI (GPT-4). If `ANTHROPIC_API_KEY` is set, support multi-model; otherwise gracefully fall back to OpenAI. Keep cost tracking via `_track_api_usage` writing to `api_usage`.

Webhooks and integrations
- Optional URLs: `WEBHOOK_CONTENT_GENERATED_URL`, `WEBHOOK_CONTENT_PUBLISHED_URL`, `WEBHOOK_DAILY_REPORT_URL`. Deliveries are recorded in `webhook_logs` with retries. Use `WebhookSystem.trigger_webhook` for emits.

Frontend shape
- Use `@/components/ui/*` imports, Phosphor icons, Tailwind. Route/page examples: `DashboardPage.tsx`, `GeneratePage.tsx`, `SettingsPage.tsx`.

Developer workflows (Makefile)
- First-time: `make start` (wizard creates `.env`, builds, runs)
- Dev attach: `make dev` | Logs: `make logs` | Status: `make status`
- Tests: `make test` (runs `python3 test_api.py` to validate backend-frontend contract)
- Backup/restore: `make backup` | `make restore file=<path>`

When adding features
- Add env toggle with default, log status at startup, and categorize with the banner comment.
- Ensure endpoints use `verify_api_key`, write to `api_usage` where relevant, and add indices for new tables.
- If adding services, keep Compose health checks and only expose via `web` proxy.
- Add or update tests in `test_api.py` (cover success + budget/limit/error paths).

Key files to scan first
- `main.py` (backend and patterns), `docker-compose.yml` (ports and health), `Makefile` (commands), `web/src/components/pages/*` (UI), `README.md` (runbook + URLs).

Notes
- API docs are served at http://localhost:3000/api/docs (proxied through `web`).
- Keep optional dependencies commented in `requirements.txt` and document how to enable.
- Prefer concise section headers in `main.py`:
  `# ============================================ <Feature/Section>`

If anything here is unclear or missing, ping to expand this TL;DR.

For full details, see the following resources:
- **Architecture:** See the [Architecture](../README.md#architecture) section in `README.md` for system layout, service boundaries, and deployment patterns.
- **Developer Workflow:** See the [Developer Workflow](../README.md#developer-workflow) section in `README.md` for setup, testing, and CI/CD practices.
- **Implementation Patterns:** For advanced features (e.g., self-healing, cost optimization, adaptive learning, workflow orchestration), refer to:
  - The "Advanced Implementation Patterns" and "Agentive Workflow Examples" subsections in `README.md` (if present).
  - `main.py` docstrings and section headers (e.g., `# ============================================ <Feature/Section>`) for code-level patterns and examples.
  - `test_api.py` for advanced testing patterns, including budget/limit/error path coverage.
