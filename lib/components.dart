import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



// abbpar 
PreferredSizeWidget buildCustomAppBar(
  String title, {
  List<Widget>? actions,
  Color textColor = Colors.white, // لون افتراضي للنص
}) {
  return AppBar(
    centerTitle: true,
    backgroundColor: Color(0xFF2B1B17),
    elevation: 0,
    title: Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: textColor, // نستخدم المتغير الصحيح
      ),
    ),
    actions: actions,
    iconTheme: const IconThemeData(color: Colors.black),
  );
}
const Color brownDark = Color(0xFF2B1B17);

// شكل كارت المنتجات في الهوم اسكرين
  Widget buildProductCard(
      String title, String imagePath, String price, String rating) {
    return Container(
      margin: EdgeInsets.only(left: 12.sp),
      width: 160.w,
      height: 190.h,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.asset(
                  imagePath,
                  height: 85.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8.h),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16.sp),
                  Text(rating),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// كروت التواصل 
  Widget buildCategory(IconData icon, String title) {
    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.grey.shade200,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 25.sp, color: Colors.blue),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

// صفحه افتراضيه عمال ما خلص الباقي يا رب الخلاص 
class PagePlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;

  const PagePlaceholder({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100.sp, color: Colors.grey),
          SizedBox(height: 20.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}



