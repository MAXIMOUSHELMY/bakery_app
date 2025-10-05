# 🍞 BAK BAK Bakery App

A complete e-commerce mobile application for a bakery business, built with Flutter and Firebase as part of the ITI Flutter Training Program graduation project.

## 📱 About

BAK BAK Bakery is a full-featured mobile application that allows users to browse bakery products, manage their shopping cart, place orders, and track order status in real-time. The app features a clean, responsive UI and follows Flutter best practices.

## ✨ Features

### User Features
- 🔐 **Secure Authentication** - Email/Password login and registration with Firebase Auth
- 🛍️ **Product Browsing** - Browse bakery products with categories and search functionality
- 🛒 **Shopping Cart** - Add, remove, and update product quantities
- 📦 **Order Management** - Place orders and track order status
- 👤 **User Profile** - Edit profile information and upload profile pictures
- ⭐ **Favorites** - Mark products as favorites for quick access
- 🔍 **Search & Filter** - Find products quickly with search and category filters

### Technical Features
- 📱 **Responsive Design** - Works seamlessly on different screen sizes using flutter_screenutil
- 🔄 **Real-time Sync** - Cart and orders sync across devices via Firebase
- 🏗️ **Clean Architecture** - Organized code structure with separation of concerns
- 🎯 **State Management** - Cubit/Bloc pattern for efficient state handling
- 🎨 **Custom UI Components** - Reusable widgets and consistent design system

## 🛠️ Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Backend:** Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **State Management:** flutter_bloc / Cubit
- **UI:** flutter_screenutil, carousel_slider
- **Image Picking:** image_picker

## 📂 Project Structure

```
lib/
├── cubit/              # State management (Cubit)
│   ├── auth_cubit.dart
│   └── auth_state.dart
├── pages/              # App screens
│   ├── welcome_page.dart
│   ├── login_page.dart
│   ├── signup_page.dart
│   ├── homepage.dart
│   ├── products_page.dart
│   ├── cart_page.dart
│   ├── orders_page.dart
│   └── profile.dart
├── components.dart     # Reusable UI components
├── cart_manager.dart   # Cart logic and Firebase sync
├── routes.dart         # App navigation
├── firebase_options.dart
└── main.dart          # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- Firebase account
- Android Studio / VS Code

### Installation

1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/bak-bak-bakery.git
cd bak-bak-bakery
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android/iOS apps to your Firebase project
   - Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Authentication (Email/Password) in Firebase Console
   - Create Firestore database
   - Set up Firebase Storage

4. Run the app
```bash
flutter run
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  flutter_screenutil: ^5.9.0
  carousel_slider: ^4.2.1
  image_picker: ^1.0.7
```

## 🎨 App Screenshots

[Add your app screenshots here]

## 🔥 Firebase Structure

### Firestore Collections

**users**
```json
{
  "uid": "string",
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "phone": "string",
  "profileImage": "string (url)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**orders**
```json
{
  "orderId": "string",
  "userId": "string",
  "items": [
    {
      "id": "string",
      "productName": "string",
      "productImage": "string",
      "price": "number",
      "quantity": "number"
    }
  ],
  "totalAmount": "number",
  "status": "string",
  "orderDate": "timestamp",
  "estimatedDelivery": "timestamp"
}
```

**users/{uid}/cart**
```json
{
  "items": [
    {
      "id": "string",
      "productName": "string",
      "productImage": "string",
      "price": "number",
      "quantity": "number"
    }
  ],
  "lastUpdated": "timestamp"
}
```

## 🎓 Learning Outcomes

This project helped me develop skills in:
- Flutter framework and Dart programming
- Firebase integration (Auth, Firestore, Storage)
- State management with Cubit/Bloc
- Responsive UI design
- Clean architecture principles
- Git version control
- Mobile app development best practices

## 🙏 Acknowledgments

Special thanks to **Ibrahim Elsaber**, my instructor at ITI, for the excellent guidance and support throughout this project.

## 📝 License

This project is part of the ITI Flutter Training Program graduation project.

## 📧 Contact

- LinkedIn: [YOUR_LINKEDIN_URL]
- Email: YOUR_EMAIL@example.com
- GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)

---

Made with ❤️ as part of ITI Flutter Training Program
