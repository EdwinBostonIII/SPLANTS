# SPLANTS Workflow Automation Guide

## Agentive Workflow Patterns for Marketing Automation

This guide provides comprehensive patterns for implementing intelligent, self-managing workflows in the SPLANTS Marketing Engine.

## Table of Contents

1. [Core Workflow Concepts](#core-workflow-concepts)
2. [Campaign Automation](#campaign-automation)
3. [Content Pipeline Automation](#content-pipeline-automation)
4. [Quality Assurance Workflows](#quality-assurance-workflows)
5. [Cost Optimization Workflows](#cost-optimization-workflows)
6. [Integration Workflows](#integration-workflows)
7. [Monitoring and Analytics](#monitoring-and-analytics)
8. [Advanced Patterns](#advanced-patterns)

## Core Workflow Concepts

### Workflow Architecture

SPLANTS workflows follow these principles:
- **Autonomous**: Self-managing with minimal human intervention
- **Resilient**: Self-healing with automatic error recovery
- **Optimized**: Cost-aware and performance-optimized
- **Observable**: Comprehensive logging and monitoring
- **Modular**: Composable and reusable components

### Basic Workflow Structure

```python
class Workflow:
    """Base workflow class for all automation."""
    
    def __init__(self, name: str):
        self.name = name
        self.steps = []
        self.state = {}
        self.checkpoints = {}
        self.error_handlers = {}
    
    async def execute(self, context: dict) -> dict:
        """Execute workflow with automatic checkpointing."""
        
        workflow_run_id = str(uuid.uuid4())
        
        for step in self.steps:
            try:
                # Execute step
                result = await step.execute(context)
                
                # Save checkpoint
                self.checkpoints[step.name] = result
                
                # Update context
                context.update(result)
                
            except Exception as e:
                # Handle error
                if handler := self.error_handlers.get(step.name):
                    context = await handler(e, context)
                else:
                    raise
        
        return context
```

## Campaign Automation

### Multi-Channel Campaign Workflow

```python
class MarketingCampaignWorkflow:
    """Automated multi-channel marketing campaign."""
    
    async def launch_campaign(self, config: dict):
        """Launch complete marketing campaign."""
        
        # Phase 1: Research and Planning
        research_data = await self.research_phase(config['topic'])
        
        # Phase 2: Content Creation
        content_suite = await self.content_creation_phase(
            research_data,
            config['platforms'],
            config['content_types']
        )
        
        # Phase 3: Optimization
        optimized_content = await self.optimization_phase(content_suite)
        
        # Phase 4: Scheduling
        schedule = await self.scheduling_phase(
            optimized_content,
            config['duration_days']
        )
        
        # Phase 5: Publishing
        published_items = await self.publishing_phase(schedule)
        
        # Phase 6: Monitoring
        await self.setup_monitoring(published_items)
        
        return {
            'campaign_id': str(uuid.uuid4()),
            'content_created': len(content_suite),
            'platforms': config['platforms'],
            'schedule': schedule,
            'monitoring_url': f'/campaigns/{campaign_id}'
        }
    
    async def research_phase(self, topic: str):
        """AI-powered research phase."""
        
        # Competitive analysis
        competitors = await self.analyze_competitors(topic)
        
        # Keyword research
        keywords = await self.research_keywords(topic)
        
        # Audience analysis
        audience_insights = await self.analyze_audience(topic)
        
        return {
            'competitors': competitors,
            'keywords': keywords,
            'audience': audience_insights,
            'content_gaps': self.identify_content_gaps(competitors)
        }
    
    async def content_creation_phase(self, research: dict, platforms: list, types: list):
        """Generate content suite for campaign."""
        
        content_items = []
        
        # Generate pillar content
        pillar = await content_engine.generate_content(
            ContentRequest(
                content_type='blog',
                topic=research['topic'],
                keywords=research['keywords'][:5],
                length=2000,
                seo_optimize=True
            )
        )
        content_items.append(pillar)
        
        # Generate derivative content for each platform
        for platform in platforms:
            for content_type in types:
                if self.is_compatible(platform, content_type):
                    content = await self.generate_platform_content(
                        pillar_content=pillar,
                        platform=platform,
                        content_type=content_type,
                        research=research
                    )
                    content_items.append(content)
        
        return content_items
    
    async def optimization_phase(self, content_suite: list):
        """Optimize all content for maximum impact."""
        
        optimized = []
        
        for content in content_suite:
            # A/B testing variants
            variants = await self.create_variants(content)
            
            # SEO optimization
            seo_optimized = await self.enhance_seo(content)
            
            # Platform-specific optimization
            platform_optimized = await self.optimize_for_platform(seo_optimized)
            
            optimized.append({
                'original': content,
                'optimized': platform_optimized,
                'variants': variants
            })
        
        return optimized
    
    async def scheduling_phase(self, content: list, duration_days: int):
        """Create optimal publishing schedule."""
        
        schedule = []
        
        # Analyze best posting times for each platform
        best_times = await self.analyze_best_times()
        
        # Distribute content over campaign duration
        for i, item in enumerate(content):
            platform = item['platform']
            
            # Calculate optimal publish time
            day_offset = i % duration_days
            time_slot = best_times[platform][i % len(best_times[platform])]
            
            publish_time = datetime.now() + timedelta(
                days=day_offset,
                hours=time_slot['hour'],
                minutes=time_slot['minute']
            )
            
            schedule.append({
                'content_id': item['id'],
                'platform': platform,
                'publish_time': publish_time,
                'priority': item.get('priority', 'normal')
            })
        
        return sorted(schedule, key=lambda x: x['publish_time'])
```

## Content Pipeline Automation

### Intelligent Content Pipeline

```python
class IntelligentContentPipeline:
    """Smart content generation pipeline with ML optimization."""
    
    def __init__(self):
        self.performance_history = []
        self.optimization_model = None
    
    async def generate_optimized_content(self, request: ContentRequest):
        """Generate content with continuous optimization."""
        
        # Step 1: Analyze historical performance
        best_practices = await self.analyze_best_practices(request.content_type)
        
        # Step 2: Enhance request with insights
        enhanced_request = self.enhance_request(request, best_practices)
        
        # Step 3: Generate with multiple models
        candidates = await self.generate_candidates(enhanced_request)
        
        # Step 4: Score and rank candidates
        scored_candidates = await self.score_candidates(candidates)
        
        # Step 5: Select winner
        winner = self.select_winner(scored_candidates)
        
        # Step 6: Post-process and polish
        final_content = await self.post_process(winner)
        
        # Step 7: Learn from result
        asyncio.create_task(self.learn_from_result(final_content))
        
        return final_content
    
    async def analyze_best_practices(self, content_type: str):
        """Analyze what has worked well in the past."""
        
        async with db_pool.acquire() as conn:
            # Get top performing content
            top_content = await conn.fetch('''
                SELECT c.*, 
                       AVG(a.engagement_rate) as avg_engagement
                FROM content c
                JOIN analytics_events a ON c.id = a.content_id
                WHERE c.content_type = $1
                AND c.quality_score > 0.8
                GROUP BY c.id
                ORDER BY avg_engagement DESC
                LIMIT 20
            ''', content_type)
        
        # Extract patterns
        patterns = {
            'optimal_length': self.calculate_optimal_length(top_content),
            'best_keywords': self.extract_top_keywords(top_content),
            'effective_tones': self.identify_effective_tones(top_content),
            'winning_structures': self.analyze_structures(top_content)
        }
        
        return patterns
    
    async def generate_candidates(self, request: ContentRequest):
        """Generate multiple content candidates."""
        
        candidates = []
        
        # Strategy 1: Standard generation
        standard = await content_engine.generate_content(request)
        candidates.append({'strategy': 'standard', 'content': standard})
        
        # Strategy 2: Premium multi-model
        if ANTHROPIC_API_KEY:
            premium = await content_engine.generate_premium_content(request)
            candidates.append({'strategy': 'premium', 'content': premium})
        
        # Strategy 3: Template-based
        if template := self.find_matching_template(request):
            templated = await self.generate_from_template(template, request)
            candidates.append({'strategy': 'template', 'content': templated})
        
        return candidates
    
    async def score_candidates(self, candidates: list):
        """Score candidates using multiple criteria."""
        
        scored = []
        
        for candidate in candidates:
            scores = {
                'quality': self.calculate_quality_score(candidate['content']),
                'seo': self.calculate_seo_score(candidate['content']),
                'readability': self.calculate_readability_score(candidate['content']),
                'uniqueness': await self.check_uniqueness(candidate['content']),
                'predicted_performance': await self.predict_performance(candidate['content'])
            }
            
            # Weighted average
            total_score = (
                scores['quality'] * 0.3 +
                scores['seo'] * 0.2 +
                scores['readability'] * 0.2 +
                scores['uniqueness'] * 0.15 +
                scores['predicted_performance'] * 0.15
            )
            
            scored.append({
                **candidate,
                'scores': scores,
                'total_score': total_score
            })
        
        return sorted(scored, key=lambda x: x['total_score'], reverse=True)
```

## Quality Assurance Workflows

### Automated QA Pipeline

```python
class QualityAssuranceWorkflow:
    """Comprehensive quality assurance for content."""
    
    async def validate_content(self, content_id: int):
        """Run full QA validation suite."""
        
        # Get content
        content = await self.get_content(content_id)
        
        # Run validation checks
        checks = {
            'grammar': await self.check_grammar(content),
            'plagiarism': await self.check_plagiarism(content),
            'brand_voice': await self.check_brand_voice(content),
            'factual_accuracy': await self.verify_facts(content),
            'seo_compliance': await self.check_seo_compliance(content),
            'legal_compliance': await self.check_legal_compliance(content)
        }
        
        # Calculate overall QA score
        qa_score = self.calculate_qa_score(checks)
        
        # Determine action
        if qa_score < 0.6:
            await self.flag_for_review(content_id, checks)
        elif qa_score < 0.8:
            await self.auto_fix_issues(content_id, checks)
        else:
            await self.approve_content(content_id)
        
        return {
            'content_id': content_id,
            'qa_score': qa_score,
            'checks': checks,
            'status': self.get_qa_status(qa_score)
        }
    
    async def auto_fix_issues(self, content_id: int, issues: dict):
        """Automatically fix detected issues."""
        
        content = await self.get_content(content_id)
        
        # Fix grammar issues
        if issues['grammar']['score'] < 0.8:
            content = await self.fix_grammar(content)
        
        # Enhance SEO
        if issues['seo_compliance']['score'] < 0.7:
            content = await self.enhance_seo(content)
        
        # Adjust brand voice
        if issues['brand_voice']['score'] < 0.7:
            content = await self.adjust_brand_voice(content)
        
        # Save fixed content
        await self.update_content(content_id, content)
        
        # Re-run validation
        return await self.validate_content(content_id)
```

## Cost Optimization Workflows

### Dynamic Cost Optimization

```python
class CostOptimizationWorkflow:
    """Intelligent cost management and optimization."""
    
    async def optimize_generation_cost(self, request: ContentRequest):
        """Generate content with optimal cost/quality balance."""
        
        # Analyze budget status
        budget_status = await self.get_budget_status()
        
        # Determine strategy based on budget
        if budget_status['remaining_percentage'] < 20:
            # Low budget: Maximum savings mode
            strategy = 'economy'
        elif budget_status['remaining_percentage'] < 50:
            # Medium budget: Balanced mode
            strategy = 'balanced'
        else:
            # High budget: Quality mode
            strategy = 'quality'
        
        # Execute strategy
        if strategy == 'economy':
            return await self.economy_generation(request)
        elif strategy == 'balanced':
            return await self.balanced_generation(request)
        else:
            return await self.quality_generation(request)
    
    async def economy_generation(self, request: ContentRequest):
        """Generate content with minimum cost."""
        
        # Check cache first
        if cached := await self.check_cache(request):
            return cached
        
        # Use cheaper model
        request.model = 'gpt-3.5-turbo'
        
        # Reduce length if possible
        if request.length > 500:
            request.length = min(request.length, 800)
        
        # Generate
        return await content_engine.generate_content(request)
    
    async def monitor_and_alert(self):
        """Monitor costs and alert on anomalies."""
        
        while True:
            # Check current spending rate
            current_rate = await self.calculate_spending_rate()
            
            # Predict month-end spending
            predicted_monthly = current_rate * 30
            
            # Alert if over budget
            if predicted_monthly > MONTHLY_AI_BUDGET:
                await self.send_budget_alert({
                    'current_rate': current_rate,
                    'predicted_monthly': predicted_monthly,
                    'budget': MONTHLY_AI_BUDGET,
                    'recommendation': 'Reduce content generation or increase budget'
                })
            
            # Wait before next check
            await asyncio.sleep(3600)  # Check hourly
```

## Integration Workflows

### Multi-Platform Integration

```python
class IntegrationWorkflow:
    """Handle integrations with external platforms."""
    
    async def sync_to_platforms(self, content_id: int):
        """Sync content to all connected platforms."""
        
        content = await self.get_content(content_id)
        results = {}
        
        # WordPress Integration
        if WORDPRESS_ENABLED:
            results['wordpress'] = await self.sync_to_wordpress(content)
        
        # Social Media Integrations
        if TWITTER_ENABLED:
            results['twitter'] = await self.post_to_twitter(content)
        
        if LINKEDIN_ENABLED:
            results['linkedin'] = await self.post_to_linkedin(content)
        
        # Email Marketing Integration
        if MAILCHIMP_ENABLED:
            results['mailchimp'] = await self.sync_to_mailchimp(content)
        
        # CRM Integration
        if HUBSPOT_ENABLED:
            results['hubspot'] = await self.sync_to_hubspot(content)
        
        return results
    
    async def sync_to_wordpress(self, content: dict):
        """Publish content to WordPress."""
        
        wp_api = WordPressAPI(WORDPRESS_URL, WORDPRESS_KEY)
        
        # Format content for WordPress
        post_data = {
            'title': content['title'],
            'content': content['body'],
            'status': 'draft',
            'categories': self.map_categories(content['keywords']),
            'tags': content['keywords'],
            'meta': {
                'seo_title': content['seo_title'],
                'meta_description': content['meta_description']
            }
        }
        
        # Create post
        response = await wp_api.create_post(post_data)
        
        # Store mapping
        await self.store_platform_mapping(
            content['id'],
            'wordpress',
            response['id']
        )
        
        return response
```

## Monitoring and Analytics

### Real-Time Monitoring Workflow

```python
class MonitoringWorkflow:
    """Real-time monitoring and alerting."""
    
    async def monitor_content_performance(self):
        """Monitor content performance in real-time."""
        
        while True:
            # Get recent content
            recent_content = await self.get_recent_content(hours=24)
            
            for content in recent_content:
                # Check performance metrics
                metrics = await self.get_performance_metrics(content['id'])
                
                # Detect anomalies
                if anomaly := self.detect_anomaly(metrics):
                    await self.handle_anomaly(content['id'], anomaly)
                
                # Check engagement thresholds
                if metrics['engagement_rate'] < 0.02:
                    await self.trigger_engagement_boost(content['id'])
                
                # Update analytics
                await self.update_analytics(content['id'], metrics)
            
            await asyncio.sleep(300)  # Check every 5 minutes
    
    async def detect_anomaly(self, metrics: dict):
        """Detect performance anomalies."""
        
        # Compare with baseline
        baseline = await self.get_baseline_metrics()
        
        anomalies = []
        
        # Check for significant deviations
        if metrics['views'] < baseline['views'] * 0.5:
            anomalies.append('low_views')
        
        if metrics['engagement_rate'] < baseline['engagement_rate'] * 0.3:
            anomalies.append('low_engagement')
        
        if metrics['bounce_rate'] > baseline['bounce_rate'] * 1.5:
            anomalies.append('high_bounce')
        
        return anomalies if anomalies else None
```

## Advanced Patterns

### Machine Learning Integration

```python
class MLWorkflow:
    """Machine learning enhanced workflows."""
    
    async def train_performance_predictor(self):
        """Train ML model to predict content performance."""
        
        # Get training data
        training_data = await self.get_training_data()
        
        # Extract features
        features = self.extract_features(training_data)
        
        # Train model
        model = self.train_model(features, training_data['performance'])
        
        # Validate model
        accuracy = self.validate_model(model)
        
        if accuracy > 0.8:
            # Deploy model
            self.performance_model = model
            await self.save_model(model)
        
        return {
            'accuracy': accuracy,
            'features_used': features.columns,
            'training_samples': len(training_data)
        }
    
    async def predict_content_success(self, content: dict):
        """Predict content performance before publishing."""
        
        if not self.performance_model:
            await self.load_model()
        
        # Extract features
        features = self.extract_content_features(content)
        
        # Predict
        prediction = self.performance_model.predict(features)
        
        return {
            'predicted_engagement': prediction['engagement'],
            'predicted_shares': prediction['shares'],
            'confidence': prediction['confidence'],
            'recommendations': self.generate_recommendations(prediction)
        }
```

### Event-Driven Automation

```python
class EventDrivenWorkflow:
    """React to events automatically."""
    
    def __init__(self):
        self.event_handlers = {}
    
    def on(self, event_type: str, handler):
        """Register event handler."""
        if event_type not in self.event_handlers:
            self.event_handlers[event_type] = []
        self.event_handlers[event_type].append(handler)
    
    async def emit(self, event_type: str, data: dict):
        """Emit event and trigger handlers."""
        
        if handlers := self.event_handlers.get(event_type):
            # Execute handlers in parallel
            tasks = [handler(data) for handler in handlers]
            await asyncio.gather(*tasks, return_exceptions=True)

# Register event handlers
workflow_events = EventDrivenWorkflow()

# Content published event
workflow_events.on('content.published', async def (data):
    await sync_to_social_media(data['content_id'])
    await update_content_index(data['content_id'])
    await notify_subscribers(data['content_id'])
)

# Budget warning event
workflow_events.on('budget.warning', async def (data):
    await switch_to_economy_mode()
    await send_budget_alert(data)
    await pause_non_critical_generation()
)

# High engagement event
workflow_events.on('engagement.high', async def (data):
    await create_similar_content(data['content_id'])
    await boost_distribution(data['content_id'])
    await analyze_success_factors(data['content_id'])
)
```

## Workflow Best Practices

### 1. Always Include Error Handling
```python
try:
    result = await risky_operation()
except SpecificError as e:
    result = await fallback_operation()
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    await alert_admin(e)
    raise
```

### 2. Implement Idempotency
```python
async def idempotent_operation(request_id: str):
    # Check if already processed
    if result := await get_cached_result(request_id):
        return result
    
    # Process
    result = await process_request()
    
    # Cache result
    await cache_result(request_id, result)
    
    return result
```

### 3. Use Checkpointing for Long Workflows
```python
async def long_workflow(context: dict):
    # Check for existing checkpoint
    if checkpoint := await load_checkpoint(context['id']):
        context = checkpoint
        start_step = context['last_completed_step'] + 1
    else:
        start_step = 0
    
    for i, step in enumerate(steps[start_step:], start_step):
        result = await step.execute(context)
        context.update(result)
        
        # Save checkpoint
        await save_checkpoint(context['id'], {
            **context,
            'last_completed_step': i
        })
```

### 4. Monitor and Measure Everything
```python
async def monitored_operation(name: str):
    start_time = time.time()
    
    try:
        result = await operation()
        
        # Record success metrics
        await record_metric(f"{name}.success", 1)
        await record_metric(f"{name}.duration", time.time() - start_time)
        
        return result
        
    except Exception as e:
        # Record failure metrics
        await record_metric(f"{name}.failure", 1)
        await record_metric(f"{name}.error", str(e))
        raise
```

## Conclusion

These workflow patterns enable SPLANTS to operate as an intelligent, self-managing marketing automation system. By implementing these patterns, you create a system that:

- **Learns** from past performance
- **Adapts** to changing conditions
- **Optimizes** for cost and quality
- **Recovers** from failures automatically
- **Scales** with your needs

Remember to always follow the modular enhancement architecture and make features toggleable as described in the main documentation.
