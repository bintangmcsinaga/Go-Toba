import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_toba/Login&Register/VerifyEmail.dart';
import 'package:go_toba/Login&Register/login.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late Map<String, dynamic> userData = {};
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool isloading = false;

  Future<void> _register() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isloading = true;
    });

    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final email = _emailController.text;
      final password = _passwordController.text;

      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user?.uid ?? "";

      if (!mounted) return;
      context.read<UserProvider>().setUid(uid);

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': _usernameController.text,
        'phone': _phoneController.text,
        'email': email,
        'hoteltags': ["tuktuk"],
        'vacationtags': ["pemandangandanau"],
        'culinarytags': ["kuah"]
      });

      await userCredential.user?.sendEmailVerification();
      await prefs.setBool('login', true);

      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const VerifyEmailPage()));
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(
          msg: error.message ?? 'Terjadi kesalahan', gravity: ToastGravity.TOP);
    } finally {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Top gradient hero ──────────────────────────────────────
          SizedBox(
            height: size.height * 0.35,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/laketoba.jpg', fit: BoxFit.cover),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xCC001F1E), Color(0x44016962)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.white54, width: 2),
                        ),
                        child: const Icon(Icons.person_add_rounded,
                            size: 28, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text('Buat Akun Baru',
                          style: AppTextStyles.headingMedium
                              .copyWith(color: Colors.white, letterSpacing: 1)),
                      const SizedBox(height: 2),
                      Text('Bergabunglah dan jelajahi Danau Toba',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom card ────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.72,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Informasi Diri', style: AppTextStyles.headingMedium),
                    const SizedBox(height: 4),
                    Text('Lengkapi data di bawah untuk mendaftar',
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 24),

                    // Username
                    TextField(
                      controller: _usernameController,
                      decoration: AppDecorations.inputDecoration('Username',
                          icon: Icons.person_outline),
                    ),
                    const SizedBox(height: 14),

                    // Email
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: AppDecorations.inputDecoration('Email',
                          icon: Icons.email_outlined),
                    ),
                    const SizedBox(height: 14),

                    // Phone
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: AppDecorations.inputDecoration('Nomor HP',
                          icon: Icons.phone_outlined),
                    ),
                    const SizedBox(height: 14),

                    // Password
                    TextField(
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
                    ),
                    const SizedBox(height: 28),

                    // Register button
                    AppPrimaryButton(
                      label: 'Daftar Sekarang',
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: isloading,
                      onTap: _register,
                    ),
                    const SizedBox(height: 20),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sudah punya akun?',
                            style: AppTextStyles.bodyMedium),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const Login()),
                          ),
                          child: Text('Masuk',
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
        ],
      ),
    );
  }
}
