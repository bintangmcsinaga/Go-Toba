import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/History/HistoryModel.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart'; // Import design system

class HistoryDetail extends StatefulWidget {
  final HistoryItem historyItem;

  const HistoryDetail({super.key, required this.historyItem});

  @override
  _HistoryDetailState createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  late Future<bool> _isReviewed;
  late Timer _timer;
  late Duration _timeLeft;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isReviewed = _checkIfReviewed();
    _startCountdown();
  }

  Future<bool> _checkIfReviewed() async {
    final userid = context.read<UserProvider>().uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('history')
        .doc(widget.historyItem.id)
        .get();
    return doc.data()?['reviewed'] ?? false;
  }

  void cancelConfirm() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Batalkan Pesanan?", style: AppTextStyles.headingMedium),
              content: Text("Apakah Anda yakin ingin membatalkan pesanan ini?", style: AppTextStyles.bodyMedium),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Tidak", style: AppTextStyles.label.copyWith(color: AppColors.textSecondary))),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _handleDeadlinePassed();
                    },
                    child: Text("Ya, Batalkan", style: AppTextStyles.label.copyWith(color: Colors.white)))
              ],
            ));
  }

  void _startCountdown() {
    final now = DateTime.now();
    final deadline = widget.historyItem.paymentDeadline;
    _timeLeft = deadline.difference(now);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) return;
      setState(() {
        _timeLeft = deadline.difference(DateTime.now());
        if (_timeLeft.isNegative) {
          _timer.cancel();
          _handleDeadlinePassed();
        }
      });
    });
  }

  void _handleDeadlinePassed() async {
    if (!widget.historyItem.pay) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(context.read<UserProvider>().uid)
          .collection('history')
          .doc(widget.historyItem.id)
          .delete();

      Fluttertoast.showToast(
        msg: 'Waktu pembayaran habis. Pesanan dibatalkan.',
        gravity: ToastGravity.TOP,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
      if (mounted) Navigator.of(context).pop(); // Kembali ke halaman history
    }
  }

  void _submitReview(BuildContext context, HistoryItem historyItem,
      String reviewText, double rating) async {
    final user = context.read<UserProvider>();
    final itemId = historyItem.historyType == 'hotel'
        ? historyItem.hotelID
        : historyItem.historyType == 'kuliner'
            ? historyItem.kulinerID
            : historyItem.ticketID;

    Map<String, dynamic> reviewData = {
      'uid': user.uid,
      'rating': rating,
      'deskripsi': reviewText,
      'tanggal': Timestamp.fromDate(DateTime.now()),
    };

    DocumentReference itemDoc = FirebaseFirestore.instance
        .collection(historyItem.historyType == 'hotel'
            ? 'hotels'
            : historyItem.historyType == 'kuliner'
                ? 'kuliner'
                : 'bus')
        .doc(itemId);

    await itemDoc.collection('reviews').add(reviewData).then((_) async {
      final userid = context.read<UserProvider>().uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .collection('history')
          .doc(historyItem.id)
          .update({'reviewed': true}).then((_) {
        if (mounted) {
          setState(() {
            _isReviewed = Future.value(true);
          });
        }
        Fluttertoast.showToast(
          msg: 'Ulasan berhasil disimpan',
          gravity: ToastGravity.TOP,
          backgroundColor: AppColors.success,
          textColor: Colors.white,
        );
      }).catchError((error) {
        Fluttertoast.showToast(
          msg: 'Ulasan gagal disimpan',
          gravity: ToastGravity.TOP,
          backgroundColor: AppColors.error,
          textColor: Colors.white,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPendingPayment = !widget.historyItem.pay;
    final showVirtualAccount =
        isPendingPayment && widget.historyItem.virtualAccountNumber.isNotEmpty;

    String pageTitle = widget.historyItem.historyType == 'hotel'
        ? widget.historyItem.hotelName
        : widget.historyItem.historyType == 'kuliner'
            ? widget.historyItem.kulinerName
            : widget.historyItem.destination;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(decoration: appBarGradient()),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(pageTitle, style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER STATUS ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isPendingPayment ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isPendingPayment ? AppColors.error.withValues(alpha: 0.3) : AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    isPendingPayment ? Icons.schedule_rounded : Icons.check_circle_rounded,
                    color: isPendingPayment ? AppColors.error : AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPendingPayment ? 'Menunggu Pembayaran' : 'Transaksi Berhasil',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: isPendingPayment ? AppColors.error : AppColors.success,
                          ),
                        ),
                        if (isPendingPayment) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Selesaikan dalam ${_formatDuration(_timeLeft)}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- INVOICE CARD ---
            Container(
              decoration: AppDecorations.card,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail Pesanan', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 16),
                  
                  _buildDetailRow('ID Transaksi', widget.historyItem.id),
                  _buildDetailRow('Tanggal Transaksi', widget.historyItem.date),
                  _buildDetailRow('Metode Pembayaran', widget.historyItem.paymentMethod),
                  if (showVirtualAccount) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.divider),
                    ),
                    Text('Nomor Virtual Account', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      widget.historyItem.virtualAccountNumber, 
                      style: AppTextStyles.headingLarge.copyWith(color: AppColors.primary, letterSpacing: 1.5)
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.divider, thickness: 1.5),
                  ),

                  // Detail Spesifik Tipe
                  if (widget.historyItem.historyType == 'hotel') ...[
                    _buildDetailRow('Nama Hotel', widget.historyItem.hotelName),
                    _buildDetailRow('Tipe Kamar', widget.historyItem.roomType),
                  ],
                  if (widget.historyItem.historyType == 'kuliner') ...[
                    _buildDetailRow('Nama Kuliner', widget.historyItem.kulinerName),
                  ],
                  if (widget.historyItem.historyType == 'bus' || widget.historyItem.historyType == 'Ship') ...[
                    _buildDetailRow('Transportasi', widget.historyItem.transportName),
                    _buildDetailRow('Tanggal Berangkat', widget.historyItem.departDate),
                    _buildDetailRow('Waktu Keberangkatan', widget.historyItem.departTime),
                    _buildDetailRow('Asal', widget.historyItem.origin),
                    _buildDetailRow('Tujuan', widget.historyItem.destination),
                    _buildDetailRow('Jumlah Penumpang', '${widget.historyItem.totalpassanger} Orang'),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.divider, thickness: 1.5),
                  ),

                  // Total Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Pembayaran', style: AppTextStyles.headingSmall),
                      Text(
                        'Rp ${widget.historyItem.price}',
                        style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // --- BOTTOM BAR ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: widget.historyItem.historyType == 'bus' || isPendingPayment || widget.historyItem.historyType == 'Ship'
              ? (isPendingPayment
                  ? OutlinedButton(
                      onPressed: cancelConfirm,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text("Batalkan Pesanan", style: AppTextStyles.button.copyWith(color: AppColors.error)),
                    )
                  : const SizedBox.shrink())
              : FutureBuilder<bool>(
                  future: _isReviewed,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
                    }
                    final isReviewed = snapshot.data ?? false;
                    return AppPrimaryButton(
                      label: isReviewed ? "Ulasan Telah Diberikan" : "Berikan Ulasan",
                      icon: isReviewed ? Icons.check_circle_outline_rounded : Icons.star_border_rounded,
                      onTap: isReviewed ? null : () => _navigateToReviewPage(context, widget.historyItem),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyles.label),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value, 
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'Kadaluarsa';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _navigateToReviewPage(BuildContext context, HistoryItem historyItem) {
    TextEditingController reviewController = TextEditingController();
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Beri Ulasan', style: AppTextStyles.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              historyItem.historyType == 'hotel' ? historyItem.hotelName : historyItem.historyType == 'kuliner' ? historyItem.kulinerName : historyItem.transportName,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 40,
              unratedColor: AppColors.divider,
              itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.accent),
              onRatingUpdate: (ratingValue) {
                rating = ratingValue;
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: reviewController,
              maxLength: 150,
              style: AppTextStyles.bodyLarge,
              decoration: AppDecorations.inputDecoration('Tulis pengalaman Anda...'),
              maxLines: 3,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Batal', style: AppTextStyles.label),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    String reviewText = reviewController.text.trim();
                    if (reviewText.isNotEmpty && rating > 0) {
                      _submitReview(context, historyItem, reviewText, rating);
                      Navigator.of(context).pop();
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Mohon berikan rating dan ulasan Anda.',
                        backgroundColor: AppColors.error,
                      );
                    }
                  },
                  child: Text('Simpan', style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer.cancel();
    super.dispose();
  }
}