import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/History/HistoryDetail.dart';
import 'package:go_toba/History/HistoryModel.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedType = 'All';
  StreamSubscription? _expirySubscription;

  @override
  void initState() {
    super.initState();
    _checkAndRemoveExpiredPayments();
  }

  @override
  void dispose() {
    _expirySubscription?.cancel();
    super.dispose();
  }

  void _checkAndRemoveExpiredPayments() {
    final userId = context.read<UserProvider>().uid;
    _expirySubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('history')
        .where('pay', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final historyItem = HistoryItem.fromFirestore(doc);
        if (historyItem.paymentDeadline.isBefore(DateTime.now())) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('history')
              .doc(doc.id)
              .delete();
          Fluttertoast.showToast(
            msg: 'Deadline missed. Booking cancelled.',
            gravity: ToastGravity.TOP,
            backgroundColor: AppColors.error,
            textColor: Colors.white,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserProvider>().uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Pending Payments Banner ────────────────────────
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('history')
                      .where('pay', isEqualTo: false)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final pendingDocs = snapshot.data!.docs;
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.error.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.access_time_filled_rounded,
                                    color: AppColors.error,
                                    size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text('Waiting for Payment',
                                  style: AppTextStyles.headingSmall
                                      .copyWith(color: AppColors.error)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...pendingDocs.map((doc) {
                            try {
                              return _PendingBookingTile(
                                  historyItem: HistoryItem.fromFirestore(doc));
                            } catch (_) {
                              return const SizedBox.shrink();
                            }
                          }),
                        ],
                      ),
                    );
                  },
                ),

                // ── Filter chips ──────────────────────────────────
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final type in [
                        ('All', 'All'),
                        ('hotel', 'Hotel'),
                        ('kuliner', 'Culinary'),
                        ('bus', 'Bus'),
                        ('Ship', 'Ship'),
                      ])
                        _FilterChip(
                          label: type.$2,
                          selected: selectedType == type.$1,
                          onTap: () => setState(() => selectedType = type.$1),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── History list (paid) ──────────────────────────────────
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('history')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                      child: Text('Error: ${snapshot.error}',
                          style: AppTextStyles.bodyMedium)),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(child: _EmptyState());
              }

              var docs = snapshot.data!.docs;
              if (selectedType != 'All') {
                docs = docs
                    .where((d) =>
                        HistoryItem.fromFirestore(d).historyType ==
                        selectedType)
                    .toList();
              }

              if (docs.isEmpty) {
                return SliverFillRemaining(child: _EmptyState());
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      try {
                        final item = HistoryItem.fromFirestore(docs[index]);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HistoryCard(historyItem: item),
                        );
                      } catch (e) {
                        return const SizedBox.shrink();
                      }
                    },
                    childCount: docs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),)
      
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.divider),
        const SizedBox(height: 16),
        Text('No history yet',
          style: AppTextStyles.headingSmall
            .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('Your first booking will appear here',
          style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

// ── Filter chip ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.primary : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.divider,
          ),
          boxShadow: selected ? AppShadows.button : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Pending booking tile (inside banner) ────────────────────────────────────
class _PendingBookingTile extends StatelessWidget {
  final HistoryItem historyItem;
  const _PendingBookingTile({required this.historyItem});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => HistoryDetail(historyItem: historyItem)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_typeIcon(historyItem.historyType),
                  color: AppColors.error, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_typeTitle(historyItem),
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text('Rp ${historyItem.price}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.error)),
                ],
              ),
            ),
            Text('Pay',
              style: AppTextStyles.label.copyWith(color: AppColors.error)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.error, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── History card ─────────────────────────────────────────────────────────────
class HistoryCard extends StatelessWidget {
  final HistoryItem historyItem;
  const HistoryCard({super.key, required this.historyItem});

  @override
  Widget build(BuildContext context) {
    final bool isPaid = historyItem.pay;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => HistoryDetail(historyItem: historyItem)),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            // Left accent strip + icon
            Container(
              width: 64,
              height: 90,
              decoration: BoxDecoration(
                gradient: isPaid
                    ? AppGradients.primary
                    : const LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFEF9A9A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(18)),
              ),
              child: Icon(_typeIcon(historyItem.historyType),
                  color: Colors.white, size: 28),
            ),

            // Content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_typeTitle(historyItem),
                        style:
                            AppTextStyles.headingSmall.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(_typeSubtitle(historyItem),
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),

            // Price + status + arrow
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    Text('Rp ${historyItem.price}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      isPaid ? 'Paid' : 'Pending',
                      style: AppTextStyles.caption.copyWith(
                        color: isPaid ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
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

// ── Shared helpers ─────────────────────────────────────────────────────────

IconData _typeIcon(String type) {
  switch (type) {
    case 'hotel':
      return Icons.hotel_rounded;
    case 'kuliner':
      return Icons.restaurant_rounded;
    case 'bus':
      return Icons.directions_bus_rounded;
    case 'Ship':
      return Icons.directions_boat_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}

String _typeTitle(HistoryItem h) {
  switch (h.historyType) {
    case 'hotel':
      return h.hotelName;
    case 'kuliner':
      return h.kulinerName;
    case 'bus':
      return h.transportName;
    case 'Ship':
      return '${h.origin} → ${h.destination}';
    default:
      return 'Unknown';
  }
}

String _typeSubtitle(HistoryItem h) {
  switch (h.historyType) {
    case 'hotel':
      return h.roomType;
    case 'kuliner':
      return h.notes.isNotEmpty ? h.notes : '-';
    case 'bus':
    case 'Ship':
      return '${h.departTime}  ${h.departDate}\n${h.origin} → ${h.destination}';
    default:
      return '-';
  }
}
