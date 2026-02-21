import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_toba/Login&Register/login.dart';
import 'package:go_toba/Profile/ChangePassword.dart';
import 'package:go_toba/Profile/EditProfile.dart';
import 'package:go_toba/Providers/NavBarProv.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/Utils/DatabaseSeeder.dart';
import 'package:go_toba/style.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    context.read<NavBarProv>().logout();
    await prefs.setBool("login", false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──────────────────────────────────────────
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
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar with gradient ring
                      Container(
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
                              color:
                                  AppColors.primaryDark.withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 46,
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
                        user.username.isEmpty ? 'Pengguna' : user.username,
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
                  const _SectionLabel('Akun'),
                  const SizedBox(height: 8),
                  _ProfileSection(tiles: [
                    _ProfileTile(
                      icon: Icons.edit_outlined,
                      color: AppColors.primary,
                      label: 'Edit Profil',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()),
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.lock_outline_rounded,
                      color: AppColors.primaryDark,
                      label: 'Ubah Password',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const Changepassword()),
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.language_rounded,
                      color: AppColors.info,
                      label: 'Bahasa',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 20),
                  const _SectionLabel('Informasi'),
                  const SizedBox(height: 8),
                  _ProfileSection(tiles: [
                    _ProfileTile(
                      icon: Icons.description_outlined,
                      color: AppColors.accent,
                      label: 'Syarat & Ketentuan',
                      onTap: () {},
                    ),
                    _ProfileTile(
                      icon: Icons.privacy_tip_outlined,
                      color: const Color(0xFF8E44AD),
                      label: 'Kebijakan Privasi',
                      onTap: () {},
                    ),
                    _ProfileTile(
                      icon: Icons.support_agent_rounded,
                      color: AppColors.success,
                      label: 'Layanan Pelanggan',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 20),
                  const _SectionLabel('Developer'),
                  const SizedBox(height: 8),
                  _ProfileSection(tiles: [
                    _ProfileTile(
                      icon: Icons.storage_rounded,
                      color: Colors.orange,
                      label: 'Seed Database',
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
                      label: 'Keluar',
                      textColor: AppColors.error,
                      onTap: _logout,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  Center(
                    child: Text('Beta V1.0',
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
