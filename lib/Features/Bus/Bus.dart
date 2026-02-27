// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_toba/Features/Bus/BusDetail.dart';
import 'package:go_toba/Features/Bus/BusModel.dart';
import 'package:go_toba/style.dart';

class BusTicketOrderPage extends StatefulWidget {
  const BusTicketOrderPage({super.key});

  @override
  _BusTicketOrderPageState createState() => _BusTicketOrderPageState();
}

class _BusTicketOrderPageState extends State<BusTicketOrderPage> {
  String? _selectedOrigin;
  String? _selectedDestination;
  List<BusTicket> _filteredBusTickets = [];
  bool _isLoading = false;

  final List<String> _origins = [
    'Medan',
    'Pematang Siantar',
    'Parapat',
    'Silangit Airport',
    'Berastagi',
    'Samosir',
  ];
  final List<String> _destinations = [
    'Medan',
    'Pematang Siantar',
    'Parapat',
    'Silangit Airport',
    'Berastagi',
    'Samosir',
  ];

  Future<List<BusTicket>> fetchBusTickets() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('buses').get();
      return snapshot.docs
          .map((doc) => BusTicket.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  void _filterBusTickets() async {
    if (_selectedOrigin != null && _selectedDestination != null) {
      setState(() {
        _isLoading = true;
      });

      var allTickets = await fetchBusTickets();
      
      if (mounted) {
        setState(() {
          _filteredBusTickets = allTickets
              .where((t) =>
                  t.from.toLowerCase() == _selectedOrigin!.toLowerCase() &&
                  t.to.toLowerCase() == _selectedDestination!.toLowerCase())
              .toList();
          _isLoading = false;
        });
      }
    }
  }

  void _swapLocations() {
    if (_selectedOrigin != null && _selectedDestination != null) {
      setState(() {
        final temp = _selectedOrigin;
        _selectedOrigin = _selectedDestination;
        _selectedDestination = temp;
      });
      _filterBusTickets();
    }
  }

  List<String> _getAvailableDestinations() {
    return _destinations
        .where((d) => _selectedOrigin == null || d != _selectedOrigin)
        .toList();
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(label, style: AppTextStyles.bodyMedium),
                isDense: true,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: value != null ? FontWeight.bold : FontWeight.normal
                ),
                dropdownColor: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                onChanged: onChanged,
                items: items
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.shimmer1,
            borderRadius: BorderRadius.circular(20),
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
          // ── Premium AppBar ────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Bus & Travel Tickets',
                  style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.primaryVertical),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -20,
                      child: Icon(Icons.directions_bus_rounded, 
                          size: 120, 
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Route card ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Choose Your Route', style: AppTextStyles.headingMedium),
                        const SizedBox(height: 6),
                        Text('Find bus or travel schedules for your trip',
                            style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 24),

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              children: [
                                _buildDropdown(
                                  label: 'Departure City',
                                  icon: Icons.departure_board_rounded,
                                  value: _selectedOrigin,
                                  items: _origins,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOrigin = value;
                                      if (_selectedDestination == value) _selectedDestination = null;
                                    });
                                    _filterBusTickets();
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildDropdown(
                                  label: 'Destination City',
                                  icon: Icons.location_on_rounded,
                                  value: _selectedDestination,
                                  items: _getAvailableDestinations(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDestination = value;
                                    });
                                    _filterBusTickets();
                                  },
                                ),
                              ],
                            ),

                            // Swap Button
                            Positioned(
                              right: 24,
                              child: GestureDetector(
                                onTap: _swapLocations,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.divider, width: 2),
                                    boxShadow: AppShadows.soft,
                                  ),
                                  child: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Results ──────────────────────────────────────────
                  if (_selectedOrigin != null && _selectedDestination != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Available Schedules', style: AppTextStyles.headingSmall),
                            const SizedBox(width: 8),
                            if (!_isLoading)
                              AppChip(
                                label: '${_filteredBusTickets.length} Travel', 
                                accent: false,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (_isLoading)
                          _buildSkeletonLoader()
                        else if (_filteredBusTickets.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.directions_bus_filled_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  'Route Not Found', 
                                  style: AppTextStyles.headingSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No bus schedules are available from $_selectedOrigin to $_selectedDestination yet.', 
                                  style: AppTextStyles.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredBusTickets.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 400 + (index * 100)),
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
                                child: _BusTicketCard(
                                  ticket: _filteredBusTickets[index],
                                  formatter: currencyFormatter,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Realistic Ticket Card ───────────────────────────────────────────────────
class _BusTicketCard extends StatelessWidget {
  final BusTicket ticket;
  final NumberFormat formatter;

  const _BusTicketCard({required this.ticket, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // Header band with dark gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Operator Bus/Travel', style: AppTextStyles.label.copyWith(color: Colors.white70)),
                      Text(ticket.transportName, style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                if (ticket.price > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Price', style: AppTextStyles.label.copyWith(color: Colors.white70)),
                      Text(
                        formatter.format(ticket.price).replaceAll(',00', ''), // Buang desimal jika ada
                        style: AppTextStyles.headingMedium.copyWith(color: AppColors.accentLight),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Dashed Divider (Efek Sobekan Tiket)
          Stack(
            alignment: Alignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final boxWidth = constraints.constrainWidth();
                  const dashWidth = 8.0;
                  final dashCount = (boxWidth / (2 * dashWidth)).floor();
                  return Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(dashCount, (_) {
                      return SizedBox(
                        width: dashWidth,
                        height: 1.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.5)),
                        ),
                      );
                    }),
                  );
                },
              ),
              Positioned(
                left: -10,
                child: Container(
                  height: 20, width: 20,
                  decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                ),
              ),
              Positioned(
                right: -10,
                child: Container(
                  height: 20, width: 20,
                  decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                ),
              ),
            ],
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FROM', style: AppTextStyles.caption.copyWith(letterSpacing: 1.2)),
                          const SizedBox(height: 4),
                          Text(ticket.from, style: AppTextStyles.headingSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Icon(Icons.arrow_forward_rounded, color: AppColors.primaryLight, size: 28),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('DESTINATION', style: AppTextStyles.caption.copyWith(letterSpacing: 1.2)),
                          const SizedBox(height: 4),
                          Text(ticket.to, style: AppTextStyles.headingSmall, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.divider, height: 1),
                ),

                if (ticket.departTime.isNotEmpty) ...[
                  Text('Departure Schedule', style: AppTextStyles.label),
                  const SizedBox(height: 10),
                  // Menggunakan Wrap untuk mencegah overflow jika jam keberangkatan banyak
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ticket.departTime.map((time) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(time, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: AppPrimaryButton(
                    label: 'Book Ticket',
                    icon: Icons.confirmation_number_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusTicketDetailPage(ticket: ticket),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
