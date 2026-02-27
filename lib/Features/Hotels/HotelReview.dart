import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_toba/Features/Culinary/KulinerModel.dart';
import 'package:go_toba/style.dart'; // Import style.dart kamu

class HotelReview extends StatefulWidget {
  final String hotelId;

  const HotelReview({super.key, required this.hotelId});

  @override
  State<HotelReview> createState() => _HotelReviewState();
}

class _HotelReviewState extends State<HotelReview> {
  String? _selectedFilter;

  Stream<List<Review>> _reviewsStream(String filter) {
    Query query = FirebaseFirestore.instance
        .collection('hotels')
        .doc(widget.hotelId)
        .collection('reviews');

    if (filter == 'Latest' || filter.isEmpty) {
      query = query.orderBy('tanggal', descending: true);
    } else {
      // Filter berdasarkan rating
      int rating = int.parse(filter);
      query = query.where('rating', isEqualTo: rating);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Review.fromFirestore(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  Stream<Map<String, dynamic>> _userStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Menggunakan warna latar dari style.dart
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: appBarGradient(), // Menggunakan gradasi dari style.dart
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'All Reviews',
          style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              tooltip: 'Filter Reviews',
              icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (String value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'Latest',
                    child: Text('Latest', style: AppTextStyles.bodyMedium),
                  ),
                  const PopupMenuDivider(),
                  ...List.generate(5, (index) {
                    int rating = 5 - index; // Urutkan dari Bintang 5 ke 1
                    return PopupMenuItem(
                      value: rating.toString(),
                      child: Row(
                        children: [
                          AppRatingBar(rating: rating.toDouble(), size: 16),
                          const SizedBox(width: 8),
                          Text('($rating)', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    );
                  }),
                ];
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Review>>(
        stream: _reviewsStream(_selectedFilter ?? 'Latest'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'An error occurred while loading reviews.',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.speaker_notes_off_rounded,
                      size: 64, color: AppColors.divider),
                  const SizedBox(height: 16),
                  Text(
                    'No matching reviews yet.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Header informasi filter (opsional, agar user tahu filter apa yang aktif)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedFilter != null && _selectedFilter != 'Latest')
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Text('Showing filter: ',
                          style: AppTextStyles.bodyMedium),
                      AppChip(label: '$_selectedFilter Stars', accent: true),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _selectedFilter = 'Latest'),
                        child: Text(
                          'Clear',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.error),
                        ),
                      )
                    ],
                  ),
                ),
                
              // List Ulasan
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final review = snapshot.data![index];
                    
                    // Tambahkan animasi simpel saat item muncul
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
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
                      child: _buildReviewCard(review),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Widget Card Ulasan ---
  Widget _buildReviewCard(Review review) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _userStream(review.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 120,
            decoration: AppDecorations.card,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight),
            ),
          );
        }

        Map<String, dynamic> userData = userSnapshot.data ?? {};
        String username = userData['username'] ?? 'Traveler';
        String profilephoto = userData['profilephoto'] ?? '';

        return Container(
          decoration: AppDecorations.card, // Menggunakan desain card dari style.dart
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profil & Rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surfaceAlt,
                    backgroundImage: profilephoto.isNotEmpty
                        ? NetworkImage(profilephoto)
                        : null,
                    child: profilephoto.isEmpty
                        ? const Icon(Icons.person, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 14),
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
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd MMM yyyy').format(review.tanggal),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  // Rating Bar dari style.dart
                  AppRatingBar(rating: review.rating.toDouble(), size: 16),
                ],
              ),
              const SizedBox(height: 16),
              
              // Isi Ulasan
              Text(
                review.deskripsi,
                style: AppTextStyles.bodyLarge, // Menggunakan bodyLarge untuk teks ulasan agar nyaman dibaca
              ),
            ],
          ),
        );
      },
    );
  }
}
