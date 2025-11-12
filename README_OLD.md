SPLANTS Marketing Engine - Small Business Edition v2.1
Enterprise AI Marketing That Runs on $30/Month 🚀
Table of Contents
What Is This?
Who Is This For?
Why Use This?
Core Features
Getting Started
Configuration Guide
Using the API
Cost Breakdown
Optional Enhancements
Common Use Cases
Troubleshooting
FAQ
What Is This?
The SPLANTS Marketing Engine is a professional AI-powered content generation and marketing automation system designed specifically for small businesses. Think of it as having a full marketing team in a box that:

Writes blog posts, social media content, emails, and ads using GPT-4 (the same AI behind ChatGPT)
Optimizes content for SEO and different social media platforms automatically
Publishes to multiple platforms on a schedule
Tracks performance and costs to ensure positive ROI
Learns what works through A/B testing
The best part? It runs on infrastructure that costs just $20-30/month total.

Who Is This For?
This system is perfect for:

Small Business Owners who need professional marketing but can't afford an agency
Solopreneurs who want to automate their content marketing
Startups looking for scalable marketing infrastructure
Marketing Freelancers who want to serve more clients efficiently
Anyone who needs to produce quality content consistently without breaking the bank
Why Use This?
The Problem
Hiring a marketing agency costs $2,000-10,000/month
Freelance writers charge $100-500 per article
Social media managers cost $1,000-5,000/month
Marketing tools like HubSpot start at $800/month
The Solution
This system gives you:

Unlimited content generation for ~$0.03 per piece
Multi-platform publishing automation
Professional quality (85%+ quality scores)
Complete ownership of your marketing infrastructure
Total cost: $30/month infrastructure + ~$20-50/month in AI costs
Core Features
🤖 AI Content Generation
GPT-4 Powered: Uses OpenAI's most advanced language model
8 Content Types: Blog posts, social media, emails, ads, landing pages, video scripts, product descriptions, press releases
Quality Scoring: Every piece gets a 0-1 quality score
SEO Optimization: Automatic keyword integration and structure optimization
📱 Multi-Platform Publishing
9 Platforms Supported: Blog, Twitter, LinkedIn, Instagram, Facebook, YouTube, TikTok, Pinterest, Email
Smart Scheduling: Post at optimal times for each platform
Platform Optimization: Content automatically adjusted for each platform's requirements
📊 Analytics & ROI Tracking (FREE Enhancement)
Performance Metrics: Track what content performs best
Cost Analysis: Know exactly what you're spending
ROI Calculation: See your return on investment
Trend Analysis: Understand what's working over time
🧪 A/B Testing (FREE Enhancement)
Automatic Variants: Generate 3 versions of any content
Performance Comparison: Track which version performs best
Learn & Improve: System learns from test results
📝 Content Templates (FREE Enhancement)
Proven Structures: Use templates that work
Quick Start: Get started without learning prompting
Consistency: Maintain brand voice across content
Getting Started
Prerequisites
You'll need:

A Computer with Docker installed (Windows, Mac, or Linux)
An OpenAI API Key (get one at platform.openai.com)
Basic Command Line Skills (we'll guide you through everything)
Step 1: Install Docker
Docker is a tool that creates a virtual environment for the application to run in. Think of it as a shipping container for software.

For Windows/Mac:

Go to docker.com/get-started
Download Docker Desktop
Install and run it
You'll see a whale icon in your system tray when it's running
For Linux:

bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
Step 2: Get Your OpenAI API Key
Go to platform.openai.com
Sign up or log in
Click on "API Keys" in the left sidebar
Click "Create new secret key"
Copy the key (it starts with sk-...) - save this, you can't see it again!
Add $10-20 credit to your account (this will last 200-600 content pieces)
Step 3: Set Up the Application
Create a project folder on your computer (e.g., splants-marketing)

Create a .env file in that folder with your configuration:

env
# REQUIRED - Core Configuration
OPENAI_API_KEY=sk-your-api-key-here
API_KEY=change-this-to-a-secure-password-123
DATABASE_URL=postgresql://splants:password@db:5432/splants

# OPTIONAL - Cost Control (Recommended)
MONTHLY_AI_BUDGET=50  # Set your monthly AI spending limit
DAILY_API_LIMIT=100   # Max API calls per day (0 = unlimited)

# OPTIONAL - Content Settings
MAX_CONTENT_LENGTH=2000    # Maximum words per generation
DEFAULT_CONTENT_LENGTH=500  # Default if not specified

# OPTIONAL BUT RECOMMENDED - Webhooks for Automation
# WEBHOOK_CONTENT_GENERATED_URL=https://hooks.zapier.com/your-webhook
# WEBHOOK_CONTENT_PUBLISHED_URL=https://hooks.zapier.com/your-webhook
Create a docker-compose.yml file (this tells Docker how to run everything):
YAML
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: splants
      POSTGRES_PASSWORD: password
      POSTGRES_DB: splants
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  app:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - db
    env_file:
      - .env
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped

volumes:
  postgres_data:
Create a Dockerfile (instructions for building the app):
Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY main.py .

# Create logs directory
RUN mkdir -p logs

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
Create requirements.txt (list of Python packages needed):
txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
asyncpg==0.29.0
openai==1.3.0
anthropic==0.7.0
httpx==0.25.0
python-multipart==0.0.6
Step 4: Start the System
Open a terminal/command prompt in your project folder and run:

bash
# Build and start everything
docker-compose up -d

# Check if it's running
docker-compose ps

# View logs
docker-compose logs -f app
The system is now running at http://localhost:8080!

Step 5: Test It's Working
Open your browser and go to:

http://localhost:8080 - Welcome page with system info
http://localhost:8080/docs - Interactive API documentation
Configuration Guide
Essential Settings
OpenAI API Key (REQUIRED)
env
OPENAI_API_KEY=sk-proj-abc123...
Get from platform.openai.com
Costs ~$0.03 per content piece
Add $20-50 credit monthly for regular use
Your API Key (REQUIRED)
env
API_KEY=my-super-secret-key-12345
This protects your API from unauthorized use
Use a strong, unique password
Include this in all API requests as X-API-Key header
Database URL (REQUIRED)
env
DATABASE_URL=postgresql://splants:password@db:5432/splants
Leave as-is if using Docker Compose
Stores all your content and analytics
Optional but Recommended
Cost Control
env
MONTHLY_AI_BUDGET=50  # Stop at $50/month
DAILY_API_LIMIT=100   # Max 100 requests/day
Prevents unexpected charges
Tracks spending in real-time
Sends alerts before limits
Content Limits
env
MAX_CONTENT_LENGTH=2000    # Max words
DEFAULT_CONTENT_LENGTH=500  # Default words
Controls content length
Affects API costs
Using the API
Your First Content Generation
The API uses HTTP requests. You can use:

Postman (user-friendly GUI)
cURL (command line)
Python/JavaScript (in your code)
The Swagger UI at http://localhost:8080/docs
Example: Generate a Blog Post
Using cURL (command line):

bash
curl -X POST "http://localhost:8080/v1/generate" \
  -H "X-API-Key: your-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "content_type": "blog",
    "topic": "5 Ways AI Can Help Small Businesses Save Time",
    "keywords": ["AI", "small business", "automation", "efficiency"],
    "tone": "professional",
    "target_audience": "Small business owners with 1-10 employees",
    "length": 800,
    "platform": "blog"
  }'
Using Python:

Python
import requests

response = requests.post(
    "http://localhost:8080/v1/generate",
    headers={
        "X-API-Key": "your-api-key-here",
        "Content-Type": "application/json"
    },
    json={
        "content_type": "blog",
        "topic": "5 Ways AI Can Help Small Businesses Save Time",
        "keywords": ["AI", "small business", "automation"],
        "tone": "professional",
        "length": 800
    }
)

content = response.json()
print(f"Generated content (Quality: {content['quality_score']})")
print(content['content'])
Common API Endpoints
Generate Content
POST /v1/generate

Creates any type of content
Returns quality score, SEO score, and recommendations
List Your Content
GET /v1/content

View all generated content
Filter by type, quality, date
Publish Content
POST /v1/publish

Schedule or publish to multiple platforms
Automatic platform optimization
View Analytics Dashboard
GET /v1/analytics/dashboard

Complete performance metrics
ROI calculations
Cost tracking
Check Costs
GET /v1/costs/usage

Current month spending
Budget status
Projections and alerts
Cost Breakdown
Monthly Costs
Component	Cost	What You Get
Infrastructure		
Database (PostgreSQL)	$5-10	Stores all content
Application Server	$5-10	Runs the engine
Optional: Redis Cache	$10-15	30-50% cost reduction
Total Infrastructure	$20-30	Complete system
AI Usage		
OpenAI GPT-4	~$0.03/piece	High-quality content
Typical Usage (500 pieces)	$15/month	Varies by usage
Heavy Usage (1500 pieces)	$45/month	Varies by usage
Total AI Costs	$15-50	Based on volume
TOTAL MONTHLY	$35-80	Complete solution
Comparison to Alternatives
Service	Monthly Cost	What You Get
SPLANTS Engine	$35-80	Unlimited content, all features
Marketing Agency	$2,000-10,000	Human-written content, strategy
HubSpot	$800-3,200	Marketing automation platform
Jasper.ai	$49-125	AI writing assistant only
Freelance Writer	$500-2,000	5-20 articles
Optional Enhancements
FREE Enhancements (Already Included!)
📊 Analytics Dashboard
Real-time performance tracking
Quality and SEO trends
Platform distribution
ROI calculations
🧪 A/B Testing
Generate 3 variants automatically
Test different tones and approaches
Find what works best
📝 Content Templates
Proven content structures
Quick content creation
Maintain consistency
💰 Cost Control
Set monthly budgets
Daily limits
Spending alerts
Usage projections
🔔 Webhooks
Connect to Zapier
Automate workflows
Trigger external actions
PAID Enhancements (Optional)
Redis Caching (+$10-15/month)
What it does: Stores frequently used content to reduce API calls Benefit: 30-50% reduction in AI costs When to add: When generating >1000 pieces/month

To enable:

Add Redis service to docker-compose.yml
Set REDIS_URL=redis://redis:6379 in .env
Uncomment Redis sections in main.py
Multi-Model Synthesis (+$0.02-0.05/request)
What it does: Uses both GPT-4 and Claude AI for premium quality Benefit: 20-30% quality improvement When to use: Important content like landing pages

To enable:

Get Anthropic API key from anthropic.com
Add ANTHROPIC_API_KEY=your-key to .env
Set use_premium: true in requests
Auto-Publishing (Costs vary)
What it does: Actually posts to social media automatically Platforms: Twitter, LinkedIn, Instagram, Facebook When to add: When you want full automation

To enable:

Get API keys from each platform
Add to .env file
Content will auto-post
Common Use Cases
1. Daily Blog Content
Python
# Generate a blog post every day at 9 AM
{
    "content_type": "blog",
    "topic": "Today's AI marketing tip",
    "length": 800,
    "seo_optimize": true
}
2. Social Media Campaign
Python
# Create coordinated campaign across platforms
{
    "content_type": "social_post",
    "topic": "New product launch announcement",
    "platform": "twitter",
    "generate_variants": true  # Creates 3 versions
}
3. Email Newsletter
Python
# Weekly newsletter content
{
    "content_type": "email",
    "topic": "This week in AI: 5 things you need to know",
    "tone": "conversational",
    "target_audience": "Tech-savvy business owners"
}
4. Product Descriptions
Python
# E-commerce product copy
{
    "content_type": "product_description",
    "topic": "Wireless Bluetooth earbuds with 30-hour battery",
    "keywords": ["bluetooth earbuds", "wireless", "long battery"],
    "tone": "enthusiastic"
}
Troubleshooting
System Won't Start
Problem: Docker containers won't start Solution:

Check Docker is running (whale icon in system tray)
Check port 8080 isn't already in use
Run docker-compose down then docker-compose up -d
API Key Errors
Problem: "Invalid API Key" error Solution:

Check your OpenAI key starts with sk-
Ensure no extra spaces in .env file
Restart with docker-compose restart
Content Generation Fails
Problem: 500 error when generating content Solution:

Check OpenAI account has credit
Verify API key is correct
Check logs: docker-compose logs app
Database Connection Issues
Problem: "Database connection failed" Solution:

Wait 30 seconds after starting (database needs to initialize)
Check database is running: docker-compose ps
Recreate database: docker-compose down -v then up -d
High Costs
Problem: Spending more than expected Solution:

Set MONTHLY_AI_BUDGET in .env
Enable Redis caching to reduce costs 30-50%
Use shorter content lengths
Check analytics dashboard for usage patterns
FAQ
Q: Is this legal to use for my business?
A: Yes! You own all content generated. OpenAI grants you full rights to content created with their API.

Q: Can I customize the AI's writing style?
A: Yes! Use the tone parameter (professional, casual, enthusiastic, etc.) and provide specific instructions in the topic field.

Q: How much content can I generate?
A: Unlimited! You're only limited by your OpenAI API credits. Typical cost is $0.03 per piece.

Q: Can I use this for multiple clients?
A: Yes! The system supports unlimited content generation and storage. Perfect for agencies.

Q: Is my content private?
A: Yes! Everything is stored in your private database. OpenAI doesn't train on API content.

Q: Can I modify the code?
A: Absolutely! The code is fully documented and designed to be extended.

Q: What if OpenAI raises prices?
A: The system supports multiple AI providers. You can switch to Claude, Gemini, or others.

Q: Can I run this on my own server?
A: Yes! It runs anywhere Docker runs - your computer, a VPS, AWS, etc.

Q: How do I backup my content?
A: The PostgreSQL database can be backed up with: docker exec splants_db_1 pg_dump -U splants splants > backup.sql

Q: Can I white-label this for clients?
A: Yes! Modify the branding in the code and deploy separate instances.

Getting Help
Check the API Docs: http://localhost:8080/docs
View System Status: http://localhost:8080/v1/system/status
Check Logs: docker-compose logs -f app
Review This README: Most answers are here!
Next Steps
✅ Generate your first piece of content
✅ Set up cost controls
✅ Explore the analytics dashboard
✅ Try A/B testing
✅ Connect webhooks for automation
✅ Consider Redis caching if generating lots of content
Remember: This system is designed to grow with you. Start simple with basic content generation, then add enhancements as needed. Most businesses find the core features more than sufficient!

Happy Marketing! 🚀