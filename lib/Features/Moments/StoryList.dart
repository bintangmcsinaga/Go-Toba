import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Features/Moments/FullScreenImageView.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryList extends StatelessWidget {
  const StoryList({super.key});

  String formatTimestamp(Timestamp timestamp) {
    DateTime now = DateTime.now();
    DateTime date = timestamp.toDate();
    Duration difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours < 48) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  Future<void> toggleLike(BuildContext context, DocumentSnapshot story) async {
    final userId = context.read<UserProvider>().uid;
    List likes = List.from(story['likes'] ?? []);

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    try {
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(story.id)
          .update({'likes': likes});
    } catch (e) {
      print("Error updating likes: $e");
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> shareStory(BuildContext context, String caption,
      List<String> imageUrls, String username) async {
    try {
      List<XFile> imageFiles = [];
      for (String url in imageUrls) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/${url.split('/').last}');
          await file.writeAsBytes(response.bodyBytes);
          imageFiles.add(XFile(file.path));
        } else {
          Fluttertoast.showToast(
            msg: "Failed to download image: $url",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
          return;
        }
      }

      await Share.shareXFiles(
        imageFiles,
        text: 'Check out this story by $username: $caption',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to share story: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var stories = snapshot.data!.docs;
        if (stories.isEmpty) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.cardFlat,
            child: Text(
              'Belum ada story. Jadi yang pertama share momenmu.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            var story = stories[index];
            List imageUrls = story['images'];
            List likes = story['likes'] ?? [];
            final userId = context.read<UserProvider>().uid;
            bool isLiked = likes.contains(userId);

            final uid = story['uid'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: getUserData(uid),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                String username = userData['username'] ?? 'Unknown';
                String profilePictureUrl = userData['profilephoto'] ?? '';

                return Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  decoration: AppDecorations.card,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.surfaceAlt,
                            backgroundImage: profilePictureUrl.isNotEmpty
                                ? NetworkImage(profilePictureUrl)
                                : null,
                            child: profilePictureUrl.isEmpty
                                ? const Icon(Icons.person, size: 20)
                                : null,
                          ),
                          title: Text(username, style: AppTextStyles.headingSmall),
                          subtitle: Text(
                            formatTimestamp(story['date']),
                            style: AppTextStyles.caption,
                          ),
                          contentPadding: EdgeInsets.zero,
                          horizontalTitleGap: 10,
                        ),
                        if ((story['caption'] ?? '').toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(story['caption'], style: AppTextStyles.bodyLarge),
                          ),
                        if (imageUrls.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: imageUrls.length > 6 ? 6 : imageUrls.length,
                            itemBuilder: (context, imageIndex) {
                              String url = imageUrls[imageIndex];
                              final hiddenCount = imageUrls.length - 6;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImageView(
                                        imageUrls: imageUrls.cast<String>(),
                                        initialIndex: imageIndex,
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: AppColors.surfaceAlt,
                                          child: const Icon(
                                            Icons.broken_image_outlined,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      if (imageIndex == 5 && hiddenCount > 0)
                                        Container(
                                          color: Colors.black.withValues(alpha: 0.45),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '+$hiddenCount',
                                            style: AppTextStyles.headingMedium.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? AppColors.error : AppColors.textSecondary,
                              ),
                              onPressed: () {
                                print(
                                    'Toggling like for story ID: ${story.id}');
                                toggleLike(context, story);
                              },
                            ),
                            Text('${likes.length} likes', style: AppTextStyles.bodyMedium),
                            const SizedBox(width: 16.0),
                            IconButton(
                              icon: const Icon(Icons.share_outlined),
                              onPressed: () {
                                shareStory(context, story['caption'],
                                    imageUrls.cast<String>(), username);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
