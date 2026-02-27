import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_toba/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_toba/Login&Register/login.dart';
import 'package:go_toba/Profile/ChangePassword.dart';
import 'package:go_toba/Profile/EditProfile.dart';
import 'package:go_toba/Providers/LocaleProv.dart';
import 'package:go_toba/Providers/NavBarProv.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/Utils/DatabaseSeeder.dart';
import 'package:go_toba/style.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cloudController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  // Function to execute actual logout
  void _executeLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    
    if (!mounted) return;
    context.read<NavBarProv>().logout();
    await prefs.setBool("login", false);
    
    if (!mounted) return;
    // Using pushAndRemoveUntil so user cannot go back to profile page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false, 
    );
  }

  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    final currentCode = localeProvider.locale.languageCode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.chooseLanguage, style: AppTextStyles.headingMedium),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l10n.english),
                  trailing: currentCode == 'en'
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    await localeProvider.setLocale(const Locale('en'));
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l10n.indonesian),
                  trailing: currentCode == 'id'
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    await localeProvider.setLocale(const Locale('id'));
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to show confirmation pop-up
  void _confirmLogout() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.surface,
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.signOutTitle,
                style: AppTextStyles.headingMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            l10n.signOutConfirm,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(), // Tutup pop-up
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup pop-up dulu
                      _executeLogout(); // Baru eksekusi logout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.signOut,
                      style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.primaryVertical,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _cloudController,
                        builder: (context, _) => _MovingCloudLayer(
                          progress: _cloudController.value,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.accent, AppColors.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(alpha: 0.5),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.surfaceAlt,
                              backgroundImage: (user.profilephoto != null &&
                                      user.profilephoto!.isNotEmpty)
                                  ? NetworkImage(user.profilephoto!)
                                  : null,
                              child: (user.profilephoto == null ||
                                      user.profilephoto!.isEmpty)
                                  ? const Icon(Icons.person,
                                      size: 46, color: AppColors.primary)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.username.isEmpty ? l10n.user : user.username,
                            style: AppTextStyles.headingMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70),
                          ),
                          if (user.phone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              user.phone,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: Colors.white60),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Settings list ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(l10n.account),
                  const SizedBox(height: 8),
                  _ProfileSection(tiles: [
                    _ProfileTile(
                      icon: Icons.edit_outlined,
                      color: AppColors.primary,
                      label: l10n.editProfile,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()),
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.lock_outline_rounded,
                      color: AppColors.primaryDark,
                      label: l10n.changePassword,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const Changepassword()),
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.language_rounded,
                      color: AppColors.info,
                      label: l10n.language,
                      onTap: _showLanguagePicker,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _SectionLabel(l10n.information),
                  const SizedBox(height: 8),
                  _ProfileSection(tiles: [
                    _ProfileTile(
                      icon: Icons.description_outlined,
                      color: AppColors.accent,
                      label: l10n.terms,
                      onTap: () {},
                    ),
                    _ProfileTile(
                      icon: Icons.privacy_tip_outlined,
                      color: const Color(0xFF8E44AD),
                      label: l10n.privacy,
                      onTap: () {},
                    ),
                    _ProfileTile(
                      icon: Icons.support_agent_rounded,
                      color: AppColors.success,
                      label: l10n.customer,
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _SectionLabel(l10n.developer),
                  const SizedBox(height: 8),
                  _ProfileSection(tiles: [
                    _ProfileTile(
                      icon: Icons.storage_rounded,
                      color: Colors.orange,
                      label: l10n.seed,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DatabaseSeederPage()),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _ProfileSection(tiles: [
                    _ProfileTile(
                      icon: Icons.logout_rounded,
                      color: AppColors.error,
                      label: l10n.signOut,
                      textColor: AppColors.error,
                      onTap: _confirmLogout, // Calls confirmation pop-up
                    ),
                  ]),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(l10n.beta,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
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

// ── Helper Widgets ─────────────────────────────────────────────────────────

class _MovingCloudLayer extends StatelessWidget {
  final double progress;
  const _MovingCloudLayer({required this.progress});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              _buildCloud(
                width: width,
                top: 34,
                size: 76,
                speed: 1.0,
                startFraction: 0.08,
                opacity: 0.24,
              ),
              _buildCloud(
                width: width,
                top: 72,
                size: 58,
                speed: 0.7,
                startFraction: 0.52,
                opacity: 0.18,
              ),
              _buildCloud(
                width: width,
                top: 110,
                size: 88,
                speed: 1.15,
                startFraction: 0.78,
                opacity: 0.20,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCloud({
    required double width,
    required double top,
    required double size,
    required double speed,
    required double startFraction,
    required double opacity,
  }) {
    final travel = width + (size * 2);
    final current = ((progress * speed) + startFraction) % 1.0;
    final dx = (current * travel) - size;
    final bob = math.sin((progress + startFraction) * 2 * math.pi) * 2.0;

    return Positioned(
      top: top + bob,
      left: dx,
      child: Icon(
        Icons.cloud_rounded,
        size: size,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final List<_ProfileTile> tiles;
  const _ProfileSection({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final i = entry.key;
          final tile = entry.value;
          return Column(
            children: [
              tile,
              if (i < tiles.length - 1)
                const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                    indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  const _ProfileTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 15,
                  color: textColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
