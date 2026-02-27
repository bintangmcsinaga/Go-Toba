import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Features/Hotels/HotelModel.dart';
import 'package:go_toba/Features/Hotels/VirtualAccountPage.dart';
import 'package:go_toba/l10n/l10n.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart'; // Import style.dart

class BookingPage extends StatefulWidget {
  final Room room;
  final Hotel hotel;

  const BookingPage({super.key, required this.room, required this.hotel});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late int price;
  String _selectedPaymentMethod = 'Bank Transfer';
  String _selectedBank = 'BCA';
  String _creditCardNumber = '';
  String _selectedEwallet = "OVO";

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now();
    _checkOutDate = DateTime.now().add(const Duration(days: 1));
    _calculateTotalPrice();
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime) onDateSelected, DateTime initial) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, 
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  void _calculateTotalPrice() {
    int numberOfDays = _checkOutDate.difference(_checkInDate).inDays;
    if (numberOfDays <= 0) numberOfDays = 1; 
    price = widget.room.pricePerNight * numberOfDays;
  }

  void _selectCheckInDate(DateTime selectedDate) {
    setState(() {
      _checkInDate = selectedDate;
      if (_checkOutDate.isBefore(_checkInDate) || _checkOutDate.isAtSameMomentAs(_checkInDate)) {
        _checkOutDate = _checkInDate.add(const Duration(days: 1));
      }
      _calculateTotalPrice();
    });
  }

  void _selectCheckOutDate(DateTime selectedDate) {
    setState(() {
      if (selectedDate.isAfter(_checkInDate)) {
        _checkOutDate = selectedDate;
        _calculateTotalPrice();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.checkOutAfterCheckIn),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.confirmBooking, style: AppTextStyles.headingMedium),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${context.l10n.hotel}: ${widget.hotel.name}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text('${context.l10n.room}: ${widget.room.type}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${context.l10n.checkIn}: ${DateFormat('dd MMM yyyy').format(_checkInDate)}', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text('${context.l10n.checkOut}: ${DateFormat('dd MMM yyyy').format(_checkOutDate)}', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${context.l10n.total}: ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(price)}',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text('${context.l10n.method}: ${_paymentMethodLabel(context, _selectedPaymentMethod)}', style: AppTextStyles.bodyMedium),
            if (_selectedPaymentMethod == 'Credit Card')
              Text('${context.l10n.card}: ${_creditCardNumber.isNotEmpty ? _creditCardNumber : "-"}', style: AppTextStyles.bodySmall),
            if (_selectedPaymentMethod == 'Bank Transfer')
              Text('${context.l10n.selectBank}: $_selectedBank', style: AppTextStyles.bodySmall),
            if (_selectedPaymentMethod == 'E-Wallet')
              Text('E-Wallet: $_selectedEwallet', style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            Text(context.l10n.continueBooking, style: AppTextStyles.bodyLarge),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(context.l10n.cancel, style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(context.l10n.confirm, style: AppTextStyles.button.copyWith(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop();
              _prosesBooking();
            },
          ),
        ],
      ),
    );
  }

  void _prosesBooking() {
    final userId = context.read<UserProvider>().uid;
    DateTime paymentDeadline = DateTime.now().add(const Duration(hours: 1));
    String virtualAccountNumber = _generateVirtualAccountNumber();

    Map<String, dynamic> bookingData = {
      'roomId': widget.room.id,
      'hotelName': widget.hotel.name,
      'roomType': widget.room.type,
      'checkInDate': _checkInDate,
      'checkOutDate': _checkOutDate,
      'price': price,
      'bookingDate': DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()),
      'paymentMethod': _selectedPaymentMethod,
      'user': userId,
      'virtualAccountNumber': virtualAccountNumber,
    };

    if (_selectedPaymentMethod == 'Credit Card') {
      bookingData['creditCardNumber'] = _creditCardNumber;
    } else if (_selectedPaymentMethod == 'E-Wallet') {
      bookingData['eWalletName'] = _selectedEwallet;
    } else {
      bookingData['bankName'] = _selectedBank;
    }

    // --- ANIMATED LOADING DIALOG ---
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              DefaultTextStyle(
                style: AppTextStyles.label,
                child: Text(context.l10n.processingOrder),
              ),
            ],
          ),
        ),
      ),
    );

    FirebaseFirestore.instance
        .collection('bookings')
        .add(bookingData)
        .then((value) {
      Map<String, dynamic> historyData = {
        'historyType': 'hotel',
        'date': DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()),
        'paymentMethod': _selectedPaymentMethod,
        'price': price,
        'username': context.read<UserProvider>().username,
        'reviewed': false,
        'hotelID': widget.hotel.id,
        'hotelName': widget.hotel.name,
        'roomType': widget.room.type,
        'virtualAccountNumber': virtualAccountNumber,
        'pay': false,
        'paymentDeadline': paymentDeadline,
      };

      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('history')
          .add(historyData)
          .then((_) {
        Navigator.pop(context); // Tutup loading dialog

        // --- ANIMATED SUCCESS DIALOG ---
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animasi Centang Bouncy
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 84,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Animasi Slide Up untuk Teks dan Nomor VA
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(context.l10n.bookingSuccessful, style: AppTextStyles.headingMedium),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.thankYouBookingProcessed,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(context.l10n.virtualAccountNumberLabel, style: AppTextStyles.label),
                            const SizedBox(height: 8),
                            Text(
                              virtualAccountNumber,
                              style: AppTextStyles.headingMedium.copyWith(
                                letterSpacing: 2.5,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: AppPrimaryButton(
                          label: context.l10n.completePayment,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VirtualAccountPage(
                                  virtualAccountNumber: virtualAccountNumber,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).catchError((error) {
        Navigator.pop(context); // Tutup loading
        _showErrorDialog(context.l10n.error, context.l10n.failedToAddHistory(error.toString()));
      });
    }).catchError((error) {
      Navigator.pop(context); // Tutup loading
      _showErrorDialog(context.l10n.error, context.l10n.failedToProcessBooking(error.toString()));
    });
  }

  String _generateVirtualAccountNumber() {
    final random = Random();
    return List.generate(15, (index) => random.nextInt(10)).join();
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTextStyles.headingMedium.copyWith(color: AppColors.error)),
        content: Text(content, style: AppTextStyles.bodyMedium),
        actions: <Widget>[
          TextButton(
            child: Text(context.l10n.ok, style: AppTextStyles.button.copyWith(color: AppColors.primary)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // --- Widget Builders Pembantu ---
  
  Widget _buildDateBox(String title, DateTime date, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: AppDecorations.cardFlat,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.label),
              const SizedBox(height: 6),
              Text(
                DateFormat('dd MMM yyyy').format(date),
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(decoration: appBarGradient()),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(context.l10n.orderDetails, style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INFO KAMAR ---
            Container(
              decoration: AppDecorations.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.room.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        widget.room.imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(widget.room.type, style: AppTextStyles.headingMedium)),
                            AppChip(
                              label: widget.room.available ? context.l10n.available : context.l10n.full,
                              accent: !widget.room.available,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(widget.hotel.name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.sell_outlined, size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text('Rp ${currencyFormatter.format(widget.room.pricePerNight).split('Rp')[1]} / ${context.l10n.night}', 
                              style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.weekend_outlined, size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(widget.room.facilities.join(', '), style: AppTextStyles.bodyMedium),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- TANGGAL MENGINAP ---
            Text(context.l10n.stayDates, style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDateBox(context.l10n.checkIn, _checkInDate, () => _selectDate(context, _selectCheckInDate, _checkInDate)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward_rounded, color: AppColors.primaryLight),
                ),
                _buildDateBox(context.l10n.checkOut, _checkOutDate, () => _selectDate(context, _selectCheckOutDate, _checkOutDate)),
              ],
            ),
            const SizedBox(height: 24),

            // --- METODE PEMBAYARAN ---
            Text(context.l10n.paymentMethod, style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedPaymentMethod,
              decoration: AppDecorations.inputDecoration(context.l10n.selectPaymentMethod, icon: Icons.payment_rounded),
              icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
              items: <String>['Bank Transfer', 'Credit Card', 'E-Wallet'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_paymentMethodLabel(context, value), style: AppTextStyles.bodyLarge),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                  _selectedBank = 'BCA';
                  _creditCardNumber = '';
                  _selectedEwallet = 'OVO';
                });
              },
            ),

            if (_selectedPaymentMethod == 'Bank Transfer') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedBank,
                decoration: AppDecorations.inputDecoration(context.l10n.selectBank, icon: Icons.account_balance_rounded),
                icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
                items: <String>['BCA', 'BRI', 'BNI', 'Mandiri'].map((String bank) {
                  return DropdownMenuItem<String>(
                    value: bank,
                    child: Text(bank, style: AppTextStyles.bodyLarge),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedBank = value!),
              ),
            ],

            if (_selectedPaymentMethod == 'E-Wallet') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedEwallet,
                decoration: AppDecorations.inputDecoration(context.l10n.selectEWallet, icon: Icons.account_balance_wallet_rounded),
                icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
                items: <String>['DANA', 'OVO', 'Doku', 'Gopay'].map((String eWallet) {
                  return DropdownMenuItem<String>(
                    value: eWallet,
                    child: Text(eWallet, style: AppTextStyles.bodyLarge),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedEwallet = value!),
              ),
            ],

            if (_selectedPaymentMethod == 'Credit Card') ...[
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyLarge,
                decoration: AppDecorations.inputDecoration(context.l10n.creditCardNumber, icon: Icons.credit_card_rounded),
                onChanged: (value) => setState(() => _creditCardNumber = value),
              ),
            ],
            const SizedBox(height: 40), 
          ],
        ),
      ),
      
      // --- STICKY BOTTOM BAR ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16).copyWith(
          bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 8 : 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.totalPrice, style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormatter.format(price),
                    style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppPrimaryButton(
                label: context.l10n.confirm,
                icon: Icons.check_circle_outline_rounded,
                onTap: _confirmBooking,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _paymentMethodLabel(BuildContext context, String value) {
    if (value == 'Bank Transfer') return context.l10n.bankTransfer;
    if (value == 'Credit Card') return context.l10n.creditCard;
    if (value == 'E-Wallet') return 'E-Wallet';
    return value;
  }
}
