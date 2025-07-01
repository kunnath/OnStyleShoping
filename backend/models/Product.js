const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    required: true,
    min: 0
  },
  originalPrice: {
    type: Number,
    min: 0
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: true
  },
  subcategory: {
    type: String,
    trim: true
  },
  brand: {
    type: String,
    trim: true
  },
  images: [{
    url: {
      type: String,
      required: true
    },
    alt: {
      type: String
    }
  }],
  sizes: [{
    size: {
      type: String,
      required: true
    },
    stock: {
      type: Number,
      required: true,
      min: 0,
      default: 0
    }
  }],
  colors: [{
    name: {
      type: String,
      required: true
    },
    code: {
      type: String // Hex color code
    },
    images: [String] // Image URLs for this color
  }],
  totalStock: {
    type: Number,
    required: true,
    min: 0,
    default: 0
  },
  rating: {
    average: {
      type: Number,
      min: 0,
      max: 5,
      default: 0
    },
    count: {
      type: Number,
      default: 0
    }
  },
  reviews: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },
    comment: {
      type: String,
      required: true
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  tags: [String],
  isActive: {
    type: Boolean,
    default: true
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  isNewArrival: {
    type: Boolean,
    default: false
  },
  discount: {
    percentage: {
      type: Number,
      min: 0,
      max: 100,
      default: 0
    },
    startDate: Date,
    endDate: Date
  },
  seo: {
    title: String,
    description: String,
    keywords: [String]
  }
}, {
  timestamps: true
});

// Virtual for discounted price
productSchema.virtual('discountedPrice').get(function() {
  if (this.discount.percentage > 0) {
    return this.price * (1 - this.discount.percentage / 100);
  }
  return this.price;
});

// Virtual for discount amount
productSchema.virtual('discountAmount').get(function() {
  if (this.discount.percentage > 0) {
    return this.price * (this.discount.percentage / 100);
  }
  return 0;
});

// Virtual for main image
productSchema.virtual('mainImage').get(function() {
  return this.images.length > 0 ? this.images[0].url : null;
});

// Method to check if product is in stock
productSchema.methods.isInStock = function(size = null) {
  if (size) {
    const sizeInfo = this.sizes.find(s => s.size === size);
    return sizeInfo ? sizeInfo.stock > 0 : false;
  }
  return this.totalStock > 0;
};

// Method to reduce stock
productSchema.methods.reduceStock = function(quantity, size = null) {
  if (size) {
    const sizeIndex = this.sizes.findIndex(s => s.size === size);
    if (sizeIndex >= 0 && this.sizes[sizeIndex].stock >= quantity) {
      this.sizes[sizeIndex].stock -= quantity;
      this.totalStock -= quantity;
      return this.save();
    }
    throw new Error('Insufficient stock');
  } else {
    if (this.totalStock >= quantity) {
      this.totalStock -= quantity;
      return this.save();
    }
    throw new Error('Insufficient stock');
  }
};

// Index for search
productSchema.index({
  name: 'text',
  description: 'text',
  brand: 'text',
  tags: 'text'
});

// Index for category and price filtering
productSchema.index({ category: 1, price: 1 });
productSchema.index({ isActive: 1, isFeatured: 1 });
productSchema.index({ isActive: 1, isNewArrival: 1 });

module.exports = mongoose.model('Product', productSchema);
