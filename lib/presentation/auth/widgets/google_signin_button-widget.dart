import 'package:flutter/material.dart';

class GoogleSignInButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const GoogleSignInButtonWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.grey),
          ),
          elevation: 2, // Add a subtle shadow
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google.png', // Make sure this image is in assets
              height: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              "Sign in with Google",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
