
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fitnessapp/data/db.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';

class SettingsProvider with ChangeNotifier {
  var currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> changePassword({
    required BuildContext context,
    required String email,
    required String oldPassword,
    required String newPassword,
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
      print("Reauthenticating user...");
      var credential =
          EmailAuthProvider.credential(email: email, password: oldPassword);
      await currentUser!.reauthenticateWithCredential(credential).then((value) {
        print("Reauthentication successful, updating password...");
        currentUser!.updatePassword(newPassword);
        print("Password updated successfully.");
      });

      Navigator.pop(context); // Ensure dialog is dismissed
      notifyListeners();
    } catch (e) {
      print("Error in changePassword: $e");
      Navigator.pop(context); // Dismiss the dialog even on error
      rethrow;
    }
  }

  Future<void> changeEmail({
    required BuildContext context,
    required String oldEmail,
    required String newEmail,
    required String password,
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
      print("Reauthenticating user...");
      var credential =
          EmailAuthProvider.credential(email: oldEmail, password: password);
      await currentUser!.reauthenticateWithCredential(credential).then((value) {
        print("Reauthentication successful, updating email...");
        currentUser!.updateEmail(newEmail);
        print("Email updated successfully.");
      });

      Navigator.pop(context); // Ensure dialog is dismissed
      notifyListeners();
    } catch (e) {
      print("Error in changeEmail: $e");
      Navigator.pop(context); // Dismiss the dialog even on error
      rethrow;
    }
  }

  Future<void> deleteUser({
    required String email,
    required String password,
  }) async {
    try {
      print("Deleting user...");
      User? user = _auth.currentUser;
      if (user == null) {
        print("Error: No current user.");
        return;
      }
  print("Reauthenticating with email: $email");
  AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
  UserCredential result = await user.reauthenticateWithCredential(credential);
  print("Reauthentication result: $result");
} catch (e) {
  print("Error during reauthentication: $e");
  rethrow;
}
  }

  Future<void> signOut({
  required BuildContext context,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissing dialog by tapping outside
    builder: (_) => Center(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: SpinKitSpinningLines(color: ColorManager.limerGreen2),
      ),
    ),
  );

  try {
    print("Signing out...");
    await FirebaseAuth.instance.signOut();
    print("User signed out successfully.");

    // Navigate to the Sign-Up page after successful sign-out
    Navigator.pop(context); // Close the dialog
    Navigator.pushReplacementNamed(context, '/login'); // Change '/signUp' to your actual sign-up route
  } on FirebaseAuthException catch (e) {
    print("Error in signOut: $e");
    // Optionally, show an error message to the user
  } finally {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Ensure dialog is dismissed if still open
    }
    notifyListeners();
  }
}

}
