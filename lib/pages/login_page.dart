import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B1B17),
        title:  Text(
          "Login Page",
          style: TextStyle(color: Colors.white, fontSize: 25.sp),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              '/home', 
              (route) => false,
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Container(
            color: const Color(0xFF2B1B17),
            child: Padding(
              padding:  EdgeInsets.all(22.sp),
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png"),
                  TextField(
                    controller: emailcontroller,
                    style:  TextStyle(color: Colors.white, fontSize: 17.sp),
                    decoration: InputDecoration(
                      label: const Text(
                        "Email",
                        style: TextStyle(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                    ),
                  ),
                   SizedBox(height: 25.h),
                  TextField(
                    controller: passwordcontroller,
                    style:  TextStyle(color: Colors.white, fontSize: 17.sp),
                    obscureText: true,
                    decoration: InputDecoration(
                      label: const Text(
                        "Password",
                        style: TextStyle(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      prefixIcon: const Icon(Icons.key, color: Colors.white),
                    ),
                  ),
                   SizedBox(height: 25.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                        "Don`t have an account ?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                       SizedBox(width: 13.w),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child:  Text(
                          "Sign up",
                          style: TextStyle(
                            color: Color.fromARGB(255, 141, 99, 48),
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                   SizedBox(height: 25.h),
                  InkWell(
                    onTap: state is AuthLoading
                        ? null
                        : () {
                            context.read<AuthCubit>().login(
                              emailcontroller.text.trim(),
                              passwordcontroller.text.trim(),
                            );
                          },
                    child: Container(
                      width: 350.w,
                      height: 70.h,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 141, 99, 48),
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            :  Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}