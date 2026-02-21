import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:go_toba/Features/Moments/StoryList.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';

class Story extends StatefulWidget {
  const Story({super.key});

  @override
  _StoryState createState() => _StoryState();
}

class _StoryState extends State<Story> {
  final TextEditingController captionController = TextEditingController();
  List<File> images = [];
  bool uploading = false;

  Future<void> uploadStory(BuildContext context) async {
    DateTime now = DateTime.now();
    String caption = captionController.text;
    final user = Provider.of<UserProvider>(context, listen: false);

    if (caption.isEmpty && images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least fill the caption')),
      );
      return;
    }

    List<String> imageUrls = [];
    var uuid = const Uuid();

    try {
      setState(() {
        uploading = true;
      });

      for (File image in images) {
        String fileName = '${uuid.v4()}.jpg';
        Reference storageReference =
            FirebaseStorage.instance.ref().child('stories/$fileName');
        UploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.whenComplete(() => null);
        String imageUrl = await storageReference.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      await FirebaseFirestore.instance.collection('stories').add({
        'uid': user.uid,
        'date': now,
        'caption': caption,
        'images': imageUrls,
        'likes': [],
      });

      setState(() {
        captionController.clear();
        images.clear();
        uploading = false;
      });
    } catch (e) {
      print('Error uploading story: $e');
      setState(() {
        uploading = false;
      });
    }
  }

  Future<void> pickImages(ImageSource source) async {
    if (await _requestPermission(source)) {
      if (source == ImageSource.gallery) {
        final pickedFiles = await ImagePicker().pickMultiImage();
        setState(() {
          images =
              pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
        });
      } else if (source == ImageSource.camera) {
        final pickedFile = await ImagePicker().pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            images.add(File(pickedFile.path));
          });
        }
      }
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    Permission permission;
    if (source == ImageSource.gallery) {
      permission = Permission.storage;
    } else {
      permission = Permission.camera;
    }
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: color1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(decoration: appBarGradient()),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Moments',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: AppDecorations.card,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.surfaceAlt,
                        backgroundImage: (userProvider.profilephoto ?? '').isNotEmpty
                            ? NetworkImage(userProvider.profilephoto!)
                            : null,
                        child: (userProvider.profilephoto ?? '').isEmpty
                            ? const Icon(Icons.person, color: AppColors.textSecondary)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: captionController,
                          maxLines: 5,
                          minLines: 3,
                          style: AppTextStyles.bodyLarge,
                          decoration: AppDecorations.inputDecoration(
                            'Tell us your vacation...',
                            icon: Icons.edit_note_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => pickImages(ImageSource.gallery),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        icon: const Icon(Icons.collections_outlined, size: 20),
                        label: const Text('Gallery'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => pickImages(ImageSource.camera),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        icon: const Icon(Icons.photo_camera_outlined, size: 20),
                        label: const Text('Camera'),
                      ),
                    ],
                  ),
                  if (images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 92,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  images[index],
                                  width: 92,
                                  height: 92,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      images.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.45),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  AppPrimaryButton(
                    label: 'Share Story',
                    isLoading: uploading,
                    icon: Icons.send_rounded,
                    onTap: uploading ? null : () => uploadStory(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Latest Moments', style: AppTextStyles.headingSmall),
            const SizedBox(height: 6),
            const StoryList(),
          ],
        ),
      ),
    );
  }
}
