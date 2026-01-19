import 'package:flutter/material.dart';
import 'package:prm393/services/momo_payment_service.dart';
import 'package:prm393/widget/widget_support.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> with WidgetsBindingObserver {
  int _selectedAmount = 10000; // Default 10,000 VND
  final MomoPaymentService _momoService = MomoPaymentService();
  bool _isLoading = false;
  String? _currentOrderId;
  String? _currentRequestId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPaymentStatus();
    }
  }

  Future<void> _checkPaymentStatus() async {
    if (_currentOrderId == null || _currentRequestId == null) return;

    try {
      final response = await _momoService.checkStatus(
        orderId: _currentOrderId!,
        requestId: _currentRequestId!,
      );

      if (response.resultCode == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thanh toán thành công!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Clear fields to prevent duplicate checks
        _currentOrderId = null;
        _currentRequestId = null;
      } else {
        // Optional: handle failure silently or show error if user is expecting immediate result
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thanh toán thất bại!"),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error checking status: $e");
    }
  }

  void _handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _momoService.createPayment(
        amount: _selectedAmount,
        orderInfo: 'Nap tien vi $_selectedAmount VND',
        onStatusUpdate: (status) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );

      // Store IDs for verification when app resumes
      _currentOrderId = response.orderId;
      _currentRequestId = response.requestId;
    } catch (e) {
      // Error handled in service or already shown
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAmountButton(int amount) {
    bool isSelected = _selectedAmount == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = amount;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF009688) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.black12, width: 1)
              : null,
        ),
        child: Text(
          "${amount ~/ 1000}k",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "Wallet",
                      style: AppWidget.boldTextFieldStyle(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Image.asset(
                          "images/wallet.png",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your wallet",
                              style: AppWidget.boldTextFieldStyle(),
                            ),
                            Text(
                              "0 VND", // Placeholder balance
                              style: AppWidget.SemiBoldTextFieldStyle(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Add money", style: AppWidget.SemiBoldTextFieldStyle()),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAmountButton(10000),
                      _buildAmountButton(20000),
                      _buildAmountButton(50000),
                      _buildAmountButton(100000),
                    ],
                  ),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: _isLoading ? null : _handlePayment,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _isLoading
                            ? Colors.grey
                            : const Color(0xFF009688),
                      ),
                      child: Center(
                        child: Text(
                          _isLoading ? "Đang xử lý..." : "Thanh toán Momo",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
