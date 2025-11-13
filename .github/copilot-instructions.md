# GitHub Copilot Instructions — SPLANTS Marketing Engine

**Version:** 2.1.1  
**Last Updated:** 2025-11-13  
**Purpose:** Comprehensive reference guide for AI coding agents working on SPLANTS

---

## Table of Contents

1. [Project Overview & Goals](#1-project-overview--goals)
2. [Architecture & System Design](#2-architecture--system-design)
3. [Core Principles & Mandates](#3-core-principles--mandates)
4. [Development Workflow](#4-development-workflow)
5. [Feature Implementation Patterns](#5-feature-implementation-patterns)
6. [Backend Conventions](#6-backend-conventions)
7. [Frontend Conventions](#7-frontend-conventions)
8. [Database Schema & Patterns](#8-database-schema--patterns)
9. [API Design Standards](#9-api-design-standards)
10. [Testing Requirements](#10-testing-requirements)
11. [Security Patterns](#11-security-patterns)
12. [Cost Control & Tracking](#12-cost-control--tracking)
13. [Configuration Management](#13-configuration-management)
14. [Troubleshooting Guide](#14-troubleshooting-guide)
15. [Documentation Requirements](#15-documentation-requirements)
16. [Quick Reference Card](#16-quick-reference-card)

---

## 1. Project Overview & Goals

### Primary Goal
Build an AI-powered marketing engine that enables small businesses (specifically SPLANTS custom pants) to compete with large marketing budgets through automation and intelligence.

### Success Criteria
- **Cost Efficiency:** Reduce marketing costs by 90-95% ($35-80/month vs $1,700-3,400/month traditional)
- **Quality:** Generate professional marketing content scoring 0.85+ on quality metrics
- **Accessibility:** Non-technical users can install, configure, and use the system
- **Scalability:** Support from 1 to 1,000+ content pieces per month without linear cost increase
- **Comprehensiveness:** Complete solution from content generation to performance tracking

### Key Differentiators
1. **Core + Optional Enhancement Pattern** - Not bloated, pay only for what you use
2. **Monolithic Intentionality** - Single `main.py` file (3,908 lines) for simplicity and maintainability
3. **AI-First Architecture** - Leverage GPT-4 for 80% of marketing tasks
4. **Data-Driven** - Built-in analytics, A/B testing, quality scoring
5. **Bootstrap-Friendly** - Designed for solo entrepreneurs with limited budget

---

## 2. Architecture & System Design

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User / External API                       │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ HTTP (Port 3000)
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                  Web Service (NGINX + React)                 │
│  - Serves React frontend                                     │
│  - Proxies /api/* to backend                                 │
│  - Static assets                                             │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Internal: /api/* → app:8080
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                  App Service (FastAPI)                       │
│  - main.py (monolithic backend)                              │
│  - REST API endpoints                                        │
│  - AI content generation                                     │
│  - Business logic                                            │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ PostgreSQL protocol
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                  DB Service (PostgreSQL 15)                  │
│  - Content storage                                           │
│  - Analytics data                                            │
│  - Usage tracking                                            │
└─────────────────────────────────────────────────────────────┘
```

### Service Boundaries

**DB Service (`db`)**
- Image: `postgres:15-alpine`
- Purpose: Persistent data storage
- Port: 5432 (internal only, optionally exposed)
- Health check: `pg_isready -U splants`
- Volume: `postgres_data` (persists across restarts)

**App Service (`app`)**
- Built from: `Dockerfile` (root)
- Purpose: Backend API, business logic, AI integration
- Port: 8080 (internal only, accessed via web proxy)
- Dependencies: DB must be healthy before starting
- Health check: `curl -f http://localhost:8080/health`
- Volume: `./logs` mounted for log persistence, `./main.py` for hot-reload

**Web Service (`web`)**
- Built from: `web/Dockerfile`
- Purpose: Frontend UI + NGINX reverse proxy
- Port: 3000 (public entry point)
- Dependencies: App service running
- Health check: `wget http://localhost:3000`
- Routing: `/api/*` → `http://app:8080/*`

### Technology Stack

**Backend:**
- FastAPI (Python web framework)
- AsyncPG (PostgreSQL async driver)
- OpenAI SDK (GPT-4 integration)
- Anthropic SDK (Claude integration, optional)
- HTTPX (async HTTP client)

**Frontend:**
- React 18 + TypeScript
- Vite (build tool)
- Tailwind CSS (styling)
- shadcn/ui (component library)
- Phosphor Icons
- NGINX (reverse proxy)

**Infrastructure:**
- Docker Compose (orchestration)
- PostgreSQL 15 (database)
- Redis (optional caching)

---

## 3. Core Principles & Mandates

### Principle 1: Simplicity Over Cleverness

**MANDATE:** Every architectural decision must favor simplicity and maintainability over clever solutions.

**Implementation:**
- **Monolithic Backend:** All backend logic in single `main.py` file
  - Reason: Easier to understand, deploy, and debug for small teams
  - Trade-off: Accepted complexity in one file vs. microservice overhead
  
- **Clear Section Markers:** Use ASCII art headers to delineate sections
  ```python
  # ============================================
  # SECTION NAME
  # ============================================
  ```
  
- **Minimal Dependencies:** Keep `requirements.txt` under 15 packages
- **No Relative Imports:** Everything in one file, no local imports

### Principle 2: Core + Optional Enhancement Pattern

**MANDATE:** Separate functionality into CORE, FREE OPTIONAL, and PAID OPTIONAL categories.

**CORE FEATURES** (Always Included):
- AI content generation (GPT-4)
- Multi-platform publishing
- SEO optimization
- Quality scoring
- Content storage & management
- Basic API endpoints
- Web UI

**FREE OPTIONAL ENHANCEMENTS** (Enable via environment variables):
- Analytics dashboard
- A/B testing
- Content templates
- Cost control & budget monitoring
- Webhook system
- Smart hashtags
- Platform optimization

**PAID OPTIONAL ENHANCEMENTS** (Require additional services/costs):
- Redis caching (+$10-15/month)
- Multi-model AI synthesis (+$0.02-0.05 per request)
- Social media auto-posting (varies by platform)

**Code Structure Mandate:**
Each optional feature MUST:
1. Have an environment variable toggle: `FEATURE_ENABLED=true/false`
2. Include startup logging: `logger.info("✅/❌ Feature: Enabled/Disabled")`
3. Have safe defaults (disabled unless explicitly enabled)
4. Include in-code comments: `# FREE OPTIONAL ENHANCEMENT: Feature Name`
5. Gracefully degrade if dependencies missing
6. Return HTTP 501 if disabled and endpoint is called

### Principle 3: Data-Driven Decision Making

**MANDATE:** Build measurement, testing, and optimization capabilities into the core system.

**Built-In Analytics:**
- Track every API call: content type, platform, tokens used, cost, quality score
- Store in `analytics_events` table with timestamps
- Provide aggregation endpoints: daily, weekly, monthly views
- Calculate ROI: content performance vs. cost

**A/B Testing Framework:**
- Store content variations in `ab_tests` table
- Track performance metrics for each variant
- Provide statistical significance calculations

---

## 4. Development Workflow

### Initial Setup (First Time)

```bash
# Clone repository
git clone https://github.com/EdwinBostonIII/SPLANTS.git
cd SPLANTS

# Run interactive setup wizard
make start
# This will:
# - Check Docker installation
# - Create .env file with prompts for API keys
# - Initialize database schema
# - Start all services (db, app, web)
# - Display URLs for access
```

### Daily Development

```bash
# Start with attached logs (recommended for active development)
make dev

# OR start detached and view logs separately
make start
make logs

# Check service status
make status

# View specific service logs
docker compose logs -f app
docker compose logs -f web
docker compose logs -f db
```

### Making Code Changes

**Backend Changes (main.py):**
- Edit `main.py`
- FastAPI auto-reloads on file changes (no restart needed)
- Check logs: `make logs-app`

**Frontend Changes (web/src/):**
- Edit files in `web/src/`
- Vite hot-reload rebuilds automatically
- Check logs: `make logs-web`

**Database Schema Changes:**
- Add migration logic to `init_db()` function in `main.py`
- Restart app service: `docker compose restart app`
- Verify: `make db-shell` then check schema

### Testing Changes

```bash
# Run full test suite
make test

# Runs: python3 test_api.py
# Tests all major endpoints and validates backend-frontend contract
# MUST pass before committing

# Manual API testing
curl -X POST http://localhost:3000/api/v1/generate \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"content_type": "blog", "topic": "Test", "platform": "blog"}'
```

### Database Operations

```bash
# Access PostgreSQL shell
make db-shell

# Backup database
make backup
# Creates: ./backups/splants-backup-YYYY-MM-DD-HHMMSS.sql.gz

# Restore from backup
make restore file=./backups/splants-backup-2025-11-13-100000.sql.gz
```

### Common Commands (Makefile)

| Command | Purpose |
|---------|---------|
| `make start` | First-time setup or start detached |
| `make dev` | Start with attached logs |
| `make stop` | Stop all services |
| `make restart` | Restart all services |
| `make status` | Check service health |
| `make logs` | View all logs (follow mode) |
| `make test` | Run API test suite |
| `make db-shell` | Open PostgreSQL prompt |
| `make backup` | Backup database |
| `make clean` | Remove containers and volumes |
| `make build` | Rebuild Docker images |

---

## 5. Feature Implementation Patterns

### Pattern: Adding a FREE Optional Enhancement

**Step 1:** Categorize in code comments:
```python
# In main.py configuration section (~line 108-150)

# FREE OPTIONAL ENHANCEMENT: Your Feature Name
# Description: What this feature does and why it's useful
FEATURE_NAME_ENABLED = os.getenv("FEATURE_NAME_ENABLED", "false").lower() == "true"
```

**Step 2:** Add to `.env.example`:
```bash
# Your Feature Name (FREE OPTIONAL ENHANCEMENT)
# Description: What this feature does
# Benefit: Specific value it provides
# To enable: Set to true
# FEATURE_NAME_ENABLED=false
```

**Step 3:** Add startup logging:
```python
# In startup_event() function (~line 182-250)
if FEATURE_NAME_ENABLED:
    logger.info("✅ Your Feature Name: Enabled")
else:
    logger.info("❌ Your Feature Name: Disabled (set FEATURE_NAME_ENABLED=true)")
```

**Step 4:** Implement feature with toggle:
```python
@app.post("/api/v1/feature-name")
async def feature_endpoint(
    request: FeatureRequest,
    api_key: str = Depends(verify_api_key),
    db = Depends(get_db)
):
    """
    Feature description.
    
    ## Category: FREE OPTIONAL ENHANCEMENT
    Cost: $0
    
    ## Usage
    Enable by setting FEATURE_NAME_ENABLED=true in .env
    """
    if not FEATURE_NAME_ENABLED:
        raise HTTPException(
            status_code=501,
            detail="Feature disabled. Set FEATURE_NAME_ENABLED=true to enable."
        )
    
    # Implementation...
    try:
        result = await process_feature(request, db)
        return {"status": "success", "data": result}
    except Exception as e:
        logger.error(f"Feature error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
```

**Step 5:** Add test:
```python
# In test_api.py
def test_feature_disabled():
    """Test that feature returns 501 when disabled"""
    response = client.post('/api/v1/feature-name', 
                          headers=headers,
                          json={"test": "data"})
    assert response.status_code == 501
    assert "disabled" in response.json()["detail"].lower()
```

### Pattern: Adding a PAID Optional Enhancement

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
# Setup: Uncomment Redis service in docker-compose.yml
# REDIS_URL=redis://redis:6379
```

---

## 6. Backend Conventions

### File Structure
- **Everything in `main.py`** - Intentionally monolithic (3,908 lines)
- Sections marked with ASCII art headers
- Order: Imports → Configuration → Models → Database → AI Logic → Endpoints → Startup

### Section Headers
```python
# ============================================
# SECTION NAME (e.g., AUTHENTICATION, DATABASE SETUP)
# ============================================
```

### Naming Conventions
- **Constants:** `UPPER_SNAKE_CASE` (e.g., `OPENAI_API_KEY`, `MONTHLY_AI_BUDGET`)
- **Functions:** `snake_case` (e.g., `generate_content`, `calculate_quality_score`)
- **Classes:** `PascalCase` (e.g., `ContentRequest`, `GenerationResponse`)
- **Private functions:** `_snake_case` (e.g., `_track_api_usage`, `_validate_request`)

### Async/Await Pattern
```python
# ✅ CORRECT - Use async for all I/O operations
async def database_operation(db):
    result = await db.fetchrow("SELECT * FROM content WHERE id = $1", content_id)
    return result

async def ai_call():
    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=data)
    return response.json()

# ❌ WRONG - Never block the event loop
def blocking_operation():
    result = requests.get(url)  # Synchronous - BAD
    return result.json()
```

### Error Handling
```python
# Standard pattern for endpoint errors
try:
    result = await process_request(request)
    return {"status": "success", "data": result}
except ValueError as e:
    # Client error - bad input
    raise HTTPException(status_code=400, detail=str(e))
except PermissionError as e:
    # Authorization error
    raise HTTPException(status_code=403, detail=str(e))
except Exception as e:
    # Server error - log and return generic message
    logger.error(f"Endpoint failed: {e}", exc_info=True)
    raise HTTPException(status_code=500, detail="Internal server error")
```

### Logging Standards
```python
# Use structured logging with context
logger.info(f"Content generated: id={content_id}, type={content_type}, quality={quality_score}")
logger.warning(f"Budget warning: ${current_spend:.2f} of ${MONTHLY_AI_BUDGET} used")
logger.error(f"AI generation failed: {error_message}", exc_info=True)

# ❌ NEVER log secrets
# logger.info(f"API key: {api_key}")  # NEVER DO THIS
```

### Dependency Injection Pattern
```python
# Use FastAPI's dependency injection for common resources

# Database connection
async def get_db():
    async with db_pool.acquire() as connection:
        yield connection

# API key verification
async def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API Key")
    return api_key

# Usage in endpoint
@app.post("/api/v1/generate")
async def generate_content(
    request: ContentRequest,
    api_key: str = Depends(verify_api_key),
    db = Depends(get_db)
):
    # endpoint logic
    pass
```

---

## 7. Frontend Conventions

### Directory Structure
```
web/
├── src/
│   ├── components/
│   │   ├── pages/          # Page components
│   │   │   ├── DashboardPage.tsx
│   │   │   ├── GeneratePage.tsx
│   │   │   ├── LibraryPage.tsx
│   │   │   ├── SettingsPage.tsx
│   │   │   └── BookmarksPage.tsx
│   │   └── ui/             # Reusable UI components (shadcn/ui)
│   │       ├── button.tsx
│   │       ├── card.tsx
│   │       ├── input.tsx
│   │       └── ...
│   ├── App.tsx             # Main app component (routing)
│   ├── index.css           # Global styles
│   └── main.tsx            # Entry point
├── public/                 # Static assets
├── index.html              # HTML template
└── nginx.conf              # NGINX reverse proxy config
```

### Routing Pattern (No React Router)
```typescript
// App.tsx - Simple page switching without react-router
type Page = 'generate' | 'dashboard' | 'library' | 'settings' | 'bookmarks';

function App() {
  const [currentPage, setCurrentPage] = useState<Page>('generate');

  const renderPage = () => {
    switch (currentPage) {
      case 'generate': return <GeneratePage />;
      case 'dashboard': return <DashboardPage />;
      case 'library': return <LibraryPage />;
      case 'settings': return <SettingsPage />;
      case 'bookmarks': return <BookmarksPage />;
    }
  };

  return (
    <div className="app">
      <nav>
        <button onClick={() => setCurrentPage('generate')}>Generate</button>
        {/* More nav buttons */}
      </nav>
      {renderPage()}
    </div>
  );
}
```

**Why:** Simplicity. No router dependency, instant page switches.

### Component Naming
- **Page components:** `{Name}Page.tsx` (e.g., `GeneratePage.tsx`)
- **UI components:** `{name}.tsx` (e.g., `button.tsx`, `card.tsx`)
- **Custom components:** `PascalCase.tsx` (e.g., `RadialProgress.tsx`)

### API Call Pattern
```typescript
const handleGenerate = async () => {
  setLoading(true);
  setError(null);
  
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
      throw new Error(error.detail || 'Generation failed');
    }
    
    const data = await response.json();
    setGenerated(data);
    toast.success('Content generated successfully!');
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Network error';
    setError(message);
    toast.error(message);
  } finally {
    setLoading(false);
  }
};
```

### Styling Conventions
```typescript
// ✅ Tailwind utility classes (preferred)
<Card className="p-6 shadow-md hover:shadow-lg transition-shadow">
  <h2 className="text-2xl font-bold mb-4 text-primary">Title</h2>
  <p className="text-muted-foreground">Description</p>
</Card>

// CSS variables for theme colors (defined in index.css)
:root {
  --primary: oklch(0.75 0.15 85);      /* SPLANTS brand orange */
  --secondary: oklch(0.60 0.15 85);    /* Darker orange */
  --background: oklch(0.98 0 0);       /* Off-white */
  --foreground: oklch(0.20 0 0);       /* Dark text */
}

// Responsive design with Tailwind
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
  {/* Mobile: 1 column, Tablet: 2, Desktop: 4 */}
</div>
```

### TypeScript Conventions
```typescript
// Component props interface
interface GeneratePageProps {
  onGenerate?: (content: GeneratedContent) => void;
  initialTopic?: string;
}

// Type for page states
type LoadingState = 'idle' | 'loading' | 'success' | 'error';

// Strict null checks
const content: string | null = null;
if (content) {
  // TypeScript knows content is string here
  console.log(content.toUpperCase());
}

// Use enums for fixed sets of values
enum ContentType {
  Blog = 'blog',
  Social = 'social_post',
  Email = 'email',
  Ad = 'ad'
}
```

---

## 8. Database Schema & Patterns

### Table Naming Convention
- Plural nouns: `content`, `analytics_events`, `webhook_logs`
- Snake_case: `api_usage`, `ab_tests`, `social_posts`

### Required Columns
Every table MUST have:
```sql
id SERIAL PRIMARY KEY,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
```

### Time-Series Tables
Tables with time-series data MUST have descending index:
```sql
CREATE INDEX IF NOT EXISTS idx_<table>_created_at 
ON <table>(created_at DESC);
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

#### `analytics_events` (User Activity Tracking)
```sql
CREATE TABLE analytics_events (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,        -- page_view, button_click, content_generated
    event_data JSONB DEFAULT '{}',          -- Flexible event properties
    user_id VARCHAR(100),                   -- Optional user identifier
    session_id VARCHAR(100),                -- Session tracking
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_analytics_events_created_at ON analytics_events(created_at DESC);
CREATE INDEX idx_analytics_events_type ON analytics_events(event_type);
```

#### `webhook_logs` (Webhook Delivery Tracking)
```sql
CREATE TABLE webhook_logs (
    id SERIAL PRIMARY KEY,
    webhook_url TEXT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL,
    status_code INTEGER,
    response TEXT,
    retry_count INTEGER DEFAULT 0,
    success BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_webhook_logs_created_at ON webhook_logs(created_at DESC);
```

### Database Interaction Patterns

**Always use parameterized queries:**
```python
# ✅ CORRECT - Prevents SQL injection
result = await conn.fetchrow(
    "SELECT * FROM content WHERE id = $1 AND user_id = $2",
    content_id, user_id
)

# ❌ WRONG - SQL injection vulnerability
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

# Usage in endpoint
@app.post("/api/v1/content/{content_id}")
async def get_content(content_id: int, db = Depends(get_db)):
    content = await db.fetchrow(
        "SELECT * FROM content WHERE id = $1", content_id
    )
    return dict(content) if content else None
```

---

## 9. API Design Standards

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
    
    ## Category: CORE / FREE OPTIONAL ENHANCEMENT / PAID OPTIONAL ENHANCEMENT
    
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
        logger.error(f"Endpoint failed: {e}", exc_info=True)
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
    db = Depends(get_db)
):
    # Query with LIMIT and OFFSET
    content = await db.fetch(
        "SELECT * FROM content ORDER BY created_at DESC LIMIT $1 OFFSET $2",
        limit, offset
    )
    total = await db.fetchval("SELECT COUNT(*) FROM content")
    
    return {
        "total": total,
        "limit": limit,
        "offset": offset,
        "has_more": (offset + limit) < total,
        "items": [dict(c) for c in content]
    }
```

---

## 10. Testing Requirements

### Test Structure (`test_api.py`)

```python
#!/usr/bin/env python3
"""
SPLANTS Marketing Engine - API Test Suite
Tests all major endpoints and features
"""

import requests
import json
from typing import Dict, Any

# Configuration
BASE_URL = "http://localhost:3000/api"
API_KEY = "change-this-to-a-secure-password-123"  # Must match .env

headers = {
    "X-API-Key": API_KEY,
    "Content-Type": "application/json"
}

def test_endpoint(name: str, method: str, endpoint: str, data: Dict = None):
    """Test a single endpoint and report results"""
    print(f"\nTesting: {name}")
    print(f"  Endpoint: {method} {endpoint}")
    
    try:
        if method == "GET":
            response = requests.get(f"{BASE_URL}{endpoint}", headers=headers)
        elif method == "POST":
            response = requests.post(f"{BASE_URL}{endpoint}", 
                                    headers=headers, json=data)
        
        if response.status_code in [200, 201]:
            print(f"  ✅ Success (Status: {response.status_code})")
            return True
        else:
            print(f"  ❌ Failed (Status: {response.status_code})")
            print(f"  Error: {response.text[:200]}")
            return False
    except Exception as e:
        print(f"  ❌ Exception: {str(e)}")
        return False
```

### Test Coverage Requirements
- **All API endpoints:** 100% (every endpoint must have at least one test)
- **Core logic:** 90%+ (ContentEngine, quality scoring, cost control)
- **Utility functions:** 80%+

### Running Tests
```bash
# Run all tests
make test

# Manual testing with curl
curl -X POST http://localhost:3000/api/v1/generate \
  -H "X-API-Key: your-key" \
  -H "Content-Type: application/json" \
  -d '{"content_type": "blog", "topic": "Test", "platform": "blog"}'
```

---

## 11. Security Patterns

### API Key Validation
```python
# In verify_api_key dependency
async def verify_api_key(api_key: str = Security(api_key_header)):
    if not api_key or api_key != API_KEY:
        logger.warning(f"Invalid API key attempt")
        raise HTTPException(
            status_code=403,
            detail="Invalid or missing API key. Include X-API-Key header."
        )
    return api_key
```

**Never log API keys:**
```python
# ✅ CORRECT
logger.info(f"Request authenticated for endpoint: {endpoint}")

# ❌ WRONG - Security violation
logger.info(f"API key {api_key} used")  # NEVER LOG SECRETS
```

### SQL Injection Prevention
```python
# ✅ CORRECT - Parameterized queries
await conn.fetchrow(
    "SELECT * FROM content WHERE id = $1 AND user_id = $2",
    content_id, user_id
)

# ❌ WRONG - String interpolation vulnerability
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

## 12. Cost Control & Tracking

### Budget Checking Pattern
```python
# Before every AI API call
if MONTHLY_AI_BUDGET > 0:
    current_spend = await get_monthly_spend(db)
    estimated_cost = calculate_estimated_cost(request)
    
    if current_spend + estimated_cost > MONTHLY_AI_BUDGET:
        raise HTTPException(
            status_code=402,
            detail=f"Monthly budget of ${MONTHLY_AI_BUDGET} reached. "
                   f"Current spend: ${current_spend:.2f}. "
                   f"Increase MONTHLY_AI_BUDGET or wait until next month."
        )
```

### Usage Tracking Pattern
```python
# After every AI API call
async def _track_api_usage(
    db, 
    endpoint: str, 
    model: str, 
    tokens_used: int, 
    estimated_cost: float, 
    success: bool,
    error_message: str = None
):
    """Track API usage for cost monitoring and analytics"""
    await db.execute(
        """
        INSERT INTO api_usage 
        (endpoint, model, tokens_used, cost, success, error_message, created_at)
        VALUES ($1, $2, $3, $4, $5, $6, NOW())
        """,
        endpoint, model, tokens_used, estimated_cost, success, error_message
    )
```

### Cost Calculation
```python
def calculate_cost(tokens: int, model: str) -> float:
    """Calculate cost based on OpenAI/Anthropic pricing"""
    pricing = {
        "gpt-4": {
            "input": 0.03 / 1000,   # $0.03 per 1K input tokens
            "output": 0.06 / 1000   # $0.06 per 1K output tokens
        },
        "gpt-4-turbo": {
            "input": 0.01 / 1000,
            "output": 0.03 / 1000
        },
        "claude-3-opus": {
            "input": 0.015 / 1000,
            "output": 0.075 / 1000
        }
    }
    # Simplified: assume 50/50 input/output split
    avg_price = (pricing[model]["input"] + pricing[model]["output"]) / 2
    return tokens * avg_price
```

---

## 13. Configuration Management

### Environment Variables

**REQUIRED (Core System):**
```bash
OPENAI_API_KEY=sk-proj-...        # OpenAI GPT-4 access (REQUIRED)
API_KEY=YourSecurePassword123!    # System authentication (REQUIRED)
DATABASE_URL=postgresql://...     # Default OK for Docker
```

**COST CONTROL (Highly Recommended):**
```bash
MONTHLY_AI_BUDGET=50              # $50/month limit (0=unlimited)
DAILY_API_LIMIT=100               # 100 requests/day (0=unlimited)
```

**FREE OPTIONAL ENHANCEMENTS:**
```bash
ANALYTICS_ENABLED=true            # Analytics dashboard
AB_TESTING_ENABLED=true           # A/B testing
COST_CONTROL_ENABLED=true         # Budget monitoring
ENABLE_WEBHOOKS=true              # Webhook system
```

**PAID OPTIONAL ENHANCEMENTS:**
```bash
REDIS_URL=redis://redis:6379      # Caching (+$10-15/month)
ANTHROPIC_API_KEY=sk-ant-...      # Multi-model (+$0.02-0.05/request)
```

**WEBHOOK URLs (Free, Optional):**
```bash
WEBHOOK_CONTENT_GENERATED_URL=https://hooks.zapier.com/...
WEBHOOK_CONTENT_PUBLISHED_URL=https://hooks.zapier.com/...
WEBHOOK_DAILY_REPORT_URL=https://hooks.zapier.com/...
```

### Configuration Validation
```python
# At startup, validate critical configuration
if not OPENAI_API_KEY:
    logger.error("CRITICAL: OPENAI_API_KEY not set!")
    logger.error("Application will not function properly.")

if API_KEY == "change-this-to-a-secure-key":
    logger.warning("WARNING: Using default API key. Change in production!")

if MONTHLY_AI_BUDGET == 0:
    logger.warning("WARNING: No AI budget limit set. Costs could be unlimited!")
```

---

## 14. Troubleshooting Guide

### Quick Diagnostics

**Step 1: Check Service Status**
```bash
make status
# All services should show "Up" and "healthy"
```

**Step 2: Run Test Suite**
```bash
make test
# Should see ✅ for all tests
# If fails, error messages show which component is broken
```

**Step 3: Check Logs**
```bash
# All services
make logs

# Specific service
docker compose logs -f app
docker compose logs -f web
docker compose logs -f db
```

### Common Issues

**Issue: "Connection refused to app:8080"**
- **Cause:** App service not running or not healthy
- **Fix:** Check `make status`, wait 60 seconds for startup, or `make restart`

**Issue: "Invalid API key"**
- **Cause:** `API_KEY` in `.env` doesn't match `X-API-Key` header
- **Fix:** Check `.env` file, ensure header matches exactly

**Issue: "Budget limit reached"**
- **Cause:** `MONTHLY_AI_BUDGET` exceeded
- **Fix:** Increase `MONTHLY_AI_BUDGET` in `.env` or wait until next month

**Issue: Tests failing**
- **Cause:** Services not running or configuration mismatch
- **Fix:** Ensure `make status` shows all healthy, check `API_KEY` in `test_api.py`

**Issue: Database errors**
- **Cause:** Database not initialized or corrupted
- **Fix:** `make restart`, check `docker compose logs db`

**Issue: Frontend not loading**
- **Cause:** Web service not running or NGINX misconfigured
- **Fix:** Check `docker compose logs web`, verify `nginx.conf`

---

## 15. Documentation Requirements

### When to Update Documentation

**ALWAYS update when:**
- Adding new environment variable → Update `.env.example`
- Adding new endpoint → Update `docs_API_GUIDE.md`
- Adding new feature → Update `README.md` and `FEATURE_TEMPLATE.md`
- Changing workflow → Update `DEVELOPER_GUIDE.md`
- Fixing bug → Add entry to `FIXES_APPLIED.md`
- Changing schema → Update relevant documentation

### Documentation Standards
- **Target audience:** Non-technical entrepreneurs
- **Reading level:** 8th grade (simple language)
- **Format:** Markdown with clear headers, examples
- **Length:** As long as needed for clarity

### Key Documentation Files
| File | Purpose |
|------|---------|
| `README.md` | User-facing guide, setup instructions |
| `DEVELOPER_GUIDE.md` | Developer workflows and patterns |
| `PROJECT_SPECIFICATION.md` | Complete project specification |
| `FEATURE_TEMPLATE.md` | Template for adding features |
| `TROUBLESHOOTING.md` | Problem-solving reference |
| `docs_API_GUIDE.md` | API endpoint reference |
| `.env.example` | Configuration template with descriptions |
| `.github/copilot-instructions.md` | This file - AI agent reference |

---

## 16. Quick Reference Card

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
  make logs              View all logs

DATABASE:
  make db-shell          PostgreSQL prompt
  make backup            Backup to ./backups/
  make restore file=X    Restore from backup

PORTS:
  3000  Public entry (NGINX + React) - http://localhost:3000
  8080  Backend API (internal only) - http://app:8080
  5432  PostgreSQL (internal)

KEY FILES:
  main.py                Entire backend (3,908 lines)
  web/src/App.tsx        Frontend router
  docker-compose.yml     Service orchestration
  .env.example           Config template
  test_api.py            API tests

MANDATES (Always Follow):
  ✓ Categorize features: CORE | FREE OPTIONAL | PAID OPTIONAL
  ✓ Gate with environment variables + safe defaults
  ✓ Log startup status for all features
  ✓ Protect endpoints with verify_api_key
  ✓ Track AI usage with _track_api_usage
  ✓ Test before commit (make test)
  ✓ Keep logic in main.py (monolithic pattern)
  ✓ Use parameterized SQL queries (prevent injection)
  ✓ Never log secrets/API keys
  ✓ Add indices for time-series tables

FEATURE PATTERN:
  1. Add env var with default (disabled)
  2. Log status at startup
  3. Implement with feature toggle (HTTP 501 if disabled)
  4. Add test (disabled + enabled cases)
  5. Document in .env.example

DOCUMENTATION:
  http://localhost:3000/api/docs  Interactive API docs (Swagger)
  README.md                       User guide
  DEVELOPER_GUIDE.md              Developer workflows
  TROUBLESHOOTING.md              Problem solving

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

**END OF COMPREHENSIVE COPILOT INSTRUCTIONS**  
**Version:** 2.1.1  
**Maintained by:** SPLANTS Development Team  
**Last Updated:** 2025-11-13

For full details on specific topics:
- **Complete Project Spec:** See `PROJECT_SPECIFICATION.md`
- **User Documentation:** See `README.md`
- **Developer Workflows:** See `DEVELOPER_GUIDE.md`
- **API Reference:** See `docs_API_GUIDE.md` or http://localhost:3000/api/docs
- **Troubleshooting:** See `TROUBLESHOOTING.md`
