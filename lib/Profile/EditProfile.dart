import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  late UserProvider userProvider;
  File? _profileImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final up = Provider.of<UserProvider>(context, listen: false);
      nameController.text = up.username;
      phoneController.text = up.phone;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _profileImage = File(image.path));
  }

  Future<void> _takePhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _profileImage = File(image.path));
  }

  Future<String?> _uploadProfilePhoto(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${DateTime.now().toIso8601String()}.jpg');
      final snap = await ref.putFile(file).whenComplete(() => null);
      return await snap.ref.getDownloadURL();
    } catch (e) {
      // ignore: avoid_print
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> _updateProfile(
      String name, String phone, String? photoUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'username': name,
        'phone': phone,
        'profilephoto': photoUrl ?? userProvider.profilephoto,
      });
      userProvider.username = name;
      userProvider.phone = phone;
      userProvider.profilephoto = photoUrl ?? userProvider.profilephoto;
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Update error: $e');
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    if (_profileImage != null) {
      final url = await _uploadProfilePhoto(_profileImage!);
      await _updateProfile(nameController.text, phoneController.text, url);
    } else {
      await _updateProfile(
        nameController.text,
        phoneController.text,
        userProvider.profilephoto,
      );
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ───────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text('Edit Profil',
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
                  // ── Avatar picker ─────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                      color: AppColors.divider,
                                      borderRadius:
                                          BorderRadius.circular(100))),
                              const SizedBox(height: 12),
                              ListTile(
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      color: AppColors.primary, size: 20),
                                ),
                                title: Text('Ambil Foto',
                                    style: AppTextStyles.bodyLarge),
                                onTap: () {
                                  Navigator.pop(context);
                                  _takePhoto();
                                },
                              ),
                              ListTile(
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.accent.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.image_rounded,
                                      color: AppColors.accent, size: 20),
                                ),
                                title: Text('Pilih dari Galeri',
                                    style: AppTextStyles.bodyLarge),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.accent,
                                  AppColors.primaryLight
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: AppColors.surfaceAlt,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : (userProvider.profilephoto != null &&
                                          userProvider.profilephoto!.isNotEmpty)
                                      ? NetworkImage(userProvider.profilephoto!)
                                          as ImageProvider
                                      : null,
                              child: (_profileImage == null &&
                                      (userProvider.profilephoto == null ||
                                          userProvider.profilephoto!.isEmpty))
                                  ? const Icon(Icons.person,
                                      size: 52, color: AppColors.primary)
                                  : null,
                            ),
                          ),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              gradient: AppGradients.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Center(
                    child: Text('Ketuk foto untuk mengubah',
                        style: AppTextStyles.caption),
                  ),
                  const SizedBox(height: 32),

                  // ── Fields ───────────────────────────────────
                  Text('Informasi Akun',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 10),

                  TextField(
                    controller: nameController,
                    decoration: AppDecorations.inputDecoration('Nama Pengguna',
                        icon: Icons.person_outline),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: AppDecorations.inputDecoration('Nomor HP',
                        icon: Icons.phone_outlined),
                  ),
                  const SizedBox(height: 32),

                  // ── Save btn ──────────────────────────────────
                  AppPrimaryButton(
                    label: 'Simpan Perubahan',
                    icon: Icons.save_rounded,
                    isLoading: _isSaving,
                    onTap: _saveProfile,
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
