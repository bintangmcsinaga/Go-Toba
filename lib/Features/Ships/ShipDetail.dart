import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Features/Ships/VirtualAccountPage.dart';
import 'package:go_toba/Features/Ships/ShipModel.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';

class ShipTicketDetailPage extends StatefulWidget {
  final ShipTicket ticket;

  const ShipTicketDetailPage({super.key, required this.ticket});

  @override
  _ShipTicketDetailPageState createState() => _ShipTicketDetailPageState();
}

class _ShipTicketDetailPageState extends State<ShipTicketDetailPage> {
  String? _selectedDepartureTime;
  String? _selectedPaymentMethod;
  String? _selectedPaymentOption;
  DateTime? _selectedDate;
  int _selectedNumberOfPeople = 1;
  final TextEditingController _dateController = TextEditingController();

  final Map<String, List<String>> paymentOptions = {
    'E-Wallet': ['Dana', 'OVO', 'Doku'],
    'Bank Transfer': ['BRI', 'BCA', 'Mandiri'],
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
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat("dd-MM-yyyy").format(pickedDate);
      });
    }
  }

  void _showConfirmationDialog() {
    final String virtualAccountNumber = _generateVirtualAccountNumber();
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    final user = context.read<UserProvider>();
    // Capture parent context before entering dialog
    final BuildContext parentContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${widget.ticket.from}'),
              Text('To: ${widget.ticket.to}'),
              Text(
                  'Departure Date: ${_selectedDate != null ? DateFormat("dd-MM-yyyy").format(_selectedDate!) : 'Not selected'}'),
              Text('Departure Time: $_selectedDepartureTime'),
              Text('Number of People: $_selectedNumberOfPeople'),
              Text(
                  'Total Price: ${currencyFormatter.format(widget.ticket.price * _selectedNumberOfPeople)}'),
              Text('Payment Method: $_selectedPaymentMethod'),
              if (_selectedPaymentOption != null)
                Text('Payment Option: $_selectedPaymentOption'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final DateTime paymentDeadline =
                    DateTime.now().add(const Duration(hours: 1));
                final String formattedNow =
                    DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now());
                final String? formattedDepartDate = _selectedDate != null
                    ? DateFormat("dd-MM-yyyy").format(_selectedDate!)
                    : null;

                try {
                  await FirebaseFirestore.instance
                      .collection('Ship_ticket_bookings')
                      .add({
                    'totalPassanger': _selectedNumberOfPeople,
                    'ticketID': widget.ticket.id,
                    'userId': user.uid,
                    'username': user.username,
                    'bookingDate': formattedNow,
                    'origin': widget.ticket.from,
                    'destination': widget.ticket.to,
                    'departDate': formattedDepartDate,
                    'departTime': _selectedDepartureTime,
                    'price': widget.ticket.price * _selectedNumberOfPeople,
                    'paymentMethod': _selectedPaymentMethod,
                    'paymentOption': _selectedPaymentOption,
                    'virtualAccountNumber': virtualAccountNumber
                  });

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('history')
                      .add({
                    'totalPassanger': _selectedNumberOfPeople,
                    'historyType': 'Ship',
                    'ticketID': widget.ticket.id,
                    'userId': user.uid,
                    'username': user.username,
                    'date': formattedNow,
                    'origin': widget.ticket.from,
                    'destination': widget.ticket.to,
                    'departDate': formattedDepartDate,
                    'departTime': _selectedDepartureTime,
                    'price': widget.ticket.price * _selectedNumberOfPeople,
                    'paymentMethod': _selectedPaymentMethod,
                    'paymentOption': _selectedPaymentOption,
                    'pay': false,
                    'virtualAccountNumber': virtualAccountNumber,
                    'paymentDeadline': paymentDeadline
                  });

                  Fluttertoast.showToast(
                      msg: "Booking Success",
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.green,
                      textColor: Colors.white);

                  Navigator.pushReplacement(
                    parentContext,
                    MaterialPageRoute(
                      builder: (context) => VirtualAccountPage(
                        virtualAccountNumber: virtualAccountNumber,
                      ),
                    ),
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: "Booking failed: $e",
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white);
                }
              },
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: color2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Ticket Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 35,
                ),
                Text(
                  widget.ticket.from,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color2),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_downward_rounded,
              color: color2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 35,
                ),
                Text(
                  widget.ticket.to,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color2),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Depart Date:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _showDatePicker,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Departure Date',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Depart Time:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDepartureTime,
                  isDense: true,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDepartureTime = newValue;
                    });
                  },
                  items: widget.ticket.departTime
                      .map((time) => DropdownMenuItem<String>(
                            value: time,
                            child: Text(time),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Number of People:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedNumberOfPeople,
                  isDense: true,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedNumberOfPeople = newValue!;
                    });
                  },
                  items: List.generate(6, (index) => index + 1)
                      .map((number) => DropdownMenuItem<int>(
                            value: number,
                            child: Text(number.toString()),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  isDense: true,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue;
                      _selectedPaymentOption = null;
                    });
                  },
                  items: paymentOptions.keys
                      .map((method) => DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          ))
                      .toList(),
                ),
              ),
            ),
            if (_selectedPaymentMethod != null) const SizedBox(height: 20),
            if (_selectedPaymentMethod != null)
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Payment Option',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPaymentOption,
                    isDense: true,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPaymentOption = newValue;
                      });
                    },
                    items: paymentOptions[_selectedPaymentMethod]!
                        .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'Total Price: ${currencyFormatter.format(widget.ticket.price * _selectedNumberOfPeople)}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_selectedDate != null &&
                    _selectedDepartureTime != null &&
                    _selectedPaymentMethod != null &&
                    _selectedPaymentOption != null) {
                  _showConfirmationDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please select all required fields.'),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color2,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text(
                'Book Ticket',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
