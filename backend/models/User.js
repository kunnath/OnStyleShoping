const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  phone: {
    type: String,
    trim: true
  },
  address: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: String
  },
  cart: [{
    product: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Product',
      required: true
    },
    quantity: {
      type: Number,
      required: true,
      min: 1,
      default: 1
    },
    addedAt: {
      type: Date,
      default: Date.now
    }
  }],
  wishlist: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product'
  }],
  orders: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order'
  }],
  isActive: {
    type: Boolean,
    default: true
  },
  role: {
    type: String,
    enum: ['customer', 'admin'],
    default: 'customer'
  }
}, {
  timestamps: true
});

// Virtual for cart total
userSchema.virtual('cartTotal').get(function() {
  return this.cart.reduce((total, item) => {
    return total + (item.product.price * item.quantity);
  }, 0);
});

// Virtual for cart item count
userSchema.virtual('cartItemCount').get(function() {
  return this.cart.reduce((total, item) => total + item.quantity, 0);
});

// Method to add item to cart
userSchema.methods.addToCart = function(productId, quantity = 1) {
  const existingItemIndex = this.cart.findIndex(
    item => item.product.toString() === productId.toString()
  );
  
  if (existingItemIndex >= 0) {
    this.cart[existingItemIndex].quantity += quantity;
  } else {
    this.cart.push({
      product: productId,
      quantity: quantity
    });
  }
  
  return this.save();
};

// Method to remove item from cart
userSchema.methods.removeFromCart = function(productId) {
  this.cart = this.cart.filter(
    item => item.product.toString() !== productId.toString()
  );
  return this.save();
};

// Method to update cart item quantity
userSchema.methods.updateCartItemQuantity = function(productId, quantity) {
  const itemIndex = this.cart.findIndex(
    item => item.product.toString() === productId.toString()
  );
  
  if (itemIndex >= 0) {
    if (quantity <= 0) {
      this.cart.splice(itemIndex, 1);
    } else {
      this.cart[itemIndex].quantity = quantity;
    }
  }
  
  return this.save();
};

// Method to clear cart
userSchema.methods.clearCart = function() {
  this.cart = [];
  return this.save();
};

module.exports = mongoose.model('User', userSchema);
