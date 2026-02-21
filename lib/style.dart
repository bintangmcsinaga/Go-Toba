import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Legacy compatibility aliases ────────────────────────────────────────────
const color2 = AppColors.primary;
const color1 = AppColors.background;
const color3 = AppColors.primaryLight;

const smallfontsize = 0.035;
const normalfontsize = 0.050;
const mediumfontsize = 0.070;
const largefontsize = 0.100;
const iconsize = 0.100;
const screenpadding = 0.040;

// ── Palette ─────────────────────────────────────────────────────────────────
class AppColors {
  // Primary — Danau Toba teal
  static const Color primary = Color(0xFF02A29A);
  static const Color primaryDark = Color(0xFF016962);
  static const Color primaryLight = Color(0xFF4ECDC4);

  // Accent — warm gold (sun over the lake)
  static const Color accent = Color(0xFFE8A923);
  static const Color accentLight = Color(0xFFFFF0C0);

  // Neutrals
  static const Color background = Color(0xFFF0F4F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFE8F4F3);

  // Text
  static const Color textPrimary = Color(0xFF1A2B3C);
  static const Color textSecondary = Color(0xFF6B7A8D);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF2980B9);

  // Utility
  static const Color divider = Color(0xFFE0E8EF);
  static const Color shimmer1 = Color(0xFFECEFF1);
  static const Color shimmer2 = Color(0xFFF5F7F8);
}

// ── Gradients ───────────────────────────────────────────────────────────────
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryVertical = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFE8A923), Color(0xFFF5C842)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient surface = LinearGradient(
    colors: [AppColors.surface, AppColors.surfaceAlt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ── Shadows ─────────────────────────────────────────────────────────────────
class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF02A29A).withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: const Color(0xFF02A29A).withValues(alpha: 0.40),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

// ── Typography ───────────────────────────────────────────────────────────────
class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headingLarge => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingMedium => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSmall => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.lato(
        fontSize: 16,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.lato(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.lato(
        fontSize: 12,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get caption => GoogleFonts.lato(
        fontSize: 11,
        color: AppColors.textSecondary,
      );
}

// ── Decorations ──────────────────────────────────────────────────────────────
class AppDecorations {
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      );

  static BoxDecoration get cardFlat => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      );

  static BoxDecoration get gradientPrimary => const BoxDecoration(
        gradient: AppGradients.primary,
      );

  static BoxDecoration get chip => BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      );

  static BoxDecoration get accentChip => BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(100),
      );

  static InputDecoration inputDecoration(String label, {IconData? icon}) =>
      InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.primary, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      );
}

// ── Reusable Widgets ─────────────────────────────────────────────────────────

/// Full-width gradient primary button with optional loading state
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: onTap != null
              ? const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFAAD7D5), Color(0xFFAAD7D5)],
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: onTap != null ? AppShadows.button : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: AppTextStyles.button),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Star rating row
class AppRatingBar extends StatelessWidget {
  final double rating;
  final double size;
  const AppRatingBar({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star_rounded, color: AppColors.accent, size: size);
        } else if (i < rating) {
          return Icon(Icons.star_half_rounded,
              color: AppColors.accent, size: size);
        } else {
          return Icon(Icons.star_outline_rounded,
              color: AppColors.accent, size: size);
        }
      }),
    );
  }
}

/// Pill-shaped tag chip
class AppChip extends StatelessWidget {
  final String label;
  final bool accent;
  const AppChip({super.key, required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: accent ? AppDecorations.accentChip : AppDecorations.chip,
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: accent ? const Color(0xFF7D5A00) : AppColors.primaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Gradient AppBar decoration helper
BoxDecoration appBarGradient() => const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primaryDark, AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
