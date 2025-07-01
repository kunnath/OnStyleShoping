#!/bin/bash

# Fashion Store App - Quick Setup Script
# This script helps set up the development environment

echo "🚀 Fashion Store App - Quick Setup"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_status "Node.js found: $NODE_VERSION"
    else
        print_error "Node.js is not installed. Please install Node.js 18+ from https://nodejs.org/"
        exit 1
    fi
    
    # Check Flutter
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        print_status "Flutter found: $FLUTTER_VERSION"
    else
        print_error "Flutter is not installed. Please install Flutter from https://flutter.dev/"
        exit 1
    fi
    
    # Check MongoDB
    if command -v mongod &> /dev/null; then
        print_status "MongoDB found"
    else
        print_warning "MongoDB not found locally. You can use MongoDB Atlas for cloud database."
    fi
}

# Setup backend
setup_backend() {
    print_status "Setting up backend..."
    
    cd backend
    
    # Install dependencies
    print_status "Installing backend dependencies..."
    npm install
    
    # Create environment file if it doesn't exist
    if [ ! -f .env ]; then
        print_status "Creating environment file..."
        cat > .env << EOL
# Database
MONGODB_URI=mongodb://localhost:27017/fashionstore

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# Server
PORT=5000
NODE_ENV=development

# PayPal Configuration (Sandbox)
PAYPAL_CLIENT_ID=your-paypal-sandbox-client-id
PAYPAL_CLIENT_SECRET=your-paypal-sandbox-client-secret
PAYPAL_MODE=sandbox

# API Base URL
API_BASE_URL=http://localhost:5000/api
EOL
        print_warning "Environment file created. Please update PayPal credentials in backend/.env"
    else
        print_status "Environment file already exists"
    fi
    
    cd ..
}

# Setup Flutter app
setup_flutter() {
    print_status "Setting up Flutter app..."
    
    cd flutter_app
    
    # Get dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    # Run Flutter doctor
    print_status "Running Flutter doctor..."
    flutter doctor
    
    cd ..
}

# Setup frontend (optional)
setup_frontend() {
    if [ -d "frontend" ]; then
        print_status "Setting up React frontend..."
        cd frontend
        npm install
        cd ..
    else
        print_status "React frontend not found, skipping..."
    fi
}

# Create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    # Backend uploads directory
    mkdir -p backend/uploads/products
    mkdir -p backend/logs
    
    # Screenshots directory for README
    mkdir -p screenshots
    
    print_status "Directories created successfully"
}

# Start services
start_services() {
    print_status "Starting development services..."
    
    # Start MongoDB if available
    if command -v mongod &> /dev/null; then
        print_status "Starting MongoDB..."
        mongod --dbpath ./data/db --fork --logpath ./data/logs/mongodb.log
    fi
    
    print_status "Setup complete! You can now start the services:"
    echo ""
    echo "📱 Flutter App:"
    echo "   cd flutter_app && flutter run"
    echo ""
    echo "🔧 Backend API:"
    echo "   cd backend && npm start"
    echo ""
    echo "🌐 React Frontend (if available):"
    echo "   cd frontend && npm start"
    echo ""
    echo "📚 Next Steps:"
    echo "   1. Update PayPal credentials in backend/.env"
    echo "   2. Set up MongoDB database (local or Atlas)"
    echo "   3. Run Flutter app on emulator/device"
    echo ""
}

# Main execution
main() {
    echo ""
    check_requirements
    echo ""
    create_directories
    echo ""
    setup_backend
    echo ""
    setup_flutter
    echo ""
    setup_frontend
    echo ""
    start_services
}

# Run main function
main

print_status "🎉 Setup completed successfully!"
