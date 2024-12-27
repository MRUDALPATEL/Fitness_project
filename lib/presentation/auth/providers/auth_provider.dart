import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:Fitness/utils/managers/color_manager.dart';
import 'package:Fitness/utils/managers/string_manager.dart';
import 'package:Fitness/utils/managers/style_manager.dart';
import 'package:Fitness/utils/managers/value_manager.dart';
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
          notifyListeners();
        });
      } else {
        _hasAgeParameter = null;
        _isNewUser = null;
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
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      if (!docSnapshot.exists) {
        Navigator.pushReplacementNamed(context, '/addData');
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }

      notifyListeners();
    } on FirebaseAuthException catch (_) {
      Future.delayed(const Duration(seconds: 2)).then(
        (value) {
          Navigator.pop(context);
          notifyListeners();
        },
      );
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
  required BuildContext context,
}) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Check if the document exists
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      // Update existing document
      await docRef.update({
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
        'chest': 0.0,
        'shoulders': 0.0,
        'biceps': 0.0,
        'foreArm': 0.0,
        'waist': 0.0,
        'hips': 0.0,
        'thigh': 0.0,
        'calf': 0.0,
      });
    } else {
      // Create a new document if it doesn't exist
      await docRef.set({
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
        'chest': 0.0,
        'shoulders': 0.0,
        'biceps': 0.0,
        'foreArm': 0.0,
        'waist': 0.0,
        'hips': 0.0,
        'thigh': 0.0,
        'calf': 0.0,
      });
    }

    notifyListeners();
  } catch (e) {
    debugPrint("Error in addUserData: $e");
    rethrow;
  }
}

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // The user canceled the sign-in
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
        if (!docSnapshot.exists) {
          await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
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