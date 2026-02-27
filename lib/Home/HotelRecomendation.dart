import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_toba/Features/Hotels/HotelDetail.dart';
import 'package:go_toba/Features/Hotels/HotelModel.dart';
import 'package:go_toba/style.dart';

class HotelRecommendationListPage extends StatefulWidget {
  final String userId;

  const HotelRecommendationListPage({super.key, required this.userId});

  @override
  _HotelRecommendationListPageState createState() =>
      _HotelRecommendationListPageState();
}

class _HotelRecommendationListPageState
    extends State<HotelRecommendationListPage> {
  final TextEditingController searchController = TextEditingController();
  bool isFetching = true;
  List<Hotel> allHotels = [];

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<Hotel>> fetchAllRecommendedHotels(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> userTags = await getHotelTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('hotels')
        .where('tags', arrayContainsAny: userTags)
        .get();

    List<Hotel> recommendedHotels = [];
    for (var doc in snapshot.docs) {
      recommendedHotels.add(Hotel.fromDocSnapshot(doc));
    }
    return recommendedHotels;
  }

  Future<List<String>> getHotelTags(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await db.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      List<String> userTags =
          List<String>.from(userSnapshot.get('hoteltags') ?? []);
      return userTags;
    } else {
      return [];
    }
  }

  Future<void> fetchHotels() async {
    setState(() {
      isFetching = true;
    });

    List<Hotel> hotels = await fetchAllRecommendedHotels(widget.userId);

    if (mounted) {
      setState(() {
        allHotels = hotels;
        isFetching = false;
      });
    }
  }

  List<Hotel> filteredHotels(String query) {
    if (query.isEmpty) {
      return allHotels;
    } else {
      return allHotels
          .where(
              (hotel) => hotel.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // --- Widget Skeleton Loading ---
  Widget _buildSkeletonGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.shimmer1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.shimmer2,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: double.infinity, color: AppColors.shimmer2),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 60, color: AppColors.shimmer2),
                      const SizedBox(height: 12),
                      Container(height: 16, width: 100, color: AppColors.shimmer2),
                    ],
                  ),
                )
              ],
            ),
          );
        },
        childCount: 6, // Tampilkan 6 kotak abu-abu sbg placeholder
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    
    final displayedHotels = filteredHotels(searchController.text);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Rekomendasi Hotel',
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
                      child: Icon(Icons.apartment_rounded, 
                          size: 100, 
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search Bar ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.soft,
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {}); // Picu rebuild untuk filter
                  },
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Cari nama hotel...',
                    hintStyle: AppTextStyles.bodyMedium,
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),
          ),

          // ── Grid Content ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: isFetching
                ? _buildSkeletonGrid()
                : displayedHotels.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 80, color: AppColors.divider),
                              const SizedBox(height: 16),
                              Text('Hotel Tidak Ditemukan', style: AppTextStyles.headingSmall),
                              const SizedBox(height: 8),
                              Text('Coba gunakan kata kunci pencarian yang lain.',
                                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75, // Mengatur proporsi kartu agar lebih lega
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final hotel = displayedHotels[index];
                            
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
                              child: _HotelCard(hotel: hotel, formatter: currencyFormatter),
                            );
                          },
                          childCount: displayedHotels.length,
                        ),
                      ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)), // Spasi bawah
        ],
      ),
    );
  }
}

// ── Widget Khusus Kartu Hotel ─────────────────────────────────────────
class _HotelCard extends StatelessWidget {
  final Hotel hotel;
  final NumberFormat formatter;

  const _HotelCard({required this.hotel, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailPage(hotel: hotel),
          ),
        );
      },
      child: Container(
        decoration: AppDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Hotel
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  hotel.imageUrls.isNotEmpty ? hotel.imageUrls[0] : hotel.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: AppColors.shimmer1);
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.shimmer2,
                    child: const Icon(Icons.broken_image_rounded, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            
            // Detail Info Hotel
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headingSmall.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  
                  // Rating Bar
                  AppRatingBar(rating: hotel.rating.toDouble(), size: 14),
                  
                  const SizedBox(height: 12),
                  
                  // Harga
                  Text(
                    formatter.format(hotel.price),
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
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