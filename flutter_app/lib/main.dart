import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

// Checkout Models
class ShippingAddress {
  final String fullName;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phone;

  ShippingAddress({
    required this.fullName,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phone,
  });
}

class PaymentMethod {
  final String id;
  final String type; // 'card', 'paypal', 'apple_pay', etc.
  final String displayName;
  final String? lastFourDigits;
  final String? expiryDate;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    this.lastFourDigits,
    this.expiryDate,
  });
}

class Order {
  final String id;
  final List<CartItem> items;
  final ShippingAddress shippingAddress;
  final PaymentMethod paymentMethod;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.orderDate,
    this.status = 'confirmed',
  });
}

// Cart Item Model
class CartItem {
  final String id;
  final String name;
  final String price;
  final String image;
  int quantity;
  final double numericPrice;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
    required this.numericPrice,
  });
}

// Wishlist Item Model
class WishlistItem {
  final String id;
  final String name;
  final String price;
  final String image;
  final String? discount;
  final double numericPrice;
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.discount,
    required this.numericPrice,
    required this.addedAt,
  });
}

// Cart State Management
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + (item.numericPrice * item.quantity));
  
  void addItem(Map<String, dynamic> product) {
    final productId = product['name'];
    final numericPrice = double.parse(product['price'].replaceAll('\$', ''));
    
    final existingIndex = _items.indexWhere((item) => item.id == productId);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        id: productId,
        name: product['name'],
        price: product['price'],
        image: product['image'],
        numericPrice: numericPrice,
      ));
    }
    notifyListeners();
  }
  
  void removeItem(String productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }
  
  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }
  
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// Wishlist State Management
class WishlistProvider extends ChangeNotifier {
  final List<WishlistItem> _items = [];
  
  List<WishlistItem> get items => _items;
  int get itemCount => _items.length;
  
  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }
  
  void addItem(Map<String, dynamic> product) {
    final productId = product['name'];
    
    if (!isInWishlist(productId)) {
      final numericPrice = double.parse(product['price'].replaceAll('\$', ''));
      
      _items.add(WishlistItem(
        id: productId,
        name: product['name'],
        price: product['price'],
        image: product['image'],
        discount: product['discount'],
        numericPrice: numericPrice,
        addedAt: DateTime.now(),
      ));
      notifyListeners();
    }
  }
  
  void removeItem(String productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }
  
  void toggleItem(Map<String, dynamic> product) {
    final productId = product['name'];
    if (isInWishlist(productId)) {
      removeItem(productId);
    } else {
      addItem(product);
    }
  }
  
  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => WishlistProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ],
      child: const FashionApp(),
    ),
  );
}

class FashionApp extends StatelessWidget {
  const FashionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C2C2C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _currentBottomNavIndex = 0;
  
  final List<String> _bannerImages = [
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=2340&q=80',
    'https://images.unsplash.com/photo-1445205170230-053b83016050?ixlib=rb-4.0.3&auto=format&fit=crop&w=2342&q=80',
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-4.0.3&auto=format&fit=crop&w=2340&q=80',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Women', 'icon': Icons.woman, 'color': Colors.pink},
    {'name': 'Men', 'icon': Icons.man, 'color': Colors.blue},
    {'name': 'Kids', 'icon': Icons.child_care, 'color': Colors.orange},
    {'name': 'Accessories', 'icon': Icons.watch, 'color': Colors.purple},
    {'name': 'Shoes', 'icon': Icons.directions_walk, 'color': Colors.green},
    {'name': 'Sale', 'icon': Icons.local_offer, 'color': Colors.red},
  ];

  final List<Map<String, dynamic>> _featuredProducts = [
    {
      'name': 'Summer Dress',
      'price': '\$49.99',
      'image': 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&w=1000&q=80',
      'discount': '20% OFF'
    },
    {
      'name': 'Casual Shirt',
      'price': '\$29.99',
      'image': 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=1000&q=80',
      'discount': null
    },
    {
      'name': 'Designer Jeans',
      'price': '\$79.99',
      'image': 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=1000&q=80',
      'discount': '15% OFF'
    },
    {
      'name': 'Sneakers',
      'price': '\$89.99',
      'image': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=1000&q=80',
      'discount': null
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Fashion Store',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () => _showSearchDialog(context),
              ),
              Consumer<WishlistProvider>(
                builder: (context, wishlist, child) => Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.black),
                      onPressed: () => _showWishlist(context),
                    ),
                    if (wishlist.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${wishlist.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Consumer<CartProvider>(
                builder: (context, cart, child) => Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                      onPressed: () => _showCart(context),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildBannerCarousel()),
          SliverToBoxAdapter(child: _buildCategoriesSection()),
          SliverToBoxAdapter(child: _buildFeaturedSection()),
          SliverToBoxAdapter(child: _buildNewArrivalsSection()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBannerCarousel() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      margin: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(_bannerImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New Collection', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('Discover the latest trends', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _bannerImages.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == entry.key ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Categories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return GestureDetector(
                onTap: () => _navigateToCategory(category['name']),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, spreadRadius: 2)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: (category['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(category['icon'], color: category['color'], size: 30),
                      ),
                      const SizedBox(height: 8),
                      Text(category['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Featured Products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => _viewAllProducts('Featured'), child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredProducts.length,
              itemBuilder: (context, index) => _buildProductCard(_featuredProducts[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewArrivalsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('New Arrivals', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => _viewAllProducts('New Arrivals'), child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _featuredProducts.length,
            itemBuilder: (context, index) => _buildGridProductCard(_featuredProducts[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                if (product['discount'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                      child: Text(product['discount'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(product),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlist, child) => Icon(
                          wishlist.isInWishlist(product['name']) ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: wishlist.isInWishlist(product['name']) ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                        GestureDetector(
                          onTap: () => _addToCart(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                if (product['discount'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                      child: Text(product['discount'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(product),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlist, child) => Icon(
                          wishlist.isInWishlist(product['name']) ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: wishlist.isInWishlist(product['name']) ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add_shopping_cart, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: _handleBottomNavTap,
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: const TextField(decoration: InputDecoration(hintText: 'Search for products...', prefixIcon: Icon(Icons.search))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Search')),
        ],
      ),
    );
  }

  void _showWishlist(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
  }

  void _showCart(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
  }

  void _navigateToCategory(String categoryName) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigating to $categoryName category')));
  }

  void _viewAllProducts(String section) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing all $section products')));
  }

  void _toggleWishlist(Map<String, dynamic> product) {
    final wishlist = Provider.of<WishlistProvider>(context, listen: false);
    final wasInWishlist = wishlist.isInWishlist(product['name']);
    
    wishlist.toggleItem(product);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasInWishlist ? '${product['name']} removed from wishlist' : '${product['name']} added to wishlist'),
        action: SnackBarAction(label: 'View Wishlist', onPressed: () => _showWishlist(context)),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart'),
        action: SnackBarAction(label: 'View Cart', onPressed: () => _showCart(context)),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);
    switch (index) {
      case 1: Navigator.push(context, MaterialPageRoute(builder: (context) => const ExplorePage())); break;
      case 2: _showWishlist(context); break;
      case 3: _showCart(context); break;
      case 4: _showProfile(context); break;
    }
    setState(() => _currentBottomNavIndex = 0);
  }

  void _showProfile(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }
}

// Profile Models
class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final DateTime joinDate;
  final List<ShippingAddress> savedAddresses;
  final List<PaymentMethod> savedPaymentMethods;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.joinDate,
    required this.savedAddresses,
    required this.savedPaymentMethods,
  });
}

class ProfileProvider extends ChangeNotifier {
  UserProfile _userProfile = UserProfile(
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+1 (555) 123-4567',
    avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=300&q=80',
    joinDate: DateTime(2023, 1, 15),
    savedAddresses: [
      ShippingAddress(
        fullName: 'John Doe',
        street: '123 Main Street',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'United States',
        phone: '+1 (555) 123-4567',
      ),
    ],
    savedPaymentMethods: [
      PaymentMethod(
        id: '1',
        type: 'card',
        displayName: 'Visa ending in 1234',
        lastFourDigits: '1234',
        expiryDate: '12/25',
      ),
    ],
  );

  UserProfile get userProfile => _userProfile;

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) {
    _userProfile = UserProfile(
      name: name ?? _userProfile.name,
      email: email ?? _userProfile.email,
      phone: phone ?? _userProfile.phone,
      avatar: avatar ?? _userProfile.avatar,
      joinDate: _userProfile.joinDate,
      savedAddresses: _userProfile.savedAddresses,
      savedPaymentMethods: _userProfile.savedPaymentMethods,
    );
    notifyListeners();
  }

  void addAddress(ShippingAddress address) {
    _userProfile = UserProfile(
      name: _userProfile.name,
      email: _userProfile.email,
      phone: _userProfile.phone,
      avatar: _userProfile.avatar,
      joinDate: _userProfile.joinDate,
      savedAddresses: [..._userProfile.savedAddresses, address],
      savedPaymentMethods: _userProfile.savedPaymentMethods,
    );
    notifyListeners();
  }

  void addPaymentMethod(PaymentMethod paymentMethod) {
    _userProfile = UserProfile(
      name: _userProfile.name,
      email: _userProfile.email,
      phone: _userProfile.phone,
      avatar: _userProfile.avatar,
      joinDate: _userProfile.joinDate,
      savedAddresses: _userProfile.savedAddresses,
      savedPaymentMethods: [..._userProfile.savedPaymentMethods, paymentMethod],
    );
    notifyListeners();
  }

  void removePaymentMethod(int index) {
    final updatedMethods = List<PaymentMethod>.from(_userProfile.savedPaymentMethods);
    updatedMethods.removeAt(index);
    
    _userProfile = UserProfile(
      name: _userProfile.name,
      email: _userProfile.email,
      phone: _userProfile.phone,
      avatar: _userProfile.avatar,
      joinDate: _userProfile.joinDate,
      savedAddresses: _userProfile.savedAddresses,
      savedPaymentMethods: updatedMethods,
    );
    notifyListeners();
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final profile = profileProvider.userProfile;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(profile.avatar),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.email,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Member since ${profile.joinDate.year}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showEditProfileDialog(context, profile),
                        icon: const Icon(Icons.edit, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Account Section
                _buildSectionTitle('Account'),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  onTap: () => _showEditProfileDialog(context, profile),
                ),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Shipping Addresses',
                  subtitle: '${profile.savedAddresses.length} saved addresses',
                  onTap: () => _showAddressesScreen(context),
                ),
                _buildMenuItem(
                  icon: Icons.payment_outlined,
                  title: 'Payment Methods',
                  subtitle: '${profile.savedPaymentMethods.length} saved methods',
                  onTap: () => _showPaymentMethodsScreen(context),
                ),
                
                const SizedBox(height: 20),
                
                // Orders Section
                _buildSectionTitle('Orders'),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'Order History',
                  onTap: () => _showOrderHistory(context),
                ),
                _buildMenuItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Track Orders',
                  onTap: () => _showTrackOrders(context),
                ),
                _buildMenuItem(
                  icon: Icons.assignment_return_outlined,
                  title: 'Returns & Refunds',
                  onTap: () => _showReturnsRefunds(context),
                ),
                
                const SizedBox(height: 20),
                
                // Support Section
                _buildSectionTitle('Support'),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () => _showHelpCenter(context),
                ),
                _buildMenuItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Contact Support',
                  onTap: () => _showContactSupport(context),
                ),
                _buildMenuItem(
                  icon: Icons.star_outline,
                  title: 'Rate the App',
                  onTap: () => _rateApp(context),
                ),
                
                const SizedBox(height: 20),
                
                // Settings Section
                _buildSectionTitle('Settings'),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => _showNotificationSettings(context),
                ),
                _buildMenuItem(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () => _showLanguageSettings(context),
                ),
                _buildMenuItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  onTap: () => _showPrivacySettings(context),
                ),
                
                const SizedBox(height: 20),
                
                // Logout Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(text: profile.email);
    final phoneController = TextEditingController(text: profile.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ProfileProvider>(context, listen: false).updateProfile(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddressesScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedAddressesScreen()),
    );
  }

  void _showPaymentMethodsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedPaymentMethodsScreen()),
    );
  }

  void _showOrderHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order History feature coming soon!')),
    );
  }

  void _showTrackOrders(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Track Orders feature coming soon!')),
    );
  }

  void _showReturnsRefunds(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Returns & Refunds feature coming soon!')),
    );
  }

  void _showHelpCenter(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help Center feature coming soon!')),
    );
  }

  void _showContactSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact Support feature coming soon!')),
    );
  }

  void _rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rate App feature coming soon!')),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification Settings feature coming soon!')),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language Settings feature coming soon!')),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Settings feature coming soon!')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Saved Addresses', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final addresses = profileProvider.userProfile.savedAddresses;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('${address.street}\n${address.city}, ${address.state} ${address.zipCode}\n${address.country}'),
                            const SizedBox(height: 8),
                            Text('Phone: ${address.phone}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddAddressDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    final nameController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipController = TextEditingController();
    final countryController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Address'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streetController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: zipController,
                decoration: const InputDecoration(
                  labelText: 'ZIP Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final address = ShippingAddress(
                fullName: nameController.text,
                street: streetController.text,
                city: cityController.text,
                state: stateController.text,
                zipCode: zipController.text,
                country: countryController.text,
                phone: phoneController.text,
              );
              Provider.of<ProfileProvider>(context, listen: false).addAddress(address);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Address added successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class SavedPaymentMethodsScreen extends StatelessWidget {
  const SavedPaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final paymentMethods = profileProvider.userProfile.savedPaymentMethods;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = paymentMethods[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: method.type == 'paypal' 
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                method.type == 'card' 
                                    ? Icons.credit_card 
                                    : Icons.payment,
                                size: 24,
                                color: method.type == 'paypal' 
                                    ? Colors.blue 
                                    : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (method.type == 'card' && method.expiryDate != null)
                                    Text(
                                      'Expires: ${method.expiryDate}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    )
                                  else if (method.type == 'paypal')
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Verified',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'PayPal Account',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeletePaymentMethodDialog(context, method, index);
                                } else if (value == 'verify' && method.type == 'paypal') {
                                  _showPayPalReVerificationDialog(context, method);
                                }
                              },
                              itemBuilder: (context) => [
                                if (method.type == 'paypal')
                                  const PopupMenuItem(
                                    value: 'verify',
                                    child: Row(
                                      children: [
                                        Icon(Icons.verified, size: 20),
                                        SizedBox(width: 12),
                                        Text('Re-verify Account'),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 20),
                                      SizedBox(width: 12),
                                      Text('Remove', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              child: const Icon(Icons.more_vert, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddPaymentMethodDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment Method'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddPaymentMethodDialog(),
    );
  }

  void _showDeletePaymentMethodDialog(BuildContext context, PaymentMethod method, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: Text('Are you sure you want to remove ${method.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ProfileProvider>(context, listen: false).removePaymentMethod(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment method removed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showPayPalReVerificationDialog(BuildContext context, PaymentMethod method) {
    final email = method.displayName.replaceAll('PayPal - ', '');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PayPalVerificationDialog(
        email: email,
        onVerified: (updatedMethod) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PayPal account $email re-verified successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        onError: (error) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PayPal re-verification failed: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      ),
    );
  }
}

// Add Payment Method Dialog
class AddPaymentMethodDialog extends StatefulWidget {
  const AddPaymentMethodDialog({super.key});

  @override
  State<AddPaymentMethodDialog> createState() => _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<AddPaymentMethodDialog> {
  String _selectedPaymentType = 'card';
  final _formKey = GlobalKey<FormState>();
  
  // Card form controllers
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  // PayPal form controllers
  final _paypalEmailController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _paypalEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Payment Type Selection
            _buildPaymentTypeSelection(),
            const SizedBox(height: 20),
            
            // Form based on selected type
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: _selectedPaymentType == 'card' 
                      ? _buildCardForm() 
                      : _buildPayPalForm(),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savePaymentMethod,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentTypeCard(
                'card',
                'Credit/Debit Card',
                Icons.credit_card,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentTypeCard(
                'paypal',
                'PayPal',
                Icons.payment,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentTypeCard(String type, String title, IconData icon) {
    final isSelected = _selectedPaymentType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: Icon(Icons.credit_card),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty == true) return 'Please enter card number';
            if (value!.replaceAll(' ', '').length < 13) return 'Invalid card number';
            return null;
          },
          onChanged: (value) {
            // Format card number with spaces
            String formatted = value.replaceAll(' ', '');
            if (formatted.isNotEmpty) {
              formatted = formatted.replaceAllMapped(
                RegExp(r'.{4}'),
                (match) => '${match.group(0)} ',
              ).trim();
            }
            if (formatted != value) {
              _cardNumberController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardHolderController,
          decoration: const InputDecoration(
            labelText: 'Cardholder Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty == true ? 'Please enter cardholder name' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(
                  labelText: 'MM/YY',
                  hintText: '12/25',
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Please enter expiry date';
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) return 'Invalid format';
                  return null;
                },
                onChanged: (value) {
                  if (value.length == 2 && !value.contains('/')) {
                    _expiryController.value = TextEditingValue(
                      text: '$value/',
                      selection: const TextSelection.collapsed(offset: 3),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Please enter CVV';
                  if (value!.length < 3) return 'Invalid CVV';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayPalForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'We\'ll verify your PayPal account to ensure secure payments.',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _paypalEmailController,
          decoration: const InputDecoration(
            labelText: 'PayPal Email Address',
            hintText: 'your.email@example.com',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
            helperText: 'Enter the email address associated with your PayPal account',
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty == true) return 'Please enter PayPal email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'How PayPal Verification Works',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• We don\'t store your PayPal login credentials\n'
                '• Verification happens through PayPal\'s secure API\n'
                '• You can remove this account anytime\n'
                '• All payments go through PayPal\'s secure checkout',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.amber[800],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _savePaymentMethod() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPaymentType == 'card') {
      _saveCardPaymentMethod();
    } else {
      _savePayPalPaymentMethod();
    }
  }

  void _saveCardPaymentMethod() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    
    final paymentMethod = PaymentMethod(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      type: 'card',
      displayName: '•••• •••• •••• $lastFour',
      lastFourDigits: lastFour,
      expiryDate: _expiryController.text,
    );

    Provider.of<ProfileProvider>(context, listen: false).addPaymentMethod(paymentMethod);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Credit card added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _savePayPalPaymentMethod() {
    // Simulate PayPal account verification
    _showPayPalVerificationDialog();
  }

  void _showPayPalVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PayPalVerificationDialog(
        email: _paypalEmailController.text,
        onVerified: (paymentMethod) {
          Provider.of<ProfileProvider>(context, listen: false).addPaymentMethod(paymentMethod);
          Navigator.pop(context); // Close verification dialog
          Navigator.pop(context); // Close add payment dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PayPal account ${_paypalEmailController.text} added successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        onError: (error) {
          Navigator.pop(context); // Close verification dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PayPal verification failed: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      ),
    );
  }
}

// PayPal Verification Dialog
class PayPalVerificationDialog extends StatefulWidget {
  final String email;
  final Function(PaymentMethod) onVerified;
  final Function(String) onError;

  const PayPalVerificationDialog({
    super.key,
    required this.email,
    required this.onVerified,
    required this.onError,
  });

  @override
  State<PayPalVerificationDialog> createState() => _PayPalVerificationDialogState();
}

class _PayPalVerificationDialogState extends State<PayPalVerificationDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _currentStep = 'Connecting to PayPal...';
  int _stepIndex = 0;

  final List<String> _verificationSteps = [
    'Connecting to PayPal...',
    'Verifying email address...',
    'Checking account status...',
    'Confirming account details...',
    'Verification complete!',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _startVerification();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startVerification() async {
    _animationController.repeat();
    
    for (int i = 0; i < _verificationSteps.length; i++) {
      if (mounted) {
        setState(() {
          _currentStep = _verificationSteps[i];
          _stepIndex = i;
        });
      }
      
      // Simulate verification time
      await Future.delayed(Duration(milliseconds: i == _verificationSteps.length - 1 ? 1000 : 1500));
      
      // Simulate occasional failures for demonstration
      if (i == 2 && DateTime.now().millisecond % 10 == 0) {
        _animationController.stop();
        widget.onError('PayPal account not found or inactive');
        return;
      }
    }
    
    _animationController.stop();
    
    // Create verified PayPal payment method
    final paymentMethod = PaymentMethod(
      id: 'paypal_${DateTime.now().millisecondsSinceEpoch}',
      type: 'paypal',
      displayName: 'PayPal - ${widget.email}',
    );
    
    widget.onVerified(paymentMethod);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PayPal Logo Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.payment,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Verifying PayPal Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              widget.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Progress Indicator
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: _stepIndex == _verificationSteps.length - 1 ? 1.0 : null,
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _stepIndex == _verificationSteps.length - 1 ? Colors.green : Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentStep,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Progress Steps
            Column(
              children: _verificationSteps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isCompleted = index < _stepIndex;
                final isCurrent = index == _stepIndex;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? Colors.green 
                              : isCurrent 
                                  ? Colors.blue 
                                  : Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            color: isCompleted || isCurrent 
                                ? Colors.black87 
                                : Colors.grey[600],
                            fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}


class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = [
    'All', 'Women', 'Men', 'Kids', 'Accessories', 'Shoes', 'Bags', 'Jewelry'
  ];

  final List<Map<String, dynamic>> _allProducts = [
    // Women's Collection
    {
      'name': 'Elegant Evening Dress',
      'price': '\$89.99',
      'originalPrice': '\$120.00',
      'image': 'https://images.unsplash.com/photo-1566479179817-c0a4b8b8d35a?auto=format&fit=crop&w=1000&q=80',
      'category': 'Women',
      'discount': '25% OFF',
      'rating': 4.8,
      'reviews': 124
    },
    {
      'name': 'Casual Summer Blouse',
      'price': '\$34.99',
      'image': 'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?auto=format&fit=crop&w=1000&q=80',
      'category': 'Women',
      'rating': 4.5,
      'reviews': 89
    },
    {
      'name': 'Floral Maxi Dress',
      'price': '\$67.99',
      'originalPrice': '\$85.00',
      'image': 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&w=1000&q=80',
      'category': 'Women',
      'discount': '20% OFF',
      'rating': 4.7,
      'reviews': 156
    },
    {
      'name': 'Professional Blazer',
      'price': '\$95.99',
      'image': 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?auto=format&fit=crop&w=1000&q=80',
      'category': 'Women',
      'rating': 4.6,
      'reviews': 78
    },
    
    // Men's Collection
    {
      'name': 'Classic Button Shirt',
      'price': '\$42.99',
      'image': 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=1000&q=80',
      'category': 'Men',
      'rating': 4.4,
      'reviews': 203
    },
    {
      'name': 'Denim Jacket',
      'price': '\$79.99',
      'originalPrice': '\$99.99',
      'image': 'https://images.unsplash.com/photo-1551537901-4d4b0a2e7af3?auto=format&fit=crop&w=1000&q=80',
      'category': 'Men',
      'discount': '20% OFF',
      'rating': 4.3,
      'reviews': 167
    },
    {
      'name': 'Slim Fit Chinos',
      'price': '\$54.99',
      'image': 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?auto=format&fit=crop&w=1000&q=80',
      'category': 'Men',
      'rating': 4.5,
      'reviews': 145
    },
    {
      'name': 'Casual Polo Shirt',
      'price': '\$29.99',
      'image': 'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?auto=format&fit=crop&w=1000&q=80',
      'category': 'Men',
      'rating': 4.2,
      'reviews': 234
    },
    
    // Kids Collection
    {
      'name': 'Rainbow T-Shirt',
      'price': '\$19.99',
      'image': 'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?auto=format&fit=crop&w=1000&q=80',
      'category': 'Kids',
      'rating': 4.6,
      'reviews': 87
    },
    {
      'name': 'Denim Overalls',
      'price': '\$36.99',
      'originalPrice': '\$45.99',
      'image': 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=1000&q=80',
      'category': 'Kids',
      'discount': '20% OFF',
      'rating': 4.7,
      'reviews': 92
    },
    {
      'name': 'Cute Sundress',
      'price': '\$24.99',
      'image': 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?auto=format&fit=crop&w=1000&q=80',
      'category': 'Kids',
      'rating': 4.5,
      'reviews': 76
    },
    
    // Shoes Collection
    {
      'name': 'Running Sneakers',
      'price': '\$89.99',
      'image': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=1000&q=80',
      'category': 'Shoes',
      'rating': 4.8,
      'reviews': 312
    },
    {
      'name': 'Leather Boots',
      'price': '\$129.99',
      'originalPrice': '\$160.00',
      'image': 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?auto=format&fit=crop&w=1000&q=80',
      'category': 'Shoes',
      'discount': '19% OFF',
      'rating': 4.6,
      'reviews': 189
    },
    {
      'name': 'Canvas Sneakers',
      'price': '\$45.99',
      'image': 'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=1000&q=80',
      'category': 'Shoes',
      'rating': 4.3,
      'reviews': 145
    },
    
    // Accessories Collection
    {
      'name': 'Designer Sunglasses',
      'price': '\$159.99',
      'originalPrice': '\$199.99',
      'image': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&w=1000&q=80',
      'category': 'Accessories',
      'discount': '20% OFF',
      'rating': 4.7,
      'reviews': 98
    },
    {
      'name': 'Leather Watch',
      'price': '\$199.99',
      'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1000&q=80',
      'category': 'Accessories',
      'rating': 4.9,
      'reviews': 156
    },
    {
      'name': 'Silk Scarf',
      'price': '\$39.99',
      'image': 'https://images.unsplash.com/photo-1590736969955-71cc94901144?auto=format&fit=crop&w=1000&q=80',
      'category': 'Accessories',
      'rating': 4.4,
      'reviews': 67
    },
    
    // Bags Collection
    {
      'name': 'Leather Handbag',
      'price': '\$149.99',
      'originalPrice': '\$189.99',
      'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=1000&q=80',
      'category': 'Bags',
      'discount': '21% OFF',
      'rating': 4.8,
      'reviews': 203
    },
    {
      'name': 'Canvas Backpack',
      'price': '\$69.99',
      'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=1000&q=80',
      'category': 'Bags',
      'rating': 4.5,
      'reviews': 134
    },
    
    // Jewelry Collection
    {
      'name': 'Gold Necklace',
      'price': '\$299.99',
      'originalPrice': '\$399.99',
      'image': 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=1000&q=80',
      'category': 'Jewelry',
      'discount': '25% OFF',
      'rating': 4.9,
      'reviews': 87
    },
    {
      'name': 'Silver Earrings',
      'price': '\$79.99',
      'image': 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=1000&q=80',
      'category': 'Jewelry',
      'rating': 4.6,
      'reviews': 112
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((product) {
      final matchesCategory = _selectedCategory == 'All' || product['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product['category'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlist, child) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black),
                  onPressed: () => _showWishlist(context),
                ),
                if (wishlist.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${wishlist.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                  onPressed: () => _showCart(context),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          _buildResultsHeader(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) => setState(() => _selectedCategory = category),
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsHeader() {
    final filteredCount = _filteredProducts.length;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$filteredCount Products Found',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showSortDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = _filteredProducts;
    
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'No products found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildExploreProductCard(products[index]),
    );
  }

  Widget _buildExploreProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                if (product['discount'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        product['discount'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(product),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlist, child) => Icon(
                          wishlist.isInWishlist(product['name']) ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: wishlist.isInWishlist(product['name']) ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product['rating'] != null)
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rating']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' (${product['reviews']})',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product['originalPrice'] != null) ...[
                            Text(
                              product['originalPrice'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            product['price'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Price: Low to High'),
              onTap: () {
                _allProducts.sort((a, b) => double.parse(a['price'].replaceAll('\$', '')).compareTo(double.parse(b['price'].replaceAll('\$', ''))));
                setState(() {});
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Price: High to Low'),
              onTap: () {
                _allProducts.sort((a, b) => double.parse(b['price'].replaceAll('\$', '')).compareTo(double.parse(a['price'].replaceAll('\$', ''))));
                setState(() {});
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Rating'),
              onTap: () {
                _allProducts.sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));
                setState(() {});
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Name A-Z'),
              onTap: () {
                _allProducts.sort((a, b) => a['name'].compareTo(b['name']));
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWishlist(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
  }

  void _showCart(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
  }

  void _toggleWishlist(Map<String, dynamic> product) {
    final wishlist = Provider.of<WishlistProvider>(context, listen: false);
    final wasInWishlist = wishlist.isInWishlist(product['name']);
    
    wishlist.toggleItem(product);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasInWishlist ? '${product['name']} removed from wishlist' : '${product['name']} added to wishlist'),
        action: SnackBarAction(label: 'View Wishlist', onPressed: () => _showWishlist(context)),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      
      // Check if product is already in cart
      final existingItem = cart.items.where((item) => item.id == product['name']).firstOrNull;
      
      cart.addItem(product);
      
      // Provide appropriate feedback based on whether item was already in cart
      if (existingItem != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.refresh, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${product['name']} quantity updated in cart'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () => _showCart(context),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${product['name']} added to cart!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () => _showCart(context),
            ),
          ),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Failed to add item to cart. Please try again.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlist, child) => wishlist.items.isNotEmpty
                ? TextButton(
                    onPressed: () => _showClearWishlistDialog(context),
                    child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          if (wishlist.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text('Your wishlist is empty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  Text('Save items you love to buy them later', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                    child: const Text('Start Shopping', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlist.items.length,
            itemBuilder: (context, index) {
              final item = wishlist.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
                        onPressed: () => _addToCartFromWishlist(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => _removeFromWishlist(context, item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addToCartFromWishlist(BuildContext context, WishlistItem item) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem({'name': item.name, 'price': item.price, 'image': item.image, 'discount': item.discount});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to cart')));
  }

  void _removeFromWishlist(BuildContext context, WishlistItem item) {
    final wishlist = Provider.of<WishlistProvider>(context, listen: false);
    wishlist.removeItem(item.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} removed from wishlist')));
  }

  void _showClearWishlistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text('Remove all items from your wishlist?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<WishlistProvider>(context, listen: false).clearWishlist();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) => cart.items.isNotEmpty
                ? TextButton(
                    onPressed: () => _showClearCartDialog(context),
                    child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text('Your cart is empty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  Text('Add some products to get started', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                    child: const Text('Continue Shopping', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(item.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () => _updateQuantity(context, item, item.quantity - 1),
                                              child: Container(padding: const EdgeInsets.all(8), child: const Icon(Icons.remove, size: 16)),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            ),
                                            InkWell(
                                              onTap: () => _updateQuantity(context, item, item.quantity + 1),
                                              child: Container(padding: const EdgeInsets.all(8), child: const Icon(Icons.add, size: 16)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      InkWell(
                                        onTap: () => _removeItem(context, item),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                                          child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildCartSummary(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cart) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal (${cart.itemCount} items)', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                Text('\$${cart.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipping', style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text(cart.totalPrice > 50 ? 'Free' : '\$5.99', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('\$${(cart.totalPrice + (cart.totalPrice > 50 ? 0 : 5.99)).toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _proceedToCheckout(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Proceed to Checkout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(BuildContext context, CartItem item, int newQuantity) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.updateQuantity(item.id, newQuantity);
  }

  void _removeItem(BuildContext context, CartItem item) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.removeItem(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed from cart'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => cart.addItem({'name': item.name, 'price': item.price, 'image': item.image}),
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart cleared successfully')));
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cartItems: cart.items),
      ),
    );
  }
}

// Checkout Screen
class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  ShippingAddress? _shippingAddress;
  PaymentMethod? _paymentMethod;

  double get _subtotal => widget.cartItems.fold(0.0, (sum, item) => sum + (item.numericPrice * item.quantity));
  double get _shipping => _subtotal > 50 ? 0.0 : 5.99;
  double get _tax => _subtotal * 0.08; // 8% tax
  double get _total => _subtotal + _shipping + _tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.black),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (details.stepIndex > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(details.stepIndex == 2 ? 'Place Order' : 'Continue'),
                ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Shipping Address'),
              content: _buildShippingStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Payment Method'),
              content: _buildPaymentStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : (_currentStep == 1 ? StepState.indexed : StepState.disabled),
            ),
            Step(
              title: const Text('Review & Place Order'),
              content: _buildReviewStep(),
              isActive: _currentStep >= 2,
              state: _currentStep == 2 ? StepState.indexed : StepState.disabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingStep() {
    return ShippingAddressForm(
      onAddressSelected: (address) {
        setState(() => _shippingAddress = address);
        if (_currentStep == 0) {
          setState(() => _currentStep = 1);
        }
      },
      initialAddress: _shippingAddress,
    );
  }

  Widget _buildPaymentStep() {
    return PaymentMethodForm(
      onPaymentSelected: (payment) {
        setState(() => _paymentMethod = payment);
        if (_currentStep == 1) {
          setState(() => _currentStep = 2);
        }
      },
      cartItems: widget.cartItems,
      initialPayment: _paymentMethod,
    );
  }

  Widget _buildReviewStep() {
    return OrderReviewWidget(
      cartItems: widget.cartItems,
      shippingAddress: _shippingAddress,
      paymentMethod: _paymentMethod,
      subtotal: _subtotal,
      shipping: _shipping,
      tax: _tax,
      total: _total,
      onPlaceOrder: _placeOrder,
    );
  }

  void _placeOrder() {
    if (_shippingAddress == null || _paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all steps')),
      );
      return;
    }

    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(widget.cartItems),
      shippingAddress: _shippingAddress!,
      paymentMethod: _paymentMethod!,
      subtotal: _subtotal,
      shipping: _shipping,
      tax: _tax,
      total: _total,
      orderDate: DateTime.now(),
    );

    // Clear cart after successful order
    Provider.of<CartProvider>(context, listen: false).clearCart();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(order: order),
      ),
    );
  }
}

// Shipping Address Form
class ShippingAddressForm extends StatefulWidget {
  final Function(ShippingAddress) onAddressSelected;
  final ShippingAddress? initialAddress;

  const ShippingAddressForm({
    super.key,
    required this.onAddressSelected,
    this.initialAddress,
  });

  @override
  State<ShippingAddressForm> createState() => _ShippingAddressFormState();
}

class _ShippingAddressFormState extends State<ShippingAddressForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _phoneController;
  String _selectedCountry = 'United States';

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.initialAddress?.fullName ?? '');
    _streetController = TextEditingController(text: widget.initialAddress?.street ?? '');
    _cityController = TextEditingController(text: widget.initialAddress?.city ?? '');
    _stateController = TextEditingController(text: widget.initialAddress?.state ?? '');
    _zipController = TextEditingController(text: widget.initialAddress?.zipCode ?? '');
    _phoneController = TextEditingController(text: widget.initialAddress?.phone ?? '');
    if (widget.initialAddress?.country != null) {
      _selectedCountry = widget.initialAddress!.country;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(_fullNameController, 'Full Name', Icons.person),
          const SizedBox(height: 16),
          _buildTextField(_streetController, 'Street Address', Icons.home),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(_cityController, 'City', Icons.location_city)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_stateController, 'State', Icons.map)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(_zipController, 'ZIP Code', Icons.local_post_office)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(),
                  ),
                  items: ['United States', 'Canada', 'United Kingdom', 'Australia']
                      .map((country) => DropdownMenuItem(value: country, child: Text(country)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCountry = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(_phoneController, 'Phone Number', Icons.phone),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Address', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value?.isEmpty == true ? 'Please enter $label' : null,
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = ShippingAddress(
        fullName: _fullNameController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        country: _selectedCountry,
        phone: _phoneController.text,
      );
      widget.onAddressSelected(address);
    }
  }
}

// Payment Method Form
class PaymentMethodForm extends StatefulWidget {
  final Function(PaymentMethod) onPaymentSelected;
  final PaymentMethod? initialPayment;
  final List<CartItem> cartItems;

  const PaymentMethodForm({
    super.key,
    required this.onPaymentSelected,
    required this.cartItems,
    this.initialPayment,
  });

  @override
  State<PaymentMethodForm> createState() => _PaymentMethodFormState();
}

class _PaymentMethodFormState extends State<PaymentMethodForm> {
  String _selectedPaymentType = 'card';
  final _cardFormKey = GlobalKey<FormState>();
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;
  late TextEditingController _cardHolderController;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();
    _cardHolderController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildPaymentOptions(),
        const SizedBox(height: 20),
        if (_selectedPaymentType == 'card') _buildCardForm(),
        if (_selectedPaymentType != 'card') _buildAlternativePayment(),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: [
        _buildPaymentOption('card', 'Credit/Debit Card', Icons.credit_card),
        _buildPaymentOption('paypal', 'PayPal', Icons.payment),
        _buildPaymentOption('apple_pay', 'Apple Pay', Icons.phone_iphone),
        _buildPaymentOption('google_pay', 'Google Pay', Icons.smartphone),
      ],
    );
  }

  Widget _buildPaymentOption(String type, String title, IconData icon) {
    return Card(
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        value: type,
        groupValue: _selectedPaymentType,
        onChanged: (value) => setState(() => _selectedPaymentType = value!),
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _cardFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _cardHolderController,
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) => value?.isEmpty == true ? 'Please enter cardholder name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => value?.isEmpty == true ? 'Please enter card number' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'MM/YY',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Please enter expiry date' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty == true ? 'Please enter CVV' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savePaymentMethod,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Payment Method', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativePayment() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(_getPaymentIcon(), size: 48, color: Colors.grey[600]),
              const SizedBox(height: 12),
              Text('Continue with ${_getPaymentDisplayName()}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('You will be redirected to complete the payment', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _savePaymentMethod,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Continue with ${_getPaymentDisplayName()}', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  IconData _getPaymentIcon() {
    switch (_selectedPaymentType) {
      case 'paypal': return Icons.payment;
      case 'apple_pay': return Icons.phone_iphone;
      case 'google_pay': return Icons.smartphone;
      default: return Icons.payment;
    }
  }

  String _getPaymentDisplayName() {
    switch (_selectedPaymentType) {
      case 'paypal': return 'PayPal';
      case 'apple_pay': return 'Apple Pay';
      case 'google_pay': return 'Google Pay';
      default: return 'Payment';
    }
  }

  void _savePaymentMethod() {
    if (_selectedPaymentType == 'card') {
      if (_cardFormKey.currentState!.validate()) {
        final payment = PaymentMethod(
          id: 'card_${DateTime.now().millisecondsSinceEpoch}',
          type: 'card',
          displayName: '•••• •••• •••• ${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}',
          lastFourDigits: _cardNumberController.text.substring(_cardNumberController.text.length - 4),
          expiryDate: _expiryController.text,
        );
        widget.onPaymentSelected(payment);
      }
    } else if (_selectedPaymentType == 'paypal') {
      _processPayPalPayment();
    } else {
      final payment = PaymentMethod(
        id: '${_selectedPaymentType}_${DateTime.now().millisecondsSinceEpoch}',
        type: _selectedPaymentType,
        displayName: _getPaymentDisplayName(),
      );
      widget.onPaymentSelected(payment);
    }
  }

  void _processPayPalPayment() {
    // Calculate total amount for PayPal
    double subtotalAmount = 0.0;
    for (var item in widget.cartItems) {
      subtotalAmount += double.parse(item.price.replaceAll('\$', '')) * item.quantity;
    }
    double shippingAmount = 5.99;
    double totalAmount = subtotalAmount + shippingAmount;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckoutView(
        sandboxMode: true, // Set to false for production
        clientId: "AW1TdvpSGbIM5iP4HJNI5TyTmwpY9Gv9dCg_kzE1eOm-oYlpIi6XbhUnWdbcb6TTbsBGRTDl6mLEIvzd", // Demo Client ID
        secretKey: "EK3cWUVGpZdZ7d9PYCxRVJCHNkAZ_7vAU5HKdZF_wcl6-K-0-Bj_3W5N9H9E6l9R5N9H9E6l9R5N9H9E", // Demo Secret Key
        transactions: [
          {
            "amount": {
              "total": totalAmount.toStringAsFixed(2),
              "currency": "USD",
              "details": {
                "subtotal": subtotalAmount.toStringAsFixed(2),
                "shipping": shippingAmount.toStringAsFixed(2),
                "shipping_discount": "0.00"
              }
            },
            "description": "Fashion Store Purchase - ${widget.cartItems.length} items",
            "payment_options": {
              "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
            },
            "item_list": {
              "items": widget.cartItems.map((item) => {
                "name": item.name.length > 127 ? item.name.substring(0, 127) : item.name,
                "quantity": item.quantity.toString(),
                "price": item.price.replaceAll('\$', ''),
                "currency": "USD"
              }).toList(),
              "shipping_address": {
                "recipient_name": "Fashion Store Customer",
                "line1": "123 Fashion Street",
                "line2": "",
                "city": "Fashion City", 
                "country_code": "US",
                "postal_code": "12345",
                "phone": "+1234567890",
                "state": "CA"
              },
            }
          }
        ],
        note: "Thank you for shopping with Fashion Store!",
        onSuccess: (Map params) async {
          debugPrint("PayPal Payment Success: $params");
          
          // Create PayPal payment method with transaction ID
          final payment = PaymentMethod(
            id: 'paypal_${params['paymentId'] ?? DateTime.now().millisecondsSinceEpoch}',
            type: 'paypal',
            displayName: 'PayPal Payment - ${params['paymentId'] ?? 'Success'}',
          );
          
          // Navigate back and pass the payment method
          Navigator.pop(context);
          widget.onPaymentSelected(payment);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PayPal payment completed successfully!\nTransaction ID: ${params['paymentId'] ?? 'N/A'}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        },
        onError: (error) {
          debugPrint("PayPal Payment Error: $error");
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PayPal payment failed: ${error.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        },
        onCancel: (params) {
          debugPrint('PayPal Payment Cancelled: $params');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PayPal payment was cancelled'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        },
      ),
    ));
  }
}

// Order Review Widget
class OrderReviewWidget extends StatelessWidget {
  final List<CartItem> cartItems;
  final ShippingAddress? shippingAddress;
  final PaymentMethod? paymentMethod;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final VoidCallback onPlaceOrder;

  const OrderReviewWidget({
    super.key,
    required this.cartItems,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOrderItems(),
        const SizedBox(height: 20),
        _buildShippingInfo(),
        const SizedBox(height: 20),
        _buildPaymentInfo(),
        const SizedBox(height: 20),
        _buildOrderSummary(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPlaceOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Place Order - \$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...cartItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(item.image, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Qty: ${item.quantity}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Text(item.price, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (shippingAddress != null) ...[
              Text(shippingAddress!.fullName, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(shippingAddress!.street),
              Text('${shippingAddress!.city}, ${shippingAddress!.state} ${shippingAddress!.zipCode}'),
              Text(shippingAddress!.country),
              Text(shippingAddress!.phone),
            ] else
              const Text('No shipping address selected', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (paymentMethod != null) ...[
              Row(
                children: [
                  Icon(_getPaymentIcon(paymentMethod!.type)),
                  const SizedBox(width: 12),
                  Text(paymentMethod!.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ] else
              const Text('No payment method selected', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            _buildSummaryRow('Shipping', shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}'),
            _buildSummaryRow('Tax', '\$${tax.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow('Total', '\$${total.toStringAsFixed(2)}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'card': return Icons.credit_card;
      case 'paypal': return Icons.payment;
      case 'apple_pay': return Icons.phone_iphone;
      case 'google_pay': return Icons.smartphone;
      default: return Icons.payment;
    }
  }
}

// Order Confirmation Screen
class OrderConfirmationScreen extends StatelessWidget {
  final Order order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for your purchase. Your order has been confirmed and will be shipped soon.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildOrderDetails(),
            const SizedBox(height: 24),
            _buildOrderItems(),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    ),
                    child: const Text('Continue Shopping'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _trackOrder(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text('Track Order', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDetailRow('Order ID', order.id),
            _buildDetailRow('Order Date', '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}'),
            _buildDetailRow('Status', order.status.toUpperCase()),
            _buildDetailRow('Total Amount', '\$${order.total.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            const Text('Shipping Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(order.shippingAddress.fullName),
            Text(order.shippingAddress.street),
            Text('${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.zipCode}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items Ordered', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(item.image, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Quantity: ${item.quantity}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Text(item.price, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _trackOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track Your Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order ID: ${order.id}'),
            const SizedBox(height: 16),
            const Text('Your order is being processed and will be shipped within 2-3 business days.'),
            const SizedBox(height: 16),
            const Text('You will receive a tracking number via email once your order ships.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
