import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Features/Culinary/KulinerModel.dart';
import 'package:go_toba/Features/Culinary/VirtualAccountPage.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart'; // Import design system

class KulinerPayment extends StatefulWidget {
  final KulinerModel kuliner;

  const KulinerPayment({super.key, required this.kuliner});

  @override
  State<KulinerPayment> createState() => _KulinerPaymentState();
}

class _KulinerPaymentState extends State<KulinerPayment> {
  final TextEditingController _completeAddressController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _detailBangunanController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String _selectedPaymentMethod = 'Bank Transfer';
  String _selectedEWallet = 'Gopay';
  String _selectedBankTransfer = 'BCA';
  int _quantity = 1;

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delivery Address Details', style: AppTextStyles.headingMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  style: AppTextStyles.bodyLarge,
                  decoration: AppDecorations.inputDecoration('Street / Landmark', icon: Icons.map_rounded),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _kecamatanController,
                  style: AppTextStyles.bodyLarge,
                  decoration: AppDecorations.inputDecoration('District', icon: Icons.location_city_rounded),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _detailBangunanController,
                  style: AppTextStyles.bodyLarge,
                  decoration: AppDecorations.inputDecoration('Building Details (House No., Color)', icon: Icons.home_work_rounded),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noHpController,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.bodyLarge,
                  decoration: AppDecorations.inputDecoration('Active Phone Number', icon: Icons.phone_rounded),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: AppTextStyles.label),
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
                      if (_addressController.text.isEmpty || _noHpController.text.isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Street address and phone number are required!'), backgroundColor: AppColors.error)
                         );
                         return;
                      }
                      
                      Navigator.pop(context);
                      setState(() {
                        _completeAddressController.text = '${_addressController.text}, '
                            '${_kecamatanController.text}, '
                            '${_detailBangunanController.text} (Phone: ${_noHpController.text})';
                      });
                    },
                    child: Text('Save', style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _confirmPurchase() {
    if (_completeAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the delivery address first.'), backgroundColor: AppColors.error),
      );
      return;
    }

    int totalPrice = widget.kuliner.price * _quantity;
    final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Confirm Order', style: AppTextStyles.headingMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order:', style: AppTextStyles.label),
              Text('${widget.kuliner.name} ($_quantity portions)', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 12),
              
              Text('Address:', style: AppTextStyles.label),
              Text(_completeAddressController.text, style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              
              Text('Notes:', style: AppTextStyles.label),
              Text(_notesController.text.isEmpty ? '-' : _notesController.text, style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              
              Text('Payment:', style: AppTextStyles.label),
              Text('$_selectedPaymentMethod (${_selectedPaymentMethod == 'E-Wallet' ? _selectedEWallet : _selectedBankTransfer})', style: AppTextStyles.bodyMedium),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.divider),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyles.headingSmall),
                  Text(currencyFormatter.format(totalPrice), style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTextStyles.label),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _processPayment();
              },
              child: Text('Order Now', style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPayment() async {
    // Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.soft),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              DefaultTextStyle(style: AppTextStyles.label, child: const Text('Processing your order...')),
            ],
          ),
        ),
      ),
    );

    String virtualAccountNumber = _generateVirtualAccountNumber();
    final user = context.read<UserProvider>();
    DateTime paymentDeadline = DateTime.now().add(const Duration(hours: 1));
    String address = _completeAddressController.text;
    String notes = _notesController.text;
    int totalPrice = widget.kuliner.price * _quantity;

    try {
      Map<String, dynamic> purchaseData = {
        'kulinerId': widget.kuliner.id,
        'kulinerName': widget.kuliner.name,
        'quantity': _quantity,
        'totalPrice': totalPrice,
        'date': Timestamp.now(),
        'userid': user.uid
      };
      await FirebaseFirestore.instance.collection('kuliner_log').add(purchaseData);

      Map<String, dynamic> historyData = {
        'historyType': 'kuliner',
        'date': DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now()),
        'paymentMethod': _selectedPaymentMethod,
        'paymentOption': _selectedPaymentMethod == 'E-Wallet' ? _selectedEWallet : _selectedBankTransfer,
        'price': totalPrice,
        'username': user.username,
        'kulinerID': widget.kuliner.id,
        'kulinerName': widget.kuliner.name,
        'quantity': _quantity,
        'address': address,
        'notes': notes,
        'pay': false,
        'virtualAccountNumber': virtualAccountNumber,
        'paymentDeadline': paymentDeadline,
      };
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('history').add(historyData);

      if (mounted) Navigator.pop(context); // Tutup loading

      // Tampilkan Sukses Animasi
      if (mounted) {
        showDialog(
          context: context,
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
                      Text('Order Successful!', style: AppTextStyles.headingMedium),
                      const SizedBox(height: 8),
                      Text('Complete your payment so the food can be processed.', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
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
                            Text(virtualAccountNumber, style: AppTextStyles.headingMedium.copyWith(letterSpacing: 2.5, color: AppColors.primaryDark, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: AppPrimaryButton(
                          label: 'Continue to Payment',
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => VirtualAccountPage(virtualAccountNumber: virtualAccountNumber)),
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
      }
    } catch (error) {
      if (mounted) Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error'), backgroundColor: AppColors.error));
    }
  }

  String _generateVirtualAccountNumber() {
    final random = Random();
    return List.generate(15, (index) => random.nextInt(10)).join();
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    int totalPrice = widget.kuliner.price * _quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(decoration: appBarGradient()),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text('Order', style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KARTU PENGIRIMAN ---
            Text('Delivery Address', style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showAddressDialog,
              child: Container(
                decoration: AppDecorations.card,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_completeAddressController.text.isEmpty ? 'Choose Delivery Address' : 'Your Address', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            _completeAddressController.text.isEmpty ? 'Not set yet' : _completeAddressController.text,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: _completeAddressController.text.isEmpty ? AppColors.error : AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Text('Order Details', style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            
            // --- KARTU MENU KULINER ---
            Container(
              decoration: AppDecorations.card,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(widget.kuliner.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.kuliner.name, style: AppTextStyles.headingSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(currencyFormatter.format(widget.kuliner.price), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.divider, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Portion Quantity', style: AppTextStyles.bodyMedium),
                      Container(
                        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider)),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_rounded, size: 18),
                              color: AppColors.textSecondary,
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                            ),
                            Text('$_quantity', style: AppTextStyles.headingSmall),
                            IconButton(
                              icon: const Icon(Icons.add_rounded, size: 18),
                              color: AppColors.primary,
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    style: AppTextStyles.bodyMedium,
                    decoration: AppDecorations.inputDecoration('Notes (e.g., spicy, no celery)', icon: Icons.edit_note_rounded),
                    maxLines: 2,
                    minLines: 1,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text('Payment Method', style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            
            // --- KARTU METODE PEMBAYARAN ---
            Container(
              decoration: AppDecorations.card,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPaymentMethod,
                    decoration: AppDecorations.inputDecoration('Payment Type', icon: Icons.payment_rounded),
                    icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                    items: ['Bank Transfer', 'E-Wallet'].map((method) => DropdownMenuItem(value: method, child: Text(method, style: AppTextStyles.bodyLarge))).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedPaymentMethod == 'E-Wallet')
                    DropdownButtonFormField<String>(
                      initialValue: _selectedEWallet,
                      decoration: AppDecorations.inputDecoration('Select E-Wallet', icon: Icons.account_balance_wallet_rounded),
                      icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
                      onChanged: (value) => setState(() => _selectedEWallet = value!),
                      items: ['Gopay', 'Ovo', 'Dana', 'ShopeePay'].map((ewallet) => DropdownMenuItem(value: ewallet, child: Text(ewallet, style: AppTextStyles.bodyLarge))).toList(),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBankTransfer,
                      decoration: AppDecorations.inputDecoration('Select Bank', icon: Icons.account_balance_rounded),
                      icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
                      onChanged: (value) => setState(() => _selectedBankTransfer = value!),
                      items: ['BCA', 'BRI', 'BNI', 'Mandiri'].map((bank) => DropdownMenuItem(value: bank, child: Text(bank, style: AppTextStyles.bodyLarge))).toList(),
                    ),
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
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Price', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormatter.format(totalPrice),
                    style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppPrimaryButton(
                label: 'Pay',
                icon: Icons.check_circle_outline_rounded,
                onTap: _confirmPurchase,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
