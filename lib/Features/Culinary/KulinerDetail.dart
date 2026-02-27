import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_toba/style.dart'; // Menggunakan design system kamu
import 'package:url_launcher/url_launcher_string.dart';
import 'KulinerModel.dart';
import 'KulinerPayment.dart';
import 'kulinerReview.dart';

class KulinerDetail extends StatelessWidget {
  final KulinerModel kuliner;

  const KulinerDetail({super.key, required this.kuliner});

  Stream<List<Review>> _reviewsStream(String kulinerId) {
    return FirebaseFirestore.instance
        .collection('kuliner')
        .doc(kulinerId)
        .collection('reviews')
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  Future<DocumentSnapshot> _getUserSnapshot(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  void _openGoogleMaps(BuildContext context) async {
    final url = kuliner.gmaps;
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the map link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HEADER: PARALLAX IMAGE ──────────────────────────────
          SliverAppBar(
            expandedHeight: size.height * 0.30,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: kuliner.imageUrl, 
                    child: Image.network(
                      kuliner.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(color: AppColors.shimmer1);
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.shimmer2,
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, size: 50, color: AppColors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                  // Gradasi gelap di atas untuk tombol Back
                  Positioned(
                    top: 0, left: 0, right: 0, height: 120,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Gradasi gelap di bawah agar teks di card menonjol
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: 80,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black45, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── KONTEN DETAIL ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── KARTU INFO UTAMA ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Transform.translate(
                        offset: const Offset(0, -20),
                        child: Container(
                          margin: const EdgeInsets.only(top:80),
                          padding: const EdgeInsets.all(24),
                          decoration: AppDecorations.card,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      kuliner.name,
                                      style: AppTextStyles.headingLarge.copyWith(height: 1.2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          kuliner.rating.toString(),
                                          style: AppTextStyles.label.copyWith(color: const Color(0xFF7D5A00), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    currencyFormatter.format(kuliner.price),
                                    style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
                                  ),
                                  if (kuliner.tags.isNotEmpty)
                                    AppChip(label: kuliner.tags.first.toUpperCase()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── KONTEN DENGAN ANIMASI FADE-SLIDE ──
                    _FadeInSlide(
                      delay: 100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tombol Maps
                            GestureDetector(
                              onTap: () => _openGoogleMaps(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.divider),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.map_rounded, color: Colors.green, size: 24),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Open in Google Maps",
                                      style: AppTextStyles.label.copyWith(color: AppColors.textPrimary, fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Deskripsi
                            Text('Description', style: AppTextStyles.headingMedium),
                            const SizedBox(height: 12),
                            Text(
                              kuliner.deskripsi,
                              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Divider(color: AppColors.divider),
                            ),
                            
                            // Review Section Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Latest Reviews', style: AppTextStyles.headingMedium),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => KulinerReview(kulinerId: kuliner.id),
                                      ),
                                    );
                                  },
                                  child: Text('See All', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── DAFTAR REVIEW (Horizontal Scroll) ──
                    _FadeInSlide(
                      delay: 200,
                      child: StreamBuilder<List<Review>>(
                        stream: _reviewsStream(kuliner.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Failed to load reviews', style: AppTextStyles.bodyMedium));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: AppColors.shimmer2, borderRadius: BorderRadius.circular(12)),
                              child: Center(child: Text('No reviews yet.', style: AppTextStyles.bodyMedium)),
                            );
                          }

                          List<Review> latestReviews = snapshot.data!.take(5).toList();

                          return SizedBox(
                            height: 160,
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: latestReviews.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                return _buildReviewCard(latestReviews[index]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 60), // Spasi aman bawah
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      
      // ── STICKY BOTTOM BAR ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16).copyWith(
          bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 8 : 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: AppPrimaryButton(
          label: 'Continue to Payment',
          icon: Icons.shopping_bag_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KulinerPayment(kuliner: kuliner),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN REVIEW CARD ---
  Widget _buildReviewCard(Review review) {
    return FutureBuilder<DocumentSnapshot>(
      future: _getUserSnapshot(review.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 280,
            decoration: AppDecorations.cardFlat,
            child: const Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
          );
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final profilePicUrl = userData['profilephoto'] ?? '';
        final username = userData['username'] ?? 'Traveler';

        return Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.cardFlat.copyWith(boxShadow: AppShadows.soft),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.shimmer1,
                    backgroundImage: profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
                    child: profilePicUrl.isEmpty ? const Icon(Icons.person, color: AppColors.textSecondary) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: AppTextStyles.headingSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(review.tanggal),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  AppRatingBar(rating: review.rating.toDouble(), size: 14),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  review.deskripsi,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- ANIMATION HELPER WIDGET ---
class _FadeInSlide extends StatelessWidget {
  final Widget child;
  final int delay;

  const _FadeInSlide({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        final start = delay / 1000.0;
        final adjustedValue = (value - start).clamp(0.0, 1.0) / (1.0 - start);
        
        return Opacity(
          opacity: adjustedValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - adjustedValue)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}
