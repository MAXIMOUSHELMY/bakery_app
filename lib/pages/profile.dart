// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application_3/components.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  
  User? currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  File? _selectedImage;

  // ألوان التطبيق
  static const Color brownDark = Color(0xFF2B1B17);
  static const Color brownLight = Color(0xFFD7A86E);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    currentUser = _auth.currentUser;
    print("Current user: ${currentUser?.uid}");

    if (currentUser != null) {
      try {
        // محاولة قراءة البيانات من Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        
        print("Document exists: ${userDoc.exists}");
        
        if (userDoc.exists && userDoc.data() != null) {
          userData = userDoc.data() as Map<String, dynamic>;
          print("User data loaded: $userData");
        } else {
          print("No user document found, creating default data");
          // إذا لم توجد البيانات، ننشئ مستند جديد بالبيانات الافتراضية
          userData = {
            'uid': currentUser!.uid,
            'firstName': '',
            'lastName': '',
            'email': currentUser!.email ?? '',
            'phone': '',
            'profileImage': null,
          };
          
          // حفظ البيانات الافتراضية في Firestore
          await _firestore.collection('users').doc(currentUser!.uid).set(userData!);
        }
      } catch (e) {
        print('Error loading user data: $e');
        // في حالة حدوث خطأ، ننشئ بيانات افتراضية
        userData = {
          'uid': currentUser!.uid,
          'firstName': '',
          'lastName': '',
          'email': currentUser!.email ?? '',
          'phone': '',
          'profileImage': null,
        };
      }
    } else {
      print("No current user found");
      // إذا لم يكن هناك مستخدم مسجل دخول، الانتقال لصفحة تسجيل الدخول
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: brownDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Select Profile Picture",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                      Icons.camera_alt_rounded,
                      "Camera",
                      () => _getImage(ImageSource.camera),
                    ),
                    _buildImageOption(
                      Icons.photo_library_rounded,
                      "Gallery",
                      () => _getImage(ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: brownLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 35, color: brownDark),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: brownDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      await _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_selectedImage == null || currentUser == null) return;

    try {
      // إظهار loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: brownLight),
          ),
        );
      }

      // رفع الصورة لـ Firebase Storage
      String fileName = 'profile_${currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('profile_images/$fileName');
      
      await ref.putFile(_selectedImage!);
      String downloadUrl = await ref.getDownloadURL();

      // تحديث الرابط في Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'profileImage': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // تحديث البيانات المحلية
      setState(() {
        userData!['profileImage'] = downloadUrl;
      });

      if (mounted) {
        Navigator.pop(context); // إخفاء loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile picture updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      print('Image upload error: $e');
      if (mounted) {
        Navigator.pop(context); // إخفاء loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to upload image: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(String field, String currentValue) async {
    final TextEditingController controller = TextEditingController(text: currentValue);
    
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: brownDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Edit ${_getFieldDisplayName(field)}",
                style: const TextStyle(color: Colors.white),
              ),
              content: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter ${_getFieldDisplayName(field)}",
                  hintStyle: const TextStyle(color: Colors.white60),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: brownLight),
                  ),
                  filled: true,
                  fillColor: Colors.white10,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (controller.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Field cannot be empty"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    setDialogState(() {
                      isLoading = true;
                    });

                    bool success = await _updateUserData(field, controller.text.trim());
                    
                    setDialogState(() {
                      isLoading = false;
                    });

                    if (success) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brownLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: brownDark,
                          ),
                        )
                      : const Text(
                          "Save",
                          style: TextStyle(color: brownDark, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'firstName':
        return 'First Name';
      case 'lastName':
        return 'Last Name';
      case 'phone':
        return 'Phone Number';
      default:
        return field;
    }
  }

  Future<bool> _updateUserData(String field, String value) async {
    if (currentUser == null) return false;

    try {
      print("Updating $field with value: $value");
      
      // تحديث البيانات في Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // تحديث البيانات المحلية
      setState(() {
        userData![field] = value;
      });

      print("Successfully updated $field");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_getFieldDisplayName(field)} updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      
      return true;
    } catch (e) {
      print("Error updating $field: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update ${_getFieldDisplayName(field)}: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: brownDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Sign Out",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to sign out?",
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
                await _auth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: brownDark,
        body: Center(
          child: CircularProgressIndicator(color: brownLight),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: buildCustomAppBar("Profile page"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Profile Image
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [brownDark, brownLight],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (userData?['profileImage'] != null && userData!['profileImage'].toString().isNotEmpty
                                    ? NetworkImage(userData!['profileImage'])
                                    : const AssetImage("assets/images/logo.png"))
                                    as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: brownDark,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _getDisplayName(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?['email'] ?? 'No email',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Profile Information Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.person_rounded,
                    title: "First Name",
                    value: userData?['firstName']?.toString().isNotEmpty == true 
                        ? userData!['firstName'] 
                        : 'Tap to add first name',
                    onEdit: () => _showEditDialog('firstName', userData?['firstName'] ?? ''),
                  ),
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    icon: Icons.person_outline_rounded,
                    title: "Last Name",
                    value: userData?['lastName']?.toString().isNotEmpty == true 
                        ? userData!['lastName'] 
                        : 'Tap to add last name',
                    onEdit: () => _showEditDialog('lastName', userData?['lastName'] ?? ''),
                  ),
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    icon: Icons.email_rounded,
                    title: "Email",
                    value: userData?['email'] ?? 'No email',
                    onEdit: null, // Email لا يمكن تعديله
                  ),
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    icon: Icons.phone_rounded,
                    title: "Phone",
                    value: userData?['phone']?.toString().isNotEmpty == true 
                        ? userData!['phone'] 
                        : 'Tap to add phone number',
                    onEdit: () => _showEditDialog('phone', userData?['phone'] ?? ''),
                  ),
                  const SizedBox(height: 30),

                  // Refresh button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brownLight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.refresh, color: brownDark),
                      label: const Text(
                        "Refresh Profile",
                        style: TextStyle(
                          color: brownDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Sign Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName() {
    if (userData != null) {
      String firstName = userData!['firstName']?.toString() ?? '';
      String lastName = userData!['lastName']?.toString() ?? '';
      
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return "$firstName $lastName".trim();
      }
    }
    return "Welcome User";
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onEdit,
  }) {
    bool isEmpty = value.startsWith('Tap to add') || value.isEmpty || value == 'No email';
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: brownLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: brownDark,
              size: 26,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: isEmpty ? Colors.grey.shade500 : brownDark,
                    fontSize: 17,
                    fontWeight: isEmpty ? FontWeight.normal : FontWeight.w600,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            Container(
              decoration: BoxDecoration(
                color: brownLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_rounded,
                  color: brownLight,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}