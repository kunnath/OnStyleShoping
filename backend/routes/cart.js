const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Product = require('../models/Product');
const auth = require('../middleware/auth');

// Get user's cart
router.get('/', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id)
      .populate({
        path: 'cart.product',
        select: 'name price images description discountedPrice discount'
      });
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Calculate cart totals
    const cartItems = user.cart.map(item => ({
      _id: item._id,
      product: item.product,
      quantity: item.quantity,
      addedAt: item.addedAt,
      itemTotal: item.product.discountedPrice * item.quantity
    }));

    const subtotal = cartItems.reduce((sum, item) => sum + item.itemTotal, 0);
    const itemCount = cartItems.reduce((sum, item) => sum + item.quantity, 0);
    const shipping = subtotal > 50 ? 0 : 5.99;
    const total = subtotal + shipping;

    res.json({
      success: true,
      data: {
        items: cartItems,
        summary: {
          itemCount,
          subtotal: subtotal.toFixed(2),
          shipping: shipping.toFixed(2),
          total: total.toFixed(2)
        }
      }
    });
  } catch (error) {
    console.error('Get cart error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error',
      error: error.message 
    });
  }
});

// Add item to cart
router.post('/add', auth, async (req, res) => {
  try {
    const { productId, quantity = 1 } = req.body;

    if (!productId) {
      return res.status(400).json({ 
        success: false,
        message: 'Product ID is required' 
      });
    }

    // Check if product exists and is active
    const product = await Product.findById(productId);
    if (!product || !product.isActive) {
      return res.status(404).json({ 
        success: false,
        message: 'Product not found or not available' 
      });
    }

    // Check stock availability
    if (!product.isInStock()) {
      return res.status(400).json({ 
        success: false,
        message: 'Product is out of stock' 
      });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ 
        success: false,
        message: 'User not found' 
      });
    }

    await user.addToCart(productId, quantity);

    // Get updated cart
    const updatedUser = await User.findById(req.user.id)
      .populate({
        path: 'cart.product',
        select: 'name price images description discountedPrice'
      });

    res.json({
      success: true,
      message: 'Item added to cart successfully',
      data: {
        cartItemCount: updatedUser.cartItemCount,
        cart: updatedUser.cart
      }
    });
  } catch (error) {
    console.error('Add to cart error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error',
      error: error.message 
    });
  }
});

// Update cart item quantity
router.put('/update/:itemId', auth, async (req, res) => {
  try {
    const { itemId } = req.params;
    const { quantity } = req.body;

    if (!quantity || quantity < 0) {
      return res.status(400).json({ 
        success: false,
        message: 'Valid quantity is required' 
      });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ 
        success: false,
        message: 'User not found' 
      });
    }

    // Find the cart item
    const cartItem = user.cart.id(itemId);
    if (!cartItem) {
      return res.status(404).json({ 
        success: false,
        message: 'Cart item not found' 
      });
    }

    await user.updateCartItemQuantity(cartItem.product, quantity);

    res.json({
      success: true,
      message: 'Cart updated successfully'
    });
  } catch (error) {
    console.error('Update cart error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error',
      error: error.message 
    });
  }
});

// Remove item from cart
router.delete('/remove/:itemId', auth, async (req, res) => {
  try {
    const { itemId } = req.params;

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ 
        success: false,
        message: 'User not found' 
      });
    }

    // Find the cart item
    const cartItem = user.cart.id(itemId);
    if (!cartItem) {
      return res.status(404).json({ 
        success: false,
        message: 'Cart item not found' 
      });
    }

    await user.removeFromCart(cartItem.product);

    res.json({
      success: true,
      message: 'Item removed from cart successfully'
    });
  } catch (error) {
    console.error('Remove from cart error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error',
      error: error.message 
    });
  }
});

// Clear entire cart
router.delete('/clear', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ 
        success: false,
        message: 'User not found' 
      });
    }

    await user.clearCart();

    res.json({
      success: true,
      message: 'Cart cleared successfully'
    });
  } catch (error) {
    console.error('Clear cart error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error',
      error: error.message 
    });
  }
});

// Get cart item count (for header badge)
router.get('/count', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ 
        success: false,
        message: 'User not found' 
      });
    }

    res.json({
      success: true,
      data: {
        count: user.cartItemCount
      }
    });
  } catch (error) {
    console.error('Get cart count error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error',
      error: error.message 
    });
  }
});

module.exports = router;
