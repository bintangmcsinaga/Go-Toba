import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Features/Vacations/VacationsDetail.dart';
import 'package:go_toba/Features/Vacations/VacationsModel.dart';
import 'package:go_toba/l10n/l10n.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';

class Vacations extends StatefulWidget {
  const Vacations({super.key});

  @override
  _VacationsState createState() => _VacationsState();
}

class _VacationsState extends State<Vacations> {
  String searchQuery = '';
  String filterCategory = 'All';
  String filterTag = 'All';

  List<Map<String, String>> _filters(BuildContext context) => [
        {'name': context.l10n.all, 'tag': 'All'},
        {'name': context.l10n.lake, 'tag': 'pemandangandanau'},
        {'name': context.l10n.waterfall, 'tag': 'airterjun'},
        {'name': context.l10n.hill, 'tag': 'bukit'},
        {'name': context.l10n.culture, 'tag': 'budaya'},
        {'name': context.l10n.beach, 'tag': 'pantai'},
      ];

  Future<void> updateUserTags(String userId, List<String> newTags) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference userDoc = db.collection('users').doc(userId);

    try {
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        List<String> existingTags =
            List<String>.from(userSnapshot.get('vacationtags') ?? []);

        for (String tag in newTags) {
          if (!existingTags.contains(tag)) {
            if (existingTags.length >= 5) {
              existingTags.removeAt(0);
            }
            existingTags.add(tag);
          }
        }

        await userDoc
            .set({'vacationtags': existingTags}, SetOptions(merge: true));
      } else {
        List<String> uniqueNewTags = newTags.toSet().toList();
        List<String> initialTags = uniqueNewTags.length > 5
            ? uniqueNewTags.sublist(0, 5)
            : uniqueNewTags;
        await userDoc.set({'vacationtags': initialTags});
      }
    } catch (e) {
      debugPrint('Error updating tags: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = _filters(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium Header ─────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(context.l10n.travelDestinations,
                  style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.primaryVertical),
              ),
            ),
          ),

          // ── Search & Filters ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.soft,
                    ),
                    child: TextField(
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: context.l10n.searchDestinations,
                        hintStyle: AppTextStyles.bodyMedium,
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filter Chips (Scrollable)
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filters.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isSelected = filterTag == filter['tag'];
                        return FilterButton(
                          text: filter['name']!,
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              filterTag = filter['tag']!;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Destination List ───────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0).copyWith(bottom: 40),
            sliver: SliverToBoxAdapter(
              child: DestinationList(
                searchQuery: searchQuery,
                filterTag: filterTag,
                onTagUpdate: updateUserTags,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── WIDGET: Filter Button ───────────────────────────────────────────
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
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: 1,
          ),
          boxShadow: selected ? AppShadows.soft : [],
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.label.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── WIDGET: Destination List (StreamBuilder) ────────────────────────
class DestinationList extends StatelessWidget {
  final String searchQuery;
  final String filterTag;
  final Function(String, List<String>) onTagUpdate;

  const DestinationList({
    super.key,
    required this.searchQuery,
    required this.filterTag,
    required this.onTagUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('destinations').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          // Skeleton Loading
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.shimmer1,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }

        var destinations = snapshot.data!.docs
            .map((doc) => Destination.fromDocSnapshot(
                doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        if (searchQuery.isNotEmpty) {
          destinations = destinations
              .where((d) =>
                  d.name.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
        }

        if (filterTag != 'All') {
          destinations =
              destinations.where((d) => d.tags.contains(filterTag)).toList();
        }

        if (destinations.isEmpty) {
          // Empty State
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              children: [
                Icon(Icons.landscape_rounded, size: 80, color: AppColors.divider),
                const SizedBox(height: 16),
                Text(context.l10n.destinationNotFound, style: AppTextStyles.headingSmall),
                const SizedBox(height: 8),
                Text(
                  context.l10n.tryDifferentKeywordOrCategory,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: destinations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {

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
              child: DestinationCard(
                destination: destinations[index],
                onTagUpdate: onTagUpdate,
              ),
            );
          },
        );
      },
    );
  }
}

// ── WIDGET: Destination Card ─────────────────────────────────────────
class DestinationCard extends StatelessWidget {
  final Destination destination;
  final Function(String, List<String>) onTagUpdate;

  const DestinationCard({
    super.key, 
    required this.destination,
    required this.onTagUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final userId = context.read<UserProvider>().uid;
        if (userId != null) {
          await onTagUpdate(userId, destination.tags);
        }
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DestinationDetailPage(destination: destination),
            ),
          );
        }
      },
      child: Container(
        height: 240, // Tinggi konsisten
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.card,
          color: AppColors.surface,
        ),
        child: Stack(
          children: [
            // Gambar Background
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
                    child: const Center(child: Icon(Icons.broken_image_rounded, size: 50, color: AppColors.textSecondary)),
                  );
                },
              ),
            ),

            // Gradient Overlay (Gelap di bawah agar teks terbaca)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0], // Mulai gelap di pertengahan ke bawah
                ),
              ),
            ),

            // Teks Informasi (Nama, Lokasi, Rating)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                                    destination.location, // Asumsi properti location ada sesuai modelmu sebelumnya
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
