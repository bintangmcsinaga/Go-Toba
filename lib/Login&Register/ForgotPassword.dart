// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Providers/ResetPasswordProv.dart';
import 'package:go_toba/style.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  void _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showToast('Email tidak boleh kosong', isError: true);
      return;
    }
    final emailValid =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
            .hasMatch(email);
    if (!emailValid) {
      _showToast('Format email tidak valid', isError: true);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showToast('Link reset dikirim ke email!', isError: false);
      if (!mounted) return;
      context.read<ResetPasswordProvider>().startTimer();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => _ForgotEmailSentScreen(email: email)),
      );
    } catch (e) {
      _showToast('Terjadi kesalahan: $e', isError: true);
    }
  }

  void _showToast(String msg, {required bool isError}) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.TOP,
      backgroundColor: isError ? AppColors.error : AppColors.success,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Back button ────────────────────────────────────────
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 16),

              // ── Illustration ───────────────────────────────────────
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.button,
                  ),
                  child: const Icon(Icons.lock_open_rounded,
                      color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 24),

              Text('Lupa Password?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingLarge),
              const SizedBox(height: 8),
              Text(
                'Masukkan email yang terdaftar, dan kami\nakan mengirim link reset passwordmu.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 36),

              // ── Email field ────────────────────────────────────────
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: AppDecorations.inputDecoration(
                  'Alamat Email',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 24),

              // ── Send button ────────────────────────────────────────
              Consumer<ResetPasswordProvider>(
                builder: (context, prov, _) => AppPrimaryButton(
                  label: prov.canResendEmail
                      ? 'Kirim Link Reset'
                      : 'Tunggu ${prov.secondsRemaining}s',
                  icon: prov.canResendEmail
                      ? Icons.send_rounded
                      : Icons.hourglass_empty_rounded,
                  onTap: prov.canResendEmail ? _resetPassword : () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Email Sent Confirmation ──────────────────────────────────────────────────
class _ForgotEmailSentScreen extends StatefulWidget {
  final String email;
  const _ForgotEmailSentScreen({required this.email});

  @override
  State<_ForgotEmailSentScreen> createState() => _ForgotEmailSentScreenState();
}

class _ForgotEmailSentScreenState extends State<_ForgotEmailSentScreen> {
  void _resendEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      Fluttertoast.showToast(
        msg: 'Link reset dikirim ulang',
        gravity: ToastGravity.TOP,
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
      if (!mounted) return;
      context.read<ResetPasswordProvider>().startTimer();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Gagal: $e',
        gravity: ToastGravity.TOP,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.button,
                  ),
                  child: const Icon(Icons.mark_email_read_rounded,
                      color: Colors.white, size: 52),
                ),
              ),
              const SizedBox(height: 28),
              Text('Email Terkirim!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingLarge),
              const SizedBox(height: 12),
              Text(
                'Link reset password dikirim ke:\n${widget.email}\n\nPeriksa kotak masuk atau folder spam.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 36),
              Consumer<ResetPasswordProvider>(
                builder: (context, prov, _) => AppPrimaryButton(
                  label: prov.canResendEmail
                      ? 'Kirim Ulang'
                      : 'Kirim ulang dalam ${prov.secondsRemaining}s',
                  icon: prov.canResendEmail
                      ? Icons.refresh_rounded
                      : Icons.timer_rounded,
                  onTap: prov.canResendEmail ? _resendEmail : () {},
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Kembali ke Login',
                    style: AppTextStyles.button
                        .copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
