import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Fitness/presentation/auth/providers/auth_provider.dart';
import 'package:Fitness/presentation/auth/widgets/login_or_register_view.dart';
import 'package:Fitness/utils/managers/asset_manager.dart';
import 'package:Fitness/utils/managers/color_manager.dart';
import 'package:Fitness/utils/managers/string_manager.dart';
import 'package:Fitness/utils/managers/style_manager.dart';
import 'package:Fitness/utils/managers/value_manager.dart';
import 'package:Fitness/utils/router/router.dart';
import 'package:Fitness/utils/widgets/lime_green_rounded_button.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _repeatPasswordController = TextEditingController();
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

  void _switchAuthMode() {
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

  Future<void> _signInWithGoogle() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle(context);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    Future<void> signUserIn() async {
      try {
        await authProvider.signIn(
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
        );
      } catch (e) {
        rethrow;
      }
    }

    Future<void> signUserUp() async {
      try {
        await authProvider.register(
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
        );
      } catch (e) {
        rethrow;
      }
    }

    void onPressed() {
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
                  padding: const EdgeInsets.only(top: PaddingManager.p18),
                  child: LimeGreenRoundedButtonWidget(
                    onTap: _signInWithGoogle,
                    title: StringsManager.signInWithGoogle,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms),
          ),
        ),
      ),
    );
  }
}