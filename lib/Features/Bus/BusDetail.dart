import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Features/Bus/BusModel.dart';
import 'package:go_toba/Features/Bus/VirtualAccountPage.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart'; // Import design system

class BusTicketDetailPage extends StatefulWidget {
  final BusTicket ticket;

  const BusTicketDetailPage({super.key, required this.ticket});

  @override
  _BusTicketDetailPageState createState() => _BusTicketDetailPageState();
}

class _BusTicketDetailPageState extends State<BusTicketDetailPage> {
  String? _selectedDepartureTime;
  String? _selectedPaymentMethod;
  String? _selectedPaymentOption;
  DateTime? _selectedDate;
  int _selectedNumberOfPeople = 1;
  final TextEditingController _dateController = TextEditingController();

  final Map<String, List<String>> paymentOptions = {
    'E-Wallet': ['Dana', 'OVO', 'Doku', 'Gopay'],
    'Transfer Bank': ['BRI', 'BCA', 'Mandiri', 'BNI'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.ticket.departTime.isNotEmpty) {
      _selectedDepartureTime = widget.ticket.departTime.first;
    }
  }

  String _generateVirtualAccountNumber() {
    final random = Random.secure();
    final accountNumber =
        List.generate(15, (index) => random.nextInt(10)).join();
    return accountNumber;
  }

  void _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat("dd MMM yyyy").format(pickedDate);
      });
    }
  }

  void _showConfirmationDialog() {
    final String virtualAccountNumber = _generateVirtualAccountNumber();
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    final user = context.read<UserProvider>();
    final BuildContext parentContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Konfirmasi Pesanan', style: AppTextStyles.headingMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rute Perjalanan', style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text('${widget.ticket.from} ➔ ${widget.ticket.to}', style: AppTextStyles.bodyMedium),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.divider),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal', style: AppTextStyles.label),
                      Text(_selectedDate != null ? DateFormat("dd MMM yyyy").format(_selectedDate!) : '-', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Waktu', style: AppTextStyles.label),
                      Text('$_selectedDepartureTime', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ],
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.divider),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Penumpang', style: AppTextStyles.bodyMedium),
                  Text('$_selectedNumberOfPeople Orang', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pembayaran', style: AppTextStyles.bodyMedium),
                  Text('$_selectedPaymentOption', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Harga', style: AppTextStyles.headingSmall),
                    Text(
                      currencyFormatter.format(widget.ticket.price * _selectedNumberOfPeople),
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Konfirmasi', style: AppTextStyles.button.copyWith(color: Colors.white)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _processBooking(parentContext, user, virtualAccountNumber);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _processBooking(BuildContext parentContext, UserProvider user, String virtualAccountNumber) async {
    // --- ANIMATED LOADING DIALOG ---
    showDialog(
      context: parentContext,
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
                child: const Text('Memproses pesanan...'),
              ),
            ],
          ),
        ),
      ),
    );

    final DateTime paymentDeadline = DateTime.now().add(const Duration(hours: 1));
    final String formattedNow = DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now());
    final String? formattedDepartDate = _selectedDate != null ? DateFormat("dd-MM-yyyy").format(_selectedDate!) : null;
    final int totalPrice = widget.ticket.price * _selectedNumberOfPeople;

    try {
      await FirebaseFirestore.instance.collection('bus_ticket_bookings').add({
        'totalPassanger': _selectedNumberOfPeople,
        'ticketID': widget.ticket.id,
        'transportName': widget.ticket.transportName,
        'userId': user.uid,
        'username': user.username,
        'bookingDate': formattedNow,
        'origin': widget.ticket.from,
        'destination': widget.ticket.to,
        'departDate': formattedDepartDate,
        'departTime': _selectedDepartureTime,
        'price': totalPrice,
        'paymentMethod': _selectedPaymentMethod,
        'paymentOption': _selectedPaymentOption,
        'virtualAccountNumber': virtualAccountNumber
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add({
        'totalpassanger': _selectedNumberOfPeople,
        'historyType': 'bus',
        'ticketID': widget.ticket.id,
        'transportName': widget.ticket.transportName,
        'userId': user.uid,
        'username': user.username,
        'date': formattedNow,
        'origin': widget.ticket.from,
        'destination': widget.ticket.to,
        'departDate': formattedDepartDate,
        'departTime': _selectedDepartureTime,
        'price': totalPrice,
        'paymentMethod': _selectedPaymentMethod,
        'paymentOption': _selectedPaymentOption,
        'pay': false,
        'virtualAccountNumber': virtualAccountNumber,
        'paymentDeadline': paymentDeadline,
      });

      // Tutup loading
      Navigator.pop(parentContext);

      // --- ANIMATED SUCCESS DIALOG ---
      showDialog(
        context: parentContext,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 84),
                  );
                },
              ),
              const SizedBox(height: 24),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                  );
                },
                child: Column(
                  children: [
                    Text('Pesanan Berhasil!', style: AppTextStyles.headingMedium),
                    const SizedBox(height: 8),
                    Text('Silakan selesaikan pembayaran.', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Text('No. Virtual Account', style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          Text(
                            virtualAccountNumber,
                            style: AppTextStyles.headingMedium.copyWith(letterSpacing: 2.5, color: AppColors.primaryDark, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: AppPrimaryButton(
                        label: 'Lanjut ke Pembayaran',
                        onTap: () {
                          Navigator.pushReplacement(
                            parentContext,
                            MaterialPageRoute(
                              builder: (context) => VirtualAccountPage(virtualAccountNumber: virtualAccountNumber),
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
    } catch (e) {
      Navigator.pop(parentContext); // Tutup loading
      Fluttertoast.showToast(
          msg: "Booking failed: $e",
          gravity: ToastGravity.TOP,
          backgroundColor: AppColors.error,
          textColor: Colors.white);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
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
        title: Text(
          'Detail Pemesanan',
          style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- KARTU RUTE ---
            Container(
              decoration: AppDecorations.card,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Operator Travel', style: AppTextStyles.headingSmall),
                      AppChip(label: widget.ticket.transportName, accent: true),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 20),
                          Container(height: 30, width: 2, color: AppColors.divider),
                          const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 24),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dari', style: AppTextStyles.caption),
                            Text(widget.ticket.from, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            Text('Tujuan', style: AppTextStyles.caption),
                            Text(widget.ticket.to, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text('Jadwal & Penumpang', style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            
            // --- KARTU FORM ---
            Container(
              decoration: AppDecorations.card,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showDatePicker,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dateController,
                        style: AppTextStyles.bodyLarge,
                        decoration: AppDecorations.inputDecoration('Tanggal Keberangkatan', icon: Icons.calendar_month_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDepartureTime,
                    decoration: AppDecorations.inputDecoration('Waktu Keberangkatan', icon: Icons.schedule_rounded),
                    icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
                    onChanged: (newValue) => setState(() => _selectedDepartureTime = newValue),
                    items: widget.ticket.departTime
                        .map((time) => DropdownMenuItem(value: time, child: Text(time, style: AppTextStyles.bodyLarge)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedNumberOfPeople,
                    decoration: AppDecorations.inputDecoration('Jumlah Penumpang', icon: Icons.group_rounded),
                    icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
                    onChanged: (newValue) => setState(() => _selectedNumberOfPeople = newValue!),
                    items: List.generate(6, (index) => index + 1)
                        .map((number) => DropdownMenuItem(value: number, child: Text('$number Orang', style: AppTextStyles.bodyLarge)))
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('Metode Pembayaran', style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            
            // --- KARTU PEMBAYARAN ---
            Container(
              decoration: AppDecorations.card,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: AppDecorations.inputDecoration('Pilih Jenis', icon: Icons.account_balance_wallet_rounded),
                    icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPaymentMethod = newValue;
                        _selectedPaymentOption = null;
                      });
                    },
                    items: paymentOptions.keys
                        .map((method) => DropdownMenuItem(value: method, child: Text(method, style: AppTextStyles.bodyLarge)))
                        .toList(),
                  ),
                  if (_selectedPaymentMethod != null) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentOption,
                      decoration: AppDecorations.inputDecoration('Pilih Bank/Provider', icon: Icons.account_balance_rounded),
                      icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
                      onChanged: (newValue) => setState(() => _selectedPaymentOption = newValue),
                      items: paymentOptions[_selectedPaymentMethod]!
                          .map((option) => DropdownMenuItem(value: option, child: Text(option, style: AppTextStyles.bodyLarge)))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
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
                  Text('Total Harga', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormatter.format(widget.ticket.price * _selectedNumberOfPeople),
                    style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppPrimaryButton(
                label: 'Pesan',
                icon: Icons.confirmation_number_rounded,
                onTap: () {
                  if (_selectedDate != null &&
                      _selectedDepartureTime != null &&
                      _selectedPaymentMethod != null &&
                      _selectedPaymentOption != null) {
                    _showConfirmationDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Mohon lengkapi semua data.'),
                      backgroundColor: AppColors.warning,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}