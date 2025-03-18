import 'package:fitnessapp/presentation/auth/widgets/google_signin_button-widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fitnessapp/presentation/auth/providers/auth_provider.dart';
import 'package:fitnessapp/presentation/auth/widgets/login_or_register_view.dart';
import 'package:fitnessapp/utils/managers/asset_manager.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/string_manager.dart';
import 'package:fitnessapp/utils/managers/style_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';
import 'package:fitnessapp/utils/router/router.dart';
import 'package:fitnessapp/utils/widgets/lime_green_rounded_button.dart';

enum AuthMode { signUp, signIn }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  AuthMode _authMode = AuthMode.signIn;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get isEmailNotEmpty => _emailController.text.isNotEmpty;
  bool get isPasswordConfirmed =>
      _passwordController == _repeatPasswordController;
  bool get isRegisterView => _authMode == AuthMode.signUp;
  bool get isLoginView => _authMode == AuthMode.signIn;

  // Inside the _switchAuthMode method
  void _switchAuthMode() {
    debugPrint('Switching Auth Mode: ${isLoginView ? 'SignUp' : 'SignIn'}');
    if (isLoginView) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
    } else if (isRegisterView) {
      setState(() {
        _authMode = AuthMode.signIn;
      });
    }
  }

  // Inside the _signInWithGoogle method
  Future<void> _signInWithGoogle() async {
    try {
      debugPrint('Attempting Google Sign-In');
      await Provider.of<AuthProvider>(context, listen: false)
          .signInWithGoogle(context);
      debugPrint('Google Sign-In Successful');
    } catch (e) {
      debugPrint('Google Sign-In Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Inside signUserIn method
    Future<void> signUserIn() async {
      try {
        debugPrint('Attempting Sign-In with Email: ${_emailController.text}');
        await authProvider.signIn(
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
        );
        debugPrint('Sign-In Successful');
      } catch (e) {
        debugPrint('Sign-In Failed: $e');
        rethrow;
      }
    }

// Inside signUserUp method
    Future<void> signUserUp() async {
      try {
        debugPrint('Attempting Sign-Up with Email: ${_emailController.text}');
        await authProvider.register(
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
        );
        debugPrint('Sign-Up Successful');
      } catch (e) {
        debugPrint('Sign-Up Failed: $e');
        rethrow;
      }
    }

// Inside onPressed function
    void onPressed() {
      debugPrint('Auth Button Pressed: ${isLoginView ? 'SignIn' : 'SignUp'}');
      if (isLoginView) {
        signUserIn();
      } else if (isRegisterView) {
        signUserUp();
      }
    }

    return Scaffold(
      backgroundColor: ColorManager.darkGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: PaddingManager.p12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: PaddingManager.p8),
                  child: SizedBox(
                    width: SizeManager.s250.w,
                    height: SizeManager.s250.h,
                    child: Image.asset(
                      ImageManager.logo,
                    ),
                  ),
                ),
                LoginOrRegisterView(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isRegisterView: isRegisterView,
                  repeatPasswordController: _repeatPasswordController,
                ),
                isLoginView
                    ? Padding(
                        padding: const EdgeInsets.only(
                          right: PaddingManager.p28,
                          left: PaddingManager.p28,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(Routes.forgotPasswordRoute);
                            },
                            child: Text(
                              StringsManager.forgotPassword,
                              style: StyleManager.loginPageSubTextTextStyle,
                            ),
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(top: PaddingManager.p2),
                  child: LimeGreenRoundedButtonWidget(
                    onTap: onPressed,
                    title: isLoginView
                        ? StringsManager.signIn
                        : StringsManager.signUp,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: PaddingManager.p28,
                    right: PaddingManager.p28,
                    top: PaddingManager.p18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLoginView
                            ? StringsManager.dontHaveAcc
                            : StringsManager.haveAcc,
                        style: StyleManager.loginPageSubTextTextStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: PaddingManager.p8),
                        child: GestureDetector(
                          onTap: _switchAuthMode,
                          child: Text(
                            isLoginView
                                ? StringsManager.signUp
                                : StringsManager.signIn,
                            style:
                                StyleManager.loginPageSubButtonSmallTextStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: GoogleSignInButtonWidget(onTap: _signInWithGoogle),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms),
          ),
        ),
      ),
    );
  }
}
