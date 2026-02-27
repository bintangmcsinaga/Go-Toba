import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_toba/Features/Vacations/VacationsDetail.dart';
import 'package:go_toba/Features/Vacations/VacationsModel.dart';
import 'package:go_toba/style.dart'; // Import style.dart

class DestinationRecommendationPage extends StatefulWidget {
  final String userId;

  const DestinationRecommendationPage({super.key, required this.userId});

  @override
  _DestinationRecommendationPageState createState() =>
      _DestinationRecommendationPageState();
}

class _DestinationRecommendationPageState
    extends State<DestinationRecommendationPage> {
  List<Destination> recommendedDestinations = [];
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    fetchDestinations();
  }

  Future<List<Destination>> fetchRecommendedDestination(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> userTags = await getDestinationTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('destinations')
        .where('tags', arrayContainsAny: userTags)
        .get();

    List<Destination> recommendedDestination = [];
    for (var doc in snapshot.docs) {
      recommendedDestination.add(Destination.fromDocSnapshot(doc));
    }
    return recommendedDestination;
  }

  Future<List<String>> getDestinationTags(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await db.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      List<String> userTags =
          List<String>.from(userSnapshot.get('vacationtags') ?? []);
      return userTags;
    } else {
      return [];
    }
  }

  Future<void> fetchDestinations() async {
    setState(() {
      isFetching = true;
    });

    try {
      List<Destination> destinations =
          await fetchRecommendedDestination(widget.userId);
      if (mounted) {
        setState(() {
          recommendedDestinations = destinations;
        });
      }
    } catch (e) {
      debugPrint('Error fetching destinations: $e');
    } finally {
      if (mounted) {
        setState(() {
          isFetching = false;
        });
      }
    }
  }

  // Efek Loading Modern (Skeleton)
  Widget _buildSkeletonLoader() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        return Container(
          height: 240,
          decoration: BoxDecoration(
            color: AppColors.shimmer1,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.shimmer2,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium AppBar ─────────────────────────────────────
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Destination Recommendations',
                style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.primaryVertical,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -10,
                      child: Icon(Icons.landscape_rounded, 
                          size: 100, 
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── List Destinasi ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: isFetching
                ? SliverToBoxAdapter(child: _buildSkeletonLoader())
                : recommendedDestinations.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.landscape_rounded, size: 80, color: AppColors.divider),
                              const SizedBox(height: 16),
                              Text('No Recommendations Yet', style: AppTextStyles.headingSmall),
                              const SizedBox(height: 8),
                              Text(
                                'Explore more destinations so we can recommend places that fit you better.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final destination = recommendedDestinations[index];
                            
                            // Animasi Staggered
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 600)),
                              tween: Tween<double>(begin: 0, end: 1),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _DestinationCard(destination: destination),
                              ),
                            );
                          },
                          childCount: recommendedDestinations.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Widget Khusus Kartu Destinasi ─────────────────────────────────────────
class _DestinationCard extends StatelessWidget {
  final Destination destination;

  const _DestinationCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetailPage(destination: destination),
          ),
        );
      },
      child: Container(
        height: 240, // Tinggi konsisten yang proporsional
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.card,
          color: AppColors.surface,
        ),
        child: Stack(
          children: [
            // Gambar Background Full Bleed
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                destination.imageUrl,
                width: double.infinity,
                height: double.infinity,
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

            // Gradient Overlay (Gelap di bawah agar teks terbaca jelas)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0], // Transparan di atas, pekat di bawah
                ),
              ),
            ),

            // Teks Informasi (Nama, Lokasi, Rating, Arrow)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination.name,
                          style: AppTextStyles.headingMedium.copyWith(color: Colors.white, height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.primaryLight, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                destination.location, // Properti lokasi dari model
                                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Rating & Arrow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppRatingBar(rating: destination.rating.toDouble(), size: 16),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
