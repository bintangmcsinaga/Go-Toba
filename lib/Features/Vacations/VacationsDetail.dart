import 'package:flutter/material.dart';
import 'package:go_toba/Features/Vacations/VacationsModel.dart';
import 'package:go_toba/style.dart'; // Menggunakan design system kamu
import 'package:url_launcher/url_launcher_string.dart';

class DestinationDetailPage extends StatefulWidget {
  final Destination destination;

  const DestinationDetailPage({super.key, required this.destination});

  @override
  _DestinationDetailPageState createState() => _DestinationDetailPageState();
}

class _DestinationDetailPageState extends State<DestinationDetailPage> {
  void _openGoogleMaps() async {
    final url = widget.destination.gmaps;
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan peta.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HEADER: PARALLAX IMAGE ──────────────────────────────
          SliverAppBar(
            expandedHeight: size.height * 0.30, // Dinamis 45% tinggi layar
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
                  Image.network(
                    widget.destination.imageUrl,
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
                  // Gradasi gelap di atas untuk mengamankan tombol Back
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
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
                  // Gradasi gelap di bawah agar menyatu dengan konten
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black38, Colors.transparent],
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
              offset: const Offset(0, -30), // Tarik konten naik menutupi gambar
              child: Container(
                margin: const EdgeInsets.only(top: 70), // Jarak bawah agar tidak terlalu mepet dengan konten selanjutnya
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
                        offset: const Offset(0, -20), // Kartu info melayang di atas batas
                        child: Container(
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
                                      widget.destination.name,
                                      style: AppTextStyles.headingLarge.copyWith(height: 1.2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Widget Rating dari style.dart
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
                                          widget.destination.rating.toString(),
                                          style: AppTextStyles.label.copyWith(color: const Color(0xFF7D5A00), fontWeight: FontWeight.bold),
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
                                  const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.destination.location,
                                      style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── TOMBOL MAPS ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: _openGoogleMaps,
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
                              // Jika kamu punya asset google maps, pakai baris di bawah, jika tidak pakai Icon bawaan
                              // Image.asset("assets/googlemaps_logo.png", height: 24), 
                              const Icon(Icons.map_rounded, color: Colors.green, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                "Buka di Google Maps",
                                style: AppTextStyles.label.copyWith(color: AppColors.textPrimary, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── TENTANG LOKASI ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tentang Lokasi Ini',
                            style: AppTextStyles.headingMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.destination.description,
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                          ),
                          
                          // Tambahan padding bawah agar teks tidak terpotong tepi layar
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}