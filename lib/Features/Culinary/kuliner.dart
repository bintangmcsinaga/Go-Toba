import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart'; // Import style.dart kamu
import 'KulinerModel.dart';
import 'KulinerDetail.dart';

class KulinerWidget extends StatefulWidget {
  const KulinerWidget({super.key});

  @override
  State<KulinerWidget> createState() => _KulinerWidgetState();
}

class _KulinerWidgetState extends State<KulinerWidget> {
  List<KulinerModel> kuliner = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> updateUserTags(String userId, List<String> newTags) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference userDoc = db.collection('users').doc(userId);

    DocumentSnapshot userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      List<String> existingTags =
          List<String>.from(userSnapshot.get('culinarytags') ?? []);

      for (String tag in newTags) {
        if (!existingTags.contains(tag)) {
          if (existingTags.length >= 5) {
            existingTags.removeAt(0);
          }
          existingTags.add(tag);
        }
      }

      await userDoc
          .set({'culinarytags': existingTags}, SetOptions(merge: true));
    } else {
      List<String> uniqueNewTags = newTags.toSet().toList();
      List<String> initialTags = uniqueNewTags.length > 5
          ? uniqueNewTags.sublist(0, 5)
          : uniqueNewTags;
      await userDoc.set({'culinarytags': initialTags});
    }
  }

  Future<void> readData() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var data = await db.collection('kuliner').get();
    
    if (mounted) {
      setState(() {
        kuliner =
            data.docs.map((doc) => KulinerModel.fromDocSnapshot(doc)).toList();
        isLoading = false;
      });
    }
  }

  // Efek Loading Modern (Skeleton)
  Widget _buildSkeletonLoader() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.shimmer1,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.shimmer2,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 16, width: double.infinity, color: AppColors.shimmer2),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 100, color: AppColors.shimmer2),
                    const SizedBox(height: 16),
                    Container(height: 20, width: 80, color: AppColors.shimmer2),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().uid;
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background, // Menggunakan background style.dart
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(decoration: appBarGradient()), // Header premium
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'Signature Culinary',
          style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
        ),
      ),
      body: isLoading
          ? _buildSkeletonLoader()
          : kuliner.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu_rounded, size: 80, color: AppColors.divider),
                      const SizedBox(height: 16),
                      Text('No culinary data available yet', style: AppTextStyles.bodyLarge),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: kuliner.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = kuliner[index];
                    
                    // Animasi Staggered Slide-Up & Fade-In
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
                      tween: Tween<double>(begin: 0, end: 1),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          if (userId != null) {
                            updateUserTags(userId, item.tags);
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KulinerDetail(kuliner: item),
                            ),
                          );
                        },
                        child: Container(
                          height: 130,
                          decoration: AppDecorations.card, // Card premium
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Gambar Kuliner
                              Hero(
                                tag: item.imageUrl, // Animasi transisi gambar
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 106,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 106,
                                        color: AppColors.shimmer1,
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 106,
                                        color: AppColors.shimmer2,
                                        child: const Icon(Icons.broken_image_rounded, color: AppColors.textSecondary),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Detail Kuliner
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.name,
                                      style: AppTextStyles.headingSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    
                                    // Widget Rating dari style.dart
                                    AppRatingBar(rating: item.rating.toDouble(), size: 16),
                                    
                                    const Spacer(),
                                    
                                    // Harga & Tag
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          currencyFormatter.format(item.price),
                                          style: AppTextStyles.headingMedium.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        // Menampilkan tag pertama jika ada
                                        if (item.tags.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentLight,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.tags.first.toUpperCase(),
                                              style: AppTextStyles.caption.copyWith(
                                                color: const Color(0xFF7D5A00),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
