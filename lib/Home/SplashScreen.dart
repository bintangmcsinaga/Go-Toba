import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_toba/Login&Register/login.dart';
import 'package:go_toba/MainPage.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Pulse ring
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // Logo + text fade
  late AnimationController _fadeCtrl;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _textFade;

  // Wave
  late AnimationController _waveCtrl;
  late Animation<double> _waveAnim;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Pulse ring animation
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    // Logo fade-in + slide-up
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutBack));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _fadeCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    _waveCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    _waveAnim = Tween<double>(begin: 0, end: 2 * pi).animate(_waveCtrl);

    // Start entrance animation after brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeCtrl.forward();
    });

    // Hide loading indicator after 3.5s
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _isLoading = false);
    });

    // Navigate after 4.5s
    Future.delayed(const Duration(milliseconds: 4500), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('login') ?? false;
    if (!mounted) return;
    if (isLoggedIn) {
      final uid = prefs.getString('uid');
      context.read<UserProvider>().setUid(uid);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainPage(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const Login(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background lake image ──────────────────────────────────────
          Image.asset('assets/lake.jpeg', fit: BoxFit.cover),

          // ── Dark gradient overlay ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xCC001F1E),
                  Color(0x88016962),
                  Colors.transparent
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // ── Animated wave at bottom ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.25,
            child: AnimatedBuilder(
              animation: _waveAnim,
              builder: (_, __) => CustomPaint(
                painter: _SplashWavePainter(_waveAnim.value),
                size: Size(size.width, size.height * 0.25),
              ),
            ),
          ),

          // ── Center content ─────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulse ring behind logo
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // outer pulse ring
                        Transform.scale(
                          scale: _pulseScale.value,
                          child: Opacity(
                            opacity: _pulseOpacity.value,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primaryLight, width: 2),
                              ),
                            ),
                          ),
                        ),
                        child!,
                      ],
                    );
                  },
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryDark, AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: const Icon(Icons.water,
                            size: 44, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App name
                FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      Text(
                        'Go Toba',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: const [
                            Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 2))
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jelajahi Keindahan Danau Toba',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Loading indicator
                AnimatedOpacity(
                  opacity: _isLoading ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashWavePainter extends CustomPainter {
  final double phase;
  _SplashWavePainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = AppColors.primaryDark.withValues(alpha: 0.15 + i * 0.07)
        ..style = PaintingStyle.fill;
      final path = Path();
      path.moveTo(0, size.height * (0.5 + i * 0.1));
      for (double x = 0; x <= size.width; x++) {
        final y = size.height * (0.5 + i * 0.1) +
            sin(x / size.width * 2 * pi * 2.5 + phase + i * 1.0) *
                (10.0 - i * 2.0);
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SplashWavePainter old) => old.phase != phase;
}
