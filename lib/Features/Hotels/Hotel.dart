// ignore_for_file: use_build_context_synchronously, empty_catches, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/l10n/l10n.dart';
import 'package:go_toba/style.dart';
import 'HotelDetail.dart';
import 'HotelModel.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  _HotelScreenState createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  List<Hotel> hotels = [];
  List<String> searchHistory = [];
  Map<String, Hotel> hotelMap = {};
  bool isLoading = true;
  bool isFetching = false;
  TextEditingController searchController = TextEditingController();
  DocumentSnapshot? lastDocument;
  List<Hotel> promoHotels = [];
  String priceFilterState = 'none';
  String ratingFilterState = 'none';
  String latestFilterState = 'none';
  int selectedStarRating = 0;

  String selectedLocationFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var collection = db.collection('hotels').orderBy('name');

    var data = await collection.get();
    setState(() {
      hotels = data.docs.map((doc) => Hotel.fromDocSnapshot(doc)).toList();
      if (data.docs.isNotEmpty) {
        lastDocument = data.docs.last;
      }
      isLoading = false;
    });
  }

  List<Hotel> filteredHotels(String query) {
    List<Hotel> filteredList = hotels.where((hotel) {
      final hotelNameLower = hotel.name.toLowerCase();
      final searchLower = query.toLowerCase();
      return hotelNameLower.contains(searchLower) &&
          (selectedLocationFilter == 'All' ||
              hotel.address.contains(selectedLocationFilter));
    }).toList();

    if (priceFilterState == 'highToLow') {
      filteredList.sort((a, b) => b.price.compareTo(a.price));
    } else if (priceFilterState == 'lowToHigh') {
      filteredList.sort((a, b) => a.price.compareTo(b.price));
    }

    if (ratingFilterState == 'highToLow') {
      filteredList.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (ratingFilterState == 'lowToHigh') {
      filteredList.sort((a, b) => a.rating.compareTo(b.rating));
    }

    if (selectedStarRating > 0) {
      filteredList = filteredList
          .where((hotel) => hotel.rating == selectedStarRating)
          .toList();
    }

    return filteredList;
  }

  void togglePriceFilter() {
    setState(() {
      if (priceFilterState == 'none') {
        priceFilterState = 'highToLow';
      } else if (priceFilterState == 'highToLow') {
        priceFilterState = 'lowToHigh';
      } else {
        priceFilterState = 'none';
      }
    });
  }

  void toggleRatingFilter() {
    setState(() {
      if (ratingFilterState == 'none') {
        ratingFilterState = 'highToLow';
      } else if (ratingFilterState == 'highToLow') {
        ratingFilterState = 'lowToHigh';
      } else {
        ratingFilterState = 'none';
      }
    });
  }

  void selectStarRating(int rating) {
    setState(() {
      if (selectedStarRating == rating) {
        selectedStarRating = 0;
      } else {
        selectedStarRating = rating;
      }
    });
  }

  Future<void> updateUserTags(String userId, List<String> newTags) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference userDoc = db.collection('users').doc(userId);

    try {
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        List<String> existingTags =
            List<String>.from(userSnapshot.get('hoteltags') ?? []);

        for (String tag in newTags) {
          if (!existingTags.contains(tag)) {
            if (existingTags.length >= 5) {
              existingTags.removeAt(0);
            }
            existingTags.add(tag);
          }
        }

        await userDoc.set({'hoteltags': existingTags}, SetOptions(merge: true));
      } else {
        List<String> uniqueNewTags = newTags.toSet().toList();
        List<String> initialTags = uniqueNewTags.length > 5
            ? uniqueNewTags.sublist(0, 5)
            : uniqueNewTags;
        await userDoc.set({'hoteltags': initialTags});
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().uid;
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final bool isTablet = screenWidth >= 768;
    final double horizontalPadding = isTablet ? 20 : 12;
    final double cardRadius = isTablet ? 20 : 16;
    final filteredList = filteredHotels(searchController.text);

    final List<Map<String, String>> promoData = [
      {
        'image': 'assets/promo1.png',
        'title': 'Atsari Hotel Parapat',
        'description': '20% off for bookings made now!',
        'date': '2024-08-14',
      },
      {
        'image': 'assets/promo2.png',
        'title': 'Labersa Hotel',
        'description': '15% discount for members!',
        'date': '2024-08-15',
      },
      {
        'image': 'assets/promo3.png',
        'title': 'Parapat View Hotel',
        'description': 'Special weekend rates!',
        'date': '2024-08-16',
      },
      // Tambahkan lebih banyak data promo jika diperlukan
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          context.l10n.lakeTobaHotels,
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        flexibleSpace: Container(decoration: appBarGradient()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(horizontalPadding,
                        horizontalPadding, horizontalPadding, 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color2.withValues(alpha: 0.12),
                          Colors.white,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppShadows.soft,
                          ),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: context.l10n.searchHotelName,
                              prefixIcon: const Icon(Icons.search_rounded),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.divider, width: 1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedLocationFilter,
                              isExpanded: true,
                              icon:
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                              items: const [
                                'All',
                                'Parapat',
                                'Tongging',
                                'Tuk-tuk',
                                'Simanindo',
                                'Ajibata',
                                'Balige'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value == 'All' ? context.l10n.allLocations : value,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) async {
                                setState(() {
                                  selectedLocationFilter = newValue!;
                                });
                                await fetchHotels();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterButton(
                          text: _getPriceFilterText(context),
                          selected: priceFilterState != 'none',
                          onTap: togglePriceFilter,
                        ),
                        FilterButton(
                          text: _getRatingFilterText(context),
                          selected: ratingFilterState != 'none',
                          onTap: toggleRatingFilter,
                        ),
                        ...List.generate(5, (index) {
                          final rating = index + 1;
                          return StarFilterButton(
                            rating: rating,
                            selected: selectedStarRating == rating,
                            onTap: () => selectStarRating(rating),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      scrollDirection: Axis.horizontal,
                      children: promoData.map((promo) {
                        return Container(
                          width: isTablet ? 280 : 240,
                          margin: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(cardRadius),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(promo['image']!, fit: BoxFit.cover),
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Color(0xCC000000),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 12,
                                  right: 12,
                                  bottom: 10,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        promo['title']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        promo['description']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${context.l10n.validUntil} ${promo['date']!}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                if (filteredList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        context.l10n.hotelNotFound,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0,
                        horizontalPadding, horizontalPadding),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 3 : 2,
                        childAspectRatio: isTablet ? 0.74 : 0.68,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= filteredList.length) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final hotel = filteredList[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(cardRadius),
                            onTap: () async {
                              await updateUserTags(userId!, hotel.tags);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HotelDetailPage(hotel: hotel),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(cardRadius),
                                boxShadow: AppShadows.soft,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(cardRadius),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            hotel.imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                          const DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Color(0x66000000),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 8, 10, 4),
                                    child: Text(
                                      hotel.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: AppRatingBar(
                                      rating: hotel.rating.toDouble(),
                                      size: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 6, 10, 10),
                                    child: Text(
                                      currencyFormatter.format(hotel.price),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: filteredList.length + (isFetching ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String _getPriceFilterText(BuildContext context) {
    if (priceFilterState == 'highToLow') {
      return context.l10n.highPrice;
    } else if (priceFilterState == 'lowToHigh') {
      return context.l10n.lowPrice;
    } else {
      return context.l10n.priceFilter;
    }
  }

  String _getRatingFilterText(BuildContext context) {
    if (ratingFilterState == 'highToLow') {
      return context.l10n.highRating;
    } else if (ratingFilterState == 'lowToHigh') {
      return context.l10n.lowRating;
    } else {
      return context.l10n.ratingFilter;
    }
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const FilterButton({
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.95)
              : Colors.grey.shade100,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class StarFilterButton extends StatelessWidget {
  final int rating;
  final bool selected;
  final VoidCallback onTap;

  const StarFilterButton({
    required this.rating,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.95)
              : Colors.grey.shade100,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              '$rating',
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.star,
              color: selected ? Colors.white : AppColors.accent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
