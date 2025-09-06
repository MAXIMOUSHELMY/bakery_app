import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // قائمة السلة المحلية
  static List<Map<String, dynamic>> _cartItems = [];
  
  // للتحديث التلقائي للواجهات
  static final ValueNotifier<List<Map<String, dynamic>>> cartNotifier = 
      ValueNotifier<List<Map<String, dynamic>>>([]);

  // Getters
  static List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);
  
  static int get itemCount => _cartItems.length;
  
  static double get totalAmount {
    double total = 0.0;
    for (var item in _cartItems) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 0);
    }
    return total;
  }

  static bool get isEmpty => _cartItems.isEmpty;

  // تحميل السلة من Firebase
  static Future<void> loadCartFromFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _cartItems.clear();
        cartNotifier.value = List.from(_cartItems);
        return;
      }

      DocumentSnapshot cartDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc('items')
          .get();

      if (cartDoc.exists && cartDoc.data() != null) {
        Map<String, dynamic> data = cartDoc.data() as Map<String, dynamic>;
        if (data['items'] != null) {
          _cartItems = List<Map<String, dynamic>>.from(data['items']);
        } else {
          _cartItems = [];
        }
      } else {
        _cartItems = [];
      }

      cartNotifier.value = List.from(_cartItems);
      print('Cart loaded from Firebase: ${_cartItems.length} items');
    } catch (e) {
      print('Error loading cart from Firebase: $e');
      _cartItems = [];
      cartNotifier.value = List.from(_cartItems);
    }
  }

  // حفظ السلة في Firebase
  static Future<void> _saveCartToFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc('items')
          .set({
        'items': _cartItems,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('Cart saved to Firebase: ${_cartItems.length} items');
    } catch (e) {
      print('Error saving cart to Firebase: $e');
    }
  }

  // إضافة منتج للسلة
  static Future<bool> addToCart(Map<String, dynamic> product) async {
    try {
      int existingIndex = _cartItems.indexWhere(
        (item) => item['id'] == product['id']
      );
      
      if (existingIndex != -1) {
        // زيادة الكمية إذا كان المنتج موجود
        _cartItems[existingIndex]['quantity'] += 1;
      } else {
        // إضافة منتج جديد
        _cartItems.add({
          'id': product['id'],
          'productName': product['name'],
          'productImage': product['image'],
          'price': double.tryParse(product['price'].toString()) ?? 0.0,
          'quantity': 1,
        });
      }

      // حفظ في Firebase
      await _saveCartToFirebase();
      
      // تحديث الواجهات
      cartNotifier.value = List.from(_cartItems);
      
      print('Added to cart: ${product['name']}');
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // إزالة منتج من السلة
  static Future<bool> removeFromCart(String productId) async {
    try {
      _cartItems.removeWhere((item) => item['id'] == productId);
      
      // حفظ في Firebase
      await _saveCartToFirebase();
      
      // تحديث الواجهات
      cartNotifier.value = List.from(_cartItems);
      
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // تحديث كمية المنتج
  static Future<bool> updateQuantity(String productId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        return await removeFromCart(productId);
      }

      int index = _cartItems.indexWhere((item) => item['id'] == productId);
      if (index != -1) {
        _cartItems[index]['quantity'] = newQuantity;
        
        // حفظ في Firebase
        await _saveCartToFirebase();
        
        // تحديث الواجهات
        cartNotifier.value = List.from(_cartItems);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }

  // مسح السلة بالكامل
  static Future<bool> clearCart() async {
    try {
      _cartItems.clear();
      
      // حفظ في Firebase
      await _saveCartToFirebase();
      
      // تحديث الواجهات
      cartNotifier.value = List.from(_cartItems);
      
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // التحقق من وجود منتج في السلة
  static bool isInCart(String productId) {
    return _cartItems.any((item) => item['id'] == productId);
  }

  // الحصول على كمية منتج معين
  static int getProductQuantity(String productId) {
    var item = _cartItems.firstWhere(
      (item) => item['id'] == productId,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'] ?? 0;
  }

  // إنشاء طلب جديد (للربط مع صفحة الطلبات)
  static Future<bool> createOrder() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || _cartItems.isEmpty) return false;

      String orderId = DateTime.now().millisecondsSinceEpoch.toString();
      
      Map<String, dynamic> orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'items': List.from(_cartItems),
        'totalAmount': totalAmount,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        'estimatedDelivery': DateTime.now().add(const Duration(minutes: 30)),
      };

      // حفظ الطلب في Firebase
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderData);

      // مسح السلة بعد إنشاء الطلب
      await clearCart();

      print('Order created successfully: $orderId');
      return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  // الاستماع لتغييرات السلة (للواجهات التي تحتاج تحديث مباشر)
  static Stream<List<Map<String, dynamic>>> get cartStream {
    return Stream<List<Map<String, dynamic>>>.fromFuture(
      Future.value(cartNotifier.value)
    );
  }

  // تهيئة السلة عند بدء التطبيق
  static Future<void> initialize() async {
    await loadCartFromFirebase();
  }
}