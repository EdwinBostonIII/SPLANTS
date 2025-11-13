# GitHub Copilot Instructions — SPLANTS Marketing Engine: COMPLETE REFERENCE

**Version:** 2.1.1  
**Last Updated:** 2025-11-13  
**Purpose:** Definitive guide for AI coding agents working on the SPLANTS Marketing Engine codebase.  
**Scope:** Architecture, conventions, mandates, preferences, workflows, file structure, dependencies, patterns.

---

## TABLE OF CONTENTS

1. [Project Goal & Vision](#1-project-goal--vision)
2. [Comprehensive Architecture](#2-comprehensive-architecture)
3. [Technology Stack](#3-technology-stack)
4. [Complete File Structure & Purposes](#4-complete-file-structure--purposes)
5. [Core Development Mandates](#5-core-development-mandates)
6. [Feature Implementation Patterns](#6-feature-implementation-patterns)
7. [Database Schema & Patterns](#7-database-schema--patterns)
8. [API Endpoint Conventions](#8-api-endpoint-conventions)
9. [Frontend Architecture & Patterns](#9-frontend-architecture--patterns)
10. [Testing Requirements](#10-testing-requirements)
11. [Developer Workflows](#11-developer-workflows)
12. [Configuration & Environment Variables](#12-configuration--environment-variables)
13. [Code Style & Standards](#13-code-style--standards)
14. [Security Patterns](#14-security-patterns)
15. [Cost Control Patterns](#15-cost-control-patterns)
16. [Deployment & Production](#16-deployment--production)
17. [Documentation Requirements](#17-documentation-requirements)
18. [Common Patterns & Conventions](#18-common-patterns--conventions)
19. [Troubleshooting Patterns](#19-troubleshooting-patterns)
20. [Key Files Reference](#20-key-files-reference)

---

## 1. Project Goal & Vision

### Primary Goal
Build an AI-powered marketing engine that enables **small businesses** to compete with large marketing budgets through automation and AI. The fictional "SPLANTS" custom pants brand serves as the reference use case.

### Success Metrics
- **Cost Efficiency:** $35-80/month vs. $1,700-3,400/month traditional marketing
- **Quality:** 0.85+ average quality scores on generated content
- **Accessibility:** Non-technical users can install and use in <60 minutes
- **Scalability:** Support 1-1,000+ content pieces/month without linear cost increase

### Core Philosophy: "Core + Optional Enhancements"
- **Core features:** Always included, simple, robust
- **FREE optional enhancements:** $0/month, feature-gated with env vars
- **PAID optional enhancements:** Require additional services, explicitly documented

**Design Principles:**
1. **Simplicity Over Cleverness:** Monolithic > Microservices, Explicit > Implicit
2. **Safe Defaults:** All optional features default to disabled
3. **Progressive Enhancement:** Start simple, add complexity only when needed
4. **User-First:** Non-technical entrepreneurs are the primary audience

---

## 2. Comprehensive Architecture

### Service Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PUBLIC ENTRY POINT                        │
│                 http://localhost:3000                        │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ WEB SERVICE (NGINX + React)                                 │
│ • Port: 3000 (public)                                       │
│ • Serves: React SPA from /usr/share/nginx/html             │
│ • Proxies: /api/* → http://app:8080/                       │
│ • Technology: NGINX 1.25, React 19, Vite 6, TypeScript     │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ APP SERVICE (FastAPI Backend)                               │
│ • Port: 8080 (internal only, not publicly exposed)         │
│ • File: main.py (3,938 lines, intentionally monolithic)    │
│ • Technology: FastAPI 0.115.5, Python 3.11+, uvicorn       │
│ • Pattern: Async/await throughout                          │
│ • Authentication: X-API-Key header on all protected routes │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ DB SERVICE (PostgreSQL)                                     │
│ • Port: 5432 (internal, optional external for debugging)   │
│ • Technology: PostgreSQL 15-alpine                          │
│ • Driver: asyncpg 0.30.0 (async connection pool)          │
│ • Tables: content, api_usage, analytics_events, ab_tests,  │
│           webhook_logs, social_posts, system_settings       │
└─────────────────────────────────────────────────────────────┘

OPTIONAL SERVICES (commented out in docker-compose.yml):
┌─────────────────────────────────────────────────────────────┐
│ REDIS SERVICE (Caching - PAID ENHANCEMENT)                  │
│ • Port: 6379 (internal)                                     │
│ • Cost: +$10-15/month                                       │
│ • Benefit: 30-50% API cost reduction                        │
│ • Enable: Uncomment in docker-compose.yml + set REDIS_URL  │
└─────────────────────────────────────────────────────────────┘
```

### Request Flow: Content Generation

```
1. User fills form in React UI (GeneratePage.tsx)
2. React calls: POST /api/v1/generate with JSON payload
3. NGINX receives on :3000, strips /api, proxies to app:8080
4. FastAPI receives, validates with Pydantic (ContentRequest model)
5. verify_api_key dependency checks X-API-Key header
6. cost_controller.check_budget() verifies within limits
7. [If Redis enabled] Check cache for similar request
8. [Cache miss] ContentEngine.generate_content() calls OpenAI GPT-4
9. Response parsed, quality_score calculated (0-1 scale)
10. SEO optimization applied (keyword extraction)
11. Platform-specific formatting (Instagram spacing, Twitter limits)
12. Content saved to PostgreSQL content table
13. api_usage table updated with cost tracking
14. [If ANALYTICS_ENABLED] analytics_events record created
15. [If webhooks configured] webhook_system.trigger_webhook()
16. ContentResponse returned to React UI
17. User sees generated content with quality metrics
```

### Data Flow Patterns

- **Synchronous:** User request → API → OpenAI → Database → Response
- **Asynchronous:** Background tasks for webhooks, analytics aggregation, A/B variant generation
- **Caching:** Redis stores (key=request_hash, value=content) for 1 hour
- **Webhooks:** Fire-and-forget with 3-retry exponential backoff

---

## 3. Technology Stack

### Backend Dependencies (`requirements.txt`)

```python
# Core Framework
fastapi==0.115.5           # Modern async API framework
uvicorn[standard]==0.32.1  # ASGI server with WebSocket support
pydantic==2.10.3           # Data validation (v2 syntax!)

# Database
asyncpg==0.30.0            # Async PostgreSQL driver (fastest available)

# AI Providers
openai==1.57.2             # GPT-4 access (REQUIRED)
anthropic==0.42.0          # Claude access (OPTIONAL, multi-model)

# HTTP Client
httpx==0.28.1              # Async HTTP for webhooks

# Utilities
python-multipart==0.0.20   # Form data parsing
python-dotenv==1.0.1       # .env file loading

# OPTIONAL (commented out)
# redis==5.2.1             # Caching (uncomment if using)
```

### Frontend Dependencies (`web/package.json`)

```json
{
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "@github/spark": "^0.39.0",        // Spark UI components
    "@phosphor-icons/react": "^2.1.7",  // Icon library
    "@radix-ui/*": "...",               // UI primitives (40+ components)
    "recharts": "^2.15.1",              // Charts for analytics
    "sonner": "^2.0.1",                 // Toast notifications
    "tailwindcss": "^4.1.11",           // Utility-first CSS
    "vite": "^6.3.5"                    // Build tool (fast!)
  }
}
```

### Infrastructure

- **Orchestration:** Docker Compose v2+
- **Web Server:** NGINX (production), Vite dev server (development)
- **Database:** PostgreSQL 15-alpine
- **Optional Cache:** Redis 7-alpine

---

## 4. Complete File Structure & Purposes

```
SPLANTS/
├── .github/
│   └── copilot-instructions.md      # THIS FILE - AI agent guide
│
├── main.py                          # Backend (3,938 lines, monolithic)
│   Purpose: ALL backend logic in one file for simplicity
│   Structure: Sections marked with ASCII art headers
│   Pattern: Top-to-bottom: imports → config → models → logic → endpoints
│
├── test_api.py                      # API integration tests
│   Purpose: Validate backend-frontend contract (NOT unit tests)
│   Pattern: TestClass per feature, pytest fixtures
│   Mandate: Run `make test` before committing changes to main.py
│
├── docker-compose.yml               # Service orchestration
│   Services: db (postgres), app (fastapi), web (nginx+react)
│   Volumes: postgres_data (persistent), logs (ephemeral)
│   Networks: Default bridge, internal service communication
│
├── Makefile                         # Developer command interface
│   Purpose: Abstraction over docker-compose commands
│   Mandate: ALWAYS use `make` commands, never raw docker-compose
│   Key commands: start, dev, stop, logs, test, backup, restore
│
├── requirements.txt                 # Python dependencies (pinned versions)
│   Pattern: Core required, optional commented with instructions
│
├── Dockerfile                       # Backend container build
│   Base: python:3.11-slim
│   Pattern: Multi-stage build for optimization
│
├── .env.example                     # Configuration template (1,000+ lines)
│   Purpose: Documents EVERY environment variable with examples
│   Mandate: Copy to .env, never commit .env to git
│
├── .env                             # Actual secrets (gitignored)
│   Contains: API keys, passwords, configuration
│
├── web/                             # Frontend application
│   ├── Dockerfile                   # Frontend container (multi-stage)
│   ├── nginx.conf                   # Reverse proxy configuration
│   │   Key rule: location /api/ { proxy_pass http://app:8080; }
│   ├── package.json                 # Node dependencies
│   ├── vite.config.ts               # Build configuration
│   ├── tsconfig.json                # TypeScript configuration
│   ├── tailwind.config.js           # Tailwind CSS setup
│   ├── src/
│   │   ├── App.tsx                  # Main app, routing, navigation
│   │   │   Pattern: Single-page app, no react-router (simple state)
│   │   ├── main.tsx                 # Entry point, ReactDOM.render
│   │   ├── index.css                # Global styles, Tailwind imports
│   │   ├── config.ts                # Frontend config (API_BASE_URL)
│   │   ├── components/
│   │   │   ├── pages/               # Page-level components
│   │   │   │   ├── GeneratePage.tsx      # Content generation form
│   │   │   │   ├── DashboardPage.tsx     # Analytics, charts
│   │   │   │   ├── LibraryPage.tsx       # Content browser
│   │   │   │   ├── SettingsPage.tsx      # Budget, webhooks config
│   │   │   │   └── BookmarksPage.tsx     # Saved content
│   │   │   ├── ui/                  # Reusable UI components (shadcn)
│   │   │   │   ├── button.tsx, card.tsx, input.tsx, etc.
│   │   │   │   Pattern: Radix UI primitives + Tailwind styling
│   │   │   └── RadialProgress.tsx   # Custom progress circle
│   │   └── hooks/
│   │       └── use-mobile.ts        # Responsive breakpoint hook
│   └── public/                      # Static assets
│
├── scripts/                         # Utility bash scripts
│   ├── scripts_quick-start.sh       # Interactive setup wizard
│   ├── scripts_backup.sh            # Database backup to ./backups/
│   ├── scripts_restore.sh           # Restore from backup
│   ├── scripts_check-system.sh      # Pre-install dependency check
│   └── scripts_verify-installation.sh # Post-install validation
│
├── logs/                            # Application logs (gitignored)
│   └── app.log                      # Rolling log file from uvicorn
│
├── backups/                         # Database backups (gitignored)
│   └── backup-YYYYMMDD.sql.gz      # Daily automated backups
│
└── Documentation/ (Root Level)      # All .md files for easy access
    ├── README.md                    # Primary user documentation (1,700+ lines)
    ├── DEVELOPER_GUIDE.md           # Developer workflows (600+ lines)
    ├── PROJECT_SPECIFICATION.md     # Complete spec (2,396+ lines)
    ├── FEATURE_TEMPLATE.md          # Template for new features
    ├── SETUP_GUIDE.md               # Installation guide (1,300+ lines)
    ├── TROUBLESHOOTING.md           # Problem solving (1,400+ lines)
    ├── FAQ.md                       # 100+ Q&A (1,400+ lines)
    ├── DOCUMENTATION_INDEX.md       # Documentation navigation
    ├── docs_API_GUIDE.md            # API reference (300+ lines)
    ├── docs_DEPLOYMENT.md           # Production deployment (350+ lines)
    ├── WORKFLOW_AUTOMATION.md       # Automation patterns (800+ lines)
    ├── QUICK_REFERENCE.md           # Quick lookup (300+ lines)
    ├── QUICKSTART_WINDOWS.md        # Windows-specific (400+ lines)
    ├── CHANGELOG.md                 # Version history
    ├── FIXES_APPLIED.md             # Bug fix log
    └── UPDATE_GUIDE_v2.1.1.md       # Update instructions
```

---

## 5. Core Development Mandates

These are **NON-NEGOTIABLE** requirements for all code changes:

### Mandate 1: Feature Categorization
Every feature **MUST** be categorized with a banner comment:

```python
# ============================================
# CORE FEATURE: Feature Name
# ============================================
# OR
# ============================================
# FREE OPTIONAL ENHANCEMENT: Feature Name
# ============================================
# OR
# ============================================
# PAID OPTIONAL ENHANCEMENT: Feature Name (+$X/month)
# ============================================
```

**Why:** Users need to understand cost implications before enabling features.

### Mandate 2: Environment Variable Gating
Every optional feature **MUST**:
1. Have an environment variable toggle in `.env.example`
2. Provide a safe default value
3. Document the cost/benefit in `.env.example` comments

```python
# In main.py configuration section:
FEATURE_ENABLED = os.getenv("FEATURE_ENABLED", "false").lower() == "true"

# In endpoint:
@app.post("/api/feature")
async def feature_endpoint(api_key: str = Depends(verify_api_key)):
    if not FEATURE_ENABLED:
        raise HTTPException(
            status_code=501,
            detail="Feature disabled. Set FEATURE_ENABLED=true in .env to enable."
        )
```

### Mandate 3: Startup Logging
Every feature **MUST** log its status in the `startup_event()` function:

```python
@app.on_event("startup")
async def startup_event():
    if FEATURE_ENABLED:
        logger.info("✅ Feature Name: Enabled")
        if FEATURE_API_KEY:
            logger.info("   └─ API Key: Configured")
    else:
        logger.info("❌ Feature Name: Disabled (set FEATURE_ENABLED=true)")
```

**Why:** Users need immediate visibility into what features are active.

### Mandate 4: API Authentication
All endpoints (except `/health` and `/`) **MUST** use `Depends(verify_api_key)`:

```python
@app.post("/api/sensitive-operation")
async def operation(
    request: RequestModel,
    api_key: str = Depends(verify_api_key),  # REQUIRED
    db = Depends(get_db)
):
    # Implementation
```

### Mandate 5: Cost Tracking
Any function calling external AI APIs **MUST** call `_track_api_usage`:

```python
await _track_api_usage(
    db=db,
    endpoint="content_generation",
    tokens_used=response.usage.total_tokens,
    estimated_cost=calculated_cost,
    model="gpt-4",
    success=True
)
```

### Mandate 6: Test Before Commit
Before committing ANY change to `main.py`:

```bash
make test  # MUST pass
```

If you add a new endpoint, add a test to `test_api.py`.

### Mandate 7: Monolithic Backend
**DO NOT** create new Python files for business logic. Keep everything in `main.py`.

**Rationale:** Simplicity for small teams/solo developers. Trade-off accepted.

**Exception:** Utility scripts in `scripts/` directory only.

---

## 6. Feature Implementation Patterns

### Pattern 1: Adding a FREE Optional Enhancement

**Step 1:** Add configuration section in `main.py`:

```python
# ============================================
# FREE OPTIONAL ENHANCEMENT: Smart Summarization
# ============================================
SMART_SUMMARIZATION_ENABLED = os.getenv("SMART_SUMMARIZATION_ENABLED", "false").lower() == "true"
```

**Step 2:** Update `.env.example`:

```bash
# Smart Summarization (FREE OPTIONAL)
# What: Automatically generates executive summaries of content
# Cost: $0/month (uses existing OpenAI budget)
# Benefit: Saves time, improves content utility
# To enable: Set to true
# SMART_SUMMARIZATION_ENABLED=false
```

**Step 3:** Add startup logging:

```python
# In startup_event()
if SMART_SUMMARIZATION_ENABLED:
    logger.info("✅ Smart Summarization: Enabled")
else:
    logger.info("❌ Smart Summarization: Disabled")
```

**Step 4:** Implement feature with toggle:

```python
@app.post("/api/content/summarize")
async def summarize_content(
    content_id: int,
    api_key: str = Depends(verify_api_key),
    db = Depends(get_db)
):
    if not SMART_SUMMARIZATION_ENABLED:
        raise HTTPException(501, "Feature disabled. Set SMART_SUMMARIZATION_ENABLED=true")
    
    # Implementation...
```

**Step 5:** Add test:

```python
# In test_api.py
def test_summarize_disabled():
    os.environ['SMART_SUMMARIZATION_ENABLED'] = 'false'
    response = client.post('/api/content/summarize', ...)
    assert response.status_code == 501
```

### Pattern 2: Adding a PAID Optional Enhancement

Same as FREE, but:
- Clearly document monthly cost in `.env.example`
- Explain ROI/break-even point
- Provide instructions for obtaining API keys/services

Example from `.env.example`:

```bash
# Redis Caching (PAID OPTIONAL ENHANCEMENT)
# Cost: +$10-15/month (Redis hosting)
# Benefit: Reduces OpenAI costs by 30-50%
# ROI: Pays for itself if generating >300 pieces/month
# Setup: Uncomment Redis in docker-compose.yml
# REDIS_URL=redis://redis:6379
```

---

## 7. Database Schema & Patterns

### Table Naming Convention
- Plural nouns: `content`, `analytics_events`, `webhook_logs`
- Snake_case: `api_usage`, `ab_tests`, `social_posts`

### Column Patterns

**Every table MUST have:**
```sql
id SERIAL PRIMARY KEY,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
```

**Time-series tables MUST have descending index:**
```sql
CREATE INDEX IF NOT EXISTS idx_<table>_created_at ON <table>(created_at DESC);
```

**Why:** Fast queries for "recent content" patterns (`ORDER BY created_at DESC LIMIT 10`).

### Core Tables

#### `content` (Generated Content Storage)
```sql
CREATE TABLE content (
    id SERIAL PRIMARY KEY,
    content_type VARCHAR(50) NOT NULL,     -- blog, social_post, email, etc.
    platform VARCHAR(50) NOT NULL,         -- blog, twitter, instagram, etc.
    topic TEXT NOT NULL,
    content TEXT NOT NULL,                 -- The actual generated text
    quality_score FLOAT CHECK (quality_score >= 0 AND quality_score <= 1),
    seo_score FLOAT CHECK (seo_score >= 0 AND seo_score <= 1),
    metadata JSONB DEFAULT '{}',           -- Flexible storage for feature-specific data
    status VARCHAR(20) DEFAULT 'active',   -- active, variant, archived
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_content_created_at ON content(created_at DESC);
CREATE INDEX idx_content_type ON content(content_type);
CREATE INDEX idx_content_status ON content(status);
```

**Pattern:** JSONB `metadata` column allows feature-specific data without schema changes.

#### `api_usage` (Cost Tracking)
```sql
CREATE TABLE api_usage (
    id SERIAL PRIMARY KEY,
    endpoint VARCHAR(100) NOT NULL,         -- content_generation, summarization
    model VARCHAR(50) NOT NULL,             -- gpt-4, claude-3-opus
    tokens_used INTEGER,
    cost DECIMAL(10, 4),                    -- US dollars, 4 decimal precision
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_api_usage_created_at ON api_usage(created_at DESC);
```

**Critical:** Cost tracking enables `MONTHLY_AI_BUDGET` enforcement.

#### `system_settings` (Dynamic Configuration)
```sql
CREATE TABLE system_settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value TEXT,
    setting_type VARCHAR(20) DEFAULT 'string',  -- string, integer, boolean, json
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Pattern:** Allows webhook URLs and other settings to be changed via UI without restarting.

### Database Interaction Patterns

**Always use parameterized queries:**
```python
# ✅ CORRECT
result = await conn.fetchrow(
    "SELECT * FROM content WHERE id = $1",
    content_id
)

# ❌ WRONG (SQL injection risk!)
result = await conn.fetchrow(
    f"SELECT * FROM content WHERE id = {content_id}"
)
```

**Connection pooling:**
```python
# Global pool (initialized at startup)
db_pool: Optional[asyncpg.Pool] = None

# Dependency injection pattern
async def get_db():
    async with db_pool.acquire() as connection:
        yield connection
```

---

## 8. API Endpoint Conventions

### URL Structure
```
/v1/<resource>/<action>

Examples:
  POST /v1/generate          # Generate content
  GET  /v1/content           # List content
  GET  /v1/content/{id}      # Get specific content
  POST /v1/content/{id}/regenerate
  GET  /v1/analytics/dashboard
  POST /v1/ab-test
```

### Endpoint Signature Pattern
```python
@app.{method}("/v1/{resource}/{action}", 
              response_model=ResponseModel,
              tags=["Category"])
async def endpoint_name(
    request: RequestModel = Body(...),
    api_key: str = Depends(verify_api_key),
    db = Depends(get_db),
    background_tasks: BackgroundTasks = BackgroundTasks()
) -> ResponseModel:
    """
    Brief endpoint description.
    
    ## Category: CORE / FREE ENHANCEMENT / PAID ENHANCEMENT
    
    **Cost:** $X per request OR $0
    **Use case:** When to use this endpoint
    
    ## Example Request
    ```json
    {
      "field": "value"
    }
    ```
    
    ## Returns
    - field1: Description
    - field2: Description
    
    ## Errors
    - 400: Validation failed
    - 402: Budget limit reached
    - 403: Invalid API key
    - 501: Feature disabled
    """
    try:
        # Implementation
        return ResponseModel(...)
    except ValueError as e:
        raise HTTPException(400, detail=str(e))
    except Exception as e:
        logger.error(f"Endpoint failed: {e}")
        raise HTTPException(500, detail="Internal server error")
```

### Response Format Standards

**Success (200/201):**
```json
{
  "id": 123,
  "data": {...},
  "metadata": {
    "created_at": "2025-11-13T10:30:00Z",
    "version": "2.1"
  }
}
```

**Error (4xx/5xx):**
```json
{
  "detail": "Human-readable error message",
  "error_code": "BUDGET_EXCEEDED",
  "timestamp": "2025-11-13T10:30:00Z",
  "help": "Increase MONTHLY_AI_BUDGET or wait until next month"
}
```

### Pagination Pattern
```python
@app.get("/v1/content")
async def list_content(
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
    ...
):
    # Query with LIMIT and OFFSET
    content = await conn.fetch(
        "SELECT * FROM content ORDER BY created_at DESC LIMIT $1 OFFSET $2",
        limit, offset
    )
    total = await conn.fetchval("SELECT COUNT(*) FROM content")
    
    return {
        "total": total,
        "limit": limit,
        "offset": offset,
        "has_more": (offset + limit) < total,
        "items": [dict(c) for c in content]
    }
```

---

## 9. Frontend Architecture & Patterns

### React Component Structure

**Single-Page App (No Router):**
```tsx
// App.tsx pattern
type Page = 'generate' | 'analytics' | 'library' | 'settings';
const [currentPage, setCurrentPage] = useState<Page>('generate');

const renderPage = () => {
  switch (currentPage) {
    case 'generate': return <GeneratePage />;
    case 'analytics': return <DashboardPage />;
    // ...
  }
};
```

**Why:** Simplicity. No react-router dependency, instant page switches.

### Component Naming
- **Page components:** `{Name}Page.tsx` (e.g., `GeneratePage.tsx`)
- **UI components:** `{name}.tsx` (e.g., `button.tsx`, `card.tsx`)
- **Custom components:** `PascalCase.tsx` (e.g., `RadialProgress.tsx`)

### API Call Pattern
```tsx
const handleGenerate = async () => {
  setLoading(true);
  try {
    const response = await fetch('/api/v1/generate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': import.meta.env.VITE_API_KEY
      },
      body: JSON.stringify(requestData)
    });
    
    if (!response.ok) {
      const error = await response.json();
      toast.error(error.detail || 'Generation failed');
      return;
    }
    
    const data = await response.json();
    setGenerated(data);
    toast.success('Content generated successfully!');
  } catch (error) {
    toast.error('Network error. Please try again.');
  } finally {
    setLoading(false);
  }
};
```

### Styling Patterns

**Tailwind utility classes (preferred):**
```tsx
<Card className="p-6 shadow-md hover:shadow-lg transition-shadow">
  <h2 className="text-2xl font-bold mb-4">Title</h2>
</Card>
```

**CSS variables for theme colors:**
```css
/* index.css */
:root {
  --primary: oklch(0.75 0.15 85);      /* SPLANTS brand orange */
  --secondary: oklch(0.60 0.15 85);    /* Darker orange */
}
```

**Responsive design:**
```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
  {/* Mobile: 1 column, Tablet: 2, Desktop: 4 */}
</div>
```

---

## 10. Testing Requirements

### Test Structure (`test_api.py`)

```python
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

class TestContentGeneration:
    """Test suite for content generation endpoints"""
    
    def test_generate_success(self):
        """Test successful content generation"""
        response = client.post('/api/v1/generate', json={
            "content_type": "blog",
            "topic": "Test topic",
            "platform": "blog",
            "tone": "professional",
            "keywords": ["test"],
            "length": 500
        }, headers={'X-API-Key': 'test_key'})
        
        assert response.status_code == 200
        data = response.json()
        assert 'id' in data
        assert 'content' in data
        assert data['quality_score'] >= 0.7
    
    def test_generate_without_auth(self):
        """Test authentication requirement"""
        response = client.post('/api/v1/generate', json={...})
        assert response.status_code == 403
```

### Test Coverage Requirements
- **All API endpoints:** 100% (every endpoint must have at least one test)
- **Core logic:** 90%+ (ContentEngine, quality scoring, cost control)
- **Utility functions:** 80%+

### Running Tests
```bash
# Run all tests
make test

# Run specific test
pytest test_api.py::TestContentGeneration::test_generate_success

# Run with verbose output
pytest -v test_api.py

# Run with coverage report
pytest --cov=main --cov-report=html
```

---

## 11. Developer Workflows

### First-Time Setup
```bash
git clone <repo>
cd SPLANTS
make start  # Interactive wizard creates .env and starts services
```

### Daily Development
```bash
make dev     # Start with attached logs
# Edit files (main.py auto-reloads, web rebuilds on save)
make logs    # View logs in separate terminal
make test    # Run tests before committing
```

### Adding a New Feature
1. **Categorize:** Decide CORE / FREE / PAID
2. **Design:** Read `FEATURE_TEMPLATE.md`
3. **Backend:** Add to `main.py` with feature gate
4. **Frontend:** Create/update page in `web/src/components/pages/`
5. **Test:** Add tests to `test_api.py`
6. **Document:** Update `.env.example`, `README.md`
7. **Commit:** `git commit -m "feat: Add feature name"`

### Database Operations
```bash
make db-shell              # Open PostgreSQL prompt
make backup                # Create backup in ./backups/
make restore file=backup.sql.gz
```

### Debugging
```bash
# View specific service logs
docker compose logs -f app
docker compose logs -f web

# Check service status
make status

# Restart specific service
docker compose restart app

# Rebuild after code changes
make rebuild
```

---

## 12. Configuration & Environment Variables

### Critical Variables (REQUIRED)
```bash
OPENAI_API_KEY=sk-proj-...        # OpenAI GPT-4 access
API_KEY=YourSecurePassword123!    # System authentication
DATABASE_URL=postgresql://...     # Default OK for Docker
```

### Cost Control (HIGHLY RECOMMENDED)
```bash
MONTHLY_AI_BUDGET=50              # $50/month limit (0=unlimited)
DAILY_API_LIMIT=100               # 100 requests/day (0=unlimited)
```

### Feature Toggles (All Default to False)
```bash
# FREE OPTIONAL ENHANCEMENTS
ANALYTICS_ENABLED=true
AB_TESTING_ENABLED=true
COST_CONTROL_ENABLED=true
ENABLE_WEBHOOKS=true

# PAID OPTIONAL ENHANCEMENTS
REDIS_URL=redis://redis:6379      # Caching (+$10-15/month)
ANTHROPIC_API_KEY=sk-ant-...      # Multi-model (+$0.02-0.05/request)
```

### Webhook URLs (FREE, but optional)
```bash
WEBHOOK_CONTENT_GENERATED_URL=https://hooks.zapier.com/...
WEBHOOK_CONTENT_PUBLISHED_URL=https://hooks.zapier.com/...
WEBHOOK_DAILY_REPORT_URL=https://hooks.zapier.com/...
```

### Social Media Auto-Posting (PAID, advanced)
```bash
# Requires platform developer accounts
TWITTER_API_KEY=...
TWITTER_API_SECRET=...
LINKEDIN_CLIENT_ID=...
FACEBOOK_ACCESS_TOKEN=...
```

---

## 13. Code Style & Standards

### Python (PEP 8 with modifications)
```python
# Line length: 100 characters (not 79)
# Indentation: 4 spaces
# Quotes: Double quotes for strings

# Naming conventions:
CONSTANT_VALUE = "value"           # UPPER_SNAKE_CASE
variable_name = "value"            # snake_case
class ClassName:                   # PascalCase
def function_name():               # snake_case
def _private_function():           # Leading underscore

# Docstring format:
def function_name(param: str) -> dict:
    """
    Brief description.
    
    Args:
        param: Parameter description
    
    Returns:
        Dictionary with keys...
    
    Raises:
        ValueError: When param is invalid
    """
```

### TypeScript/React
```typescript
// Indentation: 2 spaces
// Quotes: Single quotes
// Semicolons: Required

// Component naming:
export function ComponentName() {}  // PascalCase
const helperFunction = () => {};    // camelCase
interface Props {}                  // PascalCase
type Page = 'home' | 'about';      // PascalCase

// Props pattern:
interface ComponentProps {
  title: string;
  count?: number;  // Optional props use ?
  onAction: (id: number) => void;
}

export function Component({ title, count = 0, onAction }: ComponentProps) {}
```

### SQL
```sql
-- Keywords: UPPERCASE
-- Identifiers: snake_case
-- Indentation: 2 spaces

SELECT 
  column_name,
  COUNT(*) as count
FROM table_name
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY column_name
ORDER BY count DESC;
```

---

## 14. Security Patterns

### API Key Validation
```python
# In verify_api_key dependency:
if not api_key or api_key != API_KEY:
    raise HTTPException(
        status_code=403,
        detail="Invalid or missing API key. Include X-API-Key header."
    )
```

**Never log API keys:**
```python
# ✅ CORRECT
logger.info(f"Request authenticated for endpoint: {endpoint}")

# ❌ WRONG
logger.info(f"API key {api_key} used")  # NEVER LOG SECRETS
```

### SQL Injection Prevention
```python
# ✅ CORRECT - Parameterized queries
await conn.fetchrow(
    "SELECT * FROM content WHERE id = $1 AND user_id = $2",
    content_id, user_id
)

# ❌ WRONG - String interpolation
await conn.fetchrow(
    f"SELECT * FROM content WHERE id = {content_id}"
)
```

### CORS Configuration
```python
# Development (permissive):
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # OK for local development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Production (restrictive):
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"],  # Specific domain
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "X-API-Key"],
)
```

---

## 15. Cost Control Patterns

### Budget Checking (Before AI Calls)
```python
# In every AI-calling endpoint:
estimated_cost = 0.03  # Estimate for GPT-4 request

if MONTHLY_AI_BUDGET > 0:
    can_proceed = await cost_controller.check_budget(estimated_cost)
    if not can_proceed:
        raise HTTPException(
            status_code=402,
            detail=f"Monthly budget of ${MONTHLY_AI_BUDGET} reached. "
                   f"Increase MONTHLY_AI_BUDGET or wait until next month."
        )
```

### Usage Tracking (After AI Calls)
```python
await _track_api_usage(
    db=db,
    endpoint="content_generation",
    model="gpt-4",
    tokens_used=response.usage.total_tokens,
    estimated_cost=cost,
    success=True,
    error_message=None
)
```

### Cost Calculation
```python
def calculate_cost(tokens: int, model: str) -> float:
    """Calculate cost based on OpenAI pricing"""
    pricing = {
        "gpt-4": {
            "input": 0.03 / 1000,   # $0.03 per 1K input tokens
            "output": 0.06 / 1000   # $0.06 per 1K output tokens
        },
        "gpt-4-turbo": {
            "input": 0.01 / 1000,
            "output": 0.03 / 1000
        }
    }
    # Simplified: assume 50/50 input/output split
    avg_price = (pricing[model]["input"] + pricing[model]["output"]) / 2
    return tokens * avg_price
```

---

## 16. Deployment & Production

### Pre-Deployment Checklist
- [ ] All tests passing: `make test`
- [ ] `.env` configured with production values
- [ ] `API_KEY` changed from default
- [ ] `CORS_ORIGINS` set to specific domain (not `*`)
- [ ] `MONTHLY_AI_BUDGET` set to prevent runaway costs
- [ ] Database backup strategy configured
- [ ] Monitoring/alerting configured
- [ ] SSL/TLS certificates obtained (if deploying with custom domain)

### Production Environment Variables
```bash
# Change these for production:
API_KEY=<strong-random-password>
OPENAI_API_KEY=<production-key>
MONTHLY_AI_BUDGET=100  # Set reasonable limit
ENV=production
LOG_LEVEL=INFO         # Less verbose than DEBUG
CORS_ORIGINS=https://yourdomain.com
```

### Deployment Options
1. **VPS (Recommended for small-scale):** DigitalOcean, Linode, Hetzner ($6-12/month)
2. **Cloud:** AWS EC2, Google Cloud, Azure VM ($10-30/month)
3. **PaaS:** Heroku, Railway, Render (varies)

See `docs_DEPLOYMENT.md` for detailed instructions.

---

## 17. Documentation Requirements

### When to Update Documentation

**ALWAYS update when:**
- Adding new environment variable → Update `.env.example`
- Adding new endpoint → Update `docs_API_GUIDE.md`
- Adding new feature → Update `README.md` and `FEATURE_TEMPLATE.md`
- Changing workflow → Update `DEVELOPER_GUIDE.md`
- Fixing bug → Add entry to `FIXES_APPLIED.md`

### Documentation Standards
- **Target audience:** Non-technical entrepreneurs
- **Reading level:** 8th grade (simple language)
- **Format:** Markdown with clear headers, examples, screenshots
- **Length:** As long as needed for clarity (no arbitrary limits)

---

## 18. Common Patterns & Conventions

### Naming Patterns
- **Tables:** Plural nouns (`content`, `users`, `api_usage`)
- **Columns:** Snake_case (`created_at`, `quality_score`)
- **API endpoints:** Kebab-case (`/v1/content/generate`, `/v1/ab-test`)
- **Python functions:** Snake_case (`generate_content`, `calculate_quality_score`)
- **React components:** PascalCase (`GeneratePage`, `RadialProgress`)
- **Environment variables:** UPPER_SNAKE_CASE (`OPENAI_API_KEY`, `MONTHLY_AI_BUDGET`)

### Import Order (Python)
```python
# 1. Standard library
import os
import json
from datetime import datetime

# 2. Third-party
from fastapi import FastAPI
import asyncpg

# 3. Local/relative (if any, which we avoid)
# from .utils import helper  # DON'T DO THIS - monolithic pattern
```

### Async/Await Pattern
```python
# ALWAYS use async/await for I/O:
async def database_operation():
    async with db_pool.acquire() as conn:
        result = await conn.fetchrow("SELECT ...")
    return result

# NEVER block event loop:
def blocking_operation():  # ❌ WRONG
    result = requests.get(url)  # Synchronous HTTP call
    return result.json()

# ✅ CORRECT - Use httpx:
async def async_operation():
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
    return response.json()
```

---

## 19. Troubleshooting Patterns

### Common Issues & Solutions

**Issue:** `HTTPException: Budget limit reached`  
**Solution:** Increase `MONTHLY_AI_BUDGET` in `.env` or wait until next month reset

**Issue:** `Connection refused to app:8080`  
**Solution:** Ensure all services running: `make status`, restart: `make restart`

**Issue:** `Invalid API key`  
**Solution:** Check `API_KEY` in `.env` matches `X-API-Key` header in requests

**Issue:** `Feature not working`  
**Solution:** Check feature toggle in `.env` (e.g., `ANALYTICS_ENABLED=true`), then `make restart`

**Issue:** Tests failing  
**Solution:** Ensure database is fresh: `make stop && make start`, then `make test`

See `TROUBLESHOOTING.md` for 50+ issue/solution pairs.

---

## 20. Key Files Reference

### Must-Read Before Coding
1. **`main.py`** - Backend source of truth (3,938 lines)
2. **`docker-compose.yml`** - Service architecture
3. **`Makefile`** - Developer workflow commands
4. **`test_api.py`** - API usage examples
5. **`.env.example`** - All configuration options
6. **`FEATURE_TEMPLATE.md`** - Pattern for new features

### API Documentation
- **Interactive:** `http://localhost:3000/api/docs` (Swagger UI)
- **Static:** `docs_API_GUIDE.md`

### Architecture Diagrams
- **System overview:** Section 2 of this file
- **Data flow:** Section 2 of this file
- **Database schema:** Section 7 of this file

---

## QUICK REFERENCE CARD

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
               SPLANTS DEVELOPMENT CHEAT SHEET
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETUP:
  make start             First-time setup (interactive wizard)
  make dev               Start with live logs
  make stop              Stop all services

TESTING:
  make test              Run API tests (MANDATORY before commit)
  pytest -v test_api.py  Verbose test output

LOGS & DEBUG:
  make logs              All services
  make logs-app          Backend only
  docker compose ps      Service status

DATABASE:
  make db-shell          PostgreSQL prompt
  make backup            Backup to ./backups/
  make restore file=X    Restore from backup

PORTS:
  3000  Public entry (NGINX + React)
  8080  Backend API (internal only)
  5432  PostgreSQL (internal)

KEY FILES:
  main.py                Entire backend (3,938 lines)
  web/src/App.tsx        Frontend router
  docker-compose.yml     Service orchestration
  .env.example           Config template
  test_api.py            API tests

MANDATES:
  ✓ Categorize features (CORE/FREE/PAID)
  ✓ Gate with environment variables
  ✓ Log startup status
  ✓ Protect endpoints with verify_api_key
  ✓ Track AI usage with _track_api_usage
  ✓ Test before commit (make test)
  ✓ Keep logic in main.py (monolithic)

DOCUMENTATION:
  http://localhost:3000/api/docs  Interactive API docs
  README.md                       User guide
  DEVELOPER_GUIDE.md              This guide
  TROUBLESHOOTING.md              Problem solving

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

**END OF COMPREHENSIVE GUIDE**  
**Version:** 2.1.1  
**Maintained by:** SPLANTS Development Team  
**Last Updated:** 2025-11-13

For questions or clarifications, consult:
1. This file (comprehensive reference)
2. `README.md` (user-facing documentation)
3. `DEVELOPER_GUIDE.md` (workflow examples)
4. `PROJECT_SPECIFICATION.md` (complete spec)