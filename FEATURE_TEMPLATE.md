# Feature Implementation Template

## Feature Name: [YOUR FEATURE NAME]

### 1. Feature Classification
```yaml
Category: [CORE | FREE OPTIONAL | PAID OPTIONAL]
Monthly Cost: $[0 | X]
Dependencies: [List any external services]
Environment Variables:
  - FEATURE_NAME_ENABLED: "true|false"
  - FEATURE_API_KEY: "optional-api-key"
```

### 2. Backend Implementation Checklist

#### Configuration (main.py - Configuration Section)
```python
# [CATEGORY]: [Feature Description]
FEATURE_NAME_ENABLED = os.getenv("FEATURE_NAME_ENABLED", "false").lower() == "true"
FEATURE_API_KEY = os.getenv("FEATURE_API_KEY", "")  # If needed
```

#### Startup Logging (main.py - startup_event)
```python
# Add to startup_event() function
if FEATURE_NAME_ENABLED:
    logger.info(f"✅ Feature Name: Enabled")
    if FEATURE_API_KEY:
        logger.info(f"   └─ API Key: Configured")
else:
    logger.info(f"❌ Feature Name: Disabled (set FEATURE_NAME_ENABLED=true)")
```

#### Database Schema (main.py - init_db)
```sql
-- Add to init_db() function if needed
CREATE TABLE IF NOT EXISTS feature_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- Feature specific columns
    data JSONB NOT NULL DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_feature_data_created_at 
ON feature_data(created_at DESC);
```

#### API Endpoint (main.py - API Routes Section)
```python
@app.post("/api/feature-name", response_model=FeatureResponse)
async def feature_endpoint(
    request: FeatureRequest,
    api_key: str = Depends(verify_api_key),
    db=Depends(get_db)
):
    """
    Feature description.
    
    Category: [CATEGORY]
    Cost: $[X] per call
    """
    if not FEATURE_NAME_ENABLED:
        raise HTTPException(
            status_code=501,
            detail="Feature is disabled. Enable with FEATURE_NAME_ENABLED=true"
        )
    
    try:
        # Implementation
        result = await process_feature(request)
        
        # Track usage if applicable
        if TRACK_API_USAGE:
            await track_api_usage(
                db=db,
                endpoint="feature-name",
                tokens_used=result.get("tokens", 0),
                estimated_cost=calculate_cost(result),
                success=True
            )
        
        # Trigger webhooks if configured
        if WEBHOOK_FEATURE_URL:
            await trigger_webhook("feature_completed", result)
        
        return FeatureResponse(**result)
        
    except Exception as e:
        logger.error(f"Feature error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
```

### 3. Frontend Implementation Checklist

#### Page Component (web/src/components/pages/FeaturePage.tsx)
```typescript
import { useState, useEffect } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Loader } from '@/components/ui/loader';
import { Warning, CheckCircle } from '@phosphor-icons/react';

export function FeaturePage() {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const isEnabled = import.meta.env.VITE_FEATURE_NAME_ENABLED === 'true';
  
  if (!isEnabled) {
    return (
      <Card className="max-w-2xl mx-auto mt-8">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Warning className="text-yellow-500" />
            Feature Disabled
          </CardTitle>
        </CardHeader>
        <CardContent>
          <p>This feature is currently disabled.</p>
          <p className="mt-2 text-sm text-gray-600">
            Enable it by setting FEATURE_NAME_ENABLED=true in your environment.
          </p>
        </CardContent>
      </Card>
    );
  }
  
  const handleFeatureAction = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/feature-name', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': import.meta.env.VITE_API_KEY
        },
        body: JSON.stringify({ /* request data */ })
      });
      
      if (!response.ok) throw new Error('Failed to process feature');
      
      const data = await response.json();
      setResult(data);
    } catch (error) {
      console.error('Feature error:', error);
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <div className="container mx-auto p-6">
      <Card>
        <CardHeader>
          <CardTitle>Feature Name</CardTitle>
        </CardHeader>
        <CardContent>
          <Button 
            onClick={handleFeatureAction}
            disabled={loading}
          >
            {loading ? <Loader /> : 'Execute Feature'}
          </Button>
          
          {result && (
            <div className="mt-4 p-4 bg-green-50 rounded">
              <CheckCircle className="text-green-500" />
              {/* Display results */}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
```

#### Add Route (web/src/App.tsx)
```typescript
// Add import
import { FeaturePage } from './components/pages/FeaturePage';

// Add route
{ path: '/feature', element: <FeaturePage /> }

// Add navigation link (if applicable)
<Link to="/feature" className="nav-link">Feature Name</Link>
```

### 4. Testing Implementation

#### API Test (test_api.py)
```python
def test_feature_name():
    """Test feature with toggle pattern."""
    
    # Test disabled state
    os.environ['FEATURE_NAME_ENABLED'] = 'false'
    response = client.post('/api/feature-name', 
                          json={"test": "data"},
                          headers={'X-API-Key': 'test-key'})
    assert response.status_code == 501
    
    # Test enabled state
    os.environ['FEATURE_NAME_ENABLED'] = 'true'
    response = client.post('/api/feature-name',
                          json={"test": "data"},
                          headers={'X-API-Key': 'test-key'})
    assert response.status_code == 200
    assert 'result' in response.json()
    
    # Test without API key
    response = client.post('/api/feature-name',
                          json={"test": "data"})
    assert response.status_code == 403
```

### 5. Documentation Updates

#### Update .env.example
```bash
# [CATEGORY]: Feature Name
FEATURE_NAME_ENABLED=false  # Set to true to enable
FEATURE_API_KEY=            # Required if using external service
```

#### Update README.md
```markdown
### Feature Name
**Category:** [Category]  
**Cost:** $[X]/month  
**Status:** Optional Enhancement

[Feature description and benefits]

To enable:
1. Set `FEATURE_NAME_ENABLED=true` in `.env`
2. (If needed) Add `FEATURE_API_KEY=your-key`
3. Restart services: `make restart`
```

### 6. Deployment Considerations

- [ ] Feature flag defaults to disabled
- [ ] API keys are optional with graceful fallback
- [ ] Database migrations are idempotent
- [ ] Error messages guide users to enable feature
- [ ] Cost tracking is implemented
- [ ] Webhooks are fired for automation
- [ ] Analytics events are tracked
- [ ] Documentation is complete

### 7. Cost Analysis

```yaml
Development Time: [X hours]
Infrastructure Cost: $[X]/month
API Costs: $[X]/1000 calls
Expected Usage: [X] calls/month
Total Monthly Cost: $[X]
ROI: [Describe value/benefits]
```

### 8. Rollback Plan

If feature needs to be disabled:
1. Set `FEATURE_NAME_ENABLED=false`
2. Feature automatically becomes inactive
3. Data remains in database for future re-enable
4. No code changes required

### 9. Monitoring

```sql
-- Monitor feature usage
SELECT 
    COUNT(*) as total_calls,
    AVG(response_time_ms) as avg_response_time,
    COUNT(CASE WHEN success THEN 1 END) as successful_calls,
    SUM(estimated_cost) as total_cost
FROM api_usage
WHERE endpoint = 'feature-name'
AND created_at > NOW() - INTERVAL '7 days';
```

### 10. Sign-off

- [ ] Backend implementation complete
- [ ] Frontend implementation complete
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Cost analysis approved
- [ ] Deployed to staging
- [ ] Deployed to production

**Implemented by:** [Your Name]  
**Reviewed by:** [Reviewer Name]  
**Date:** [YYYY-MM-DD]
