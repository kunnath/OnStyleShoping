# Quick Start Guide

## 🚀 Get Started in 5 Minutes

This guide will get your Fashion Store app running locally in just a few minutes.

## Prerequisites

Make sure you have these installed:
- **Flutter SDK** (3.7.2+): [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Node.js** (14+): [Install Node.js](https://nodejs.org/)
- **MongoDB**: [Install MongoDB](https://docs.mongodb.com/manual/installation/) or use [MongoDB Atlas](https://www.mongodb.com/atlas)
- **Git**: [Install Git](https://git-scm.com/downloads)

## 1. Clone Repository

```bash
git clone <your-repository-url>
cd fashionapp
```

## 2. Backend Setup (2 minutes)

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env file with your settings
nano .env
```

### Environment Configuration (.env)
```env
# Database
MONGODB_URI=mongodb://localhost:27017/fashionstore

# JWT
JWT_SECRET=your-jwt-secret-key-here
JWT_EXPIRE=7d

# PayPal (Use sandbox for development)
PAYPAL_CLIENT_ID=your-paypal-sandbox-client-id
PAYPAL_CLIENT_SECRET=your-paypal-sandbox-secret
PAYPAL_MODE=sandbox

# Server
PORT=3000
NODE_ENV=development
```

### Start Backend Server
```bash
npm start
```

✅ Backend should be running on `http://localhost:3000`

## 3. Flutter App Setup (2 minutes)

Open a new terminal:

```bash
# Navigate to Flutter app
cd flutter_app

# Get dependencies
flutter pub get

# Check for issues
flutter doctor
```

### Update Configuration

Edit `lib/config/app_config.dart` (create if doesn't exist):
```dart
class AppConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String paypalClientId = 'your-paypal-sandbox-client-id';
  static const bool paypalSandboxMode = true; // true for development
  static const bool isProduction = false;
}
```

### Run Flutter App
```bash
# For Android
flutter run

# For iOS (Mac only)
flutter run -d ios

# For web
flutter run -d web
```

✅ App should launch on your device/emulator!

## 4. Quick Test

1. **Open the app** on your device/emulator
2. **Browse products** on the Home tab
3. **Add items to cart** using the shopping cart icon
4. **View cart** by tapping the Cart tab
5. **Test checkout** with PayPal sandbox account

## 5. PayPal Sandbox Setup (Optional but Recommended)

### Get PayPal Developer Account
1. Go to [PayPal Developer Portal](https://developer.paypal.com/)
2. Sign up or log in
3. Create a new sandbox app
4. Copy Client ID and Secret Key
5. Update your `.env` and Flutter config files

### Create Test Accounts
1. In PayPal Developer Portal, go to "Sandbox Accounts"
2. Create a test buyer account
3. Use these credentials to test payments

## 🎉 You're Ready!

Your Fashion Store app is now running locally with:
- ✅ Backend API server
- ✅ Flutter mobile/web app
- ✅ MongoDB database
- ✅ PayPal payment integration (sandbox)

## Next Steps

### Development
- Explore the code structure
- Customize the UI and features
- Add your own products and categories
- Test different payment scenarios

### Production Setup
- Follow the [Production Deployment Guide](PRODUCTION_DEPLOYMENT_GUIDE.md)
- Set up live PayPal credentials
- Configure SSL certificates
- Deploy to cloud services

## 🆘 Troubleshooting

### Common Issues

**Backend won't start:**
```bash
# Check if MongoDB is running
mongosh --eval "db.runCommand({ connectionStatus: 1 })"

# Check port availability
lsof -i :3000
```

**Flutter build issues:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter doctor
```

**PayPal sandbox issues:**
- Verify Client ID and Secret are correct
- Ensure `sandboxMode: true` in Flutter
- Check PayPal Developer Portal for errors

**Database connection issues:**
- Make sure MongoDB is running
- Check MONGODB_URI in .env file
- Test connection with MongoDB Compass

### Getting Help

1. Check the console logs for error messages
2. Review the [full documentation](README.md)
3. Test with sample data first
4. Use debug mode for detailed error information

## 📱 Testing on Different Platforms

### Android
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### iOS (Mac required)
```bash
# Open iOS Simulator
open -a Simulator

# Run on iOS
flutter run -d ios
```

### Web
```bash
# Run on web
flutter run -d web

# Build for web
flutter build web
```

## 🔧 Development Tools

### Recommended VS Code Extensions
- Flutter
- Dart
- Thunder Client (for API testing)
- MongoDB for VS Code
- GitLens

### Useful Commands
```bash
# Flutter
flutter analyze          # Check for issues
flutter test            # Run tests
flutter build apk       # Build Android APK

# Backend
npm run dev            # Start with nodemon
npm test              # Run backend tests  
npm run lint          # Check code style
```

---

**🎯 Goal**: Get you coding and testing quickly without getting bogged down in configuration details.

For comprehensive setup including production deployment, security, and advanced features, see the [complete documentation](README.md).

Happy coding! 🚀
