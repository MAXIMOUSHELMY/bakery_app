import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_3/components.dart';
import '../cart_manager.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // قائمة المنتجات التجريبية
  final List<Map<String, dynamic>> _allProducts = [
    {
      'id': '1',
      'name': 'French Bread',
      'price': 12.0,
      'image': 'assets/images/item4.png',
      'rating': 4.8,
      'category': 'bread'
    },
    {
      'id': '2',
      'name': 'White Bread',
      'price': 8.0,
      'image': 'assets/images/item5.jpg',
      'rating': 4.5,
      'category': 'bread'
    },
    {
      'id': '3',
      'name': 'Rolls',
      'price': 15.0,
      'image': 'assets/images/item6.png',
      'rating': 4.2,
      'category': 'bread'
    },
    {
      'id': '4',
      'name': 'Swiss Roll',
      'price': 16.0,
      'image': 'assets/images/item7.png',
      'rating': 4.9,
      'category': 'pastry'
    },
    {
      'id': '5',
      'name': 'Croissant',
      'price': 5.0,
      'image': 'assets/images/item4.png',
      'rating': 4.7,
      'category': 'pastry'
    },
    {
      'id': '6',
      'name': 'Bagel',
      'price': 3.0,
      'image': 'assets/images/item5.jpg',
      'rating': 4.3,
      'category': 'bread'
    },
  ];

  // قائمة المفضلات
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    await CartManager.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  // دالة لتبديل حالة المفضلة
  void _toggleFavorite(String productId) {
    setState(() {
      if (_favorites.contains(productId)) {
        _favorites.remove(productId);
      } else {
        _favorites.add(productId);
      }
    });
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return _allProducts;
    }
    return _allProducts.where((product) {
      return product['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  // دالة إضافة المنتج للسلة
  Future<void> _addToCart(Map<String, dynamic> product) async {
    // إظهار loading مؤقت
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD7A86E)),
      ),
    );

    bool success = await CartManager.addToCart(product);

    // إخفاء loading
    Navigator.pop(context);

    if (success) {
      // إظهار SnackBar للتأكيد
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${product['name']} added to cart!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  // الانتقال لصفحة العربة (إذا كان في HomePage)
                  // يمكنك إضافة navigation هنا
                },
                child: const Text(
                  'VIEW CART',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(16.sp),
        ),
      );
    } else {
      // إظهار رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add ${product['name']} to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brownDark,
        title: Text(
          "Products",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // عداد السلة في الـ AppBar
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: CartManager.cartNotifier,
            builder: (context, cartItems, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // يمكنك إضافة navigation للعربة هنا
                    },
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  if (CartManager.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
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
                          '${CartManager.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: GradientBackground(   
        child: Column(
          children: [
 
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: brownDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25.r),
                  bottomRight: Radius.circular(25.r),
                ),
              ),
              child: Column(
                children: [
                 
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search for products...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: brownDark,
                          size: 24.sp,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: _clearSearch,
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade600,
                                  size: 20.sp,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: brownDark,
                      ),
                    ),
                  ),

                  
                  if (_searchQuery.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Text(
                          'Found ${_filteredProducts.length} products',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                        const Spacer(),
                        if (_filteredProducts.isEmpty)
                          Icon(
                            Icons.search_off,
                            color: Colors.white70,
                            size: 16.sp,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

   
            Expanded(
              child: _filteredProducts.isEmpty && _searchQuery.isNotEmpty
                  ? _buildNoResultsWidget()
                  : _buildProductsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: brownDark,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 12.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(Icons.clear_all, size: 18.sp),
            label: Text(
              'Clear Search',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.60,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 14.h,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isFavorite = _favorites.contains(product['id'].toString());
    final isInCart = CartManager.isInCart(product['id'].toString());
    final quantityInCart =
        CartManager.getProductQuantity(product['id'].toString());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  child: Image.asset(
                    product['image'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 30.sp,
                        ),
                      );
                    },
                  ),
                ),
           
                Positioned(
                  top: 6.h,
                  left: 6.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: brownDark.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      product['category'].toString().toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(product['id']),
                    child: Container(
                      padding: EdgeInsets.all(6.sp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey.shade400,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
               
                if (isInCart)
                  Positioned(
                    bottom: 6.h,
                    right: 6.w,
                    child: Container(
                      padding: EdgeInsets.all(4.sp),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '$quantityInCart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
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
              padding: EdgeInsets.all(10.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: brownDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product['price'].toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            product['rating'].toString(),
                            style: TextStyle(fontSize: 11.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                 
                  SizedBox(
                    width: double.infinity,
                    height: 32.h,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInCart
                            ? Colors.green
                            : const Color(0xFFD7A86E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        elevation: 1,
                      ),
                      child: Text(
                        isInCart ? 'Add More' : 'Add to Cart',
                        style: TextStyle(
                          color: isInCart ? Colors.white : brownDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
