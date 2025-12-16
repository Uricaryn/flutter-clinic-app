# Production Deployment Guide

## Overview

This guide covers deploying your Node.js backend and PostgreSQL database to production. We'll cover multiple cloud providers with step-by-step instructions.

## Deployment Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Mobile/Web)   │
└────────┬────────┘
         │ HTTPS
         ▼
┌─────────────────┐
│  Load Balancer  │
│  (SSL/TLS)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────────┐
│  Backend API    │◄────►│  PostgreSQL DB   │
│  (Node.js)      │      │  (Managed)       │
└─────────────────┘      └──────────────────┘
         │
         │ WebSocket
         ▼
┌─────────────────┐
│  Client Apps    │
│  (Realtime)     │
└─────────────────┘
```

## Option 1: DigitalOcean (Recommended - Easiest)

### Why DigitalOcean?

- ✅ Easy setup and management
- ✅ Affordable pricing ($5-20/month to start)
- ✅ Managed PostgreSQL database
- ✅ Auto-scaling and deployments
- ✅ Built-in SSL/TLS
- ✅ WebSocket support
- ✅ One-click deploys from Git

### Step 1: Create PostgreSQL Database

1. Go to [DigitalOcean](https://cloud.digitalocean.com/)
2. Create → Databases → PostgreSQL
3. Choose plan (start with Basic $15/month)
4. Select region (closest to users)
5. Create database cluster

**Get connection details:**
```bash
# Copy the connection string
postgresql://username:password@host:25060/clinic_db?sslmode=require
```

### Step 2: Deploy Backend (App Platform)

1. Create → Apps → GitHub
2. Select your repository
3. Select `feature/postgresql` branch
4. Choose `backend` as source directory
5. Configure:
   - **Build Command:** `npm install`
   - **Run Command:** `node src/server.js`
   - **HTTP Port:** 3000

### Step 3: Environment Variables

In App Platform, add environment variables:

```env
DATABASE_URL=postgresql://user:pass@host:25060/clinic_db?sslmode=require
JWT_SECRET=generate-random-64-char-string
JWT_EXPIRATION=7d
REFRESH_TOKEN_SECRET=generate-another-random-64-char-string
REFRESH_TOKEN_EXPIRATION=30d
NODE_ENV=production
PORT=3000
ALLOWED_ORIGINS=https://your-flutter-app.com
```

**Generate secrets:**
```bash
# On Linux/Mac
openssl rand -hex 32

# On Windows (PowerShell)
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
```

### Step 4: Run Migrations

```bash
# SSH into DigitalOcean droplet or use console
doctl apps create-deployment YOUR_APP_ID

# Or use database console
# Run your migration SQL files manually
```

### Step 5: Configure SSL

DigitalOcean provides SSL automatically. Your endpoints:

```
API: https://your-app.ondigitalocean.app/api
WebSocket: wss://your-app.ondigitalocean.app/ws
```

### Step 6: Update Flutter App

```dart
// lib/core/config/api_config.dart
static const String _productionBaseUrl = 'https://your-app.ondigitalocean.app/api';
static const String _productionWsUrl = 'wss://your-app.ondigitalocean.app/ws';
```

**Cost Estimate:**
- Database: $15/month (Basic plan)
- Backend: $5-12/month (Basic plan, auto-scales)
- **Total: ~$20-27/month**

---

## Option 2: AWS (Enterprise Scale)

### Components

- **RDS PostgreSQL** - Database
- **Elastic Beanstalk** or **ECS** - Backend
- **ALB** - Load Balancer with SSL
- **CloudWatch** - Monitoring

### Step 1: Create RDS PostgreSQL

```bash
aws rds create-db-instance \
  --db-instance-identifier clinic-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password YOUR_PASSWORD \
  --allocated-storage 20
```

### Step 2: Deploy with Elastic Beanstalk

```bash
# Initialize EB
eb init -p node.js clinic-backend

# Create environment
eb create clinic-prod

# Set environment variables
eb setenv DATABASE_URL="postgresql://..." \
  JWT_SECRET="..." \
  NODE_ENV=production

# Deploy
eb deploy
```

### Step 3: Configure SSL

```bash
# Request certificate (free with ACM)
aws acm request-certificate \
  --domain-name api.your-domain.com \
  --validation-method DNS

# Configure ALB to use HTTPS
eb setenv SSL_CERTIFICATE_ARN="arn:aws:acm:..."
```

**Cost Estimate:**
- RDS t3.micro: $15/month
- EB t3.small: $17/month
- Load Balancer: $16/month
- **Total: ~$48/month**

---

## Option 3: Google Cloud Platform

### Step 1: Cloud SQL PostgreSQL

```bash
gcloud sql instances create clinic-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1

gcloud sql databases create clinic_db --instance=clinic-db
```

### Step 2: Cloud Run Deployment

```bash
# Build container
gcloud builds submit --tag gcr.io/YOUR_PROJECT/clinic-backend

# Deploy
gcloud run deploy clinic-api \
  --image gcr.io/YOUR_PROJECT/clinic-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Step 3: Environment Variables

```bash
gcloud run services update clinic-api \
  --set-env-vars DATABASE_URL="postgresql://..." \
  --set-env-vars JWT_SECRET="..."
```

**Cost Estimate:**
- Cloud SQL f1-micro: $7/month
- Cloud Run: $5-15/month (pay per use)
- **Total: ~$12-22/month**

---

## Option 4: Railway.app (Simplest)

### Why Railway?

- Extremely simple setup
- Built-in PostgreSQL
- Free tier available
- Automatic HTTPS
- Git-based deployments

### Deployment Steps

1. Go to [Railway.app](https://railway.app/)
2. "New Project" → "Deploy from GitHub"
3. Select your repository
4. Railway auto-detects Node.js
5. Add PostgreSQL service (one click)
6. Environment variables auto-configured

**Cost:** Free tier available, then $5/month

---

## Environment Configuration

### Production .env Template

```env
# Database
DATABASE_URL=postgresql://user:pass@host:5432/clinic_db

# JWT Authentication
JWT_SECRET=your-super-secret-jwt-key-min-32-chars
JWT_EXPIRATION=7d
REFRESH_TOKEN_SECRET=another-super-secret-refresh-key
REFRESH_TOKEN_EXPIRATION=30d

# Server
NODE_ENV=production
PORT=3000

# CORS
ALLOWED_ORIGINS=https://your-flutter-app.com,https://www.your-flutter-app.com

# Email (optional - for password reset)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Monitoring (optional)
SENTRY_DSN=your-sentry-dsn
```

### Security Checklist

- [ ] Strong JWT secrets (32+ random characters)
- [ ] HTTPS enforced (no HTTP in production)
- [ ] CORS configured with specific origins (not *)
- [ ] Rate limiting enabled
- [ ] Database SSL connection enabled
- [ ] Environment variables never committed to git
- [ ] Regular security updates (`npm audit`)

## SSL/TLS Certificate

### Option A: Let's Encrypt (Free)

Most cloud providers handle this automatically. If self-hosting:

```bash
# Using certbot
sudo certbot --nginx -d api.your-domain.com
```

### Option B: Cloud Provider Certificate

- DigitalOcean: Automatic
- AWS: AWS Certificate Manager (ACM)
- GCP: Google-managed certificates
- Railway: Automatic

## Database Backup Strategy

### Automated Backups

All managed database services provide automatic backups:

**DigitalOcean:**
- Daily automatic backups (retained 7 days)
- Point-in-time recovery

**AWS RDS:**
- Automated backups (35 days retention)
- Snapshot backups

**Google Cloud SQL:**
- Automated backups (7 days default)
- Point-in-time recovery

### Manual Backups

```bash
# Daily backup script
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d).sql

# Restore from backup
psql $DATABASE_URL < backup-20241216.sql
```

### Backup to Cloud Storage

```bash
# AWS S3
pg_dump $DATABASE_URL | aws s3 cp - s3://mybucket/backups/db-$(date +%Y%m%d).sql

# Google Cloud Storage
pg_dump $DATABASE_URL | gsutil cp - gs://mybucket/backups/db-$(date +%Y%m%d).sql

# DigitalOcean Spaces
pg_dump $DATABASE_URL > backup.sql
s3cmd put backup.sql s3://your-space/backups/
```

## Monitoring & Logging

### Application Monitoring

**Recommended: Sentry**

```bash
npm install @sentry/node

# In server.js
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
});
```

### Database Monitoring

```sql
-- Monitor active connections
SELECT count(*) FROM pg_stat_activity;

-- Monitor slow queries
SELECT query, mean_exec_time 
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC 
LIMIT 10;

-- Check database size
SELECT pg_size_pretty(pg_database_size('clinic_db'));
```

### Logs

```bash
# View application logs
# DigitalOcean
doctl apps logs YOUR_APP_ID

# AWS
eb logs

# GCP
gcloud run logs read clinic-api

# Railway
railway logs
```

## Performance Optimization

### Database Indexes

Already included in schema, but monitor query performance:

```sql
-- Find missing indexes
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname = 'public'
ORDER BY abs(correlation) DESC;
```

### Connection Pooling

Already configured in `src/config/database.js`:

```javascript
const pool = new Pool({
  max: 20,  // Maximum pool size
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

Adjust based on your load.

### Caching (Optional)

Add Redis for caching:

```bash
npm install redis

# Cache frequently accessed data
const redis = require('redis');
const cache = redis.createClient();

// Cache clinic data (changes rarely)
app.get('/api/clinics/:id', async (req, res) => {
  const cached = await cache.get(`clinic:${req.params.id}`);
  if (cached) return res.json(JSON.parse(cached));
  
  // Fetch from DB and cache
  const clinic = await getClinic(req.params.id);
  await cache.setex(`clinic:${req.params.id}`, 3600, JSON.stringify(clinic));
  res.json(clinic);
});
```

## Scaling Considerations

### Horizontal Scaling

Your backend is stateless (JWT) and can scale horizontally:

```bash
# DigitalOcean - increase instances
doctl apps update YOUR_APP_ID --instance-count 3

# AWS - auto-scaling group
eb scale 3

# GCP - increase max instances
gcloud run services update clinic-api --max-instances 10
```

### Database Scaling

- **Vertical:** Upgrade instance type (more CPU/RAM)
- **Horizontal:** Add read replicas for read-heavy operations
- **Connection Pooling:** Use PgBouncer for high connection counts

### WebSocket Scaling

For multiple backend instances:

```javascript
// Use Redis pub/sub for WebSocket clustering
import Redis from 'ioredis';

const pub = new Redis(process.env.REDIS_URL);
const sub = new Redis(process.env.REDIS_URL);

// Publish changes to all instances
pub.publish('clinic_changes', JSON.stringify(data));

// Subscribe to changes
sub.subscribe('clinic_changes', (channel, message) => {
  const data = JSON.parse(message);
  websocketService.broadcastToClinic(data.clinicId, data);
});
```

## Health Checks & Monitoring

### Health Endpoint

Already implemented at `/health`. Configure monitoring:

```bash
# DigitalOcean Health Check
Path: /health
Port: 3000
Protocol: HTTP

# AWS Health Check
curl https://your-api.com/health
```

### Uptime Monitoring

Use services like:
- **UptimeRobot** (free)
- **Pingdom**
- **StatusCake**

Configure to ping `/health` every 5 minutes.

## CI/CD Pipeline

### GitHub Actions Example

```yaml
# .github/workflows/deploy-backend.yml
name: Deploy Backend

on:
  push:
    branches: [ main ]
    paths:
      - 'backend/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: cd backend && npm ci
      
      - name: Run tests
        run: cd backend && npm test
      
      - name: Deploy to DigitalOcean
        uses: digitalocean/app_action@v1.1.5
        with:
          app_name: clinic-backend
          token: ${{ secrets.DIGITALOCEAN_TOKEN }}
```

## Flutter App Deployment

### Update API URLs

```dart
// lib/core/config/api_config.dart
static const String _productionBaseUrl = 'https://api.your-domain.com/api';
static const String _productionWsUrl = 'wss://api.your-domain.com/ws';
```

### Build for Production

```bash
# Android
flutter build apk --release --dart-define=DB_MODE=postgresql

# iOS
flutter build ios --release --dart-define=DB_MODE=postgresql

# Web
flutter build web --release --dart-define=DB_MODE=postgresql
```

### App Store Deployment

Follow the existing `PLAY_STORE_DEPLOYMENT.md` guide, but ensure:
- API URLs point to production
- Database mode is set to PostgreSQL
- All API keys are production keys

## Domain & DNS Configuration

### Set up custom domain

1. **Buy domain** (Namecheap, Google Domains, etc.)

2. **Add DNS records:**

```
Type    Name    Value
A       api     YOUR_SERVER_IP
CNAME   www     your-app.ondigitalocean.app
```

3. **Configure SSL** (automatic with most providers)

### CORS Configuration

Update backend CORS to allow your domain:

```env
ALLOWED_ORIGINS=https://your-flutter-app.com,https://www.your-flutter-app.com
```

## Post-Deployment Checklist

- [ ] Database is accessible from backend
- [ ] Backend health check returns 200
- [ ] SSL certificate is valid (check https://your-api.com)
- [ ] WebSocket connection works
- [ ] CORS allows your app domain
- [ ] Environment variables are secure (not exposed)
- [ ] Database backups are enabled
- [ ] Monitoring is configured
- [ ] Logs are accessible
- [ ] Error tracking (Sentry) is set up
- [ ] Rate limiting is active
- [ ] Flutter app can connect to production API
- [ ] Test user can login
- [ ] Realtime updates work
- [ ] All CRUD operations work

## Monitoring Endpoints

Set up alerts for:

```bash
# API availability
curl https://api.your-domain.com/health

# Database connectivity
psql $DATABASE_URL -c "SELECT 1"

# WebSocket availability
wscat -c wss://api.your-domain.com/ws?token=TEST_TOKEN
```

## Cost Optimization

### Start Small, Scale Up

**Month 1 (Testing):**
- DigitalOcean Basic PostgreSQL: $15
- App Platform Basic: $5
- **Total: $20/month**

**Month 3-6 (Growing):**
- PostgreSQL Standard: $60
- App Platform Pro: $12
- **Total: $72/month**

**Month 12+ (Established):**
- PostgreSQL Production: $120
- App Platform with scaling: $30
- Redis cache: $15
- **Total: $165/month**

### Cost Saving Tips

1. **Use read replicas** instead of upgrading primary DB
2. **Implement caching** to reduce DB queries
3. **Optimize queries** with proper indexes
4. **Set connection pooling** limits
5. **Use CDN** for static assets
6. **Monitor unused resources**

## Disaster Recovery

### Recovery Time Objective (RTO)

**Target: < 30 minutes**

```bash
# 1. Restore database from backup (10 min)
psql NEW_DATABASE_URL < latest-backup.sql

# 2. Update backend environment (5 min)
# Change DATABASE_URL to point to restored DB

# 3. Restart backend (5 min)
# Trigger redeployment

# 4. Verify functionality (10 min)
# Test critical features
```

### Backup Strategy

```bash
# Automated daily backups (cron job)
0 2 * * * pg_dump $DATABASE_URL | gzip > /backups/db-$(date +\%Y\%m\%d).sql.gz

# Retention: Keep 30 days
find /backups -name "db-*.sql.gz" -mtime +30 -delete
```

## Security Best Practices

1. **Keep dependencies updated**
```bash
npm audit
npm audit fix
```

2. **Use security headers** (already included with Helmet)

3. **Enable rate limiting** (already implemented)

4. **Sanitize inputs** (already implemented with express-validator)

5. **Use parameterized queries** (already using pg with parameters)

6. **Monitor for attacks**
```bash
# Check failed login attempts
SELECT COUNT(*), date_trunc('hour', created_at)
FROM failed_login_attempts
GROUP BY date_trunc('hour', created_at)
ORDER BY date_trunc DESC;
```

7. **Regular security audits**

## Troubleshooting Production Issues

### Backend Not Responding

```bash
# Check backend logs
tail -f /var/log/backend.log

# Check if process is running
ps aux | grep node

# Restart service
pm2 restart clinic-backend
```

### Database Connection Issues

```bash
# Test connection
psql $DATABASE_URL -c "SELECT 1"

# Check active connections
SELECT * FROM pg_stat_activity;

# Kill hung connections
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE state = 'idle' 
AND state_change < now() - interval '10 minutes';
```

### WebSocket Issues

```bash
# Test WebSocket
wscat -c "wss://api.your-domain.com/ws?token=YOUR_TOKEN"

# Check WebSocket connections
# In health endpoint: /health
curl https://api.your-domain.com/health
```

## Maintenance Windows

Plan regular maintenance:

```bash
# Update dependencies (monthly)
npm update
npm audit fix

# Database maintenance (weekly)
VACUUM ANALYZE;

# Reindex (monthly)
REINDEX DATABASE clinic_db;

# Update statistics (weekly)
ANALYZE;
```

## Support Resources

- **DigitalOcean:** [Community Tutorials](https://www.digitalocean.com/community/tutorials)
- **AWS:** [Documentation](https://docs.aws.amazon.com/)
- **GCP:** [Quickstarts](https://cloud.google.com/docs/quickstarts)
- **Railway:** [Docs](https://docs.railway.app/)

## Next Steps

1. Choose cloud provider
2. Create accounts and set up billing
3. Deploy PostgreSQL database
4. Deploy backend application
5. Configure environment variables
6. Run database migrations
7. Test all endpoints
8. Configure monitoring
9. Update Flutter app with production URLs
10. Deploy Flutter app
11. Monitor and optimize

**Your backend is production-ready! 🚀**
