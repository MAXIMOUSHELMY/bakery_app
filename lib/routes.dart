import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/products_page.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/homepage.dart';
import 'pages/profile.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String Products = '/products';
  

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      
      case home:
        return MaterialPageRoute(
          builder: (_) =>  HomePage(title: "Home Page"),
        );
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case Products:
        return MaterialPageRoute(builder: (_) => const ProductsPage());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}