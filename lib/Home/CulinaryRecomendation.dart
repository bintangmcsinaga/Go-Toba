import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_toba/Features/Culinary/KulinerDetail.dart';
import 'package:go_toba/Features/Culinary/KulinerModel.dart';
import 'package:go_toba/l10n/l10n.dart';
import 'package:go_toba/style.dart'; 

class CulinaryRecommendationPage extends StatefulWidget {
  final String userId;

  const CulinaryRecommendationPage({super.key, required this.userId});

  @override
  _CulinaryRecommendationPageState createState() =>
      _CulinaryRecommendationPageState();
}

class _CulinaryRecommendationPageState
    extends State<CulinaryRecommendationPage> {
  List<KulinerModel> recommendedCulinaries = [];
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    fetchCulinaries();
  }

  Future<List<KulinerModel>> fetchRecommendedCulinary(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> userTags = await getCulinaryTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('kuliner')
        .where('tags', arrayContainsAny: userTags)
        .get();

    List<KulinerModel> recommendedCulinary = [];
    for (var doc in snapshot.docs) {
      recommendedCulinary.add(KulinerModel.fromDocSnapshot(doc));
    }
    return recommendedCulinary;
  }

  Future<List<String>> getCulinaryTags(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await db.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      List<String> userTags =
          List<String>.from(userSnapshot.get('culinarytags') ?? []);
      return userTags;
    } else {
      return [];
    }
  }

  Future<void> fetchCulinaries() async {
    setState(() {
      isFetching = true;
    });

    try {
      List<KulinerModel> culinaires =
          await fetchRecommendedCulinary(widget.userId);
      if (mounted) {
        setState(() {
          recommendedCulinaries = culinaires;
        });
      }
    } catch (e) {
      debugPrint('Error fetching culinaires: $e');
    } finally {
      if (mounted) {
        setState(() {
          isFetching = false;
        });
      }
    }
  }

  // Efek Loading Skeleton
  Widget _buildSkeletonLoader() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
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
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

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
                context.l10n.culinaryRecommendations,
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
                      child: Icon(Icons.restaurant_menu_rounded, 
                          size: 100, 
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── List Kuliner ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: isFetching
                ? SliverToBoxAdapter(child: _buildSkeletonLoader())
                : recommendedCulinaries.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_rounded, size: 80, color: AppColors.divider),
                              const SizedBox(height: 16),
                              Text(context.l10n.noRecommendationsYetTitle, style: AppTextStyles.headingSmall),
                              const SizedBox(height: 8),
                              Text(
                                context.l10n.exploreMoreCulinary,
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
                            final culinary = recommendedCulinaries[index];
                            
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
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _CulinaryCard(
                                  culinary: culinary,
                                  formatter: currencyFormatter,
                                ),
                              ),
                            );
                          },
                          childCount: recommendedCulinaries.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Widget Khusus Kartu Kuliner ─────────────────────────────────────────
class _CulinaryCard extends StatelessWidget {
  final KulinerModel culinary;
  final NumberFormat formatter;

  const _CulinaryCard({required this.culinary, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KulinerDetail(kuliner: culinary),
          ),
        );
      },
      child: Container(
        height: 130, 
        decoration: AppDecorations.card,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Gambar Kuliner
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                culinary.imageUrl,
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
            const SizedBox(width: 16),
            
            // Detail Informasi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    culinary.name,
                    style: AppTextStyles.headingSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Rating Bar
                  AppRatingBar(rating: culinary.rating.toDouble(), size: 16),
                  
                  const Spacer(),
                  
                  // Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatter.format(culinary.price),
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      
                      // Label Tag Pertama (jika ada)
                      if (culinary.tags.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            culinary.tags.first.toUpperCase(),
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
    );
  }
}
