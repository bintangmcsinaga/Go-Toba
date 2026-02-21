import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_toba/Login&Register/ForgotPassword.dart';
import 'package:go_toba/MainPage.dart'; // Sesuaikan path-nya
import 'package:go_toba/Login&Register/register.dart'; // Import halaman forgot password
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Map<String, dynamic> userData = {};
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isloading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isloading = true;
      });
      try {
        UserCredential userCredential =
            await firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        String uid = userCredential.user?.uid ?? "";

        if (!mounted) return;
        context.read<UserProvider>().setUid(uid);
        await prefs.setString("uid", uid);
        await prefs.setBool('login', true);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );

        Fluttertoast.showToast(
          msg: 'Login successful',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } on FirebaseAuthException catch (error) {
        _handleFirebaseAuthError(error);
      } catch (error) {
        Fluttertoast.showToast(
          msg: 'An error occurred during login: $error',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        await prefs.setBool('login', false);
      } finally {
        if (mounted) {
          setState(() {
            isloading = false;
          });
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Please fill in all fields correctly',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    try {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate(
        scopeHint: ['email'],
      );

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      String uid = userCredential.user?.uid ?? "";

      if (!mounted) return;
      context.read<UserProvider>().setUid(uid);
      await prefs.setString("uid", uid);
      await prefs.setBool('login', true);

      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userSnapshot.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': googleUser.email,
          'username': googleUser.displayName,
          'culinarytags': ['ikan'],
          'hoteltags': ['parapat'],
          'vacationtags': ['pemandangandanau'],
          'phone': ''
        });
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );

      Fluttertoast.showToast(
        msg: 'Login successful with Google',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } on FirebaseAuthException catch (error) {
      _handleFirebaseAuthError(error);
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'An error occurred during Google login: $error',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _loginWithFacebook() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        AuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        UserCredential userCredential =
            await firebaseAuth.signInWithCredential(credential);
        String uid = userCredential.user?.uid ?? "";
        context.read<UserProvider>().setUid(uid);
        await prefs.setString("uid", uid);

        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (!userSnapshot.exists) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'email': userCredential.user?.email,
            'name': userCredential.user?.displayName,
          });
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );

        Fluttertoast.showToast(
          msg: 'Login successful with Facebook',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Facebook login was cancelled',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } on FirebaseAuthException catch (error) {
      _handleFirebaseAuthError(error);
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'An error occurred during Facebook login: $error',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _handleFirebaseAuthError(FirebaseAuthException error) {
    String message;
    switch (error.code) {
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'user-disabled':
        message =
            'The user corresponding to the given email has been disabled.';
        break;
      case 'user-not-found':
        message = 'There is no user corresponding to the given email.';
        break;
      case 'wrong-password':
        message = 'The password is invalid for the given email.';
        break;
      case 'account-exists-with-different-credential':
        message =
            'An account already exists with the same email address but different sign-in credentials.';
        break;
      case 'operation-not-allowed':
        message = 'Signing in with this provider is not enabled.';
        break;
      case 'network-request-failed':
        message = 'Network error, please try again later.';
        break;
      default:
        message = 'An undefined error occurred: ${error.message}';
    }
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Top gradient hero ───────────────────────────────────────
          SizedBox(
            height: size.height * 0.42,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/laketoba.jpg', fit: BoxFit.cover),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xAA001F1E), Color(0x44016962)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                // Logo + title
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.white54, width: 2),
                        ),
                        child: const Icon(Icons.water,
                            size: 34, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text('Go Toba',
                          style: AppTextStyles.headingLarge.copyWith(
                              color: Colors.white, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text('Selamat datang kembali!',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom card ─────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.65,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Masuk ke Akun', style: AppTextStyles.headingMedium),
                      const SizedBox(height: 6),
                      Text('Gunakan email dan password kamu',
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 28),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: AppDecorations.inputDecoration('Email',
                            icon: Icons.email_outlined),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Masukkan email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: AppDecorations.inputDecoration('Password',
                                icon: Icons.lock_outline)
                            .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Masukkan password';
                          if (v.length < 8) return 'Minimal 8 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: Text('Lupa Password?',
                              style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Login button
                      AppPrimaryButton(
                        label: 'Masuk',
                        icon: Icons.login_rounded,
                        isLoading: isloading,
                        onTap: _login,
                      ),
                      const SizedBox(height: 20),

                      // Divider
                      Row(children: [
                        const Expanded(
                            child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('atau', style: AppTextStyles.bodySmall),
                        ),
                        const Expanded(
                            child: Divider(color: AppColors.divider)),
                      ]),
                      const SizedBox(height: 20),

                      // Google sign-in
                      _SocialLoginButton(
                        label: 'Masuk dengan Google',
                        assetIcon: 'assets/google_logo.png',
                        onTap: _loginWithGoogle,
                      ),
                      const SizedBox(height: 24),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Belum punya akun?",
                              style: AppTextStyles.bodyMedium),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const Register()),
                            ),
                            child: Text('Daftar',
                                style: AppTextStyles.label.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final String assetIcon;
  final VoidCallback onTap;
  const _SocialLoginButton(
      {required this.label, required this.assetIcon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider, width: 1.5),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(assetIcon, width: 22, height: 22),
            const SizedBox(width: 10),
            Text(label,
                style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
