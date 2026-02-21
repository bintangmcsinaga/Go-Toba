// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Providers/ResetPasswordProv.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';

// ── Change Password Page ─────────────────────────────────────────────────────
class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  _ChangepasswordState createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

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

    if (!mounted) return;
    if (email != context.read<UserProvider>().email) {
      _showToast('Email tidak cocok dengan akunmu', isError: true);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showToast('Link reset berhasil dikirim ke email', isError: false);
      if (!mounted) return;
      context.read<ResetPasswordProvider>().startTimer();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EmailSentScreen(email: email)),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text('Ganti Password',
                style:
                    AppTextStyles.headingSmall.copyWith(color: Colors.white)),
            flexibleSpace: Container(
              decoration:
                  const BoxDecoration(gradient: AppGradients.primaryVertical),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Illustration ───────────────────────────────
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_reset_rounded,
                          color: AppColors.primary, size: 44),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Masukkan emailmu dan kami akan mengirim\nlink untuk mereset passwordmu.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // ── Email field ────────────────────────────────
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppDecorations.inputDecoration(
                      'Alamat Email',
                      icon: Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Button ─────────────────────────────────────
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
        ],
      ),
    );
  }
}

// ── Email Sent Confirmation Screen ───────────────────────────────────────────
class EmailSentScreen extends StatefulWidget {
  final String email;
  const EmailSentScreen({super.key, required this.email});

  @override
  _EmailSentScreenState createState() => _EmailSentScreenState();
}

class _EmailSentScreenState extends State<EmailSentScreen> {
  void _resendEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      Fluttertoast.showToast(
        msg: 'Link reset telah dikirim ulang.',
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
              // ── Animated icon ────────────────────────────────
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
                'Link reset password telah dikirim ke\n${widget.email}\n\nPeriksa kotak masuk atau folder spam.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 36),

              // ── Resend button ────────────────────────────────
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
                child: Text('Kembali',
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
