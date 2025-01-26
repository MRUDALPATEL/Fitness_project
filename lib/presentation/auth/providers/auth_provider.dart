import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/string_manager.dart';
import 'package:fitnessapp/utils/managers/style_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool? _isNewUser;
  bool? _hasAgeParameter;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get()
            .then((docSnapshot) {
          _hasAgeParameter =
              docSnapshot.exists && docSnapshot.data()!.containsKey('age');
          _isNewUser =
              _user!.metadata.creationTime == _user!.metadata.lastSignInTime &&
                  !_hasAgeParameter!;
          debugPrint(
              '[DEBUG] User state updated: _isNewUser=$_isNewUser, _hasAgeParameter=$_hasAgeParameter');
          notifyListeners();
        }).catchError((e) {
          debugPrint('[DEBUG] Error fetching user data: $e');
        });
      } else {
        _hasAgeParameter = null;
        _isNewUser = null;
        debugPrint('[DEBUG] User signed out or no user logged in.');
        notifyListeners();
      }
    });
  }

  void callAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get()
            .then((docSnapshot) {
          _hasAgeParameter =
              docSnapshot.exists && docSnapshot.data()!.containsKey('age');
          _isNewUser =
              _user!.metadata.creationTime == _user!.metadata.lastSignInTime &&
                  !_hasAgeParameter!;
          notifyListeners();
        });
      } else {
        _hasAgeParameter = null;
        _isNewUser = null;
        notifyListeners();
      }
    });
  }

  User? get user => _user;
  bool? get isNewUser => _isNewUser;
  bool? get hasAgeParameter => _hasAgeParameter;

  Future<void> forgotPassword({
    required String email,
    required BuildContext context,
  }) async {
    debugPrint('[DEBUG] Password reset initiated for email: $email');
    showDialog(
        context: context,
        builder: (_) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: SpinKitSpinningLines(color: ColorManager.limerGreen2),
            ),
          );
        });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      debugPrint('[DEBUG] Password reset email sent.');
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (_) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(PaddingManager.p40),
                child: AlertDialog(
                  backgroundColor: ColorManager.darkGrey,
                  title: Text(
                    StringsManager.success,
                    textAlign: TextAlign.center,
                    style: StyleManager.forgotPWErrorTextStyle,
                  ),
                  content: Text(
                    StringsManager.pwResetLinkSent,
                    textAlign: TextAlign.center,
                    style: StyleManager.forgotPWErrorContentTextStyle,
                  ),
                ),
              ),
            );
          });
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      debugPrint('[DEBUG] Error during password reset: ${e.message}');
      showDialog(
          context: context,
          builder: (_) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(PaddingManager.p40),
                child: AlertDialog(
                  backgroundColor: ColorManager.darkGrey,
                  title: Text(
                    StringsManager.wrongEmail,
                    textAlign: TextAlign.center,
                    style: StyleManager.forgotPWErrorTextStyle,
                  ),
                  content: Text(
                    e.message.toString(),
                    textAlign: TextAlign.center,
                    style: StyleManager.forgotPWErrorContentTextStyle,
                  ),
                ),
              ),
            );
          });
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    debugPrint('[DEBUG] Attempting to sign in with email: $email');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: SpinKitSpinningLines(color: ColorManager.limerGreen2),
        ),
      ),
    );

    try {
      // Attempt to sign in
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      if (_user == null) {
        debugPrint('[DEBUG] User is null after sign-in.');
        Navigator.pop(context); // Close loading dialog
        return;
      }

      debugPrint('[DEBUG] Signed in successfully. User UID: ${_user!.uid}');

      // Fetch user document
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      Navigator.pop(context); // Close loading dialog

      // Navigate based on user document existence
      if (docSnapshot.exists) {
        debugPrint('[DEBUG] User document found. Redirecting to /main.');
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        debugPrint('[DEBUG] No user document found. Redirecting to /addData.');
        Navigator.pushReplacementNamed(context, '/addData');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog
      debugPrint('[DEBUG] Sign-in error: ${e.code} - ${e.message}');

      // Show error dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: ColorManager.darkGrey,
          title: Text(
            StringsManager.wrongEmail,
            textAlign: TextAlign.center,
            style: StyleManager.forgotPWErrorTextStyle,
          ),
          content: Text(
            _getFriendlyErrorMessage(e.code),
            textAlign: TextAlign.center,
            style: StyleManager.forgotPWErrorContentTextStyle,
          ),
        ),
      );
    } finally {
      debugPrint('[DEBUG] Sign-in process completed.');
    }
  }

// Helper function to map error codes to friendly messages
  String _getFriendlyErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Invalid password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address. Please check your input.';
      default:
        return 'An unexpected error occurred. Please try again later.';
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: SpinKitSpinningLines(color: ColorManager.limerGreen2),
        ),
      ),
    );

    try {
      UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({});

      Navigator.pushReplacementNamed(context, '/addData');

      notifyListeners();
    } on FirebaseAuthException catch (_) {
      Future.delayed(const Duration(seconds: 2)).then((value) {
        Navigator.pop(context);
        notifyListeners();
      });
    }
  }

  Future<void> addUserData({
  required String email,
  required String name,
  required String surname,
  required int age,
  required double height,
  required double weight,
  required String gender,
  required String activity,
  required double bmr,
  required String goal,
  required double bmi,
  required String category, // New dropdown value
  required BuildContext context,
}) async {
  try {
    // Get the currently signed-in user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Common data to store in Firestore
    final userData = {
      'email': email,
      'first name': name,
      'surname': surname,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'activity': activity,
      'bmr': bmr,
      'goal': goal,
      'bmi': bmi,
      'category': category, // Added new dropdown value
      // Measurements (can be customized or expanded later)
      'chest': 0.0,
      'shoulders': 0.0,
      'biceps': 0.0,
      'foreArm': 0.0,
      'waist': 0.0,
      'hips': 0.0,
      'thigh': 0.0,
      'calf': 0.0,
    };

    // Check if the document exists
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Update existing document
      await docRef.update(userData);
    } else {
      // Create a new document if it doesn't exist
      await docRef.set(userData);
    }

    debugPrint("User data added/updated successfully.");
  } on FirebaseException catch (e) {
    debugPrint("FirebaseException in addUserData: ${e.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to save data: ${e.message}")),
    );
    rethrow;
  } catch (e) {
    debugPrint("Unexpected error in addUserData: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An unexpected error occurred.")),
    );
    rethrow;
  }
}


  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // The user canceled the sign-in
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();
        if (!docSnapshot.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .set({
            'name': googleUser.displayName,
            'email': googleUser.email,
          });
          Navigator.pushReplacementNamed(context, '/addUserData');
        } else {
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error in signInWithGoogle: $e");
      rethrow;
    }
  }
}
