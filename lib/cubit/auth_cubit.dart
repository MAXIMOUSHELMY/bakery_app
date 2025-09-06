import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      emit(AuthSuccess());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found for this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password. Please try again.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is not valid.";
          break;
        case 'invalid-credential':
          errorMessage = "Invalid email or password. Please check your credentials.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many failed attempts. Please try again later.";
          break;
        default:
          errorMessage = "Login failed: ${e.message}";
      }
      emit(AuthFailure(errorMessage));
    } catch (e) {
      emit(AuthFailure("An unexpected error occurred. Please try again."));
    }
  }

  Future<void> signup(String email, String password, String firstName, String lastName) async {
    emit(AuthLoading());
    try {
      // إنشاء الحساب في Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // حفظ البيانات في Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.toLowerCase().trim(),
          'phone': '',  // فارغ بدلاً من "Not provided"
          'profileImage': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print("User data saved to Firestore successfully");
        print("User ID: ${userCredential.user!.uid}");
        print("First Name: $firstName");
        print("Last Name: $lastName");
        
        emit(AuthSuccess());
      } else {
        emit(AuthFailure("Failed to create user account."));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already registered. Please use a different email.";
          break;
        case 'weak-password':
          errorMessage = "Password should be at least 6 characters long.";
          break;
        case 'invalid-email':
          errorMessage = "Please enter a valid email address.";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled.";
          break;
        default:
          errorMessage = "Signup failed: ${e.message}";
      }
      emit(AuthFailure(errorMessage));
    } catch (e) {
      print("Unexpected error during signup: $e");
      emit(AuthFailure("An unexpected error occurred during signup. Please try again."));
    }
  }
  Future<bool> checkAuthStatus() async {
    try {
      User? user = _auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure("Error signing out"));
    }
  }
}