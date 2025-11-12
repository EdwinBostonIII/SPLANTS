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

### Advanced Testing Patterns

#### Pattern: Property-Based Testing
```python
# test_api.py additions
from hypothesis import given, strategies as st

@given(
    content_type=st.sampled_from(ContentType),
    length=st.integers(min_value=50, max_value=3000),
    keywords=st.lists(st.text(min_size=3, max_size=20), min_size=1, max_size=10)
)
def test_content_generation_properties(content_type, length, keywords):
    """Property-based testing for content generation."""
    
    response = client.post('/api/v1/generate', json={
        'content_type': content_type.value,
        'length': length,
        'keywords': keywords,
        'topic': 'Test topic'
    })
    
    # Properties that should always hold
    assert response.status_code in [200, 402, 429]  # Success or known errors
    
    if response.status_code == 200:
        data = response.json()
        
        # Quality score should be in valid range
        assert 0 <= data['quality_score'] <= 1
        
        # SEO score should be in valid range
        assert 0 <= data['seo_score'] <= 1
        
        # Word count should be reasonable
        word_count = data['metadata']['word_count']
        assert word_count > 0
        assert word_count <= length * 1.5  # Allow 50% over
        
        # Cost should be positive
        assert data['cost_estimate'] > 0
```

## Agentive Workflow Patterns

### Feature Implementation Workflow
When implementing a new feature, follow this agentive pattern:

1. **Categorize the Feature**
   ```python
   # Determine feature category first:
   # CORE FEATURE: Required for basic operation
   # FREE OPTIONAL ENHANCEMENT: Adds value, no extra cost
   # PAID OPTIONAL ENHANCEMENT: Requires external services
   ```

2. **Add Environment Configuration**
   ```python
   # In main.py startup section
   FEATURE_NAME_ENABLED = os.getenv("FEATURE_NAME_ENABLED", "false").lower() == "true"
   
   # Add to startup logging
   logger.info(f"📦 Feature X: {'✅ Enabled' if FEATURE_NAME_ENABLED else '❌ Disabled'}")
   ```

3. **Implement with Toggle Pattern**
   ```python
   if FEATURE_NAME_ENABLED:
       # Feature implementation
       await implement_feature()
   else:
       # Graceful fallback
       return default_response()
   ```

### Advanced Agentive Patterns

#### Pattern 1: Self-Healing Features
Implement features that can detect and recover from failures automatically:

```python
class ResilientFeature:
    """Self-healing feature pattern with automatic retry and fallback."""
    
    def __init__(self):
        self.retry_count = 0
        self.max_retries = 3
        self.health_status = "healthy"
        self.fallback_mode = False
    
    async def execute_with_resilience(self, request):
        """Execute feature with automatic healing."""
        try:
            # Check health before execution
            if not await self.check_health():
                await self.attempt_recovery()
            
            # Execute with retry logic
            result = await self.execute_with_retry(request)
            
            # Track success for health monitoring
            await self.record_success()
            return result
            
        except Exception as e:
            # Automatic fallback
            if self.fallback_mode:
                return await self.execute_fallback(request)
            
            # Trigger recovery workflow
            await self.initiate_recovery(e)
            raise
    
    async def check_health(self) -> bool:
        """Monitor feature health metrics."""
        # Check: API availability, response times, error rates
        recent_errors = await self.get_error_rate(minutes=5)
        avg_response_time = await self.get_avg_response_time(minutes=5)
        
        is_healthy = (
            recent_errors < 0.1 and  # Less than 10% error rate
            avg_response_time < 2.0   # Less than 2 seconds
        )
        
        if not is_healthy:
            logger.warning(f"Feature health degraded: errors={recent_errors}, response_time={avg_response_time}")
        
        return is_healthy
    
    async def attempt_recovery(self):
        """Automatic recovery procedures."""
        logger.info("Attempting automatic recovery...")
        
        # Clear caches
        if CACHE_ENABLED:
            await redis_cache.flushdb()
        
        # Reset connections
        await self.reset_connections()
        
        # Switch to fallback if recovery fails
        if self.retry_count > self.max_retries:
            self.fallback_mode = True
            logger.warning("Switching to fallback mode")
```

#### Pattern 2: Intelligent Cost Optimization
Implement cost-aware execution strategies:

```python
class CostOptimizedEngine:
    """Agentive cost optimization for AI operations."""
    
    def __init__(self):
        self.cost_threshold_per_request = 0.10
        self.daily_budget = DAILY_AI_BUDGET
        self.model_costs = {
            "gpt-4-turbo": 0.03,
            "gpt-3.5-turbo": 0.003,
            "claude-3-sonnet": 0.015,
            "cached": 0.0
        }
    
    async def select_optimal_model(self, request: ContentRequest) -> str:
        """Intelligently select model based on budget and requirements."""
        
        # Check remaining budget
        spent_today = await self.get_daily_spending()
        remaining = self.daily_budget - spent_today
        
        # Analyze request complexity
        complexity = self.analyze_complexity(request)
        
        # Decision matrix
        if remaining < 1.0:
            # Low budget: use cache or cheapest model
            if await self.check_cache(request):
                return "cached"
            return "gpt-3.5-turbo"
        
        elif complexity == "high" and remaining > 5.0:
            # Complex request with budget: use best model
            return "gpt-4-turbo" if not ANTHROPIC_API_KEY else "multi-model"
        
        elif complexity == "medium":
            # Balanced approach
            return "claude-3-sonnet" if ANTHROPIC_API_KEY else "gpt-3.5-turbo"
        
        else:
            # Simple request: use efficient model
            return "gpt-3.5-turbo"
    
    def analyze_complexity(self, request: ContentRequest) -> str:
        """Determine request complexity for model selection."""
        
        factors = {
            "high": 0,
            "medium": 0,
            "low": 0
        }
        
        # Length factor
        if request.length and request.length > 1500:
            factors["high"] += 1
        elif request.length and request.length > 500:
            factors["medium"] += 1
        else:
            factors["low"] += 1
        
        # Content type factor
        if request.content_type in [ContentType.LANDING_PAGE, ContentType.PRESS_RELEASE]:
            factors["high"] += 1
        elif request.content_type in [ContentType.BLOG, ContentType.EMAIL]:
            factors["medium"] += 1
        else:
            factors["low"] += 1
        
        # SEO optimization factor
        if request.seo_optimize and len(request.keywords) > 5:
            factors["high"] += 1
        
        # Return highest scoring complexity
        return max(factors, key=factors.get)
```

#### Pattern 3: Adaptive Learning System
Implement features that learn and improve over time:

```python
class AdaptiveLearningEngine:
    """System that learns from user feedback and improves."""
    
    async def learn_from_feedback(self, content_id: int, feedback: dict):
        """Adapt system based on user feedback."""
        
        # Store feedback
        async with db_pool.acquire() as conn:
            await conn.execute('''
                INSERT INTO content_feedback 
                (content_id, rating, feedback_type, details)
                VALUES ($1, $2, $3, $4)
            ''', content_id, feedback['rating'], feedback['type'], json.dumps(feedback))
        
        # Analyze patterns
        if feedback['rating'] < 0.7:
            # Learn what went wrong
            patterns = await self.analyze_failure_patterns(content_id)
            
            # Adjust prompts
            if patterns['issue'] == 'tone_mismatch':
                await self.refine_tone_prompt(patterns['details'])
            elif patterns['issue'] == 'keyword_density':
                await self.adjust_keyword_strategy(patterns['details'])
        
        else:
            # Reinforce successful patterns
            await self.reinforce_success_patterns(content_id)
    
    async def analyze_failure_patterns(self, content_id: int) -> dict:
        """Identify why content received low rating."""
        
        async with db_pool.acquire() as conn:
            # Get content and feedback history
            content = await conn.fetchrow(
                "SELECT * FROM content WHERE id = $1", content_id
            )
            
            similar_failures = await conn.fetch('''
                SELECT c.*, f.rating, f.details
                FROM content c
                JOIN content_feedback f ON c.id = f.content_id
                WHERE f.rating < 0.7
                AND c.content_type = $1
                AND c.created_at > NOW() - INTERVAL '30 days'
            ''', content['content_type'])
        
        # Pattern recognition
        patterns = {
            'issue': None,
            'details': {},
            'frequency': 0
        }
        
        # Analyze common failure points
        for failure in similar_failures:
            details = json.loads(failure['details'])
            # Machine learning analysis would go here
            # For now, simple pattern matching
            
        return patterns
    
    async def auto_improve_prompts(self):
        """Periodically improve prompts based on feedback."""
        
        async with db_pool.acquire() as conn:
            # Get high-performing content
            top_content = await conn.fetch('''
                SELECT c.*, f.rating
                FROM content c
                JOIN content_feedback f ON c.id = f.content_id
                WHERE f.rating >= 0.9
                AND c.created_at > NOW() - INTERVAL '7 days'
                ORDER BY f.rating DESC
                LIMIT 20
            ''')
        
        # Extract successful patterns
        successful_patterns = []
        for content in top_content:
            metadata = json.loads(content['metadata'])
            successful_patterns.append({
                'tone': metadata.get('tone'),
                'keywords': metadata.get('keywords'),
                'structure': self.analyze_structure(content['content'])
            })
        
        # Update prompt templates
        await self.update_prompt_templates(successful_patterns)
```

#### Pattern 4: Predictive Resource Management
Implement predictive scaling and resource allocation:

```python
class PredictiveResourceManager:
    """Predict and prepare for resource needs."""
    
    async def predict_usage(self, timeframe_hours: int = 24) -> dict:
        """Predict upcoming resource usage."""
        
        async with db_pool.acquire() as conn:
            # Historical usage patterns
            historical = await conn.fetch('''
                SELECT 
                    DATE_TRUNC('hour', created_at) as hour,
                    COUNT(*) as requests,
                    AVG(estimated_cost) as avg_cost,
                    SUM(estimated_cost) as total_cost
                FROM api_usage
                WHERE created_at > NOW() - INTERVAL '30 days'
                GROUP BY DATE_TRUNC('hour', created_at)
            ''')
        
        # Time series analysis
        predictions = {
            'expected_requests': 0,
            'expected_cost': 0.0,
            'peak_hours': [],
            'recommended_cache_keys': []
        }
        
        # Simple moving average (would use ML in production)
        for hour in range(timeframe_hours):
            hour_of_day = (datetime.now().hour + hour) % 24
            matching_hours = [h for h in historical if h['hour'].hour == hour_of_day]
            
            if matching_hours:
                avg_requests = sum(h['requests'] for h in matching_hours) / len(matching_hours)
                predictions['expected_requests'] += avg_requests
                
                if avg_requests > 10:  # High usage hour
                    predictions['peak_hours'].append(hour_of_day)
        
        # Pre-warm caches for predicted high-usage content
        if predictions['peak_hours']:
            predictions['recommended_cache_keys'] = await self.identify_cache_candidates()
        
        return predictions
    
    async def auto_scale_resources(self):
        """Automatically adjust resources based on predictions."""
        
        predictions = await self.predict_usage(24)
        
        # Adjust rate limits
        if predictions['expected_requests'] > DAILY_API_LIMIT * 0.8:
            logger.warning(f"Predicted usage ({predictions['expected_requests']}) approaching limit")
            
            # Could trigger alerts or auto-scaling here
            if WEBHOOK_BUDGET_ALERT:
                await trigger_webhook('budget_alert', predictions)
        
        # Pre-cache popular content
        if CACHE_ENABLED and predictions['recommended_cache_keys']:
            for cache_key in predictions['recommended_cache_keys']:
                await self.pre_warm_cache(cache_key)
```

#### Pattern 5: Workflow Orchestration
Implement complex multi-step workflows:

```python
class WorkflowOrchestrator:
    """Orchestrate complex content generation workflows."""
    
    async def execute_campaign_workflow(self, campaign_config: dict):
        """Execute complete marketing campaign workflow."""
        
        workflow_id = str(uuid.uuid4())
        logger.info(f"Starting campaign workflow: {workflow_id}")
        
        # Step 1: Generate pillar content
        pillar_content = await self.generate_pillar_content(
            topic=campaign_config['topic'],
            content_type='blog',
            length=2000
        )
        
        # Step 2: Extract key points for derivative content
        key_points = await self.extract_key_points(pillar_content)
        
        # Step 3: Generate derivative content in parallel
        tasks = []
        for platform in campaign_config['platforms']:
            tasks.append(
                self.generate_platform_content(
                    key_points=key_points,
                    platform=platform,
                    pillar_id=pillar_content['id']
                )
            )
        
        derivative_content = await asyncio.gather(*tasks)
        
        # Step 4: Create A/B variants for each piece
        if campaign_config.get('ab_testing', False):
            for content in derivative_content:
                await self.create_ab_variants(content['id'])
        
        # Step 5: Schedule publishing
        schedule = self.create_publishing_schedule(
            content_items=derivative_content,
            strategy=campaign_config.get('schedule_strategy', 'distributed')
        )
        
        for item in schedule:
            await self.schedule_publish(
                content_id=item['content_id'],
                platform=item['platform'],
                publish_time=item['scheduled_time']
            )
        
        # Step 6: Set up monitoring
        await self.setup_campaign_monitoring(
            workflow_id=workflow_id,
            content_ids=[c['id'] for c in derivative_content]
        )
        
        return {
            'workflow_id': workflow_id,
            'pillar_content': pillar_content,
            'derivative_content': derivative_content,
            'schedule': schedule,
            'monitoring_dashboard': f'/campaigns/{workflow_id}'
        }
    
    def create_publishing_schedule(self, content_items: list, strategy: str) -> list:
        """Create optimal publishing schedule."""
        
        schedules = []
        
        if strategy == 'distributed':
            # Spread content over time
            base_time = datetime.now() + timedelta(hours=24)
            interval = timedelta(hours=4)
            
            for i, item in enumerate(content_items):
                schedules.append({
                    'content_id': item['id'],
                    'platform': item['platform'],
                    'scheduled_time': base_time + (interval * i)
                })
        
        elif strategy == 'burst':
            # Publish all at once
            publish_time = datetime.now() + timedelta(hours=24)
            
            for item in content_items:
                schedules.append({
                    'content_id': item['id'],
                    'platform': item['platform'],
                    'scheduled_time': publish_time
                })
        
        return schedules
```

### State Management Patterns

#### Pattern: Feature State Machine
Implement features with clear state transitions:

```python
from enum import Enum
from typing import Optional

class FeatureState(Enum):
    DISABLED = "disabled"
    INITIALIZING = "initializing"
    READY = "ready"
    PROCESSING = "processing"
    ERROR = "error"
    DEGRADED = "degraded"
    MAINTENANCE = "maintenance"

class StatefulFeature:
    """Feature with explicit state management."""
    
    def __init__(self, feature_name: str):
        self.name = feature_name
        self.state = FeatureState.DISABLED
        self.state_history = []
        self.error_count = 0
        self.last_error: Optional[Exception] = None
    
    async def initialize(self) -> bool:
        """Initialize feature with state tracking."""
        
        await self.transition_to(FeatureState.INITIALIZING)
        
        try:
            # Perform initialization
            await self.check_dependencies()
            await self.load_configuration()
            await self.warm_up_resources()
            
            await self.transition_to(FeatureState.READY)
            return True
            
        except Exception as e:
            self.last_error = e
            await self.transition_to(FeatureState.ERROR)
            return False
    
    async def transition_to(self, new_state: FeatureState):
        """Manage state transitions with validation."""
        
        # Validate transition
        if not self.is_valid_transition(self.state, new_state):
            raise ValueError(f"Invalid transition from {self.state} to {new_state}")
        
        # Record transition
        self.state_history.append({
            'from': self.state,
            'to': new_state,
            'timestamp': datetime.now(),
            'error': self.last_error
        })
        
        # Update state
        old_state = self.state
        self.state = new_state
        
        # Trigger state change handlers
        await self.on_state_change(old_state, new_state)
        
        # Log transition
        logger.info(f"Feature {self.name}: {old_state.value} → {new_state.value}")
    
    def is_valid_transition(self, from_state: FeatureState, to_state: FeatureState) -> bool:
        """Define valid state transitions."""
        
        valid_transitions = {
            FeatureState.DISABLED: [FeatureState.INITIALIZING],
            FeatureState.INITIALIZING: [FeatureState.READY, FeatureState.ERROR],
            FeatureState.READY: [FeatureState.PROCESSING, FeatureState.MAINTENANCE, FeatureState.ERROR],
            FeatureState.PROCESSING: [FeatureState.READY, FeatureState.ERROR, FeatureState.DEGRADED],
            FeatureState.ERROR: [FeatureState.INITIALIZING, FeatureState.DISABLED],
            FeatureState.DEGRADED: [FeatureState.READY, FeatureState.ERROR, FeatureState.MAINTENANCE],
            FeatureState.MAINTENANCE: [FeatureState.READY, FeatureState.DISABLED]
        }
        
        return to_state in valid_transitions.get(from_state, [])
    
    async def on_state_change(self, old_state: FeatureState, new_state: FeatureState):
        """Handle state change events."""
        
        # Error state handling
        if new_state == FeatureState.ERROR:
            self.error_count += 1
            
            # Auto-recovery after 3 errors
            if self.error_count >= 3:
                logger.warning(f"Feature {self.name} failed 3 times, attempting recovery")
                await self.transition_to(FeatureState.INITIALIZING)
        
        # Degraded state handling
        elif new_state == FeatureState.DEGRADED:
            # Reduce resource usage
            await self.reduce_resource_usage()
            
            # Schedule recovery check
            asyncio.create_task(self.schedule_recovery_check())
        
        # Ready state handling
        elif new_state == FeatureState.READY:
            self.error_count = 0  # Reset error count
            self.last_error = None
```

### Event-Driven Architecture Patterns

#### Pattern: Event Bus Implementation
```python
class EventBus:
    """Central event bus for decoupled communication."""
    
    def __init__(self):
        self.subscribers = defaultdict(list)
        self.event_history = deque(maxlen=1000)
    
    async def publish(self, event_type: str, data: dict):
        """Publish event to all subscribers."""
        
        event = {
            'type': event_type,
            'data': data,
            'timestamp': datetime.now(),
            'id': str(uuid.uuid4())
        }
        
        # Store in history
        self.event_history.append(event)
        
        # Notify subscribers
        tasks = []
        for subscriber in self.subscribers[event_type]:
            tasks.append(subscriber(event))
        
        # Execute all handlers in parallel
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Log any failures
        for i, result in enumerate(results):
            if isinstance(result, Exception):
                logger.error(f"Event handler failed: {result}")
        
        return event['id']
    
    def subscribe(self, event_type: str, handler):
        """Subscribe to event type."""
        self.subscribers[event_type].append(handler)
    
    async def replay_events(self, event_type: str, since: datetime):
        """Replay events for recovery or debugging."""
        
        relevant_events = [
            e for e in self.event_history
            if e['type'] == event_type and e['timestamp'] > since
        ]
        
        for event in relevant_events:
            await self.publish(event['type'], event['data'])

# Global event bus
event_bus = EventBus()

# Example usage in content generation
async def on_content_generated(event):
    """Handler for content generation events."""
    content_id = event['data']['content_id']
    
    # Trigger secondary workflows
    await analyze_content_quality(content_id)
    await update_content_index(content_id)
    await check_plagiarism(content_id)
    
# Subscribe to events
event_bus.subscribe('content.generated', on_content_generated)
```

## Quick Reference Commands

### Development Commands
```bash
# Start with wizard
make start

# Quick development start (skip wizard)
docker-compose up -d && make logs

# Reset and rebuild
make clean && make build && make start

# Check feature status
docker-compose exec app python -c "import main; main.log_startup_config()"