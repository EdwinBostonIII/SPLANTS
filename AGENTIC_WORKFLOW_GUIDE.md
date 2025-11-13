# 🌱 SPLANTS Agentic Workflow Master Guide

## The Ground-Up Implementation Playbook for Your Splatter-Pants Brand

**Version:** 2.1.1  
**Companion To:** `BUSINESS_STARTUP_GUIDE.md`, `BUSINESS_STARTUP_GUIDE_REVISED.md`, `PROJECT_SPECIFICATION.md`, `WORKFLOW_AUTOMATION.md`  
**Reading Time:** 75-90 minutes  
**Outcome:** A complete, interoperable workflow that the business owner can follow step by step without guesswork.  

---

## 📚 Table of Contents
1. [How to Use This Guide](#how-to-use-this-guide)
2. [Orientation & Core Principles](#orientation--core-principles)
3. [Part 1 – Brand & Strategy Foundations](#part-1--brand--strategy-foundations)
4. [Part 2 – Technical Environment Preparation](#part-2--technical-environment-preparation)
5. [Part 3 – Core System Installation & Verification](#part-3--core-system-installation--verification)
6. [Part 4 – Brand Voice, Assets, and Data Calibration](#part-4--brand-voice-assets-and-data-calibration)
7. [Part 5 – Agentic Workflow Activation](#part-5--agentic-workflow-activation)
8. [Part 6 – If-Then Integration Logic (Ordered by Difficulty & Cost)](#part-6--if-then-integration-logic-ordered-by-difficulty--cost)
9. [Part 7 – Brand Potential Scorecard (Concrete Metrics)](#part-7--brand-potential-scorecard-concrete-metrics)
10. [Part 8 – Operating Rhythm & Quality Safeguards](#part-8--operating-rhythm--quality-safeguards)
11. [Part 9 – Troubleshooting, Self-Healing, and Support](#part-9--troubleshooting-self-healing-and-support)
12. [Appendix A – Command Reference](#appendix-a--command-reference)
13. [Appendix B – Decision Flow Worksheets](#appendix-b--decision-flow-worksheets)

---

## How to Use This Guide

### 🧭 Read This Way
- **Follow sequentially.** Each part builds directly on the last so the implementation happens from the ground up—no skipped foundations, no floating tools.
- **Make decisions at the checkpoints.** Whenever you see an “IF → THEN” block, finish the explanation first, then choose the branch that matches your preference. Every branch flows into compatible steps later in the guide.
- **Reference the companion documents when noted.** This guide expands the four core documents. Links and filenames appear inline (for example, `SETUP_GUIDE.md` for OS-specific installation visuals).
- **Keep your own notes.** Mark choices, API keys, and brand details as you go. The goal is implementation, not memorization.

### 🔑 What You’ll Build
1. A stable environment prepared to run SPLANTS confidently.
2. A calibrated marketing engine that speaks exactly in your brand voice.
3. Agentic workflows that research, create, optimize, and hand content to you ready for review or automated delivery.
4. Optional integrations layered responsibly using documented “if-then” logic so nothing conflicts or creates surprises.

---

## Orientation & Core Principles

### 🌟 Guiding Intent
Your Jackson Pollock-inspired splatter-pants brand deserves a marketing system that feels handcrafted yet scales your energy. This guide keeps the tone and reassurance of the original documents: direct, encouraging, and grounded. You steer—this playbook supplies the scaffolding, the prompts, and the exact buttons to press.

### 🧩 System Building Blocks
- **`main.py` (Monolithic backend):** The intentionally single-file engine with all endpoints, optional enhancements, and logic. Referenced throughout for toggles and advanced features.
- **`web/` interface:** React dashboard at `http://localhost:3000` where non-technical tasks live (content generation, scheduling, budgets, analytics).
- **Docker services:** `docker-compose.yml` defines app, database, and optional services (Redis when enabled).
- **Documentation anchors:** `README.md` for feature context, `SETUP_GUIDE.md` for visuals, `WORKFLOW_AUTOMATION.md` for automation patterns, `PROJECT_SPECIFICATION.md` for architectural rationale.

### 🎯 Core Principles (Adopted from the Specification)
- **Simplicity over cleverness:** Every instruction favors clarity. You can point to the exact file, variable, or UI toggle involved.
- **Core + Optional Enhancements:** The base workflow works fully. Optional features are layered only when you explicitly choose them, and each decision is mapped to compatible next steps.
- **Observability:** Every stage includes verification so you always know “did that work?” before moving on.
- **Human-led:** Automation amplifies your taste—it never overrides your decisions about the brand.

---

## Part 1 – Brand & Strategy Foundations

This part prepares the creative and strategic inputs SPLANTS needs to sound like you. Completing it first prevents rework once the engine starts producing content.

### 1.1 Define Your Brand Story Assets
1. **Artistic Signature:** Write a three-sentence description explaining why splatter art on pants matters. Mention materials, inspiration, and the feeling the customer has when they wear them.
2. **Voice Spectrum:** List three adjectives describing tone (e.g., “bold”, “playful”, “art-school confident”). These will seed prompts later.
3. **Product Pillars:** Note the key differentiators (e.g., hand-painted uniqueness, durable fabrics, limited drops).
4. **Ethos Statement:** Build one sentence and one short paragraph that capture your “why.” This feeds onboarding prompts for the AI brand voice.

### 1.2 Audience & Demand Map
Use the following concrete metrics to ground your optimism in reality:
- **Search Interest Trend:** Use Google Trends for keywords like “paint splatter pants” or “artwear pants.” Your target is a stable or rising three-year trend with seasonal peaks you can time. Record the normalized interest index at three points (launch month, prior year same month, all-time high).
- **Social Engagement Benchmarks:** Identify accounts with similar aesthetic (Instagram, TikTok). Track their last 12 posts for average engagement rate; note the midpoint engagement % as your near-term goal.
- **Conversion Readiness Signals:** Survey or DM five ideal customers and record how many (and what %) express immediate interest. This is your initial “warm lead rate.”
- **Retention Potential:** Outline two concrete reasons someone would buy a second pair within six months (e.g., seasonal capsule, gifting). Tie each reason to a content theme you will run through SPLANTS.

### 1.3 Offer Architecture (Without Pricing)
1. **Baseline Offering:** Describe the core product package (e.g., standard fit, customizable color palette).
2. **Value Amplifiers:** List 3 add-ons (e.g., signed authenticity card, care kit, behind-the-scenes mini-zine) without setting price tags.
3. **Fulfillment Promise:** Note your production lead time target in days and your desired turnaround experience (e.g., “updates at every paint stage”).
4. **Objection Handling:** Document three common concerns you expect (fit, durability, uniqueness) and short reassurance statements for each.

### 1.4 Customer Journey Narrative
Map a simple journey:
1. **Discovery:** Platform + trigger (e.g., Instagram Reel, Pinterest board).
2. **Consideration:** What proof do they need? (e.g., behind-the-scenes video, fabric close-ups).
3. **Decision:** Define the call-to-action phrasing you prefer (friendly, inviting).
4. **Post-Purchase Delight:** Identify the follow-up experience you want (story-driven email, invite to exclusive community).

> ✅ **Checkpoint 1:** You have a brand voice sheet, audience benchmarks, and journey notes. Keep them accessible—they feed directly into Part 4.

---

## Part 2 – Technical Environment Preparation

You now anchor the infrastructure. Everything here references `SETUP_GUIDE.md`, `README.md`, and `env.example`.

### 2.1 Hardware & OS Readiness
1. **System Requirements:** Minimum 2 CPU cores, 4GB RAM, Docker Desktop (Windows/Mac) or Docker Engine (Linux). If you are unsure, run the check script in a terminal *before* installing anything else:
   ```bash
   ./scripts_check-system.sh
   ```
   - **IF** any requirement fails → **THEN** follow the remediation section printed by the script and re-run until you get a success summary.
2. **Network Preparation:** Confirm ports `3000` (web app) and `5432` (database) are free. Use:
   ```bash
   sudo lsof -i :3000
   sudo lsof -i :5432
   ```
   - **IF** a process is listed → **THEN** stop or reassign that process before continuing to avoid conflicts during Docker startup.

### 2.2 Accounts & Keys
1. **OpenAI API Key:** Create and copy it. Store temporarily in a secure note (you will paste into `.env` later).
2. **Optional Keys to Pre-Collect (Only if you plan to use them):**
   - Anthropic Claude (for multi-model synthesis).
   - Redis URL (managed service or local).
   - Automation platforms (Zapier, Make, Slack webhook).
3. **Security Reminder:** Keep keys off screenshots and never commit `.env` to git.

### 2.3 Repository Setup
1. Open a terminal and clone the project:
   ```bash
   git clone https://github.com/yourusername/splants.git
   cd splants
   ```
2. Create your working branch if you like to track changes:
   ```bash
   git checkout -b launch-workflow
   ```
3. Copy the environment template:
   ```bash
   cp env.example .env
   ```
4. Open `.env` in your editor. You will fill it out in Part 3.

### 2.4 Documentation Bookmarking
Keep the following tabs open for quick reference:
- `SETUP_GUIDE.md` (visual installation steps).
- `README.md` (task-based instructions).
- `WORKFLOW_AUTOMATION.md` (automation patterns).
- `BUSINESS_STARTUP_GUIDE.md` (business timeline context).

> ✅ **Checkpoint 2:** Docker installed, repository cloned, `.env` ready, scripts verified. You are clear to activate the system.

---

## Part 3 – Core System Installation & Verification

Your goal here is a fully running SPLANTS instance with verified services.

### 3.1 Configure `.env`
Open `.env` and fill the following:
1. `OPENAI_API_KEY=` → paste your key.
2. `API_KEY=` → create a secure passphrase (minimum 12 characters).
3. `MONTHLY_AI_BUDGET=` and `DAILY_API_LIMIT=` → set guardrails that match your comfort. Use qualitative labels in your notes (e.g., “conservative,” “balanced”) instead of currency estimates.
4. Leave optional sections commented out for now unless you already know you will enable them in Part 6.

### 3.2 Launch the Stack
Run:
```bash
make start
```
The make target orchestrates Docker Compose, initializes the database, and starts backend + frontend containers. Watch the terminal for the success banner.

### 3.3 Access the Web Interface
1. Navigate to `http://localhost:3000`.
2. Log in using the `API_KEY` you just set.
3. Explore the dashboard to ensure sections load (Content, Templates, Analytics, Settings).

### 3.4 Verify Services
Run the verification script:
```bash
./scripts_verify-installation.sh
```
- **IF** all checks pass → proceed.
- **IF** any check fails → **THEN** open `TROUBLESHOOTING.md` and resolve before continuing.

### 3.5 Confirm Database Tables
The system auto-configures tables, including optional ones. To confirm:
```bash
docker exec -it splants-db-1 psql -U splants -d splants -c "\dt"
```
Look for tables such as `content`, `analytics_events`, `ab_tests`, `webhook_deliveries`. Their presence means optional modules are register-ready even if you have not enabled them yet.

> ✅ **Checkpoint 3:** Web app reachable, scripts pass, database seeded. You now have a reliable technical foundation.

---

## Part 4 – Brand Voice, Assets, and Data Calibration

This part injects your unique brand DNA so the agentic workflows stay true to you.

### 4.1 Load Brand Settings in the Web UI
1. Open `Settings → Brand Profile`.
2. Fill in:
   - **Brand Summary:** Use the artistic signature from Part 1.
   - **Tone Spectrum:** Input your three adjectives.
   - **Audience Snapshot:** Add highlights from the audience benchmarks (demographics, psychographics).
   - **Vocabulary Guide:** List phrases or references you always want (e.g., “studio drips,” “gallery-grade denim”).
3. Click **Save Brand Settings**.

### 4.2 Seed Core Content Themes
1. Navigate to `Content → Themes`.
2. Add at least three core themes derived from your offer architecture (e.g., “Process Stories,” “Styling Guides,” “Art History Inspirations”).
3. For each theme, specify:
   - Desired cadence (weekly, bi-weekly).
   - Preferred content formats (blog, reel script, email).
4. This trains the planner to balance your calendar automatically.

### 4.3 Upload or Create Reference Materials
1. If you have sample copy, testimonials, or product descriptions, upload them under `Settings → Reference Library`.
2. **IF** you lack existing materials → **THEN** create a “Brand Sourcebook” entry by pasting your ethos paragraph and any customer quotes you collected.
3. These references inform the contextual prompting block inside `main.py` (see `FREE OPTIONAL ENHANCEMENT: Context-aware prompting` in the codebase).

### 4.4 Configure Quality Benchmarks
1. Go to `Settings → Quality Controls`.
2. Set minimum acceptable quality score (recommendation: start at 0.82 based on internal QA thresholds).
3. Enable automatic re-run if below threshold (toggle “Auto-Rewrite below minimum”).
4. Review the weighting sliders (Clarity, Originality, Brand Voice, SEO). Adjust to emphasize artistry and storytelling if that’s your differentiator.

### 4.5 Establish Compliance & Guardrails
1. Add banned phrases or claims under “Compliance Rules.” Example: avoid statements that overpromise durability beyond what you can deliver.
2. Set factual verification triggers for materials specifics (fabric composition, wash instructions) so the QA pipeline knows to double-check those fields.

> ✅ **Checkpoint 4:** Brand profile saved, themes defined, reference material loaded, quality guardrails active. The system now knows how to sound like you.

---

## Part 5 – Agentic Workflow Activation

Now you switch on the intelligent loops described in `WORKFLOW_AUTOMATION.md`.

### 5.1 Choose Your Content Generation Lane
You can command SPLANTS via the web app, the API, or both. Decide using the logic below (after reading each explanation):

- **Web Interface First**
  - **Use When:** You prefer guided prompts and visual scheduling.
  - **How:** `Dashboard → Generate Content`.
  - **Then:** Use the “Campaign Wizard” to select platforms, tone, and themes; the system maps to the multi-phase workflow automatically.

- **API Control**
  - **Use When:** You want to script batch tasks or integrate with other tools.
  - **How:** Authenticate using your `API_KEY` and hit `/v1/generate`, `/v1/templates/generate`, `/v1/workflows/launch`.
  - **Then:** Pair with scripts (Python, Postman) to trigger content in bulk.

- **Hybrid**
  - **Use When:** You want the ease of the UI and the precision of API for specialized campaigns.
  - **Then:** Use the UI for recurring weekly cadences, and the API for special drops or collaborations.

Choose your lane now so later sections reference the correct path.

### 5.2 Launch the Research → Creation → Optimization Loop
1. From the UI, start a campaign via `Generate → Campaign`. Or call the API endpoint `/v1/workflows/launch_campaign`.
2. Provide:
   - Topic (e.g., “Paint-Splatter Styling for Creative Professionals”).
   - Target platforms.
   - Desired content types.
3. The system:
   - Runs competitive research (`analyze_competitors`, `research_keywords`).
   - Generates pillar content then derivative assets (social posts, emails) per platform compatibility.
   - Performs optimization (variants, SEO tuning, platform adjustments).
   - Schedules content using best posting times.
4. **IF** you prefer manual scheduling → **THEN** disable “Auto-Schedule” toggle before finalizing. The system will still recommend time slots without enqueuing them.

### 5.3 Configure Quality Assurance Workflow
1. Open `Settings → Automation`.
2. Enable **Quality Assurance Pipeline** to let the system auto-run grammar, plagiarism, brand voice, factual checks (`QualityAssuranceWorkflow`).
3. Decide action thresholds:
   - **IF** QA score < 0.6 → Flag for manual review.
   - **IF** 0.6 ≤ QA score < 0.8 → Auto-fix issues then flag for your quick glance.
   - **IF** QA score ≥ threshold → Approve automatically.
4. Review flagged content in `Content → Review` before publication or export.

### 5.4 Activate Cost Optimization (Strongly Recommended)
1. In the UI, enable **Cost Control** to align with `CostOptimizationWorkflow`.
2. Configure strategies:
   - **Economy Mode** kicks in when remaining monthly budget is low (automatically uses shorter content, cached responses).
   - **Balanced Mode** applies default settings.
   - **Quality Mode** steps up to premium models (if available) when budget is healthy.
3. Ensure `MONTHLY_AI_BUDGET` and `DAILY_API_LIMIT` in `.env` mirror your UI settings to keep backend logic consistent.

### 5.5 Scheduling & Publishing Preferences
1. Decide on publishing route:
   - **IF** you will publish manually → **THEN** leave “Auto-Publish” disabled and use export tools (download, copy to clipboard, push to Google Docs via Zapier).
   - **IF** you want automated posting → **THEN** see Part 6 for social auto-post integration steps.
2. Review the “Smart Timing” suggestions. Even without auto-posting, you can manually schedule in tools like Buffer using the recommended timestamps.

### 5.6 Monitoring & Feedback Loops
1. Visit `Analytics → Performance`.
2. Set target benchmarks using the metrics from Part 1 (engagement %, warm lead rate).
3. Enable **Daily Digest** webhook (or email) so you receive a snapshot of:
   - Content generated
   - Spend vs. budget
   - Top performing assets
   - Recommended adjustments
4. **IF** you want real-time alerts → **THEN** connect Slack or email via webhooks (instructions in Part 6).

> ✅ **Checkpoint 5:** Campaign workflows, QA, and cost control are active; scheduling decisions documented.

---

## Part 6 – If-Then Integration Logic (Ordered by Difficulty & Cost)

Enhancements are listed from lowest difficulty/lowest cost impact to highest. Read the explanation, then follow the IF → THEN logic to keep compatibility intact. No progressive path—choose only what you need.

### 6.1 Cost Control & Analytics Enhancements (Low Difficulty, Included)
**What:** Budget guardrails, analytics dashboards, A/B testing.  
**Why:** Protects spend and surfaces insights.  
**How:** Already available in the UI and API—just enable the toggles.

- **IF** you enable **Cost Control** → **THEN** verify `.env` values (`MONTHLY_AI_BUDGET`, `DAILY_API_LIMIT`) align to avoid conflicting thresholds.
- **IF** you activate **Analytics Dashboard** → **THEN** schedule a weekly review (Part 8) to act on recommendations.
- **IF** you want **A/B Testing** → **THEN** generate variants via `/v1/ab-test/{content_id}` and log winning variants back into your templates.

### 6.2 Webhook Automation (Low Difficulty, Free)
**What:** Sends events to Zapier, Make, IFTTT, Slack, Google Sheets.  
**How:** Configure under `Settings → Webhooks`.

- **IF** you paste a `WEBHOOK_CONTENT_GENERATED_URL` → **THEN** confirm the receiving service records the payload before relying on it for automations.
- **IF** you add a `WEBHOOK_CONTENT_PUBLISHED_URL` → **THEN** ensure you also enable publishing (manual or auto) so events fire.
- **IF** you leverage the `Daily Report` webhook → **THEN** set a daily review reminder (calendar, Slack) so the digest informs your next actions.

### 6.3 Template & Content Library Extensions (Low Difficulty, Included)
**What:** Custom templates, reference library expansion.  
**How:** `Content → Templates` / API endpoints (`/v1/templates`, `/v1/templates/generate`).

- **IF** you create a new template → **THEN** document its ideal use case and metrics so future campaigns use it intentionally.
- **IF** you prefer manual drafting → **THEN** call the template endpoint with `use_ai=false` to get the structure only, keeping compatibility with manual workflows.

### 6.4 Multi-Channel Notifications (Moderate Difficulty, Free to Low Cost)
**What:** Connect SPLANTS to Slack, email, or project tools via Zapier/Make.  

- **IF** the goal is immediate review (Slack) → **THEN** configure a Zap with the Content Generated webhook and filter by quality score so only top outputs alert you.
- **IF** the goal is task management (Asana/Trello) → **THEN** transform webhook payloads into tasks and include the review deadline.
- **IF** you prefer spreadsheet tracking → **THEN** pipe payloads into Google Sheets and link analytics fields for quick dashboards.

### 6.5 Redis Caching (Moderate Difficulty, Low Monthly Cost Category)
**What:** External cache to reduce repeated AI calls (labeled “PAID OPTIONAL ENHANCEMENT: Redis Caching” in `main.py`).  

- **Prerequisites:** Uncomment Redis service in `docker-compose.yml`, set `REDIS_URL` in `.env`, restart containers.
- **IF** you enable Redis → **THEN** monitor cache hits via logs (`make logs`) to ensure it actually reduces repeat spending.
- **IF** you notice stale content returning → **THEN** adjust cache expiration in `main.py` where caching logic resides (search for `cache.get` calls).

### 6.6 Multi-Model Synthesis (Moderate Difficulty, Variable Usage Cost)
**What:** Combines GPT-4 with Anthropic Claude for premium content (`PAID OPTIONAL ENHANCEMENT: Multi-model synthesis`).  

- **IF** you add `ANTHROPIC_API_KEY` → **THEN** enable “Premium Mode” per content request (UI toggle or API parameter).
- **IF** you only want premium for marquee assets → **THEN** leave default mode basic and switch on premium per campaign.
- **IF** outputs feel inconsistent → **THEN** review brand references (Part 4) to ensure both models have the same contextual grounding.

### 6.7 Manual Scheduling via Buffer or Similar (Moderate Difficulty, Free to Modest Cost)
**What:** Use external scheduler (Buffer, Later) while still leveraging SPLANTS for content creation.  

- **IF** you prefer this route → **THEN** export scheduled content CSV from SPLANTS (`Content → Export`) and import into Buffer’s queue.
- **IF** Buffer’s calendar suggests different times → **THEN** cross-check with SPLANTS Smart Timing; pick the slot that aligns with your audience benchmarks.
- **IF** you maintain manual quality gate → **THEN** keep QA auto-approval disabled so you can personally approve each piece before uploading.

### 6.8 Auto-Publishing (Higher Difficulty, Potential Platform Costs)
**What:** Direct posting to platforms via API keys (`PAID OPTIONAL ENHANCEMENT: Auto-posting`).  

- **Prerequisites:** Platform developer accounts (Instagram via Facebook Graph, Twitter/X API, LinkedIn Marketing Developer).
- **IF** you enable auto-publishing in `.env` and UI → **THEN** test on a private or draft channel first to confirm formatting.
- **IF** any platform lacks API access → **THEN** fall back to Buffer or manual publishing for that channel while auto-posting to others—you can mix modes safely.
- **IF** a post fails → **THEN** check `Webhook Delivery Logs` (`/v1/webhooks/logs`) and platform error codes to resolve quickly.

### 6.9 Advanced Analytics & Reporting (Higher Difficulty, Optional Tooling Cost)
**What:** Connect SPLANTS data to BI tools (Looker Studio, Metabase) or custom dashboards.  

- **IF** you export analytics tables (`analytics_events`, `campaign_reports`) → **THEN** sanitize any personal data before syncing to external services.
- **IF** you build a Looker Studio dashboard → **THEN** schedule weekly refresh and align KPIs with Part 7 metrics.
- **IF** you prefer local notebooks → **THEN** query data using `psql` or Python scripts and visualize conversions, engagement, repeat customers.

> ✅ **Checkpoint 6:** You’ve selected optional integrations that match your resources. Each choice has a documented action path and compatibility notes.

---

## Part 7 – Brand Potential Scorecard (Concrete Metrics)

Evaluate your opportunity through optimistic, grounded metrics. Update these monthly.

| Category | Metric | Why It Matters | Current Snapshot | 90-Day Target |
|----------|--------|----------------|------------------|---------------|
| **Awareness** | Search interest index (Google Trends) | Confirms demand trajectory | Record current index value | Achieve index ≥ baseline +10% |
| **Engagement** | Avg. social engagement % (Instagram/TikTok) | Measures resonance of creative | Calculate from last 12 posts | Reach midpoint benchmark from Part 1 |
| **Conversion Intent** | Warm lead rate (responses / outreach) | Validates messaging clarity | Track percentage of leads expressing readiness | Increase by 25% via nurture sequences |
| **Content Velocity** | Pieces generated per week via SPLANTS | Indicates consistent visibility | Log weekly output from Analytics dashboard | Maintain consistent cadence w/o lowering QA score |
| **Quality Assurance** | Approved-on-first-pass % | Shows how well brand voice is dialed in | Pull from QA reports | Maintain ≥ 75% while raising minimum quality threshold |
| **Retention Drivers** | Repeat interest triggers logged | Ensures second purchase motivators exist | Track via CRM or spreadsheet | Document two proven triggers with content support |

Additional qualitative checkpoints:
- **Customer Delight Stories:** Collect weekly anecdotes or messages that highlight brand affection.
- **Collaborations & Mentions:** Track creative partnerships or media mentions resulting from consistent content.
- **Production Flow Alignment:** Ensure marketing cadence matches what you can paint and ship without stress.

Use this scorecard to justify continued optimism—the metrics provide tangible proof without forcing price or cost directives.

---

## Part 8 – Operating Rhythm & Quality Safeguards

Maintain momentum with intentional routines.

### 8.1 Daily (15-20 minutes)
1. Check the **Daily Digest** (via email or Slack).
2. Approve or fine-tune any pending QA items.
3. Schedule manual posts or confirm auto-publishing status.
4. Log any customer feedback in your reference library.

### 8.2 Weekly (60-90 minutes)
1. Review Analytics dashboard; compare engagement metrics against your scorecard.
2. Adjust campaign themes for the next week inside the planner.
3. Inspect cost dashboard to confirm you remain within guardrails.
4. Capture new behind-the-scenes assets (photos, videos) to feed future prompts.

### 8.3 Monthly (Half Day)
1. Update the Brand Potential Scorecard.
2. Audit templates: retire low performers, evolve high performers.
3. Refresh brand vocabulary with new phrases or stories from the month.
4. Re-run the system check script if you updated Docker or dependencies.

### 8.4 Safeguards
- **Backup Rhythm:** Use `docker exec` or pg_dump to back up the database weekly. Store exports securely.
- **Fail-Safe Toggle:** Keep “Pause Automation” bookmarked in the UI; use it if you need to temporarily halt all workflows.
- **Documentation Updates:** When you change an optional integration, log it in a simple changelog so you can retrace steps.

---

## Part 9 – Troubleshooting, Self-Healing, and Support

### 9.1 Common Recovery Actions
- **System Not Starting:** Run `docker-compose logs app` to identify missing environment variables.
- **API Errors:** Check `make logs` and ensure your `API_KEY` matches the UI entry.
- **Quality Drift:** Revisit Part 4 to refresh reference materials; review QA logs for patterns.
- **Budget Alerts:** Adjust `MONTHLY_AI_BUDGET` only after evaluating why spend spiked (e.g., large campaign, auto-post errors causing retries).

### 9.2 Documentation Cross-Reference
- `TROUBLESHOOTING.md` → Symptom-based fixes.
- `FAQ.md` → Platform-specific clarifications (OpenAI, deployment).
- `docs_DEPLOYMENT.md` → If you ever want to run this beyond your local machine (no need unless you choose to).
- `WORKFLOW_AUTOMATION.md` → Deep dives on each automation class referenced in Part 5.

### 9.3 Support Channels
- **Self-Support Loop:** Use logs + documentation before escalating.
- **Community / Peer Support:** Share sanitized insights or questions with trusted peers; your clarity will accelerate their feedback.
- **Professional Help:** Keep notes so if you ever onboard technical assistance, they can follow your documented steps without reinventing them.

---

## Appendix A – Command Reference

| Purpose | Command |
|---------|---------|
| System check | `./scripts_check-system.sh` |
| Start stack | `make start` |
| Stop stack | `make stop` |
| View logs | `make logs` |
| Verify installation | `./scripts_verify-installation.sh` |
| Restart containers | `make restart` |
| Update project | `git pull && make restart` |
| Inspect database tables | `docker exec -it splants-db-1 psql -U splants -d splants -c "\dt"` |
| Tail backend logs | `docker logs -f splants-app-1` |

---

## Appendix B – Decision Flow Worksheets

Use these textual flowcharts to confirm you follow compatible paths. Refer back whenever you consider a change.

### B.1 Publishing Mode Flow
```
Start
 ├─> Do you want to click “Publish” yourself each time?
 │     ├─ Yes → Keep Auto-Publish disabled → Export content → Use Buffer or manual posting
 │     └─ No → Gather platform API keys → Enable Auto-Publish in settings → Test on draft channel
 └─> Regardless → Enable Webhooks if you want notifications → Review QA gate before release
```

### B.2 Cost Management Flow
```
Start
 ├─> Are you comfortable with automated budget enforcement?
 │     ├─ Yes → Set MONTHLY_AI_BUDGET & DAILY_API_LIMIT → Enable Cost Control UI toggle
 │     └─ No → Leave automation off → Manually monitor Analytics spend widget daily
 ├─> Need deeper savings?
 │     ├─ Yes → Enable Redis caching → Monitor cache hits
 │     └─ No → Keep Redis off to reduce complexity
 └─> Premium quality needed?
       ├─ For special campaigns → Toggle Multi-Model per campaign
       └─ For all content → Enable Multi-Model globally, monitor budget
```

### B.3 Automation & Notification Flow
```
Start
 ├─> Do you want real-time notifications when content is ready?
 │     ├─ Yes → Configure Content Generated webhook → Send to Slack/Zapier
 │     └─ No → Rely on Daily Digest
 ├─> Do you need tasks created automatically?
 │     ├─ Yes → Map webhook payload to task manager
 │     └─ No → Track in your own spreadsheet/notebook
 └─> Are you ready for auto-posting?
       ├─ Yes → Follow Auto-Publish path in Part 6.8
       └─ Not yet → Keep to manual/Buffer workflow, revisit later
```

Keep these worksheets with your notes—they transform optional integrations into deliberate, documented choices.

---

You now hold a thorough, decision-friendly implementation manual that matches the tone of the original documentation while dramatically expanding each point. Follow it at your pace, reference the core files whenever needed, and enjoy watching your splatter-pants brand communicate with the same artistry you put into every pair.

