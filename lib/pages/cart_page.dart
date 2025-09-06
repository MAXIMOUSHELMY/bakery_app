import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_3/components.dart';
import '../cart_manager.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeCart();
    
    // الاستماع لتغييرات السلة
    CartManager.cartNotifier.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartManager.cartNotifier.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeCart() async {
    await CartManager.loadCartFromFirebase();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(String productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeFromCart(productId);
      return;
    }

    bool success = await CartManager.updateQuantity(productId, newQuantity);
    if (!success) {
      _showErrorMessage("Failed to update quantity");
    }
  }

  Future<void> _removeFromCart(String productId) async {
    // العثور على اسم المنتج للرسالة
    var item = CartManager.cartItems.firstWhere(
      (item) => item['id'] == productId,
      orElse: () => {'productName': 'Product'},
    );
    
    bool success = await CartManager.removeFromCart(productId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item['productName']} removed from cart'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _showErrorMessage("Failed to remove item");
    }
  }

  Future<void> _clearCart() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: brownDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: const Text(
            "Clear Cart",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to remove all items from cart?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                bool success = await CartManager.clearCart();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cart cleared successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  _showErrorMessage("Failed to clear cart");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text(
                "Clear",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _proceedToCheckout() async {
    if (CartManager.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: brownDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: const Text(
            "Confirm Order",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Total Amount: \$${CartManager.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Proceed with this order?",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // إنشاء الطلب
                bool success = await CartManager.createOrder();
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order placed successfully! Check Orders page.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  _showErrorMessage("Failed to place order");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7A86E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(color: brownDark, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: brownDark,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD7A86E)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: brownDark,
        title: Text(
          'Cart (${CartManager.itemCount})',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: CartManager.itemCount > 0
            ? [
                IconButton(
                  onPressed: _clearCart,
                  icon: const Icon(Icons.delete_sweep, color: Colors.white),
                  tooltip: 'Clear Cart',
                ),
              ]
            : null,
      ),
      body: CartManager.isEmpty ? _buildEmptyCart() : _buildCartContent(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 24.h),
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Add some products from the menu',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () {
              // العودة لصفحة المنتجات
              // يمكنك استخدام Navigator أو تغيير الـ tab في HomePage
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: brownDark,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 32.w,
                vertical: 16.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: const Icon(Icons.shopping_bag),
            label: Text(
              'Browse Products',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        // عرض عدد المنتجات والمجموع السريع
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: brownDark,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25.r),
              bottomRight: Radius.circular(25.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CartManager.itemCount} Items in cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Total: \$${CartManager.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: const Color(0xFFD7A86E),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // قائمة المنتجات
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.sp),
            itemCount: CartManager.cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(CartManager.cartItems[index]);
            },
          ),
        ),

        // قسم الدفع السفلي
        _buildBottomSection(),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة المنتج
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              item['productImage'] ?? '',
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80.w,
                  height: 80.h,
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
          SizedBox(width: 16.w),
          
          // تفاصيل المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['productName'] ?? 'اسم المنتج',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: brownDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '\$${item['price'] ?? '0'}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                
                // أزرار الكمية
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _updateQuantity(
                        item['id'],
                        (item['quantity'] ?? 1) - 1,
                      ),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Icon(
                          Icons.remove,
                          color: Colors.red,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${item['quantity'] ?? 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: () => _updateQuantity(
                        item['id'],
                        (item['quantity'] ?? 1) + 1,
                      ),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.green,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // زر الحذف
          GestureDetector(
            onTap: () => _removeFromCart(item['id']),
            child: Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // تفاصيل الدفع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '\$${CartManager.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery:',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Free',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Divider(
            height: 20.h,
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: brownDark,
                ),
              ),
              Text(
                '\$${CartManager.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // زر الدفع
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: brownDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 2,
              ),
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}