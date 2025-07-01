# Production Deployment Guide - Payment Method Integration

This guide provides comprehensive instructions for setting up payment method integration in a production environment for the Fashion Store App.

## 🏭 Production Environment Overview

### Architecture Components
```
Production Environment
├── Flutter Mobile App (iOS/Android)
├── Backend API Server (Node.js/Express)
├── Database (MongoDB Atlas/Production DB)
├── PayPal Payment Gateway
├── File Storage (AWS S3/CloudFlare)
├── CDN (CloudFlare/AWS CloudFront)
├── SSL/TLS Certificates
└── Monitoring & Analytics
```

## 💳 PayPal Production Setup

### 1. PayPal Business Account Setup

#### Create PayPal Business Account
1. Visit [PayPal Business](https://www.paypal.com/business)
2. Create a business account
3. Complete business verification process
4. Add and verify your bank account
5. Complete identity verification

#### PayPal Developer Dashboard
1. Go to [PayPal Developer Portal](https://developer.paypal.com/)
2. Log in with your business account
3. Navigate to "My Apps & Credentials"
4. Create a new app for production

### 2. PayPal App Configuration

#### Create Production App
```bash
# PayPal App Settings
App Name: Fashion Store Production
Merchant ID: Your verified merchant ID
Environment: Live (Production)
Features: 
  - Accept payments
  - Access seller information
  - Access buyer information
```

#### Get Production Credentials
```env
# Production PayPal Credentials
PAYPAL_CLIENT_ID=your-live-client-id
PAYPAL_CLIENT_SECRET=your-live-client-secret
PAYPAL_MODE=live
PAYPAL_WEBHOOK_ID=your-webhook-id
```

### 3. Webhook Configuration

#### Set Up PayPal Webhooks
```javascript
// Webhook Events to Subscribe
const webhookEvents = [
  'PAYMENT.AUTHORIZATION.CREATED',
  'PAYMENT.AUTHORIZATION.VOIDED',
  'PAYMENT.CAPTURE.COMPLETED',
  'PAYMENT.CAPTURE.DENIED',
  'PAYMENT.CAPTURE.PENDING',
  'PAYMENT.CAPTURE.REFUNDED',
  'PAYMENT.CAPTURE.REVERSED',
  'CHECKOUT.ORDER.APPROVED',
  'CHECKOUT.ORDER.COMPLETED'
];
```

#### Webhook URL Configuration
```bash
# Production Webhook URL
https://your-domain.com/api/webhooks/paypal

# Webhook Verification
- Enable webhook signature verification
- Store webhook ID in environment variables
- Implement webhook validation in backend
```

## 🔐 Security Configuration

### 1. SSL/TLS Setup

#### Domain SSL Certificate
```bash
# Using Let's Encrypt (Free)
sudo certbot --nginx -d your-domain.com -d api.your-domain.com

# Or use paid SSL certificates
# - DigiCert
# - GlobalSign
# - Comodo
```

#### Backend SSL Configuration
```javascript
// server.js - HTTPS Configuration
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('/path/to/private-key.pem'),
  cert: fs.readFileSync('/path/to/certificate.pem'),
  ca: fs.readFileSync('/path/to/ca-bundle.pem') // If using CA bundle
};

https.createServer(options, app).listen(443, () => {
  console.log('HTTPS Server running on port 443');
});
```

### 2. Environment Variables (Production)

#### Backend Environment (.env.production)
```env
# Database
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/fashionstore_prod

# JWT Configuration
JWT_SECRET=your-super-secure-jwt-secret-256-bit-key
JWT_EXPIRES_IN=24h
JWT_COOKIE_EXPIRES_IN=1

# Server Configuration
NODE_ENV=production
PORT=443
API_BASE_URL=https://api.your-domain.com

# PayPal Production Configuration
PAYPAL_CLIENT_ID=your-live-paypal-client-id
PAYPAL_CLIENT_SECRET=your-live-paypal-client-secret
PAYPAL_MODE=live
PAYPAL_WEBHOOK_ID=your-paypal-webhook-id
PAYPAL_RETURN_URL=https://your-domain.com/payment/success
PAYPAL_CANCEL_URL=https://your-domain.com/payment/cancel

# Email Configuration (for order confirmations)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-business-email@domain.com
SMTP_PASS=your-app-password

# File Storage
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_S3_BUCKET=your-s3-bucket-name
AWS_S3_REGION=us-east-1

# Redis (for session management)
REDIS_URL=redis://username:password@your-redis-host:6379

# Monitoring
NEW_RELIC_LICENSE_KEY=your-newrelic-key
SENTRY_DSN=your-sentry-dsn

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000  # 15 minutes
RATE_LIMIT_MAX=100  # limit each IP to 100 requests per windowMs
```

### 3. Payment Security Implementation

#### Backend Payment Security
```javascript
// middleware/payment-security.js
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');

// Payment endpoint rate limiting
const paymentLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // limit each IP to 5 payment requests per windowMs
  message: 'Too many payment attempts, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://www.paypal.com"],
      scriptSrc: ["'self'", "https://www.paypal.com", "https://www.paypalobjects.com"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.paypal.com", "https://api.sandbox.paypal.com"],
      frameSrc: ["https://www.paypal.com"],
    },
  },
}));

module.exports = { paymentLimiter };
```

#### PayPal Integration Security
```javascript
// services/paypal-service.js
const paypal = require('@paypal/checkout-server-sdk');
const crypto = require('crypto');

class PayPalService {
  constructor() {
    this.client = new paypal.core.PayPalHttpClient(
      process.env.PAYPAL_MODE === 'live' 
        ? new paypal.core.LiveEnvironment(
            process.env.PAYPAL_CLIENT_ID,
            process.env.PAYPAL_CLIENT_SECRET
          )
        : new paypal.core.SandboxEnvironment(
            process.env.PAYPAL_CLIENT_ID,
            process.env.PAYPAL_CLIENT_SECRET
          )
    );
  }

  // Verify webhook signature
  verifyWebhookSignature(webhookEvent, headers) {
    const webhookId = process.env.PAYPAL_WEBHOOK_ID;
    const expectedSignature = headers['paypal-transmission-sig'];
    const certId = headers['paypal-cert-id'];
    const timestamp = headers['paypal-transmission-time'];
    
    // Implement signature verification logic
    return this.validateSignature(webhookEvent, expectedSignature, certId, timestamp, webhookId);
  }

  // Create secure payment
  async createPayment(orderData) {
    const request = new paypal.orders.OrdersCreateRequest();
    request.prefer("return=representation");
    request.requestBody({
      intent: 'CAPTURE',
      purchase_units: [{
        amount: {
          currency_code: 'USD',
          value: orderData.total.toString()
        },
        description: `Fashion Store Order #${orderData.orderId}`,
        invoice_id: orderData.orderId,
        custom_id: orderData.userId
      }],
      application_context: {
        return_url: process.env.PAYPAL_RETURN_URL,
        cancel_url: process.env.PAYPAL_CANCEL_URL,
        shipping_preference: 'SET_PROVIDED_ADDRESS',
        user_action: 'PAY_NOW',
        brand_name: 'Fashion Store'
      }
    });

    try {
      const response = await this.client.execute(request);
      return response.result;
    } catch (error) {
      console.error('PayPal payment creation failed:', error);
      throw new Error('Payment processing failed');
    }
  }
}

module.exports = new PayPalService();
```

## 🚀 Deployment Steps

### 1. Backend Deployment (AWS EC2)

#### Server Setup
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 for process management
sudo npm install -g pm2

# Install Nginx
sudo apt install nginx -y

# Install Certbot for SSL
sudo apt install certbot python3-certbot-nginx -y
```

#### Application Deployment
```bash
# Clone repository
git clone https://github.com/your-username/fashionapp.git
cd fashionapp/backend

# Install dependencies
npm install --production

# Create production environment file
sudo nano .env.production

# Start application with PM2
pm2 start ecosystem.config.js --env production

# Save PM2 configuration
pm2 save
pm2 startup
```

#### PM2 Configuration (ecosystem.config.js)
```javascript
module.exports = {
  apps: [{
    name: 'fashion-store-api',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'development'
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
```

#### Nginx Configuration
```nginx
# /etc/nginx/sites-available/fashion-store-api
server {
    listen 80;
    server_name api.your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.your-domain.com;

    ssl_certificate /etc/letsencrypt/live/api.your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.your-domain.com/privkey.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=30r/m;
    limit_req zone=api burst=5 nodelay;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 2. Database Setup (MongoDB Atlas)

#### MongoDB Atlas Configuration
```javascript
// Production database configuration
const mongoOptions = {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  maxPoolSize: 10,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
  family: 4,
  retryReads: true,
  retryWrites: true,
  ssl: true,
  sslValidate: true
};

mongoose.connect(process.env.MONGODB_URI, mongoOptions);
```

#### Database Indexing
```javascript
// Create indexes for performance
db.products.createIndex({ "name": "text", "description": "text" });
db.products.createIndex({ "category": 1 });
db.products.createIndex({ "price": 1 });
db.orders.createIndex({ "userId": 1, "createdAt": -1 });
db.users.createIndex({ "email": 1 }, { unique: true });
```

### 3. Flutter App Production Build

#### Android Production Build
```bash
# Navigate to Flutter app
cd flutter_app

# Update production configuration
# lib/config/app_config.dart
class AppConfig {
  static const String baseUrl = 'https://api.your-domain.com';
  static const String paypalClientId = 'your-live-paypal-client-id';
  static const bool isProduction = true;
}

# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# The built files will be in:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

#### iOS Production Build
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release

# Open in Xcode for signing and archiving
open ios/Runner.xcworkspace
```

#### Production Configuration Updates
```dart
// lib/config/payment_config.dart
class PaymentConfig {
  static const String paypalClientId = 'your-live-paypal-client-id';
  static const String paypalEnvironment = 'live'; // 'sandbox' for testing
  static const String returnUrl = 'https://your-domain.com/payment/success';
  static const String cancelUrl = 'https://your-domain.com/payment/cancel';
}

// lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'https://api.your-domain.com';
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (AuthService.token != null) 
      'Authorization': 'Bearer ${AuthService.token}',
  };
}
```

## 🔍 Testing in Production

### 1. Payment Testing Strategy

#### Test Scenarios
```bash
# Test Cases for Payment Integration
1. Successful Payment Flow
   - Add items to cart
   - Proceed to checkout
   - Select PayPal payment
   - Complete PayPal authentication
   - Verify order confirmation

2. Failed Payment Scenarios
   - Insufficient funds
   - Cancelled payment
   - Network timeout
   - Invalid payment method

3. Edge Cases
   - Multiple payment attempts
   - Payment during server maintenance
   - Concurrent payments
   - Large order amounts
```

#### PayPal Test Accounts (Sandbox)
```javascript
// Create test accounts in PayPal Developer Dashboard
const testAccounts = {
  buyer: {
    email: 'buyer@test.com',
    password: 'testpassword123'
  },
  seller: {
    email: 'seller@test.com',
    password: 'testpassword123'
  }
};
```

### 2. Load Testing

#### Payment Endpoint Load Testing
```bash
# Using Apache Bench
ab -n 1000 -c 10 -H "Authorization: Bearer token" \
   -p payment_data.json -T application/json \
   https://api.your-domain.com/api/orders/create

# Using Artillery.js
npm install -g artillery
artillery run payment-load-test.yml
```

#### Artillery Configuration (payment-load-test.yml)
```yaml
config:
  target: 'https://api.your-domain.com'
  phases:
    - duration: 60
      arrivalRate: 5
    - duration: 120
      arrivalRate: 10
    - duration: 60
      arrivalRate: 5
  payload:
    - path: "test-data.csv"
      fields:
        - "email"
        - "token"

scenarios:
  - name: "Payment Flow Test"
    weight: 100
    flow:
      - post:
          url: "/api/auth/login"
          json:
            email: "{{ email }}"
            password: "testpassword"
          capture:
            - json: "$.token"
              as: "auth_token"
      - post:
          url: "/api/orders/create"
          headers:
            Authorization: "Bearer {{ auth_token }}"
          json:
            items: [{"id": "1", "quantity": 1}]
            total: 29.99
            paymentMethod: "paypal"
```

## 📊 Monitoring & Analytics

### 1. Application Monitoring

#### Health Check Endpoints
```javascript
// routes/health.js
router.get('/health', (req, res) => {
  const health = {
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV,
    database: mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected',
    memory: process.memoryUsage(),
    cpu: process.cpuUsage()
  };
  
  res.status(200).json(health);
});

// Payment service health check
router.get('/health/payment', async (req, res) => {
  try {
    // Test PayPal connection
    const paypalHealth = await PayPalService.healthCheck();
    res.status(200).json({ status: 'OK', paypal: paypalHealth });
  } catch (error) {
    res.status(503).json({ status: 'Error', error: error.message });
  }
});
```

#### Error Tracking with Sentry
```javascript
// app.js
const Sentry = require('@sentry/node');

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
});

// Payment error tracking
app.use('/api/payments', (req, res, next) => {
  Sentry.addBreadcrumb({
    category: 'payment',
    message: 'Payment request received',
    level: 'info',
    data: { userId: req.user?.id, amount: req.body?.amount }
  });
  next();
});
```

### 2. Payment Analytics

#### Payment Metrics Collection
```javascript
// services/analytics-service.js
class AnalyticsService {
  static async trackPayment(paymentData) {
    try {
      await Analytics.create({
        event: 'payment_attempted',
        userId: paymentData.userId,
        amount: paymentData.amount,
        paymentMethod: paymentData.method,
        timestamp: new Date(),
        metadata: {
          orderId: paymentData.orderId,
          currency: paymentData.currency,
          success: paymentData.success
        }
      });
    } catch (error) {
      console.error('Analytics tracking failed:', error);
    }
  }

  static async getPaymentMetrics(timeframe = '7d') {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 7);

    return await Analytics.aggregate([
      { $match: { timestamp: { $gte: startDate } } },
      {
        $group: {
          _id: '$event',
          count: { $sum: 1 },
          totalAmount: { $sum: '$amount' },
          avgAmount: { $avg: '$amount' }
        }
      }
    ]);
  }
}
```

## 🔧 Maintenance & Updates

### 1. Regular Maintenance Tasks

#### Daily Tasks
```bash
#!/bin/bash
# daily-maintenance.sh

# Check server health
curl -f https://api.your-domain.com/health || echo "Server health check failed"

# Check database connection
mongosh --eval "db.runCommand({ping: 1})" $MONGODB_URI

# Check PayPal service status
curl -f https://api.your-domain.com/health/payment || echo "Payment service check failed"

# Check SSL certificate expiry
openssl s_client -connect api.your-domain.com:443 -servername api.your-domain.com 2>/dev/null | openssl x509 -noout -dates

# Backup database
mongodump --uri=$MONGODB_URI --out=/backups/$(date +%Y%m%d)
```

#### Weekly Tasks
```bash
#!/bin/bash
# weekly-maintenance.sh

# Update system packages
sudo apt update && sudo apt upgrade -y

# Restart PM2 processes
pm2 restart all

# Clean old logs
find /var/log -name "*.log" -type f -mtime +7 -delete

# Analyze payment metrics
node scripts/payment-analytics.js

# Check for security updates
npm audit
```

### 2. Update Procedures

#### Backend Updates
```bash
# 1. Create backup
git tag -a "v$(date +%Y%m%d)" -m "Backup before update"

# 2. Pull latest changes
git pull origin main

# 3. Update dependencies
npm update

# 4. Run tests
npm test

# 5. Deploy with zero downtime
pm2 reload ecosystem.config.js --env production
```

#### Flutter App Updates
```bash
# 1. Update Flutter SDK
flutter upgrade

# 2. Update dependencies
flutter pub upgrade

# 3. Run tests
flutter test

# 4. Build new release
flutter build appbundle --release

# 5. Deploy to app stores
# - Upload to Google Play Console
# - Upload to App Store Connect
```

## 🚨 Troubleshooting

### Common Payment Issues

#### PayPal Integration Issues
```javascript
// Common errors and solutions
const paypalErrors = {
  'INVALID_CLIENT_CREDENTIALS': {
    solution: 'Check PayPal Client ID and Secret in production environment',
    action: 'Update environment variables with live credentials'
  },
  'PAYMENT_AUTHORIZATION_EXPIRED': {
    solution: 'Payment authorization expired, request new authorization',
    action: 'Implement payment retry mechanism'
  },
  'INSTRUMENT_DECLINED': {
    solution: 'Customer payment method declined',
    action: 'Ask customer to try different payment method'
  },
  'INSUFFICIENT_FUNDS': {
    solution: 'Customer has insufficient funds',
    action: 'Display appropriate error message to customer'
  }
};
```

#### Network and Connectivity Issues
```javascript
// Implement retry mechanism
const retryPayment = async (paymentData, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await PayPalService.createPayment(paymentData);
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
};
```

### Emergency Procedures

#### Payment Service Outage
```bash
# 1. Enable maintenance mode
echo "Payment system temporarily unavailable" > /var/www/maintenance.html

# 2. Check service status
systemctl status nginx
pm2 status
mongosh --eval "db.runCommand({ping: 1})"

# 3. Check PayPal service status
curl -I https://api.paypal.com/v1/oauth2/token

# 4. Implement fallback payment method
# Enable alternative payment options in app

# 5. Monitor error logs
tail -f /var/log/nginx/error.log
pm2 logs fashion-store-api
```

---

## 📞 Support Contacts

- **Technical Support**: tech-support@your-domain.com
- **PayPal Integration**: paypal-support@your-domain.com
- **Emergency Hotline**: +1-XXX-XXX-XXXX
- **Documentation**: https://docs.your-domain.com

---

**Last Updated**: July 1, 2025
**Version**: 1.0.0
