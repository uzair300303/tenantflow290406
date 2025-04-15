import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/components/my_textfield.dart';
import 'package:tenantflow/constants.dart';

class RentPaymentPage extends StatefulWidget {
  const RentPaymentPage({super.key});

  @override
  _RentPaymentPageState createState() => _RentPaymentPageState();
}

class _RentPaymentPageState extends State<RentPaymentPage> {
  final TextEditingController amountController = TextEditingController();
  String _selectedMethod = 'UPI'; // Default to UPI for India
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTransactions = prefs.getString('payment_history');
    if (savedTransactions != null) {
      setState(() {
        transactions = List<Map<String, dynamic>>.from(jsonDecode(savedTransactions));
      });
    }
  }

  Future<void> _saveTransaction(Map<String, dynamic> transaction) async {
    transactions.add(transaction);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('payment_history', jsonEncode(transactions));
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      isLoading = false;
    });
    final transaction = {
      'amount': amountController.text,
      'method': _selectedMethod,
      'status': 'Success',
      'date': DateTime.now().toIso8601String(),
      'paymentId': response.paymentId,
    };
    _saveTransaction(transaction).then((_) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Successful! ID: ${response.paymentId}',
              style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.blue,
        ),
      );
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isLoading = false;
    });
    final transaction = {
      'amount': amountController.text,
      'method': _selectedMethod,
      'status': 'Failed',
      'date': DateTime.now().toIso8601String(),
      'error': response.message,
    };
    _saveTransaction(transaction).then((_) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: ${response.message}',
              style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Optional: Handle wallet selection (e.g., PhonePe)
  }

  Future<void> _initiatePayment() async {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty || double.tryParse(amountText) == null || double.parse(amountText) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid amount', style: TextStyle(fontFamily: 'Poppins')),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final options = {
      'key': razorpayKeyId,
      'amount': (double.parse(amountText) * 100).toInt(), // Convert to paise
      'name': 'TenantFlow Rent Payment',
      'description': 'Rent payment via ${_selectedMethod}',
      'prefill': {
        'contact': '1234567890', // Mock for testing; replace with tenant data later
        'email': 'tenant@example.com',
      },
      'method': {
        'upi': _selectedMethod == 'UPI',
        'netbanking': _selectedMethod == 'Bank Transfer',
      },
      'retry': {'enabled': true, 'max_count': 3}, // Allow retries
      'config': {
        'display': {
          'hide': [
            {'method': 'card'},
            {'method': 'wallet'},
          ], // Focus on UPI and netbanking
        },
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Razorpay Error: $e"); // Log to terminal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Razorpay Error: $e', style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Rent', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Rent Details',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: amountController,
                hintText: 'Enter amount (₹)',
                obscureText: false,
                showVisibilityToggle: false,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Payment Method',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
              ),
              RadioListTile<String>(
                title: const Text('UPI', style: TextStyle(fontFamily: 'Poppins')),
                value: 'UPI',
                groupValue: _selectedMethod,
                onChanged: (value) => setState(() => _selectedMethod = value!),
                activeColor: Colors.blue,
              ),
              RadioListTile<String>(
                title: const Text('Bank Transfer (NEFT/IMPS)',
                    style: TextStyle(fontFamily: 'Poppins')),
                value: 'Bank Transfer',
                groupValue: _selectedMethod,
                onChanged: (value) => setState(() => _selectedMethod = value!),
                activeColor: Colors.blue,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                  : MyButton(
                      onTap: _initiatePayment,
                      text: 'Pay Now',
                    ),
              const SizedBox(height: 30),
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              transactions.isEmpty
                  ? const Text(
                      'No transactions yet',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              '₹${tx['amount']} via ${tx['method']}',
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                            subtitle: Text(
                              '${tx['status']} on ${tx['date'].substring(0, 10)}',
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                            trailing: tx['status'] == 'Failed'
                                ? IconButton(
                                    icon: const Icon(Icons.refresh, color: Colors.red),
                                    onPressed: () {
                                      amountController.text = tx['amount'];
                                      _selectedMethod = tx['method'];
                                      _initiatePayment();
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    _razorpay.clear();
    super.dispose();
  }
}