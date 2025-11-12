# SPLANTS Developer Guide

## Quick Start for New Developers

### 1. Initial Setup (5 minutes)
```bash
# Clone and setup
git clone https://github.com/yourusername/splants.git
cd splants

# Run interactive setup wizard
make start

# The wizard will:
# - Check Docker installation
# - Create .env file with API keys
# - Initialize database
# - Start all services
# - Open the web interface
```

### 2. Understanding the Architecture

```
SPLANTS/
├── main.py                 # Entire backend (3900 lines, intentionally monolithic)
├── web/                    # React frontend
│   ├── src/
│   │   ├── components/
│   │   │   ├── pages/     # Page components (Dashboard, Generate, etc.)
│   │   │   └── ui/        # Reusable UI components
│   │   └── App.tsx        # Router and main app
├── docker-compose.yml      # 3 services: db, app, web
├── Makefile               # Developer commands
└── .env                   # Configuration (created by wizard)
```

### 3. Development Workflow

#### Daily Development
```bash
# Start development environment
make dev

# Watch logs in another terminal
make logs

# Make changes to main.py or web/
# Services auto-reload on save
```

#### Adding a New Feature

**Step 1: Categorize Your Feature**
```python
# In main.py, add to configuration section:

# FREE OPTIONAL ENHANCEMENT: Your Feature Name
YOUR_FEATURE_ENABLED = os.getenv("YOUR_FEATURE_ENABLED", "false").lower() == "true"

# Or for paid features:
# PAID OPTIONAL ENHANCEMENT: Your Feature (+$X/month)
YOUR_SERVICE_API_KEY = os.getenv("YOUR_SERVICE_API_KEY", "")
```

**Step 2: Add Startup Logging**
```python
# In startup_event() function:
if YOUR_FEATURE_ENABLED:
    logger.info("✅ Your Feature: Enabled")
else:
    logger.info("❌ Your Feature: Disabled (set YOUR_FEATURE_ENABLED=true to enable)")
```

**Step 3: Implement with Toggle Pattern**
```python
@app.post("/api/your-feature")
async def your_feature_endpoint(
    request: YourRequest,
    api_key: str = Depends(verify_api_key)
):
    """Your feature description.
    
    Category: FREE OPTIONAL ENHANCEMENT
    Cost: None
    """
    if not YOUR_FEATURE_ENABLED:
        raise HTTPException(
            status_code=501,
            detail="This feature is disabled. Set YOUR_FEATURE_ENABLED=true to enable."
        )
    
    # Your implementation here
    return {"status": "success"}
```

**Step 4: Add Frontend UI**
```typescript
// web/src/components/pages/YourFeaturePage.tsx
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Sparkle } from '@phosphor-icons/react';

export function YourFeaturePage() {
  const isEnabled = import.meta.env.VITE_YOUR_FEATURE_ENABLED === 'true';
  
  if (!isEnabled) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Feature Disabled</CardTitle>
        </CardHeader>
        <CardContent>
          <p>Enable this feature by setting YOUR_FEATURE_ENABLED=true</p>
        </CardContent>
      </Card>
    );
  }
  
  return (
    <div className="container mx-auto p-6">
      {/* Your feature UI */}
    </div>
  );
}
```

### 4. Testing Your Changes

```bash
# Run API tests
docker-compose exec app pytest test_api.py -v

# Test specific feature
docker-compose exec app pytest test_api.py::test_your_feature -v

# Manual API testing
curl -X POST http://localhost:8080/api/your-feature \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

### 5. Database Operations

```bash
# Access database
make db-shell

# Common queries
SELECT * FROM content ORDER BY created_at DESC LIMIT 10;
SELECT COUNT(*) FROM api_usage WHERE created_at > NOW() - INTERVAL '24 hours';
SELECT * FROM analytics_events WHERE event_type = 'page_view';
```

### 6. Debugging Tips

#### Check Service Status
```bash
# View all services
docker-compose ps

# Check specific service logs
docker-compose logs app -f
docker-compose logs web -f
docker-compose logs db -f
```

#### Common Issues and Fixes

**Issue: "Connection refused" errors**
```bash
# Ensure all services are healthy
docker-compose ps
# Restart if needed
make restart
```

**Issue: Database migrations not applied**
```bash
# Manually run migrations
docker-compose exec app python -c "import main; main.init_db()"
```

**Issue: Frontend not updating**
```bash
# Clear cache and rebuild
cd web && npm run build
docker-compose restart web
```

### 7. Cost Management

Monitor AI API usage:
```sql
-- Daily cost report
SELECT 
    DATE(created_at) as date,
    COUNT(*) as api_calls,
    SUM(estimated_cost) as total_cost,
    AVG(estimated_cost) as avg_cost_per_call
FROM api_usage
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

Set budget limits:
```bash
# In .env
MONTHLY_AI_BUDGET=50  # Stops AI calls after $50/month
```

### 8. Deployment Checklist

Before deploying:
- [ ] All tests pass: `make test`
- [ ] Environment variables documented
- [ ] Database migrations included
- [ ] Cost implications documented
- [ ] Feature toggles default to safe values
- [ ] Error messages are user-friendly
- [ ] Logging added for new features
- [ ] README updated if needed

### 9. Getting Help

1. Check the architecture diagram in `.github/copilot-instructions.md`
2. Search in `main.py` (Ctrl+F) - everything is in one file
3. Look for similar patterns in existing code
4. Check startup logs: `docker-compose logs app | grep "✅\|❌"`

### 10. Feature Categories Reference

| Category | Monthly Cost | Example Features |
|----------|-------------|------------------|
| Core | $0 (included) | Content generation, Database, API |
| Free Optional | $0 | Analytics, A/B Testing, Webhooks |
| Paid Optional | Varies | Claude AI (+$20), Redis (+$15), Premium APIs |

## Advanced Development Workflows

### Implementing Agentive Features

#### Step-by-Step: Self-Healing Feature Implementation

1. **Define Health Metrics**
```python
# In main.py, add health tracking
class FeatureHealth:
    def __init__(self, feature_name: str):
        self.name = feature_name
        self.metrics = {
            'request_count': 0,
            'error_count': 0,
            'avg_response_time': 0.0,
            'last_success': None,
            'last_error': None
        }
    
    async def check_health(self) -> bool:
        error_rate = self.metrics['error_count'] / max(self.metrics['request_count'], 1)
        return error_rate < 0.1 and self.metrics['avg_response_time'] < 2.0
```

2. **Implement Recovery Logic**
```python
async def auto_recover_feature(feature_name: str):
    """Automatic recovery workflow."""
    logger.info(f"Initiating recovery for {feature_name}")
    
    # Step 1: Clear caches
    if CACHE_ENABLED:
        await redis_cache.delete(f"{feature_name}:*")
    
    # Step 2: Reset connections
    await reset_api_connections()
    
    # Step 3: Test with simple request
    test_passed = await test_feature_health(feature_name)
    
    if test_passed:
        logger.info(f"Recovery successful for {feature_name}")
    else:
        logger.error(f"Recovery failed for {feature_name}, switching to fallback")
```

3. **Add Monitoring Dashboard**
```python
@app.get("/api/health/{feature_name}")
async def get_feature_health(
    feature_name: str,
    api_key: str = Depends(verify_api_key)
):
    """Get real-time health metrics for a feature."""
    
    health = feature_health_registry.get(feature_name)
    if not health:
        raise HTTPException(404, "Feature not found")
    
    return {
        'feature': feature_name,
        'status': 'healthy' if await health.check_health() else 'unhealthy',
        'metrics': health.metrics,
        'recommendations': health.get_recommendations()
    }
```

### Complex Workflow Implementation

#### Multi-Stage Content Pipeline

```python
class ContentPipeline:
    """Complex multi-stage content generation pipeline."""
    
    def __init__(self):
        self.stages = []
        self.checkpoints = {}
    
    def add_stage(self, name: str, handler, required: bool = True):
        """Add processing stage to pipeline."""
        self.stages.append({
            'name': name,
            'handler': handler,
            'required': required
        })
    
    async def execute(self, initial_data: dict) -> dict:
        """Execute pipeline with checkpointing."""
        
        pipeline_id = str(uuid.uuid4())
        data = initial_data.copy()
        
        for stage in self.stages:
            try:
                logger.info(f"Pipeline {pipeline_id}: Executing {stage['name']}")
                
                # Execute stage
                result = await stage['handler'](data)
                
                # Save checkpoint
                self.checkpoints[stage['name']] = result
                
                # Update data for next stage
                data.update(result)
                
            except Exception as e:
                if stage['required']:
                    logger.error(f"Pipeline {pipeline_id}: Failed at {stage['name']}: {e}")
                    raise
                else:
                    logger.warning(f"Pipeline {pipeline_id}: Optional stage {stage['name']} failed: {e}")
        
        return data

# Example usage
content_pipeline = ContentPipeline()

# Add stages
content_pipeline.add_stage('research', research_topic)
content_pipeline.add_stage('outline', generate_outline)
content_pipeline.add_stage('draft', generate_draft)
content_pipeline.add_stage('optimize', optimize_for_seo)
content_pipeline.add_stage('enhance', enhance_with_ai, required=False)
content_pipeline.add_stage('publish', schedule_publishing)

# Execute
result = await content_pipeline.execute({
    'topic': 'AI Marketing Strategies',
    'keywords': ['AI', 'marketing', 'automation']
})
```

### Database Migration Patterns

#### Safe Migration Strategy

```python
# migrations/001_add_feature.py
async def upgrade():
    """Apply migration with safety checks."""
    
    async with db_pool.acquire() as conn:
        # Check if migration already applied
        exists = await conn.fetchval('''
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_name = 'feature_table'
            )
        ''')
        
        if exists:
            logger.info("Migration already applied, skipping")
            return
        
        # Apply migration in transaction
        async with conn.transaction():
            # Create table
            await conn.execute('''
                CREATE TABLE feature_table (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    created_at TIMESTAMPTZ DEFAULT NOW(),
                    data JSONB NOT NULL DEFAULT '{}'
                )
            ''')
            
            # Create indexes
            await conn.execute('''
                CREATE INDEX idx_feature_created_at 
                ON feature_table(created_at DESC)
            ''')
            
            # Verify migration
            count = await conn.fetchval('SELECT COUNT(*) FROM feature_table')
            assert count == 0, "Table should be empty after creation"
            
        logger.info("Migration applied successfully")

async def rollback():
    """Safely rollback migration."""
    
    async with db_pool.acquire() as conn:
        # Check dependencies
        dependent_tables = await conn.fetch('''
            SELECT table_name 
            FROM information_schema.table_constraints 
            WHERE constraint_type = 'FOREIGN KEY' 
            AND foreign_table_name = 'feature_table'
        ''')
        
        if dependent_tables:
            raise Exception(f"Cannot rollback: tables depend on feature_table: {dependent_tables}")
        
        # Safe rollback
        await conn.execute('DROP TABLE IF EXISTS feature_table CASCADE')
        logger.info("Migration rolled back")
```

### Performance Optimization Patterns

#### Caching Strategy Implementation

```python
class SmartCache:
    """Intelligent caching with predictive prefetching."""
    
    def __init__(self):
        self.cache_stats = defaultdict(lambda: {'hits': 0, 'misses': 0})
    
    async def get_with_prefetch(self, key: str, generator, prefetch_related: list = None):
        """Get from cache with predictive prefetching."""
        
        # Try cache first
        value = await redis_cache.get(key)
        if value:
            self.cache_stats[key]['hits'] += 1
            
            # Prefetch related items in background
            if prefetch_related:
                asyncio.create_task(self.prefetch_related(prefetch_related))
            
            return json.loads(value)
        
        # Cache miss
        self.cache_stats[key]['misses'] += 1
        
        # Generate value
        value = await generator()
        
        # Store in cache with smart TTL
        ttl = self.calculate_smart_ttl(key)
        await redis_cache.setex(key, ttl, json.dumps(value))
        
        return value
    
    def calculate_smart_ttl(self, key: str) -> int:
        """Calculate TTL based on access patterns."""
        
        stats = self.cache_stats[key]
        hit_rate = stats['hits'] / max(stats['hits'] + stats['misses'], 1)
        
        if hit_rate > 0.8:
            return 3600  # 1 hour for hot items
        elif hit_rate > 0.5:
            return 1800  # 30 minutes for warm items
        else:
            return 300   # 5 minutes for cold items
    
    async def prefetch_related(self, keys: list):
        """Prefetch related items based on access patterns."""
        
        for key in keys:
            # Check if key is likely to be accessed
            if self.predict_access_probability(key) > 0.7:
                # Prefetch in background
                asyncio.create_task(self.warm_cache(key))
```

### Error Handling Patterns

#### Comprehensive Error Recovery

```python
class ErrorRecoveryManager:
    """Advanced error handling with recovery strategies."""
    
    def __init__(self):
        self.error_strategies = {}
        self.error_history = deque(maxlen=100)
    
    def register_strategy(self, error_type: type, strategy):
        """Register recovery strategy for error type."""
        self.error_strategies[error_type] = strategy
    
    async def handle_with_recovery(self, func, *args, **kwargs):
        """Execute function with automatic error recovery."""
        
        max_attempts = 3
        attempt = 0
        last_error = None
        
        while attempt < max_attempts:
            try:
                return await func(*args, **kwargs)
                
            except Exception as e:
                attempt += 1
                last_error = e
                
                # Record error
                self.error_history.append({
                    'error': str(e),
                    'type': type(e).__name__,
                    'timestamp': datetime.now(),
                    'attempt': attempt
                })
                
                # Find recovery strategy
                strategy = self.error_strategies.get(type(e))
                
                if strategy:
                    logger.info(f"Attempting recovery using {strategy.__name__}")
                    
                    # Execute recovery strategy
                    recovery_result = await strategy(e, attempt)
                    
                    if recovery_result.get('retry'):
                        # Wait before retry
                        await asyncio.sleep(recovery_result.get('wait', 1))
                        continue
                    elif recovery_result.get('fallback'):
                        # Use fallback value
                        return recovery_result['fallback']
                
                # No strategy found, use exponential backoff
                wait_time = 2 ** attempt
                logger.warning(f"Attempt {attempt} failed, waiting {wait_time}s")
                await asyncio.sleep(wait_time)
        
        # All attempts failed
        raise last_error

# Register recovery strategies
error_manager = ErrorRecoveryManager()

async def api_timeout_recovery(error: Exception, attempt: int):
    """Recovery strategy for API timeouts."""
    
    if attempt == 1:
        # First retry: Quick retry
        return {'retry': True, 'wait': 0.5}
    elif attempt == 2:
        # Second retry: Clear cache and retry
        await redis_cache.flushdb()
        return {'retry': True, 'wait': 2}
    else:
        # Final attempt: Use fallback
        return {'fallback': {'content': 'Fallback content', 'quality_score': 0.5}}

error_manager.register_strategy(TimeoutError, api_timeout_recovery)
```

Remember: Always categorize new features and make optional ones toggleable!
