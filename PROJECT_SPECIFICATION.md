# SPLANTS Marketing Engine - Complete Project Specification

## Exhaustive Step-by-Step Guide for Building the Entire Project

**Version:** 2.1.1  
**Document Type:** Master Implementation Specification  
**Purpose:** Complete blueprint for building SPLANTS from scratch  
**Scope:** Goals, mandates, quality controls, depth parameters, explanations  
**Audience:** Developers, architects, project managers implementing SPLANTS  

**⚠️ IMPORTANT:** This document does NOT contain actual scripts. It provides the comprehensive specification, requirements, and step-by-step instructions for writing all project components.

---

## Document Structure

This specification is organized into these major sections:

1. **Project Vision & Architecture** - Core philosophy, principles, system design
2. **Component Specifications** - Detailed requirements for each module
3. **Implementation Roadmap** - Step-by-step build sequence
4. **Quality Standards & Controls** - Testing, validation, security requirements
5. **Documentation Requirements** - All documentation that must be created
6. **Deployment & Operations** - Production readiness criteria

**Total Specification Length:** 3,000+ lines of requirements, mandates, and instructions

---

# SECTION 1: PROJECT VISION & ARCHITECTURE

## 1.1 Core Vision Statement

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
2. **Monolithic Intentionality** - Single `main.py` file for simplicity and maintainability
3. **AI-First Architecture** - Leverage GPT-4 for 80% of marketing tasks
4. **Data-Driven** - Built-in analytics, A/B testing, quality scoring
5. **Bootstrap-Friendly** - Designed for solo entrepreneurs with limited budget

---

## 1.2 Architectural Principles

### Principle 1: Simplicity Over Cleverness

**Mandate:** Every architectural decision must favor simplicity and maintainability over clever solutions.

**Implementation Requirements:**
- **Monolithic Backend:** Single `main.py` file containing all backend logic (3,900 lines)
  - Reason: Easier to understand, deploy, and debug for small teams
  - Trade-off: Accepted complexity in one file vs. microservice overhead
  
- **Clear Section Markers:** Use ASCII art headers to delineate sections
  ```python
  # ============================================
  # SECTION NAME
  # ============================================
  ```
  
- **Minimal Dependencies:** Keep `requirements.txt` under 15 packages
  - Core only: FastAPI, OpenAI, Anthropic, PostgreSQL, basic utilities
  - Optional dependencies commented out with instructions

**Quality Control:**
- Code review checklist: "Could a junior developer understand this in 6 months?"
- Reject PRs that add complexity without clear 10x benefit
- Maximum cyclomatic complexity: 10 per function

### Principle 2: Core + Optional Enhancement Pattern

**Mandate:** Separate functionality into CORE, FREE OPTIONAL, and PAID OPTIONAL categories. Users choose what they enable.

**Implementation Requirements:**

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
Each optional feature must:
1. Have an environment variable toggle: `FEATURE_ENABLED=true/false`
2. Include startup logging: `logger.info("✅/❌ Feature: Enabled/Disabled")`
3. Have safe defaults (disabled unless explicitly enabled)
4. Include in-code comments: `# FREE OPTIONAL ENHANCEMENT: Feature Name`
5. Gracefully degrade if dependencies missing

**Example Pattern:**
```python
# FREE OPTIONAL ENHANCEMENT: Analytics Dashboard
ANALYTICS_ENABLED = os.getenv("ANALYTICS_ENABLED", "false").lower() == "true"

@app.post("/api/analytics/track")
async def track_event(event: AnalyticsEvent):
    if not ANALYTICS_ENABLED:
        raise HTTPException(
            status_code=501,
            detail="Analytics is disabled. Set ANALYTICS_ENABLED=true to enable."
        )
    # Implementation here
```

**Quality Control:**
- Every new feature must be categorized during design review
- Default configuration must work with CORE features only
- Documentation must explain cost impact of each optional feature

### Principle 3: Data-Driven Decision Making

**Mandate:** Build measurement, testing, and optimization capabilities into the core system.

**Implementation Requirements:**

**Built-In Analytics:**
- Track every API call: content type, platform, tokens used, cost, quality score
- Store in `analytics_events` table with timestamps
- Provide aggregation endpoints: daily, weekly, monthly views
- Calculate ROI: content performance vs. cost

**A/B Testing Framework:**
- Store content variations in `ab_tests` table
- Track performance metrics per variation
- Auto-select winning variations after statistical significance
- Provide comparison reports

**Quality Scoring:**
- Every generated content piece gets 0-1 quality score
- Factors: coherence, relevance, SEO optimization, length appropriateness
- Store scores in `generated_content` table
- Alert if average score drops below 0.70 threshold

**Cost Tracking:**
- Log every AI API call to `api_usage` table with cost
- Real-time budget monitoring against `MONTHLY_AI_BUDGET`
- Warn at 80%, block at 100%
- Monthly cost reports and projections

**Quality Control:**
- All endpoints that generate content must log to analytics
- Monthly review of average quality scores (must maintain 0.85+)
- Quarterly review of cost trends and optimization opportunities

### Principle 4: Non-Technical User Accessibility

**Mandate:** A solo entrepreneur with basic computer skills must be able to install, configure, and use SPLANTS without developer help.

**Implementation Requirements:**

**Installation Simplification:**
- Interactive setup wizard: `make start` prompts for all required values
- Automatic Docker container management
- Pre-flight system checks: `scripts_check-system.sh`
- Post-install verification: `scripts_verify-installation.sh`
- Maximum setup time: 15 minutes for experienced users, 60 minutes for beginners

**Configuration:**
- Single `.env` file for all settings
- `env.example` with comments explaining every variable
- Required vs. optional settings clearly marked
- Validation on startup with helpful error messages

**Web UI:**
- Accessible at `http://localhost:3000` (not technical port like 8080)
- Forms with clear labels and tooltips
- Error messages in plain English ("Your API key is invalid" not "Error 401: Unauthorized")
- Example content provided for all fields
- Responsive design (works on mobile)

**Documentation:**
- README.md at 8th-grade reading level
- Screenshots for visual learners
- Glossary defining all technical terms
- Step-by-step guides with expected output shown
- FAQ addressing 100+ questions

**Quality Control:**
- User testing with non-technical individuals before each release
- Documentation review by non-developer
- Error messages tested for clarity
- Installation success rate target: 95% on first attempt

### Principle 5: Security by Default

**Mandate:** System must be secure out-of-the-box without requiring users to make security decisions.

**Implementation Requirements:**

**API Security:**
- All endpoints (except health checks) require API key authentication
- API keys never logged or exposed in errors
- Rate limiting on all endpoints (10 req/min for generation, 100 req/min for reads)
- SQL injection prevention via parameterized queries only
- No eval(), exec(), or dynamic code execution

**Database Security:**
- PostgreSQL with strong password required (validated on setup)
- No default passwords allowed
- Database not exposed to public internet
- Automatic backups every 24 hours
- Encryption at rest (via Docker volume encryption)

**Environment Security:**
- All secrets in `.env` file (never committed to git)
- `.env` in `.gitignore` by default
- Validation that `.env` has appropriate permissions (not world-readable)
- Clear warnings about securing API keys

**CORS Configuration:**
- Default: `allow_origins=["*"]` for development ease
- Production mandate: Must configure specific domains
- Documentation includes production CORS setup
- Health check endpoint warns if wildcard CORS in production

**Quality Control:**
- Security audit checklist before each release
- Dependency scanning for known vulnerabilities (GitHub Dependabot)
- No hardcoded credentials anywhere in codebase
- Penetration testing on major releases

---

## 1.3 System Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        USER LAYER                            │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │  Web Browser │         │  API Client  │                 │
│  │  (React UI)  │         │  (curl/code) │                 │
│  └──────┬───────┘         └──────┬───────┘                 │
│         │                        │                          │
│         └────────────┬───────────┘                          │
│                      │                                      │
└──────────────────────┼──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           NGINX (Web Server - Port 3000)               │ │
│  │  • Serves React static files                          │ │
│  │  • Reverse proxy to FastAPI backend                   │ │
│  └──────────────────┬─────────────────────────────────────┘ │
│                     │                                        │
│                     ▼                                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │        FastAPI Backend (Port 8080 - Internal)          │ │
│  │                                                        │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  CORE SYSTEM                                     │ │ │
│  │  │  • Content Generation Engine                     │ │ │
│  │  │  • SEO Optimization                              │ │ │
│  │  │  • Quality Scoring                               │ │ │
│  │  │  • Multi-Platform Publisher                      │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │                                                        │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  OPTIONAL ENHANCEMENTS                           │ │ │
│  │  │  • Analytics Tracker                             │ │ │
│  │  │  • A/B Testing Engine                            │ │ │
│  │  │  • Cost Control                                  │ │ │
│  │  │  • Webhook System                                │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────┬───────────────────────────────────┘ │
│                       │                                      │
└───────────────────────┼──────────────────────────────────────┘
                        │
        ┌───────────────┼────────────────┐
        │               │                │
        ▼               ▼                ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  PostgreSQL  │  │   OpenAI     │  │   Redis      │
│   Database   │  │   API        │  │  (Optional)  │
│              │  │  (GPT-4)     │  │              │
│  Port 5432   │  │              │  │  Port 6379   │
│  (Internal)  │  │  External    │  │  (Optional)  │
└──────────────┘  └──────────────┘  └──────────────┘
```

### Component Interactions

**Request Flow for Content Generation:**
1. User submits form in Web UI or makes API call
2. NGINX receives request on port 3000
3. NGINX proxies to FastAPI on port 8080 (internal)
4. FastAPI validates API key
5. FastAPI checks if Redis cache has similar request (if enabled)
6. If cache miss, FastAPI calls OpenAI GPT-4 API
7. Response processed: SEO optimization, quality scoring
8. Content saved to PostgreSQL
9. Analytics event logged
10. Response returned to user
11. A/B test recorded (if enabled)

**Data Flow:**
- **Inbound:** User requests → API → AI provider → Database
- **Outbound:** Database → API → User
- **Background:** Scheduled jobs → Analytics aggregation → Database
- **Webhooks:** Event triggers → Webhook calls → External systems

### Technology Stack Mandates

**Backend:**
- **Language:** Python 3.11+ (for timezone.utc support)
- **Framework:** FastAPI 0.115.5+ (security fixes)
- **AI:** OpenAI 1.57.2+, optional Anthropic 0.42.0+
- **Database:** PostgreSQL 15+
- **Caching:** Redis 5.2.1+ (optional)
- **ASGI Server:** Uvicorn 0.32.1+

**Frontend:**
- **Framework:** React 18+
- **Build Tool:** Vite
- **UI Library:** shadcn/ui + Tailwind CSS
- **Icons:** Phosphor Icons
- **State Management:** React hooks (no Redux unless needed)

**Infrastructure:**
- **Containerization:** Docker + Docker Compose
- **Orchestration:** Docker Compose v2+
- **Web Server:** NGINX (for production)
- **Reverse Proxy:** NGINX → FastAPI

**Development Tools:**
- **Version Control:** Git
- **Package Management:** pip (Python), npm (JavaScript)
- **Testing:** pytest (backend), Jest (frontend)
- **Linting:** flake8 (Python), ESLint (JavaScript)

---

## 1.4 Project File Structure

### Mandated Directory Layout

```
SPLANTS/
├── .github/
│   ├── copilot-instructions.md          # GitHub Copilot workspace instructions
│   └── workflows/
│       └── feature-check.yml            # CI/CD pipeline
│
├── logs/                                # Auto-created, gitignored
│   └── app.log                          # Application logs
│
├── web/                                 # Frontend application
│   ├── src/
│   │   ├── components/
│   │   │   ├── pages/                   # Page components
│   │   │   │   ├── DashboardPage.tsx
│   │   │   │   ├── GeneratePage.tsx
│   │   │   │   ├── LibraryPage.tsx
│   │   │   │   ├── AnalyticsPage.tsx
│   │   │   │   └── SettingsPage.tsx
│   │   │   └── ui/                      # Reusable UI components (shadcn)
│   │   ├── App.tsx                      # Main application router
│   │   └── main.tsx                     # Entry point
│   ├── public/                          # Static assets
│   ├── package.json                     # Dependencies
│   ├── vite.config.ts                   # Build configuration
│   ├── Dockerfile                       # Frontend container
│   └── nginx.conf                       # Production web server config
│
├── scripts/                             # Utility scripts (prefixed)
│   ├── scripts_backup.sh                # Database backup
│   ├── scripts_restore.sh               # Database restore
│   ├── scripts_check-system.sh          # Pre-install system check
│   ├── scripts_verify-installation.sh   # Post-install verification
│   └── scripts_quick-start.sh           # Interactive setup wizard
│
├── Documentation Files (Root Level):
│   ├── README.md                        # Primary documentation (1,700+ lines)
│   ├── BUSINESS_STARTUP_GUIDE.md        # Entrepreneur roadmap (1,750+ lines)
│   ├── SETUP_GUIDE.md                   # Installation guide (1,300+ lines)
│   ├── TROUBLESHOOTING.md               # Problem solving (1,400+ lines)
│   ├── FAQ.md                           # 100+ Q&A (1,400+ lines)
│   ├── DOCUMENTATION_INDEX.md           # Documentation navigation (500+ lines)
│   ├── DEVELOPER_GUIDE.md               # Development practices (600+ lines)
│   ├── WORKFLOW_AUTOMATION.md           # Automation patterns (800+ lines)
│   ├── QUICK_REFERENCE.md               # Quick lookup (300+ lines)
│   ├── QUICKSTART_WINDOWS.md            # Windows-specific (400+ lines)
│   ├── docs_API_GUIDE.md                # API reference (300+ lines)
│   ├── docs_DEPLOYMENT.md               # Production deployment (350+ lines)
│   ├── FEATURE_TEMPLATE.md              # Template for new features
│   ├── IMPROVEMENT_INSTRUCTIONS.md      # Enhancement guide (1,800+ lines)
│   ├── FIXES_APPLIED.md                 # Bug fix log
│   ├── CHANGELOG.md                     # Version history
│   ├── UPDATE_GUIDE_v2.1.1.md          # Update instructions
│   ├── VERIFICATION_SCRIPTS_REFERENCE.md # Script documentation
│   ├── PROJECT_SPECIFICATION.md         # This document
│   └── IMPLEMENTATION_SUMMARY.md        # Recent work summary
│
├── Configuration Files (Root Level):
│   ├── main.py                          # Monolithic backend (3,900 lines)
│   ├── test_api.py                      # API integration tests
│   ├── requirements.txt                 # Python dependencies
│   ├── env.example                      # Environment variable template
│   ├── .env                             # Actual environment (gitignored)
│   ├── docker-compose.yml               # Service orchestration
│   ├── Dockerfile                       # Backend container
│   ├── Makefile                         # Development commands
│   ├── .gitignore                       # Git exclusions
│   └── fix_markdown.py                  # Documentation formatter
│
└── .git/                                # Version control (not committed)
```

### File Organization Mandates

**Root Level Rules:**
- All documentation (`.md` files) at root for easy discovery
- All configuration files at root
- Backend code in `main.py` and supporting Python files at root
- Frontend code in `web/` subdirectory
- Scripts prefixed with `scripts_` for identification

**Naming Conventions:**
- Documentation: `UPPER_CASE.md` for main docs, `docs_lowercase.md` for technical API docs
- Scripts: `scripts_verb-noun.sh` pattern
- Python: `lowercase_snake_case.py`
- JavaScript/TypeScript: `PascalCase.tsx` for components, `camelCase.ts` for utilities

**Maximum File Sizes:**
- Python files: 5,000 lines max (except main.py which is intentionally monolithic)
- Documentation files: 2,000 lines max per file (split into logical sections)
- Component files: 500 lines max (refactor into sub-components)

**Quality Control:**
- New files must follow naming conventions
- File must have clear purpose (document at top)
- Before adding new file, consider if content belongs in existing file
- Unused files must be deleted (no "just in case" files)

---

## 1.5 Version Control Strategy

### Branch Strategy

**Main Branches:**
- `main` - Production-ready code only
- `develop` - Integration branch for features (if team grows)

**Feature Branches:**
- Pattern: `feature/description` or `copilot/description`
- Short-lived (merged within 1-2 days)
- One feature per branch
- Delete after merge

**Special Branches:**
- `hotfix/description` - Critical production fixes
- `release/v2.x.x` - Release preparation

### Commit Message Standards

**Format:**
```
<type>: <short summary>

<optional longer description>

<optional footer with breaking changes or issue references>
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `test:` Adding/updating tests
- `chore:` Maintenance tasks
- `security:` Security improvements

**Examples:**
```
feat: Add A/B testing framework for content variations

- Implemented ab_tests table for tracking variations
- Added API endpoints for creating and comparing tests
- Integrated with analytics for performance tracking

Closes #42
```

```
fix: Correct Pydantic v2 validator syntax

Changed @validator to @field_validator with @classmethod decorator
for compatibility with Pydantic 2.10.3

Fixes #15
```

**Commit Frequency:**
- Commit after each logical unit of work
- Minimum: Daily commits during active development
- Maximum: 500 lines changed per commit (split larger changes)

### Pull Request Process

**PR Creation:**
1. Create feature branch from `main`
2. Implement changes with tests
3. Update documentation
4. Run all tests and linters
5. Create PR with template
6. Request review (if team)
7. Address feedback
8. Merge when approved and CI passes

**PR Template Requirements:**
```markdown
## Changes
- List of changes made

## Testing
- How changes were tested

## Documentation
- Documentation updated: Yes/No

## Breaking Changes
- Any breaking changes: None/List them

## Checklist
- [ ] Tests passing
- [ ] Documentation updated
- [ ] No security issues
- [ ] Follows coding standards
```

**Merge Strategy:**
- Squash and merge for feature branches
- Preserve history for important milestones
- Delete branch after merge

---

# SECTION 2: COMPONENT SPECIFICATIONS

## 2.1 Backend API Specification (`main.py`)

### Overall Structure Mandate

**File Size:** 3,900 lines (intentionally monolithic)
**Organization:** Clear section markers with ASCII art headers
**Pattern:** All functionality in single file for simplicity

### Required Sections (In Order)

```python
# Section 1: File Header & Documentation (Lines 1-27)
# Section 2: Imports (Lines 28-50)
# Section 3: Logging Configuration (Lines 51-73)
# Section 4: Application Initialization (Lines 74-130)
# Section 5: Configuration & Environment Variables (Lines 131-250)
# Section 6: Database Connection (Lines 251-300)
# Section 7: Pydantic Models (Lines 301-600)
# Section 8: Authentication & Security (Lines 601-700)
# Section 9: Core Content Generation (Lines 701-1500)
# Section 10: Analytics & Tracking (Lines 1501-1800)
# Section 11: A/B Testing (Lines 1801-2000)
# Section 12: Webhooks (Lines 2001-2200)
# Section 13: Optional Enhancements (Lines 2201-2800)
# Section 14: API Endpoints (Lines 2801-3700)
# Section 15: Startup & Shutdown (Lines 3701-3900)
```

### Detailed Component Requirements

#### 2.1.1 Configuration & Environment Variables

**Location:** Lines 131-250

**Mandate:** All configuration via environment variables with safe defaults.

**Required Environment Variables:**

```python
# CORE REQUIRED (No defaults - must be set)
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")  # Required
API_KEY = os.getenv("API_KEY")  # Required for API authentication
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")  # Required

# CORE OPTIONAL (Safe defaults provided)
POSTGRES_USER = os.getenv("POSTGRES_USER", "splants")
POSTGRES_DB = os.getenv("POSTGRES_DB", "splants_db")
POSTGRES_HOST = os.getenv("POSTGRES_HOST", "db")
POSTGRES_PORT = os.getenv("POSTGRES_PORT", "5432")

# FREE OPTIONAL ENHANCEMENTS (Default: disabled)
MONTHLY_AI_BUDGET = float(os.getenv("MONTHLY_AI_BUDGET", "0"))  # 0 = unlimited
ANALYTICS_ENABLED = os.getenv("ANALYTICS_ENABLED", "false").lower() == "true"
AB_TESTING_ENABLED = os.getenv("AB_TESTING_ENABLED", "false").lower() == "true"
COST_CONTROL_ENABLED = os.getenv("COST_CONTROL_ENABLED", "false").lower() == "true"
ENABLE_WEBHOOKS = os.getenv("ENABLE_WEBHOOKS", "false").lower() == "true"

# PAID OPTIONAL ENHANCEMENTS (Default: disabled)
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")
REDIS_URL = os.getenv("REDIS_URL", "")

# WEBHOOK URLs (Optional)
WEBHOOK_CONTENT_GENERATED_URL = os.getenv("WEBHOOK_CONTENT_GENERATED_URL", "")
WEBHOOK_CONTENT_PUBLISHED_URL = os.getenv("WEBHOOK_CONTENT_PUBLISHED_URL", "")
WEBHOOK_DAILY_REPORT_URL = os.getenv("WEBHOOK_DAILY_REPORT_URL", "")
```

**Validation Requirements:**
- Check required variables on startup
- Raise clear error if missing: "OPENAI_API_KEY environment variable is required"
- Validate format (API keys start with expected prefix)
- Warn if optional features enabled without dependencies

**Quality Control:**
- Every new environment variable must be documented in `env.example`
- Must have safe default or clear error message
- Test with missing variables to ensure helpful errors

#### 2.1.2 Database Schema

**Mandate:** PostgreSQL database with 6 core tables, extensible for optional features.

**Table 1: `generated_content`**
```sql
CREATE TABLE generated_content (
    id SERIAL PRIMARY KEY,
    content_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    content_type VARCHAR(50) NOT NULL,  -- blog_post, social_media, email, etc.
    platform VARCHAR(50) NOT NULL,      -- instagram, facebook, blog, etc.
    topic TEXT NOT NULL,
    generated_content TEXT NOT NULL,
    quality_score FLOAT,
    seo_keywords TEXT[],
    tone VARCHAR(50),
    target_length VARCHAR(20),
    word_count INTEGER,
    estimated_reading_time VARCHAR(20),
    ai_model VARCHAR(50) DEFAULT 'gpt-4',
    cost DECIMAL(10, 4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_content_created_at ON generated_content(created_at DESC);
CREATE INDEX idx_content_type ON generated_content(content_type);
CREATE INDEX idx_content_platform ON generated_content(platform);
```

**Mandates:**
- `content_id` must be UUID for external references
- `quality_score` range: 0.0-1.0
- `created_at` indexed for fast recent queries
- `seo_keywords` stored as array for easy searching
- `cost` in dollars, 4 decimal places

**Table 2: `api_usage`**
```sql
CREATE TABLE api_usage (
    id SERIAL PRIMARY KEY,
    request_type VARCHAR(50) NOT NULL,  -- content_generation, optimization, etc.
    ai_provider VARCHAR(50) NOT NULL,   -- openai, anthropic
    model VARCHAR(50) NOT NULL,         -- gpt-4, claude-3, etc.
    tokens_used INTEGER,
    cost DECIMAL(10, 4),
    response_time_ms INTEGER,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_api_usage_created_at ON api_usage(created_at DESC);
CREATE INDEX idx_api_usage_provider ON api_usage(ai_provider);
```

**Mandates:**
- Track every AI API call for cost monitoring
- Store response time for performance analysis
- Log errors for debugging
- Index by date for monthly reports

**Table 3: `analytics_events`**
```sql
CREATE TABLE analytics_events (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,    -- content_generated, content_published, etc.
    content_id UUID REFERENCES generated_content(content_id),
    platform VARCHAR(50),
    metadata JSONB,                     -- Flexible storage for event-specific data
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_analytics_created_at ON analytics_events(created_at DESC);
CREATE INDEX idx_analytics_event_type ON analytics_events(event_type);
```

**Mandates:**
- Track user actions and content performance
- JSONB for flexible metadata storage
- Link to content via content_id
- Fast queries by event type

**Table 4: `ab_tests`**
```sql
CREATE TABLE ab_tests (
    id SERIAL PRIMARY KEY,
    test_name VARCHAR(200) NOT NULL,
    variant_a_id UUID REFERENCES generated_content(content_id),
    variant_b_id UUID REFERENCES generated_content(content_id),
    variant_a_metrics JSONB DEFAULT '{}',
    variant_b_metrics JSONB DEFAULT '{}',
    winner VARCHAR(10),                 -- 'A', 'B', or null if ongoing
    status VARCHAR(20) DEFAULT 'active', -- active, completed, archived
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_ab_tests_status ON ab_tests(status);
```

**Mandates:**
- Track A/B test variations
- Store metrics as JSONB for flexibility
- Declare winner when statistical significance reached
- Archive completed tests

**Table 5: `webhook_logs`**
```sql
CREATE TABLE webhook_logs (
    id SERIAL PRIMARY KEY,
    webhook_url TEXT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    payload JSONB NOT NULL,
    response_status INTEGER,
    response_body TEXT,
    attempt_number INTEGER DEFAULT 1,
    success BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_webhook_logs_created_at ON webhook_logs(created_at DESC);
CREATE INDEX idx_webhook_logs_success ON webhook_logs(success);
```

**Mandates:**
- Log all webhook deliveries
- Store full payload for debugging
- Track retry attempts (max 3)
- Monitor success rate

**Table 6: `content_templates`**
```sql
CREATE TABLE content_templates (
    id SERIAL PRIMARY KEY,
    template_name VARCHAR(200) NOT NULL,
    content_type VARCHAR(50) NOT NULL,
    template_structure JSONB NOT NULL,
    usage_count INTEGER DEFAULT 0,
    average_quality_score FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_templates_content_type ON content_templates(content_type);
```

**Mandates:**
- Store proven content structures
- Track usage and effectiveness
- JSONB for flexible structure storage

**Database Initialization:**
- All tables created on first startup
- Idempotent creation (CREATE IF NOT EXISTS pattern)
- Migrations tracked in code comments
- No external migration tools (keep simple)

**Quality Control:**
- All tables must have primary key
- Time-series tables must have created_at index
- Foreign keys for referential integrity
- No nullable columns without default or good reason

#### 2.1.3 Pydantic Models

**Location:** Lines 301-600

**Mandate:** Type-safe request/response models using Pydantic v2 syntax.

**Model Pattern:**
```python
class ModelName(BaseModel):
    """Clear description of model purpose."""
    
    model_config = ConfigDict(str_strip_whitespace=True)
    
    field_name: Type = Field(
        ...,  # or default value
        description="Clear field description",
        examples=["example value"]
    )
    
    @field_validator('field_name')
    @classmethod
    def validate_field_name(cls, v):
        # Validation logic
        return v
```

**Required Models:**

**1. ContentRequest**
```python
class ContentRequest(BaseModel):
    """Request model for content generation."""
    
    content_type: Literal[
        "blog_post", "social_media", "email", "ad_copy",
        "product_description", "newsletter", "press_release"
    ]
    topic: str = Field(..., min_length=10, max_length=500)
    platform: Literal[
        "instagram", "facebook", "twitter", "linkedin",
        "pinterest", "tiktok", "blog", "email", "website"
    ]
    tone: Literal[
        "professional", "casual", "friendly", "persuasive",
        "inspirational", "educational", "humorous", "formal"
    ] = "professional"
    keywords: List[str] = Field(default_factory=list, max_length=20)
    target_length: Literal["short", "medium", "long"] = "medium"
    
    @field_validator('keywords')
    @classmethod
    def validate_keywords(cls, v):
        if len(v) > 20:
            raise ValueError("Maximum 20 keywords allowed")
        return [k.strip() for k in v if k.strip()]
```

**2. ContentResponse**
```python
class ContentResponse(BaseModel):
    """Response model for generated content."""
    
    content_id: str
    content: str
    quality_score: float
    seo_keywords: List[str]
    word_count: int
    estimated_reading_time: str
    platform_optimized: bool
    cost: float
    generated_at: str
    
    model_config = ConfigDict(from_attributes=True)
```

**3. AnalyticsEvent**
```python
class AnalyticsEvent(BaseModel):
    """Analytics event tracking model."""
    
    event_type: str = Field(..., pattern="^[a-z_]+$")
    content_id: Optional[str] = None
    platform: Optional[str] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)
```

**4. ABTestCreate**
```python
class ABTestCreate(BaseModel):
    """Create A/B test model."""
    
    test_name: str = Field(..., min_length=5, max_length=200)
    content_request: ContentRequest
    variation_count: int = Field(default=2, ge=2, le=5)
```

**Validation Requirements:**
- All string fields: strip whitespace
- Length limits on all text inputs
- Enums for fixed option sets
- Clear error messages on validation failure
- Examples for all fields

**Quality Control:**
- Every API endpoint must have request/response models
- No raw dictionaries in API contracts
- Validators for business logic (not just type checking)
- Test validation errors to ensure clarity

#### 2.1.4 Content Generation Engine

**Location:** Lines 701-1500

**Mandate:** Core AI content generation with quality scoring and optimization.

**Architecture:**
```
User Request
    ↓
Validate Input (Pydantic)
    ↓
Check Budget (if Cost Control enabled)
    ↓
Check Cache (if Redis enabled)
    ↓
Build AI Prompt
    ↓
Call OpenAI/Anthropic API
    ↓
Parse Response
    ↓
Calculate Quality Score
    ↓
Apply SEO Optimization
    ↓
Platform-Specific Formatting
    ↓
Save to Database
    ↓
Track Analytics (if enabled)
    ↓
Return Response
```

**Prompt Engineering Requirements:**

**System Prompt Template:**
```python
SYSTEM_PROMPT = """
You are an expert marketing content writer for SPLANTS, a custom paint-splatter pants brand.

Brand Voice: {brand_voice}
Target Audience: Art lovers, fashion-forward individuals aged 18-35
Brand Values: Creativity, sustainability, self-expression, unique fashion

Your task: Create {content_type} content for {platform} platform.

Requirements:
- Tone: {tone}
- Length: {target_length} ({word_count_range} words)
- Include these keywords naturally: {keywords}
- Platform best practices for {platform}
- SEO optimized
- Engaging and actionable

Brand Information:
- Product: Custom paint-splatter pants inspired by Jackson Pollock
- Each pair is unique, handcrafted wearable art
- Price range: $80-150
- Sustainable, made-to-order production
- Ships worldwide

Format: Return only the content, no meta-commentary.
"""
```

**User Prompt Template:**
```python
USER_PROMPT = """
Topic: {topic}

Additional Context:
{additional_context}

Create engaging {content_type} content that:
1. Captures attention in the first sentence
2. Naturally incorporates keywords: {keywords}
3. Includes a clear call-to-action
4. Optimized for {platform} platform
5. Matches {tone} tone
6. Target length: {target_length}

Remember to make it specific to SPLANTS custom pants and our brand values.
"""
```

**Quality Scoring Algorithm:**

```python
def calculate_quality_score(content: str, keywords: List[str], target_length: str) -> float:
    """
    Calculate 0-1 quality score for generated content.
    
    Factors:
    - Length appropriateness (25%)
    - Keyword inclusion (25%)
    - Readability (25%)
    - Structure (25%)
    """
    score = 0.0
    
    # Factor 1: Length (25%)
    word_count = len(content.split())
    length_ranges = {
        "short": (100, 300),
        "medium": (300, 700),
        "long": (700, 1500)
    }
    target_range = length_ranges.get(target_length, (300, 700))
    
    if target_range[0] <= word_count <= target_range[1]:
        length_score = 1.0
    elif word_count < target_range[0]:
        length_score = word_count / target_range[0]
    else:
        length_score = target_range[1] / word_count
    
    score += length_score * 0.25
    
    # Factor 2: Keyword inclusion (25%)
    if keywords:
        content_lower = content.lower()
        keywords_found = sum(1 for kw in keywords if kw.lower() in content_lower)
        keyword_score = keywords_found / len(keywords)
        score += keyword_score * 0.25
    else:
        score += 0.25  # Full points if no keywords specified
    
    # Factor 3: Readability (25%)
    # Simple heuristic: average sentence length
    sentences = re.split(r'[.!?]+', content)
    sentences = [s for s in sentences if s.strip()]
    
    if sentences:
        avg_words_per_sentence = word_count / len(sentences)
        # Ideal: 15-20 words per sentence
        if 15 <= avg_words_per_sentence <= 20:
            readability_score = 1.0
        elif avg_words_per_sentence < 15:
            readability_score = avg_words_per_sentence / 15
        else:
            readability_score = 20 / avg_words_per_sentence
        
        score += readability_score * 0.25
    
    # Factor 4: Structure (25%)
    # Check for paragraphs, headers, clear sections
    paragraphs = content.split('\n\n')
    has_multiple_paragraphs = len(paragraphs) >= 2
    has_headers = bool(re.search(r'^#{1,3}\s+', content, re.MULTILINE))
    has_bullets = bool(re.search(r'^\s*[-*•]\s+', content, re.MULTILINE))
    
    structure_score = sum([
        0.4 if has_multiple_paragraphs else 0.2,
        0.3 if has_headers else 0,
        0.3 if has_bullets else 0
    ])
    
    score += structure_score * 0.25
    
    # Ensure final score is 0-1
    return max(0.0, min(1.0, score))
```

**SEO Optimization:**

```python
def optimize_for_seo(content: str, keywords: List[str]) -> Dict[str, Any]:
    """
    Apply SEO optimization to content.
    
    Returns:
    - optimized_content: Content with SEO improvements
    - meta_description: Generated meta description
    - seo_keywords: Extracted SEO keywords
    - seo_score: 0-1 SEO quality score
    """
    # Extract keywords from content
    word_freq = defaultdict(int)
    words = re.findall(r'\b[a-z]{4,}\b', content.lower())
    for word in words:
        if word not in STOP_WORDS:
            word_freq[word] += 1
    
    # Get top keywords
    top_keywords = sorted(word_freq.items(), key=lambda x: x[1], reverse=True)[:10]
    extracted_keywords = [kw for kw, freq in top_keywords]
    
    # Combine with provided keywords
    all_keywords = list(set(keywords + extracted_keywords))
    
    # Generate meta description (first 155 characters with keyword)
    first_paragraph = content.split('\n\n')[0] if '\n\n' in content else content[:300]
    meta_description = first_paragraph[:155].strip()
    if len(meta_description) < 155 and keywords:
        meta_description += f" {keywords[0]}"
    meta_description = meta_description[:155]
    
    # Calculate SEO score
    seo_score = calculate_seo_score(content, keywords)
    
    return {
        "optimized_content": content,
        "meta_description": meta_description,
        "seo_keywords": all_keywords[:10],
        "seo_score": seo_score
    }
```

**Platform-Specific Formatting:**

```python
def format_for_platform(content: str, platform: str) -> str:
    """
    Apply platform-specific formatting rules.
    """
    if platform == "instagram":
        # Instagram: Add line breaks, emojis, hashtags at end
        # Max 2,200 characters
        content = content[:2200]
        if not content.endswith('\n'):
            content += '\n'
        content += '\n.\n.\n.\n'  # Instagram spacing trick
        
    elif platform == "twitter":
        # Twitter: 280 character limit
        content = content[:280]
        
    elif platform == "linkedin":
        # LinkedIn: Professional tone, longer form ok
        # Add strategic line breaks for readability
        pass  # LinkedIn can handle longer content
        
    elif platform == "facebook":
        # Facebook: Optimize for first 3 lines (show more cutoff)
        # Ensure first 3 lines are engaging
        pass
        
    elif platform == "tiktok":
        # TikTok: Very short, under 300 characters
        content = content[:300]
        
    return content
```

**Error Handling Requirements:**
- Catch OpenAI API errors (rate limits, invalid key, etc.)
- Retry logic: 3 attempts with exponential backoff
- Fallback to cached content if API fails
- Log all errors for debugging
- Return helpful error messages to user

**Quality Control:**
- Test with various content types and platforms
- Verify quality scores are reasonable (should average 0.85+)
- Test error scenarios (invalid API key, rate limits)
- Validate SEO optimization improves searchability
- Benchmark generation time (target: under 30 seconds)

#### 2.1.5 API Endpoints

**Location:** Lines 2801-3700

**Mandate:** RESTful API following consistent patterns and conventions.

**Endpoint Pattern:**
```python
@app.{method}("/api/{resource}/{action}")
async def endpoint_name(
    request_model: RequestModel,
    api_key: str = Depends(verify_api_key),
    db: asyncpg.Connection = Depends(get_db)
) -> ResponseModel:
    """
    Clear endpoint description.
    
    Args:
        request_model: Description
        api_key: Authenticated API key
        db: Database connection
    
    Returns:
        ResponseModel: Description
    
    Raises:
        HTTPException: 400 if validation fails
        HTTPException: 401 if unauthorized
        HTTPException: 429 if rate limited
        HTTPException: 500 if server error
    """
    try:
        # Implementation
        pass
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error in endpoint_name: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
```

**Required Endpoints:**

**Content Generation:**
- `POST /api/content/generate` - Generate new content
- `GET /api/content/history` - List generated content
- `GET /api/content/{content_id}` - Get specific content
- `DELETE /api/content/{content_id}` - Delete content
- `POST /api/content/{content_id}/regenerate` - Regenerate with changes

**Analytics:**
- `POST /api/analytics/track` - Track custom event
- `GET /api/analytics/summary` - Get analytics summary
- `GET /api/analytics/content/{content_id}` - Content-specific analytics

**A/B Testing:**
- `POST /api/ab-test/create` - Create A/B test
- `GET /api/ab-test/list` - List all tests
- `GET /api/ab-test/{test_id}` - Get test details
- `POST /api/ab-test/{test_id}/record-result` - Record performance data
- `POST /api/ab-test/{test_id}/declare-winner` - Declare winner

**Templates:**
- `POST /api/templates/create` - Save content as template
- `GET /api/templates/list` - List all templates
- `GET /api/templates/{template_id}` - Get template
- `POST /api/templates/{template_id}/use` - Generate from template

**System:**
- `GET /api/health` - Health check (no auth required)
- `GET /api/status` - System status (auth required)
- `GET /api/usage/costs` - Cost summary
- `GET /api/usage/budget` - Budget status

**Publishing:**
- `POST /api/publish/{platform}` - Publish content to platform
- `GET /api/publish/history` - Publishing history
- `GET /api/publish/scheduled` - Scheduled publications

**Response Format Standards:**
- Success: HTTP 200/201 with JSON body
- Created: HTTP 201 with Location header
- Error: HTTP 4xx/5xx with `{"detail": "Error message"}`
- Lists: Paginated with `page`, `per_page`, `total` metadata
- Timestamps: ISO 8601 format

**Rate Limiting:**
- Content generation: 10 requests/minute per API key
- Read operations: 100 requests/minute per API key
- Implemented via decorator or middleware

**Quality Control:**
- All endpoints have OpenAPI documentation
- Request/response examples in docs
- Integration tests for all endpoints
- Error responses tested
- Rate limiting tested


---

# SECTION 3: IMPLEMENTATION ROADMAP

## 3.1 Phase 1: Foundation (Week 1)

### Day 1-2: Project Setup

**Tasks:**
1. Create Git repository
2. Initialize project structure
3. Set up Docker Compose configuration
4. Create initial `main.py` with FastAPI skeleton
5. Set up PostgreSQL connection
6. Create initial database schema

**Deliverables:**
- Repository with `.gitignore`
- `docker-compose.yml` with db, app, web services
- `main.py` with health check endpoint
- Database tables created
- `requirements.txt` with core dependencies
- `README.md` with basic setup instructions

**Quality Gates:**
- `docker-compose up` starts all services
- Health check endpoint returns 200
- Database connection successful
- Git commit history clear and clean

### Day 3-4: Core Content Generation

**Tasks:**
1. Implement ContentRequest/Response models
2. Build OpenAI integration
3. Implement quality scoring algorithm
4. Create content generation endpoint
5. Add SEO optimization
6. Add platform-specific formatting

**Deliverables:**
- `/api/content/generate` endpoint functional
- Quality scores calculate correctly
- SEO keywords extracted
- Content saved to database
- Basic error handling

**Quality Gates:**
- Generate blog post successfully
- Quality score between 0.7-1.0
- SEO keywords relevant
- Response time under 30 seconds
- Errors return helpful messages

### Day 5: Cost Tracking & Budget Control

**Tasks:**
1. Implement API usage tracking
2. Create cost calculation logic
3. Add budget checking
4. Create cost reporting endpoints
5. Add warning/blocking at budget thresholds

**Deliverables:**
- `api_usage` table populated
- `/api/usage/costs` endpoint
- `/api/usage/budget` endpoint
- Budget control blocks at 100%
- Warnings at 80% and 90%

**Quality Gates:**
- Costs tracked per generation
- Budget calculation accurate
- Blocking works at limit
- Monthly rollover correct

### Day 6-7: Documentation & Testing

**Tasks:**
1. Write comprehensive README.md
2. Create env.example with all variables
3. Write SETUP_GUIDE.md
4. Create test_api.py with integration tests
5. Document all API endpoints
6. Test installation on fresh system

**Deliverables:**
- README.md (500+ lines)
- SETUP_GUIDE.md with screenshots
- env.example documented
- test_api.py with 10+ tests
- API documentation complete
- Installation tested

**Quality Gates:**
- New user can install in 30 minutes
- All tests pass
- Documentation clear
- API docs match implementation

---

## 3.2 Phase 2: Frontend & UX (Week 2)

### Day 8-9: React Application Setup

**Tasks:**
1. Initialize React app with Vite
2. Install shadcn/ui and Tailwind
3. Set up routing with React Router
4. Create basic page components
5. Implement API client
6. Build Docker container for web

**Deliverables:**
- React app scaffolded
- Navigation working
- All pages routable
- API calls to backend
- Docker build successful

**Quality Gates:**
- App builds without errors
- All routes accessible
- API calls successful
- Responsive on mobile

### Day 10-11: Generate & Library Pages

**Tasks:**
1. Build GeneratePage form
2. Implement real-time validation
3. Handle generation loading states
4. Display generated content
5. Build LibraryPage with pagination
6. Add search and filtering

**Deliverables:**
- Full-featured generate form
- Content generation from UI
- Library grid/list view
- Search working
- Filters functional

**Quality Gates:**
- Form validates correctly
- Generation works end-to-end
- Library loads content
- Search returns relevant results

### Day 12-13: Dashboard & Analytics

**Tasks:**
1. Build DashboardPage with cards
2. Fetch and display metrics
3. Create AnalyticsPage
4. Integrate Recharts for visualizations
5. Display cost trends
6. Show quality metrics

**Deliverables:**
- Dashboard with key metrics
- Cost chart
- Quality trend chart
- A/B test results view

**Quality Gates:**
- Metrics update real-time
- Charts render correctly
- Data matches backend
- Responsive layout

### Day 14: Settings & Polish

**Tasks:**
1. Build SettingsPage
2. Implement dark mode
3. Add loading skeletons
4. Improve error messaging
5. Test full user flows
6. Fix bugs and polish UI

**Deliverables:**
- Settings page functional
- Dark mode toggle
- Loading states throughout
- Error boundaries
- Polished UI

**Quality Gates:**
- All user flows work
- No console errors
- Accessible (keyboard nav)
- Mobile responsive

---

## 3.3 Phase 3: Optional Enhancements (Week 3)

### Day 15-16: Analytics System

**Tasks:**
1. Create analytics_events table
2. Implement event tracking
3. Build aggregation queries
4. Create analytics API endpoints
5. Add analytics dashboard components
6. Test event collection

**Deliverables:**
- Analytics events logged
- Summary endpoint functional
- Dashboard displays analytics
- Event types documented

**Quality Gates:**
- Events tracked accurately
- Aggregations performant
- Dashboard updates
- Privacy compliant

### Day 17-18: A/B Testing

**Tasks:**
1. Create ab_tests table
2. Implement test creation
3. Build variation generation
4. Create result tracking
5. Implement winner declaration
6. Add A/B test UI components

**Deliverables:**
- A/B test endpoints
- Test creation functional
- Results tracked
- UI displays tests
- Winner declaration works

**Quality Gates:**
- Tests create correctly
- Variations different
- Metrics tracked
- Statistical significance checked

### Day 19: Webhooks System

**Tasks:**
1. Create webhook_logs table
2. Implement webhook delivery
3. Add retry logic (3 attempts)
4. Create webhook testing UI
5. Document webhook payloads
6. Test with external services

**Deliverables:**
- Webhook delivery functional
- Retry logic works
- Logging complete
- Test endpoint works
- Documentation clear

**Quality Gates:**
- Webhooks deliver reliably
- Retries work correctly
- Payloads well-formed
- Failures logged

### Day 20-21: Templates & Optimization

**Tasks:**
1. Create content_templates table
2. Implement template saving
3. Build template usage
4. Add smart hashtag generation
5. Improve platform optimization
6. Test template effectiveness

**Deliverables:**
- Templates saved/used
- Hashtags generated
- Platform formatting improved
- Template library UI

**Quality Gates:**
- Templates reusable
- Hashtags relevant
- Platform content optimized
- Usage tracked

---

## 3.4 Phase 4: Documentation & Polish (Week 4)

### Day 22-23: Comprehensive Documentation

**Tasks:**
1. Write TROUBLESHOOTING.md
2. Create FAQ.md (100+ Q&A)
3. Write WORKFLOW_AUTOMATION.md
4. Create DEVELOPER_GUIDE.md
5. Write DOCUMENTATION_INDEX.md
6. Create quick reference guides

**Deliverables:**
- 6+ major documentation files
- 5,000+ lines of docs
- All features documented
- Troubleshooting guide complete
- FAQ comprehensive

**Quality Gates:**
- Documentation clear
- Examples work
- Links valid
- No typos

### Day 24-25: Testing & Quality

**Tasks:**
1. Write comprehensive test suite
2. Test all error paths
3. Load testing (100+ requests)
4. Security audit
5. Performance optimization
6. Fix all bugs found

**Deliverables:**
- 50+ tests passing
- Load test results
- Security audit report
- Performance baseline
- Bug fixes

**Quality Gates:**
- 90%+ test coverage
- No critical bugs
- Security approved
- Performance acceptable

### Day 26-27: Deployment & Operations

**Tasks:**
1. Write docs_DEPLOYMENT.md
2. Create production Docker configs
3. Write backup/restore scripts
4. Create monitoring setup
5. Write runbook for operations
6. Test deployment process

**Deliverables:**
- Deployment guide
- Production configs
- Backup scripts
- Monitoring setup
- Operations runbook

**Quality Gates:**
- Deployment works
- Backups functional
- Monitoring active
- Recovery tested

### Day 28: Launch Preparation

**Tasks:**
1. Final testing
2. Documentation review
3. Create CHANGELOG.md
4. Tag v2.0.0 release
5. Create release notes
6. Prepare announcement

**Deliverables:**
- All tests passing
- Docs complete
- Release tagged
- Announcement draft

**Quality Gates:**
- Production ready
- Documentation complete
- Release tagged
- Ready to announce

---

# SECTION 4: QUALITY STANDARDS & CONTROLS

## 4.1 Code Quality Standards

### Python Code Standards

**Style Guide:** PEP 8 with modifications
**Line Length:** 100 characters (not 79)
**Indentation:** 4 spaces
**Quotes:** Double quotes for strings, single for dict keys

**Linting Tools:**
- flake8 for style checking
- mypy for type checking (optional)
- black for auto-formatting (optional)

**Code Quality Metrics:**
- Maximum function length: 50 lines
- Maximum file length: 5,000 lines (except main.py)
- Cyclomatic complexity: Max 10 per function
- Test coverage: Minimum 70% (aim for 90%)

**Naming Conventions:**
```python
# Variables and functions: snake_case
user_name = "John"
def calculate_quality_score():
    pass

# Classes: PascalCase
class ContentRequest:
    pass

# Constants: UPPER_SNAKE_CASE
MAX_RETRIES = 3
OPENAI_API_KEY = "..."

# Private methods: _leading_underscore
def _internal_helper():
    pass
```

**Documentation Standards:**
- Module docstring at file top
- Class docstring explaining purpose
- Function docstring with Args, Returns, Raises
- Complex logic commented inline

**Example:**
```python
def calculate_quality_score(content: str, keywords: List[str]) -> float:
    """
    Calculate 0-1 quality score for generated content.
    
    Score factors:
    - Length appropriateness (25%)
    - Keyword inclusion (25%)
    - Readability (25%)
    - Structure (25%)
    
    Args:
        content: The generated content text
        keywords: List of target keywords
    
    Returns:
        Quality score between 0.0 and 1.0
    
    Raises:
        ValueError: If content is empty
    """
    if not content:
        raise ValueError("Content cannot be empty")
    
    # Implementation...
```

### TypeScript/React Code Standards

**Style Guide:** Airbnb React/TypeScript
**Indentation:** 2 spaces
**Quotes:** Single quotes
**Semicolons:** Required

**Component Pattern:**
```typescript
interface ComponentProps {
  prop1: string;
  prop2?: number;
  onAction: (value: string) => void;
}

export function ComponentName({ prop1, prop2 = 0, onAction }: ComponentProps) {
  const [state, setState] = useState<string>('');
  
  useEffect(() => {
    // Effect logic
  }, [dependency]);
  
  const handleClick = () => {
    onAction(state);
  };
  
  return (
    <div className="container">
      {/* JSX */}
    </div>
  );
}
```

**Naming Conventions:**
- Components: PascalCase
- Files: PascalCase.tsx for components
- Functions: camelCase
- Constants: UPPER_SNAKE_CASE
- CSS classes: kebab-case (Tailwind)

## 4.2 Testing Requirements

### Backend Testing

**Test Types:**
1. Unit tests: Test individual functions
2. Integration tests: Test API endpoints
3. Database tests: Test queries
4. Error path tests: Test failure scenarios

**Testing Framework:** pytest

**Test Structure:**
```python
# test_api.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

class TestContentGeneration:
    def test_generate_blog_post_success(self):
        """Test successful blog post generation."""
        response = client.post("/api/content/generate", json={
            "content_type": "blog_post",
            "topic": "The art of custom paint-splatter pants",
            "platform": "blog",
            "tone": "professional",
            "keywords": ["custom pants", "wearable art"],
            "target_length": "medium"
        }, headers={"X-API-Key": "test_key"})
        
        assert response.status_code == 200
        data = response.json()
        assert "content_id" in data
        assert "content" in data
        assert data["quality_score"] >= 0.7
    
    def test_generate_invalid_content_type(self):
        """Test error handling for invalid content type."""
        response = client.post("/api/content/generate", json={
            "content_type": "invalid_type",
            # ... other fields
        }, headers={"X-API-Key": "test_key"})
        
        assert response.status_code == 422
    
    def test_generate_without_api_key(self):
        """Test authentication requirement."""
        response = client.post("/api/content/generate", json={
            # ... valid payload
        })
        
        assert response.status_code == 401
```

**Test Coverage Requirements:**
- All API endpoints: 100%
- Core logic (content generation, scoring): 90%+
- Utility functions: 80%+
- Overall codebase: 70%+ minimum

**Running Tests:**
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=main --cov-report=html

# Run specific test
pytest test_api.py::TestContentGeneration::test_generate_blog_post_success
```

### Frontend Testing

**Test Types:**
1. Component tests: Test UI components
2. Integration tests: Test user flows
3. API mocking: Test without backend

**Testing Framework:** Jest + React Testing Library

**Example:**
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { GeneratePage } from './GeneratePage';

describe('GeneratePage', () => {
  it('renders form correctly', () => {
    render(<GeneratePage />);
    expect(screen.getByLabelText('Content Type')).toBeInTheDocument();
    expect(screen.getByLabelText('Topic')).toBeInTheDocument();
  });
  
  it('validates required fields', async () => {
    render(<GeneratePage />);
    const submitButton = screen.getByRole('button', { name: 'Generate' });
    
    fireEvent.click(submitButton);
    
    expect(await screen.findByText('Topic is required')).toBeInTheDocument();
  });
});
```

## 4.3 Security Standards

### Security Checklist

**Authentication:**
- [ ] All protected endpoints require API key
- [ ] API keys never logged
- [ ] API keys validated on every request
- [ ] No default API keys in code

**Input Validation:**
- [ ] All user input validated
- [ ] SQL queries parameterized
- [ ] No eval() or exec()
- [ ] File uploads sanitized (if implemented)

**Data Protection:**
- [ ] Secrets in .env file only
- [ ] .env in .gitignore
- [ ] Database passwords strong
- [ ] HTTPS in production

**Dependencies:**
- [ ] No known vulnerabilities (Dependabot)
- [ ] Dependencies pinned to versions
- [ ] Regular security updates
- [ ] Minimal dependency count

**API Security:**
- [ ] Rate limiting implemented
- [ ] CORS configured properly
- [ ] Error messages don't leak info
- [ ] Logging doesn't include secrets

### Security Testing

**Automated Scans:**
- GitHub Dependabot for dependencies
- OWASP ZAP for penetration testing (manual)
- npm audit / pip-audit for package vulnerabilities

**Manual Review:**
- Code review security checklist
- Threat modeling for new features
- Security testing in test suite

## 4.4 Performance Standards

### Response Time Targets

**API Endpoints:**
- Health check: < 100ms
- Database reads: < 200ms
- Content generation: < 30 seconds
- Analytics aggregation: < 1 second

**Frontend:**
- Initial page load: < 3 seconds
- Route navigation: < 500ms
- Form submission: < 100ms (excluding API call)

### Scalability Targets

**Concurrent Users:**
- Support 10 concurrent users (phase 1)
- Support 100 concurrent users (phase 2)

**Content Generation:**
- Handle 1,000 pieces/day
- Database: 100,000+ content pieces
- API rate: 10 req/min per key

### Monitoring

**Metrics to Track:**
- API response times (p50, p95, p99)
- Error rates
- Database query performance
- AI API latency
- Cost per request

**Alerting Thresholds:**
- Error rate > 5%
- Response time p95 > 5 seconds
- Database connections > 8/10
- Budget > 90%

---

# SECTION 5: DOCUMENTATION REQUIREMENTS

## 5.1 Documentation Files Required

### User Documentation

**README.md (1,700+ lines)**
**Purpose:** Primary entry point for all users
**Must Include:**
- What SPLANTS is (elevator pitch)
- Who should use it
- Cost breakdown ($35-80/month)
- System requirements
- Installation guide (all OS)
- Configuration instructions
- Usage examples
- Troubleshooting basics
- FAQ (30+ questions)
- Glossary of terms

**SETUP_GUIDE.md (1,300+ lines)**
**Purpose:** Detailed installation walkthrough
**Must Include:**
- Pre-installation checklist
- Step-by-step instructions (Windows/Mac/Linux)
- Screenshots or ASCII diagrams
- Common installation problems
- Verification steps
- First content generation tutorial

**TROUBLESHOOTING.md (1,400+ lines)**
**Purpose:** Problem-solving reference
**Must Include:**
- Quick diagnostic checklist
- 60+ common problems with solutions
- Error message lookups
- Performance optimization
- Advanced debugging
- When to seek help

**FAQ.md (1,400+ lines)**
**Purpose:** Question and answer reference
**Must Include:**
- 100+ questions across 10 categories
- General questions
- Setup & installation
- Costs & pricing
- Features & capabilities
- Technical questions
- Usage & best practices
- Troubleshooting
- Legal & business
- Comparisons to alternatives
- Advanced topics

### Technical Documentation

**DEVELOPER_GUIDE.md (600+ lines)**
**Purpose:** Guide for contributors and developers
**Must Include:**
- Development setup
- Code organization
- Architecture overview
- Adding new features
- Testing guidelines
- Code style guide
- Pull request process

**docs_API_GUIDE.md (300+ lines)**
**Purpose:** API reference
**Must Include:**
- Authentication
- All endpoints documented
- Request/response examples
- Error codes
- Rate limits
- Webhook documentation
- Complete workflow examples

**docs_DEPLOYMENT.md (350+ lines)**
**Purpose:** Production deployment guide
**Must Include:**
- Deployment options (VPS, cloud, etc.)
- Production checklist
- Security guidelines
- Performance tuning
- Monitoring setup
- Backup automation
- Scaling strategies

### Operational Documentation

**WORKFLOW_AUTOMATION.md (800+ lines)**
**Purpose:** Marketing automation patterns
**Must Include:**
- Campaign automation workflows
- Content pipeline setup
- Quality assurance patterns
- Cost optimization strategies
- Integration examples
- Advanced patterns

**CHANGELOG.md**
**Purpose:** Version history
**Must Include:**
- All versions since 1.0
- Added features
- Changed functionality
- Fixed bugs
- Security updates
- Breaking changes
- Migration notes

### Quick Reference

**QUICK_REFERENCE.md (300+ lines)**
**Purpose:** Fast lookup guide
**Must Include:**
- TL;DR of system
- Common commands
- Key environment variables
- API endpoint list
- Troubleshooting quick fixes

### Navigation

**DOCUMENTATION_INDEX.md (500+ lines)**
**Purpose:** Documentation map
**Must Include:**
- Complete file listing
- Descriptions of each file
- Navigation by task
- Navigation by experience level
- Reading time estimates
- Quick reference section

## 5.2 Documentation Standards

### Writing Style

**Tone:** Friendly, clear, non-technical
**Audience:** Assume 8th-grade reading level
**Format:** Markdown with proper headers
**Length:** Be comprehensive, not concise

**Example (Good):**
```markdown
### What is Docker?

Docker is like a "shipping container" for software. Just like how shipping containers let you transport anything anywhere, Docker packages your software with everything it needs to run.

**Why you need it:** Without Docker, you'd need to manually install Python, PostgreSQL, and many other tools. Docker does all of this automatically!

**Where to get it:** [docker.com](https://docker.com) (free)
```

**Example (Bad):**
```markdown
### Docker

Container orchestration platform. Install from docker.com.
```

### Code Examples

**All examples must:**
- Be copy-pasteable
- Include expected output
- Show full commands (not snippets)
- Include error handling
- Have comments explaining non-obvious parts

**Example:**
```bash
# Generate a blog post about paint-splatter pants
curl -X POST http://localhost:3000/api/content/generate \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_api_key_here" \
  -d '{
    "content_type": "blog_post",
    "topic": "Why custom paint-splatter pants are the future of fashion",
    "platform": "blog",
    "tone": "professional",
    "keywords": ["custom pants", "wearable art", "fashion"],
    "target_length": "medium"
  }'

# Expected response:
# {
#   "content_id": "123e4567-e89b-12d3-a456-426614174000",
#   "content": "# Why Custom Paint-Splatter Pants...",
#   "quality_score": 0.92,
#   ...
# }
```

### Visual Aids

**ASCII Diagrams:**
Use for architecture, workflows, file structure

**Screenshots:**
Required for UI walkthroughs (future enhancement)

**Tables:**
Use for comparisons, feature lists, cost breakdowns

**Code Blocks:**
Always specify language for syntax highlighting

### Cross-Referencing

**Internal Links:**
```markdown
See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#common-problems) for solutions.
```

**Section Links:**
```markdown
Jump to [Installation Guide](#installation-guide)
```

### Version Control

**Updates:**
- Date all major updates
- Note version compatibility
- Update CHANGELOG.md
- Review annually for accuracy

---

# SECTION 6: DEPLOYMENT & OPERATIONS

## 6.1 Development Environment

**Local Development:**
```bash
# Clone repository
git clone https://github.com/your-org/splants.git
cd splants

# Create .env file
cp env.example .env
# Edit .env with your API keys

# Start services
docker-compose up --build

# Access:
# Web UI: http://localhost:3000
# API Docs: http://localhost:3000/api/docs
```

**Development Tools:**
- Docker Desktop
- VS Code or PyCharm
- Postman for API testing
- Git for version control

## 6.2 Production Deployment

### Option 1: VPS Deployment (Recommended)

**Requirements:**
- Ubuntu 22.04 LTS server
- 2 CPU cores minimum
- 4GB RAM minimum
- 50GB disk space
- Static IP address
- Domain name (optional)

**Steps:**
1. Install Docker and Docker Compose
2. Clone repository
3. Configure .env for production
4. Set up HTTPS with Let's Encrypt
5. Configure firewall (UFW)
6. Set up monitoring
7. Configure automated backups
8. Start services

**Production .env Differences:**
```bash
# Production CORS - specify your domain!
CORS_ORIGINS=https://yourdomain.com

# Production database - strong password!
POSTGRES_PASSWORD=<very-strong-password>

# API key for production
API_KEY=<production-api-key>

# Monitoring (optional)
SENTRY_DSN=<your-sentry-dsn>
```

### Option 2: Cloud Platforms

**AWS Deployment:**
- EC2 instance (t3.medium)
- RDS for PostgreSQL
- ELB for load balancing
- S3 for backups
- CloudWatch for monitoring

**GCP Deployment:**
- Compute Engine VM
- Cloud SQL for PostgreSQL
- Cloud Load Balancing
- Cloud Storage for backups
- Cloud Monitoring

**Azure Deployment:**
- Azure VM
- Azure Database for PostgreSQL
- Azure Load Balancer
- Azure Blob Storage
- Azure Monitor

## 6.3 Operations

### Daily Tasks
- Monitor error logs
- Check backup success
- Review cost reports
- Check system health

### Weekly Tasks
- Review analytics trends
- Update content if needed
- Check for updates
- Test backup restore (monthly)

### Monthly Tasks
- Security updates
- Dependency updates
- Performance review
- Cost optimization

### Quarterly Tasks
- Full security audit
- Disaster recovery test
- Documentation review
- Feature planning

---

# SECTION 7: CONCLUSION

## 7.1 Project Success Criteria

**Technical Success:**
- ✅ All core features implemented and working
- ✅ 90%+ uptime in production
- ✅ Response times meet targets
- ✅ No critical security vulnerabilities
- ✅ Test coverage above 70%

**Business Success:**
- ✅ Cost under $80/month for typical usage
- ✅ Content quality scores average 0.85+
- ✅ Installation success rate 95%+
- ✅ User satisfaction high
- ✅ Saves users $1,600-3,300/month vs. alternatives

**Documentation Success:**
- ✅ 10,000+ lines of comprehensive documentation
- ✅ All features documented
- ✅ Troubleshooting guide solves 90%+ of issues
- ✅ Users can self-serve for most questions

## 7.2 Maintenance & Evolution

**Ongoing Maintenance:**
- Monthly dependency updates
- Quarterly security audits
- Bug fixes as reported
- Performance monitoring
- Cost optimization

**Feature Evolution:**
- User feedback prioritization
- Optional enhancement expansion
- New AI model support
- Additional platform integrations
- Enhanced automation

## 7.3 Final Notes

**This specification provides:**
- Complete vision and architecture
- Detailed component requirements
- Step-by-step implementation roadmap
- Quality standards and controls
- Comprehensive documentation requirements
- Deployment and operational guidance

**Total Specification Length:** 3,000+ lines

**Implementation Time:** 4 weeks for core system, ongoing for enhancements

**Remember:**
- Simplicity over complexity
- Core + optional pattern
- Non-technical accessibility
- Security by default
- Comprehensive documentation

**This is the complete blueprint for building SPLANTS from scratch. Follow this specification to create a production-ready AI marketing engine that delivers exceptional value to small businesses.**

---

**End of PROJECT_SPECIFICATION.md**

