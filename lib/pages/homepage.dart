import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_3/pages/cart_page.dart';
import 'package:flutter_application_3/pages/orders_page.dart';
import 'package:flutter_application_3/pages/products_page.dart';
import 'package:flutter_application_3/pages/profile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_3/components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<String> items = [
    "assets/images/item1.jpg",
    "assets/images/item2.jpg",
    "assets/images/item3.jpg",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContentForIndex(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFD7A86E),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Products",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // دالة لعرض المحتوى حسب الـ tab المختار
  Widget _buildContentForIndex(int index) {
    switch (index) {
      case 0:
        return _buildHome();
      case 1:
        return const ProductsPage();
      case 2:
        return const CartPage();
      case 3:
        return const OrdersPage();
      case 4:
        return const ProfilePage();
      default:
        return _buildHome();
    }
  }

  Widget _buildHome() {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(10.sp),
          children: [
            const DrawerHeader(child: Text("data")),
            ListTile(
              title: const Text("profile"),
              onTap: () {},
            )
          ],
        ),
      ),
      appBar: buildCustomAppBar("Home page", textColor: Colors.white),
      body: GradientBackground( 
        child: Padding(
          padding: EdgeInsets.only(top: 10.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSlider(
                items: items.map((path) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: Image.asset(
                      path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 150.h,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.95.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Padding(
                padding: EdgeInsets.only(left: 15.sp),
                child: Text(
                  "FEATURED PRODUCTS",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildProductCard(
                      "franch bread",
                      "assets/images/item4.png",
                      "\$12",
                      "4.8",
                    ),
                    buildProductCard(
                      "white bread",
                      "assets/images/item5.jpg",
                      "\$8",
                      "4.5",
                    ),
                    buildProductCard(
                      "Rols",
                      "assets/images/item6.png",
                      "\$15",
                      "4.2",
                    ),
                    buildProductCard(
                      "swiss roll",
                      "assets/images/item7.png",
                      "\$16",
                      "4.9",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.only(left: 16.sp),
                child: Text(
                  "categories",
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.3.sp,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.only(left: 12.sp),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    buildCategory(Icons.bakery_dining_rounded, "BREADS"),
                    buildCategory(Icons.shopping_bag_rounded, "SHOPPING"),
                    buildCategory(Icons.backpack_rounded, "ORDERS"),
                    buildCategory(Icons.backup_table_rounded, "BACKUP"),
                    buildCategory(Icons.phone_android_outlined, "CONTACT US"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
