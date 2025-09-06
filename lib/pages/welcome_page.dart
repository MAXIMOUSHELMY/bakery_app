// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const brownLight = Color(0xFFD7A86E);
    const brownDark = Color(0xFF2B1B17);
    
    return Scaffold(
      backgroundColor: brownDark,
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: 17.sp, horizontal: 30.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:  EdgeInsets.only(left: 22.sp),
                width: 300.w,
                height: 100.h,
                child: Image.asset(
                  'assets/images/upperlogo.png',
                  width: 200.w,
                  height: 200.h,
                  fit: BoxFit.contain,
                ),
              ),
               SizedBox(height: 15.h),
               Text(
                "WELCOME",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 45.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
               Text(
                "to BAK BAK Bakery",
                style: TextStyle(color: Colors.white, fontSize: 22.sp),
              ),
               SizedBox(height: 12.h),
              Container(
                width: 365.w,
                height: 365.h,
                child: Image.asset(
                  'assets/images/bread-removebg-preview.png',
                  width: 400.w,
                  height: 400.h,
                  fit: BoxFit.contain,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Container(
                  width: 250.w,
                  height: 60.h,
                  padding:  EdgeInsets.symmetric(horizontal: 12.sp),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 141, 99, 48), 
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        "Get Start",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: const BoxDecoration(
                          color: brownLight, 
                          shape: BoxShape.circle,
                        ),
                        child:  Icon(
                          Icons.arrow_forward,
                          color: brownDark, 
                          size: 25.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 80.h,)
            ],
          ),
        ),
      ),
    );
  }
}