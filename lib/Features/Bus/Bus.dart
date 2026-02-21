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
      var allTickets = await fetchBusTickets();
      setState(() {
        _filteredBusTickets = allTickets
            .where((t) =>
                t.from.toLowerCase() == _selectedOrigin!.toLowerCase() &&
                t.to.toLowerCase() == _selectedDestination!.toLowerCase())
            .toList();
      });
    }
  }

  List<String> _getAvailableDestinations() {
    return _destinations
        .where((d) => _selectedOrigin == null || d != _selectedOrigin)
        .toList();
  }

  // ── Helper: styled dropdown ────────────────────────────────────────────────
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.soft,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(label, style: AppTextStyles.bodyMedium),
                isDense: true,
                isExpanded: true,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textPrimary),
                dropdownColor: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                onChanged: onChanged,
                items: items
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Premium AppBar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Tiket Bus',
                  style:
                      AppTextStyles.headingSmall.copyWith(color: Colors.white)),
              centerTitle: true,
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppGradients.primaryVertical),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Route card ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pilih Rute', style: AppTextStyles.headingSmall),
                        const SizedBox(height: 4),
                        Text('Tentukan keberangkatan & tujuan',
                            style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 16),

                        // Origin
                        _buildDropdown(
                          label: 'Asal keberangkatan',
                          icon: Icons.departure_board_rounded,
                          value: _selectedOrigin,
                          items: _origins,
                          onChanged: (value) {
                            setState(() {
                              _selectedOrigin = value;
                              _selectedDestination = null;
                              _filterBusTickets();
                            });
                          },
                        ),

                        // Arrow
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_downward_rounded,
                                  color: AppColors.primary, size: 18),
                            ),
                          ),
                        ),

                        // Destination
                        _buildDropdown(
                          label: 'Tujuan',
                          icon: Icons.location_on_rounded,
                          value: _selectedDestination,
                          items: _getAvailableDestinations(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDestination = value;
                              _filterBusTickets();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Results ──────────────────────────────────────────
                  if (_selectedOrigin != null && _selectedDestination != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Tersedia', style: AppTextStyles.headingSmall),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100)),
                              child: Text(
                                '${_filteredBusTickets.length} results',
                                style: AppTextStyles.label
                                    .copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_filteredBusTickets.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded,
                                    color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text('Tidak ada jadwal tersedia',
                                    style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredBusTickets.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final ticket = _filteredBusTickets[index];
                              return _BusTicketCard(
                                ticket: ticket,
                                formatter: currencyFormatter,
                              );
                            },
                          ),
                      ],
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ticket Card ────────────────────────────────────────────────────────────
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
          // Header band
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_bus_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticket.transportName,
                    style: AppTextStyles.headingSmall
                        .copyWith(color: Colors.white, fontSize: 14),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    formatter.format(ticket.price),
                    style: AppTextStyles.label
                        .copyWith(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Route row
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dari', style: AppTextStyles.caption),
                        Text(ticket.from, style: AppTextStyles.headingSmall),
                      ],
                    ),
                    const Expanded(
                      child: Center(
                        child: Icon(Icons.arrow_forward_rounded,
                            color: AppColors.primary),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Ke', style: AppTextStyles.caption),
                        Text(ticket.to, style: AppTextStyles.headingSmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 12),

                // Departure times
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Jam: ${ticket.departTime.join(', ')}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Book button
                SizedBox(
                  width: double.infinity,
                  child: AppPrimaryButton(
                    label: 'Pesan Tiket',
                    icon: Icons.confirmation_number_rounded,
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
