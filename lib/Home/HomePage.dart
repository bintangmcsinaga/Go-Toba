import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Features/Bus/Bus.dart';
import 'package:go_toba/Features/Culinary/KulinerDetail.dart';
import 'package:go_toba/Features/Culinary/KulinerModel.dart';
import 'package:go_toba/Features/Hotels/Hotel.dart';
import 'package:go_toba/Features/Culinary/kuliner.dart';
import 'package:go_toba/Features/Hotels/HotelDetail.dart';
import 'package:go_toba/Features/Hotels/HotelModel.dart';
import 'package:go_toba/Features/Moments/Story.dart';
import 'package:go_toba/Features/Ships/Ship.dart';
import 'package:go_toba/Features/Vacations/Vacations.dart';
import 'package:go_toba/Features/Vacations/VacationsDetail.dart';
import 'package:go_toba/Features/Vacations/VacationsModel.dart';
import 'package:go_toba/Home/CulinaryRecomendation.dart';
import 'package:go_toba/Home/DestinationRecomendation.dart';
import 'package:go_toba/Home/HotelRecomendation.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';
import 'package:go_toba/main.dart';
import 'package:go_toba/Home/HomeWidgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, RouteAware {
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.bedroom_parent_rounded, 'name': 'Hotels'},
    {'icon': Icons.sailing_rounded, 'name': 'Ships'},
    {'icon': Icons.landscape_rounded, 'name': 'Vacations'},
    {'icon': Icons.auto_stories_rounded, 'name': 'Moments'},
    {'icon': Icons.local_dining_rounded, 'name': 'Culinary'},
    {'icon': Icons.directions_bus_rounded, 'name': 'Bus'},
  ];

  Future<List<Hotel>>? _hotelsFuture;
  Future<List<Destination>>? _destinationFuture;
  Future<List<KulinerModel>>? _culinaryFuture;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void fetchRecommendations() {
    final userId = context.read<UserProvider>().uid;
    if (userId == null) return;
    setState(() {
      _hotelsFuture = fetchRecommendedHotels(userId);
      _destinationFuture = fetchRecommendedDestination(userId);
      _culinaryFuture = fetchRecommendedCulinary(userId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    fetchRecommendations();
  }

  // --- Fetch Methods (Unchanged Logic) ---
  Future<List<KulinerModel>> fetchRecommendedCulinary(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<String> userTags = await getCulinaryTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('kuliner')
        .where('tags', arrayContainsAny: userTags)
        .limit(5)
        .get();
    return snapshot.docs
        .map((doc) => KulinerModel.fromDocSnapshot(doc))
        .toList();
  }

  Future<List<String>> getCulinaryTags(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      return List<String>.from(userSnapshot.get('culinarytags') ?? []);
    }
    return [];
  }

  Future<List<Destination>> fetchRecommendedDestination(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<String> userTags = await getDestinationTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('destinations')
        .where('tags', arrayContainsAny: userTags)
        .limit(5)
        .get();
    return snapshot.docs
        .map((doc) => Destination.fromDocSnapshot(doc))
        .toList();
  }

  Future<List<String>> getDestinationTags(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      return List<String>.from(userSnapshot.get('vacationtags') ?? []);
    }
    return [];
  }

  Future<List<Hotel>> fetchRecommendedHotels(String userId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<String> userTags = await getHotelTags(userId);
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('hotels')
        .where('tags', arrayContainsAny: userTags)
        .limit(5)
        .get();
    return snapshot.docs.map((doc) => Hotel.fromDocSnapshot(doc)).toList();
  }

  Future<List<String>> getHotelTags(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      return List<String>.from(userSnapshot.get('hoteltags') ?? []);
    }
    return [];
  }

  void _onFeatureTap(String featureName) {
    switch (featureName) {
      case 'Hotels':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HotelScreen()));
        break;
      case 'Ships':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ShipTicketOrderPage()));
        break;
      case 'Vacations':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Vacations()));
        break;
      case 'Moments':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Story()));
        break;
      case 'Culinary':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const KulinerWidget()));
        break;
      case 'Bus':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const BusTicketOrderPage()));
        break;
    }
  }

  final List<String> imgList = [
    'assets/homeslider/slider1.png',
    'assets/homeslider/slider2.png',
    'assets/homeslider/slider3.png',
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>();
    final screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width >= 768;
    final double horizontalPadding = isTablet ? 24 : 16;

    return Scaffold(
      backgroundColor: AppColors.background ?? Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // Lebih smooth ala iOS
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                SizedBox(
                  height: isTablet ? 420 : 350, // Sedikit diperbesar
                  width: double.infinity,
                  child: FlutterCarousel.builder(
                    itemCount: imgList.length,
                    itemBuilder: (context, index, realIndex) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(imgList[index], fit: BoxFit.cover),
                          // Peningkatan Gradient: Lebih transparan di atas, lebih gelap di bawah
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.3, 0.7, 1.0],
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    options: FlutterCarouselOptions(
                      height: isTablet ? 420 : 350,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      viewportFraction: 1.0,
                      showIndicator: false,
                    ),
                  ),
                ),
                // Badge Lokasi (Glassmorphism)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: horizontalPadding,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_rounded,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Danau Toba',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Welcome Text
                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 40, // Memberi ruang agar tidak menabrak Layanan Cepat
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, ${user.username.isNotEmpty ? user.username : 'Traveler'}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ) ??
                            TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Explore Danau Toba\nToday",
                        style: AppTextStyles.headingLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ) ??
                            const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Layanan Cepat (Quick Features)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 16,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: features.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 6 : 3,
                        childAspectRatio: 0.9,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        return FeatureItem(
                          feature: features[index],
                          onTap: () => _onFeatureTap(features[index]['name']),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Sections List
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                30, // Bottom padding lebih lega
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: "Recommended Hotels",
                    onSeeAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HotelRecommendationListPage(
                                userId: user.uid!))),
                  ),
                  const SizedBox(height: 12),
                  _buildHorizontalList<Hotel>(
                    _hotelsFuture ?? Future.value([]),
                    (hotel) => RecommendationCard(
                      imageUrl: hotel.imageUrls.isNotEmpty
                          ? hotel.imageUrls[0]
                          : 'https://via.placeholder.com/150',
                      title: hotel.name,
                      subtitle: "Hotel",
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HotelDetailPage(hotel: hotel))),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  SectionHeader(
                    title: "Top Destinations",
                    onSeeAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DestinationRecommendationPage(
                                userId: user.uid!))),
                  ),
                  const SizedBox(height: 12),
                  _buildHorizontalList<Destination>(
                    _destinationFuture ?? Future.value([]),
                    (dest) => RecommendationCard(
                      imageUrl: dest.imageUrl,
                      title: dest.name,
                      subtitle: "Destination",
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DestinationDetailPage(destination: dest))),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  SectionHeader(
                    title: "Culinary Delights",
                    onSeeAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CulinaryRecommendationPage(
                                userId: user.uid!))),
                  ),
                  const SizedBox(height: 12),
                  _buildHorizontalList<KulinerModel>(
                    _culinaryFuture ?? Future.value([]),
                    (food) => RecommendationCard(
                      imageUrl: food.imageUrl,
                      title: food.name,
                      subtitle: "Culinary",
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  KulinerDetail(kuliner: food))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildHorizontalList<T>(
      Future<List<T>> future, Widget Function(T) itemBuilder) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeletonLoading(); // Diganti dengan Skeleton Loading
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Gagal memuat data.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Belum ada rekomendasi.',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          );
        } else {
          return SizedBox(
            height: 220, // Tinggi RecommendationCard
            child: ListView.separated(
              physics: const BouncingScrollPhysics(), // Scroll lebih smooth
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0), // Slide dari samping
                        child: child,
                      ),
                    );
                  },
                  child: itemBuilder(snapshot.data![index]),
                );
              },
            ),
          );
        }
      },
    );
  }

  // Efek Loading Skeleton Modern
  Widget _buildSkeletonLoading() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Container(
            width: 150, // Sesuaikan dengan lebar RecommendationCard kamu
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 80,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}