# GitHub Copilot Instructions - SPLANTS Marketing Engine

## Project Architecture Overview

SPLANTS is an AI-powered marketing content generation system with a **modular enhancement architecture**. The system follows a "core + optional enhancements" pattern where features are explicitly categorized as:
- **Core Features**: Always enabled ($30/month infrastructure)
- **Free Optional Enhancements**: Can be toggled on/off
- **Paid Optional Enhancements**: Require additional services/API keys

### Service Architecture
- **Backend**: FastAPI app in `main.py` (single 3900-line file by design)
- **Frontend**: React/TypeScript with Vite in `web/` directory using GitHub Spark components
- **Database**: PostgreSQL with comprehensive schema for analytics, A/B testing, cost tracking
- **Deployment**: Docker Compose with 3 services: `db`, `app`, `web`

## Key Development Patterns

### Enhancement Architecture Pattern
The codebase uses explicit feature categorization throughout:

```python
# Core Feature (always enabled)
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://...")

# FREE OPTIONAL ENHANCEMENT: Cost Control  
MONTHLY_AI_BUDGET = float(os.getenv("MONTHLY_AI_BUDGET", "0"))

# PAID OPTIONAL ENHANCEMENT: Redis Caching (+$10-15/month)
# import aioredis  # Commented imports for optional features
```

When adding features, categorize them clearly in comments and make optional features configurable via environment variables.

### Single-File Backend Design
`main.py` contains the entire backend (3900 lines) intentionally. This monolithic approach:
- Keeps all business logic searchable in one file
- Uses clear section headers with `# ============================================`
- Groups related functionality with detailed docstrings
- Maintains startup logging that explicitly shows which features are active

### Database Schema Philosophy
The schema includes comprehensive tracking tables even for "optional" features:
- `analytics_events` - Free enhancement tracking
- `api_usage` - Cost control and monitoring
- `ab_tests` - A/B testing framework
- `webhook_logs` - Integration monitoring

Always create indexes for time-based queries: `CREATE INDEX IF NOT EXISTS idx_tablename_created_at ON table(created_at DESC)`

### Frontend Component Structure
Uses GitHub Spark components with shadcn/ui patterns:
- Page components in `components/pages/` (DashboardPage, GeneratePage, etc.)
- UI components from `@/components/ui/` with consistent imports
- Phosphor icons for consistent design language
- Custom CSS classes like `splatter-texture` for brand theming

## Development Workflows

### Setup and Development
- **First-time setup**: `make start` (runs interactive wizard via `scripts_quick-start.sh`)
- **Development**: `make dev` (starts with hot reload)
- **Logs**: `make logs` (follows all services)
- **Reset**: `make clean && make start`

### Docker Compose Architecture
The compose file uses health checks and proper service dependencies:
```yaml
depends_on:
  db:
    condition: service_healthy  # Wait for DB to be ready
```

The app service exposes port 8080 internally but is only accessible via the web service proxy at port 3000.

### Environment Configuration
Critical pattern: All optional features use environment variables with safe defaults:
```bash
MONTHLY_AI_BUDGET=0  # 0 = unlimited (default)
CACHE_ENABLED=false  # Optional Redis caching
WEBHOOK_CONTENT_GENERATED_URL=  # Optional webhook URL
```

Always provide descriptive defaults and validation in `main.py` startup.

## Cost and Enhancement Management

### Cost Tracking Pattern
Every AI API call is logged to `api_usage` table with:
- Token count and estimated cost
- Model used (GPT-4, Claude, etc.)
- Success/failure status
- Associated content_id for traceability

### Multi-Model AI Pattern
The system supports optional Claude integration alongside OpenAI:
```python
if ANTHROPIC_API_KEY:
    # Use both models for enhanced quality
else:
    # Fall back to OpenAI only
```

When implementing new AI features, always support the multi-model pattern.

### A/B Testing Infrastructure
Built-in A/B testing framework tracks:
- Test variants in `ab_tests` table
- Performance metrics in `analytics_events`
- Winner selection based on configurable metrics

## Integration Patterns

### Webhook System
Comprehensive webhook logging for automation integration:
- Content generation events
- Publishing events  
- Daily usage reports

All webhook calls are logged with retry logic and status tracking.

### API Authentication
Simple but effective API key pattern using FastAPI Security:
```python
async def verify_api_key(api_key: str = Security(api_key_header)):
```

All protected endpoints use this dependency for consistent auth.

## File-Specific Guidelines

### `main.py` Modifications
- Use section headers: `# ============================================`
- Add startup logging for new features showing enabled/disabled state
- Include cost/enhancement category in all feature comments
- Maintain comprehensive error handling with user-friendly messages

### `web/` Frontend Changes
- Import UI components from `@/components/ui/`
- Use Phosphor icons for consistency
- Follow the page-based routing pattern in `App.tsx`
- Maintain responsive design with Tailwind classes

### Configuration Files
- `docker-compose.yml`: Always include health checks for new services
- `Makefile`: Add helpful commands with descriptive help text
- `requirements.txt`: Keep optional dependencies commented with enable instructions

## Common Anti-Patterns to Avoid

1. **Don't** add features without categorizing them as core/free/paid
2. **Don't** modify the database schema without corresponding indexes
3. **Don't** add API endpoints without authentication via `verify_api_key`
4. **Don't** implement features without startup logging to show status
5. **Don't** add environment variables without safe defaults and documentation

## Testing and Quality Patterns

The system includes `test_api.py` for API validation. When adding endpoints:
- Include realistic test data
- Test both success and error cases
- Validate authentication requirements
- Test optional feature toggle behavior

## Brand and Content Specifics

SPLANTS focuses on Jackson Pollock-inspired paint-splatter pants. When working on content generation:
- Maintain contemplative/creative tone in marketing copy
- Reference paint splatters, artistic expression, custom pants themes
- Use eccentric vibrant language matching the artistic brand