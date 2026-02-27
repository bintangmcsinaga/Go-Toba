import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:intl/intl.dart';
import 'package:go_toba/Features/Hotels/HotelReview.dart';
import 'package:go_toba/l10n/l10n.dart';
import 'package:go_toba/style.dart'; // Menggunakan style.dart
import 'HotelBooking.dart';
import 'HotelModel.dart';

class HotelDetailPage extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailPage({super.key, required this.hotel});

  @override
  _HotelDetailPageState createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  late Future<List<Room>> _roomsFuture;
  late Stream<List<Review>> _reviewsStream;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _fetchRooms();
    _reviewsStream = FirebaseFirestore.instance
        .collection('hotels')
        .doc(widget.hotel.id)
        .collection('reviews')
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  Future<List<Room>> _fetchRooms() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('hotels')
        .doc(widget.hotel.id)
        .collection('rooms')
        .get();

    return snapshot.docs.map((doc) => Room.fromDocSnapshot(doc)).toList();
  }

  Future<DocumentSnapshot> _getUserSnapshot(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background, // Dari style.dart
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER: IMAGE CAROUSEL ---
            Stack(
              children: [
                FlutterCarousel(
                  options: FlutterCarouselOptions(
                    height: 350,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: true,
                    initialPage: 0,
                    autoPlay: true,
                    showIndicator: true,
                    slideIndicator: CircularSlideIndicator(
                      slideIndicatorOptions: SlideIndicatorOptions(
                        itemSpacing: 12,
                        indicatorRadius: 4,
                        currentIndicatorColor: AppColors.primary, // Dari style.dart
                        indicatorBackgroundColor: Colors.white54,
                      ),
                    ),
                  ),
                  items: widget.hotel.imageUrls.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final String imageUrl = entry.value;
                    return Builder(
                      builder: (BuildContext context) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            if (idx == 0)
                              Hero(
                                tag: imageUrl,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: _buildImageLoading,
                                  errorBuilder: _buildImageError,
                                ),
                              )
                            else
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: _buildImageLoading,
                                errorBuilder: _buildImageError,
                              ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: AppGradients.cardOverlay, // Dari style.dart
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
                
                // --- BACK BUTTON ---
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- CONTENT ---
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface, // Dari style.dart
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: AppShadows.soft, // Dari style.dart
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HOTEL INFO SECTION
                    _FadeInSlide(
                      delay: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.hotel.name,
                                  style: AppTextStyles.displayLarge.copyWith(fontSize: 26),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Memakai widget bawaan dari style.dart
                                    AppRatingBar(
                                      rating: widget.hotel.rating.toDouble(), 
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.hotel.rating.toStringAsFixed(1),
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  color: AppColors.primary, size: 20), // Dari style.dart
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.hotel.address.join(', '),
                                  style: AppTextStyles.bodyMedium, // Dari style.dart
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.email_rounded,
                                  color: AppColors.primary, size: 20), // Dari style.dart
                              const SizedBox(width: 6),
                              Text(
                                widget.hotel.contact,
                                style: AppTextStyles.bodyMedium, // Dari style.dart
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1, thickness: 1, color: AppColors.divider),
                    ),

                    // 2. FACILITIES SECTION
                    _FadeInSlide(
                      delay: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.mainFacilities,
                            style: AppTextStyles.headingMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            // Memakai AppChip dari style.dart
                            children: widget.hotel.facilities.map((facility) {
                              return AppChip(label: facility); 
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1, thickness: 1, color: AppColors.divider),
                    ),

                    // 3. REVIEWS SECTION
                    _FadeInSlide(
                      delay: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.latestReviews,
                                style: AppTextStyles.headingMedium,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HotelReview(
                                              hotelId: widget.hotel.id)));
                                },
                                child: Text(
                                  context.l10n.seeAll,
                                  style: AppTextStyles.label.copyWith(
                                      color: AppColors.primary, 
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          StreamBuilder<List<Review>>(
                            stream: _reviewsStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(color: AppColors.primary));
                              }
                              if (snapshot.hasError ||
                                  !snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.shimmer2,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(context.l10n.noReviewsForHotelYet,
                                        style: AppTextStyles.bodyMedium),
                                  ),
                                );
                              }

                              List<Review> latestReviews =
                                  snapshot.data!.take(5).toList();

                              return SizedBox(
                                height: 160,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: latestReviews.length,
                                  itemBuilder: (context, index) {
                                    return _buildReviewCard(
                                        latestReviews[index]);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1, thickness: 1, color: AppColors.divider),
                    ),

                    // 4. ROOMS SECTION
                    _FadeInSlide(
                      delay: 400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.roomOptions,
                            style: AppTextStyles.headingMedium,
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<List<Room>>(
                            future: _roomsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(color: AppColors.primary));
                              } else if (snapshot.hasError ||
                                  !snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text(context.l10n.noRoomsAvailable, 
                                    style: AppTextStyles.bodyMedium));
                              } else {
                                return Column(
                                  children: snapshot.data!.map((room) {
                                    return _buildRoomCard(
                                        room, currencyFormatter, context);
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildImageLoading(BuildContext context, Widget child,
      ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Container(
      color: AppColors.shimmer1,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }

  Widget _buildImageError(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      color: AppColors.shimmer1,
      child: const Center(
          child: Icon(Icons.broken_image, size: 50, color: AppColors.textSecondary)),
    );
  }

  Widget _buildReviewCard(Review review) {
    return FutureBuilder<DocumentSnapshot>(
      future: _getUserSnapshot(review.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              width: 280, child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
        }
        
        final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final profilePicUrl = userData['profilephoto'] ?? '';
        final username = userData['username'] ?? context.l10n.traveler;

        return Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16, bottom: 8, top: 4),
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.cardFlat.copyWith( // Dari style.dart
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.shimmer1,
                    backgroundImage: profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : null,
                    child: profilePicUrl.isEmpty
                        ? const Icon(Icons.person, color: AppColors.textSecondary)
                        : null,
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
                  // Memakai widget bawaan dari style.dart
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

  Widget _buildRoomCard(
      Room room, NumberFormat formatter, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppDecorations.card, // Dari style.dart (shadow & radius)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Kamar
          if (room.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                room.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: _buildImageLoading,
                errorBuilder: _buildImageError,
              ),
            ),
          
          // Konten Info Kamar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        room.type,
                        style: AppTextStyles.headingMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: room.available
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        room.available ? context.l10n.available : context.l10n.full,
                        style: AppTextStyles.label.copyWith(
                          color: room.available ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${context.l10n.facilities}: ${room.facilities.join(', ')}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                
                // Harga & Tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.startingFrom,
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          formatter.format(widget.hotel.price), 
                          style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Menggunakan tombol bawaan style.dart dengan Expanded
                    Expanded(
                      child: AppPrimaryButton(
                        label: context.l10n.book,
                        onTap: room.available
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingPage(
                                      room: room,
                                      hotel: widget.hotel,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
