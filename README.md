# Fashion Store App

A comprehensive e-commerce fashion application built with Flutter (frontend) and Node.js/Express (backend), featuring cart management, wishlist functionality, secure checkout, and integrated payment processing with PayPal.

## 🚀 Features

### 📱 Mobile App (Flutter)
- **User Authentication**: Secure login and registration
- **Product Catalog**: Browse and search fashion items with filters
- **Shopping Cart**: Add, remove, and manage items
- **Wishlist**: Save favorite items for later
- **User Profile**: Manage personal information, addresses, and payment methods
- **Payment Integration**: Secure PayPal integration for payments
- **Order Management**: Track orders and view history
- **Responsive Design**: Modern UI with Material Design 3

### 🔧 Backend (Node.js/Express)
- **RESTful API**: Complete API for product management
- **Authentication**: JWT-based authentication system
- **Database Integration**: MongoDB for data persistence
- **File Upload**: Product image management
- **Cart Management**: Server-side cart operations
- **Order Processing**: Complete order workflow

## 🏗️ Architecture

```
fashionapp/
├── flutter_app/          # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart      # Main app entry point
│   │   ├── models/        # Data models
│   │   ├── providers/     # State management
│   │   ├── screens/       # UI screens
│   │   └── widgets/       # Reusable widgets
│   ├── android/           # Android configuration
│   ├── ios/              # iOS configuration
│   └── pubspec.yaml      # Flutter dependencies
├── backend/              # Node.js backend
│   ├── server.js         # Express server
│   ├── models/           # Database models
│   ├── routes/           # API routes
│   ├── middleware/       # Authentication middleware
│   └── uploads/          # File uploads
└── frontend/             # React web app (optional)
```

## 🛠️ Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.24.3
- **State Management**: Provider
- **HTTP Client**: http package
- **Payment Processing**: flutter_paypal_payment
- **Image Handling**: image_picker
- **Local Storage**: shared_preferences

### Backend (Node.js)
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose
- **Authentication**: JSON Web Tokens (JWT)
- **File Upload**: Multer
- **CORS**: cors middleware

## 📋 Prerequisites

Before running this application, make sure you have the following installed:

- **Flutter SDK** (3.24.3 or later)
- **Dart SDK** (3.5.3 or later)
- **Node.js** (18.0 or later)
- **npm** or **yarn**
- **MongoDB** (local or cloud instance)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **PayPal Developer Account** (for payment integration)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd fashionapp
```

### 2. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Configure your environment variables in .env
# - MONGODB_URI=mongodb://localhost:27017/fashionstore
# - JWT_SECRET=your-jwt-secret-key
# - PORT=5000
# - PAYPAL_CLIENT_ID=your-paypal-client-id
# - PAYPAL_CLIENT_SECRET=your-paypal-client-secret

# Start the server
npm start
```

### 3. Flutter App Setup

```bash
# Navigate to Flutter app directory
cd ../flutter_app

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## 🔧 Configuration

### Environment Variables (Backend)

Create a `.env` file in the `backend` directory:

```env
# Database
MONGODB_URI=mongodb://localhost:27017/fashionstore

# JWT
JWT_SECRET=your-super-secret-jwt-key-here

# Server
PORT=5000
NODE_ENV=development

# PayPal Configuration
PAYPAL_CLIENT_ID=your-paypal-client-id
PAYPAL_CLIENT_SECRET=your-paypal-client-secret
PAYPAL_MODE=sandbox  # Use 'live' for production

# API Keys
API_BASE_URL=http://localhost:5000/api
```

### Flutter Configuration

Update the API base URL in your Flutter app:

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String baseUrl = 'http://localhost:5000/api';
  static const String paypalClientId = 'your-paypal-client-id';
}
```

## 💳 Payment Integration

### PayPal Setup

1. **Create PayPal Developer Account**
   - Visit [PayPal Developer Portal](https://developer.paypal.com/)
   - Create a new application
   - Get your Client ID and Client Secret

2. **Configure PayPal in Flutter**
   ```dart
   // Already configured in main.dart
   FlutterPaypalPayment.makePayment(
     PaypalPaymentSettings(
       clientId: "your-paypal-client-id",
       secretKey: "your-paypal-secret-key",
       // ... other settings
     ),
   );
   ```

3. **Backend PayPal Integration**
   ```javascript
   // Implement PayPal SDK in your backend
   const paypal = require('@paypal/checkout-server-sdk');
   ```

## 📱 Running the Application

### Development Mode

```bash
# Terminal 1: Start Backend
cd backend
npm run dev

# Terminal 2: Start Flutter App
cd flutter_app
flutter run

# Optional Terminal 3: Start React Web App
cd frontend
npm start
```

### Production Mode

See [PRODUCTION_DEPLOYMENT_GUIDE.md](./PRODUCTION_DEPLOYMENT_GUIDE.md) for detailed production setup instructions.

## 🧪 Testing

### Flutter Tests
```bash
cd flutter_app
flutter test
```

### Backend Tests
```bash
cd backend
npm test
```

## 📚 API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile

### Product Endpoints
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create product (admin)
- `PUT /api/products/:id` - Update product (admin)
- `DELETE /api/products/:id` - Delete product (admin)

### Cart Endpoints
- `GET /api/cart` - Get user cart
- `POST /api/cart/add` - Add item to cart
- `PUT /api/cart/update` - Update cart item
- `DELETE /api/cart/remove` - Remove item from cart

### Order Endpoints
- `POST /api/orders` - Create new order
- `GET /api/orders` - Get user orders
- `GET /api/orders/:id` - Get order by ID

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt for password security
- **CORS Protection**: Configured CORS middleware
- **Input Validation**: Request validation and sanitization
- **PayPal Integration**: Secure payment processing
- **File Upload Security**: Secure file handling

## 🎨 UI/UX Features

- **Material Design 3**: Modern Flutter UI components
- **Dark/Light Theme**: Automatic theme switching
- **Responsive Design**: Works on all screen sizes
- **Smooth Animations**: Engaging user interactions
- **Loading States**: User-friendly loading indicators
- **Error Handling**: Graceful error messages

## 🚀 Deployment

### Flutter App Deployment
- **Android**: Generate APK/AAB for Google Play Store
- **iOS**: Build for App Store submission
- **Web**: Deploy to Firebase Hosting or Netlify

### Backend Deployment
- **Heroku**: Easy deployment with MongoDB Atlas
- **AWS**: EC2 with RDS/DocumentDB
- **DigitalOcean**: Droplet with managed database
- **Vercel/Netlify**: Serverless deployment

## 📈 Performance Optimization

- **Image Optimization**: Compressed images and lazy loading
- **Caching**: Implemented caching strategies
- **Database Indexing**: Optimized database queries
- **Code Splitting**: Lazy loading of screens
- **Bundle Optimization**: Minimized app size

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Contact: your-email@example.com
- Documentation: [Wiki](link-to-wiki)

## 🎯 Roadmap

- [ ] Social media authentication (Google, Facebook)
- [ ] Push notifications
- [ ] Offline support
- [ ] Multi-language support
- [ ] Advanced analytics
- [ ] Machine learning recommendations
- [ ] Voice search
- [ ] Augmented reality try-on

## 📊 Screenshots

| Home Screen | Product Details | Cart | Profile |
|-------------|----------------|------|---------|
| ![Home](screenshots/home.png) | ![Product](screenshots/product.png) | ![Cart](screenshots/cart.png) | ![Profile](screenshots/profile.png) |

---

**Made with ❤️ by Your Team**
# OnStyleShoping
