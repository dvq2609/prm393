import 'package:flutter/material.dart';
import 'package:prm393/services/momo_payment_service.dart';
import 'package:prm393/services/wallet_service.dart';
import 'package:prm393/widget/widget_support.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> with WidgetsBindingObserver {
  int _selectedAmount = 10000;
  final MomoPaymentService _momoService = MomoPaymentService();
  final WalletService _walletService = WalletService();
  bool _isLoading = false;
  String? _currentOrderId;
  String? _currentRequestId;
  int? _pendingAmount; // Lưu số tiền đang chờ xác nhận

  final TextEditingController _customAmountController = TextEditingController();
  bool _isCustomAmount = false; // Đánh dấu có dùng số tiền tùy chỉnh không

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPaymentStatus();
    }
  }

  Future<void> _checkPaymentStatus() async {
    print('=== CHECK PAYMENT STATUS ===');
    print('_currentOrderId: $_currentOrderId');
    print('_currentRequestId: $_currentRequestId');

    if (_currentOrderId == null || _currentRequestId == null) {
      print('OrderId or RequestId is null - skipping check');
      return;
    }

    try {
      print('Checking payment status...');
      final response = await _momoService.checkStatus(
        orderId: _currentOrderId!,
        requestId: _currentRequestId!,
      );

      print('Response resultCode: ${response.resultCode}');
      print('Response message: ${response.message}');

      if (response.resultCode == 0) {
        print('Payment SUCCESS! Adding balance...');

        // Thanh toán thành công - cập nhật số dư
        final success = await _walletService.addBalance(
          amount: _pendingAmount ?? _selectedAmount,
          orderId: _currentOrderId!,
          transactionId: _currentRequestId!, // Dùng requestId đã lưu
        );

        print('Balance update success: $success');

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Nạp ${(_pendingAmount ?? _selectedAmount) ~/ 1000}k VND thành công!",
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Có lỗi khi cập nhật số dư!"),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Clear để tránh check lại
        _currentOrderId = null;
        _currentRequestId = null;
        _pendingAmount = null;
      } else if (response.resultCode == 1006) {
        // User đang thực hiện giao dịch - chờ
        print("Transaction in progress...");
        debugPrint("Transaction in progress...");
      } else {
        print('Payment FAILED! ResultCode: ${response.resultCode}');
        // Thanh toán thất bại
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Thanh toán thất bại! Mã lỗi: ${response.resultCode}",
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear
        _currentOrderId = null;
        _currentRequestId = null;
        _pendingAmount = null;
      }
    } catch (e) {
      print("ERROR checking status: $e");
      debugPrint("Error checking status: $e");
    }
  }

  void _handlePayment() async {
    // Lấy số tiền từ custom input hoặc button đã chọn
    int amountToPay = _selectedAmount;

    if (_isCustomAmount && _customAmountController.text.isNotEmpty) {
      final customAmount = int.tryParse(_customAmountController.text.replaceAll(',', ''));
      if (customAmount == null || customAmount < 1000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng nhập số tiền hợp lệ (tối thiểu 1,000 VND)"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      amountToPay = customAmount;
    }

    setState(() {
      _isLoading = true;
    });

    print('=== CREATING PAYMENT ===');
    print('Amount: $amountToPay');

    try {
      final response = await _momoService.createPayment(
        amount: amountToPay,
        orderInfo: 'Nap tien vi $amountToPay VND',
        onStatusUpdate: (status) {
          print('Status update: $status');
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

      // Lưu thông tin để verify sau
      _currentOrderId = response.orderId;
      _currentRequestId = response.requestId;
      _pendingAmount = amountToPay;

      print('Payment created:');
      print('OrderId: $_currentOrderId');
      print('RequestId: $_currentRequestId');
      print('Pending amount: $_pendingAmount');
    } catch (e) {
      print("Payment error: $e");
      debugPrint("Payment error: $e");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAmountButton(int amount) {
    bool isSelected = _selectedAmount == amount && !_isCustomAmount;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = amount;
          _isCustomAmount = false;
          _customAmountController.clear();
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
                              "Ví của bạn",
                              style: AppWidget.boldTextFieldStyle(),
                            ),
                            // Sử dụng StreamBuilder để hiển thị số dư realtime
                            StreamBuilder<int>(
                              stream: _walletService.getBalanceStream(),
                              builder: (context, snapshot) {
                                final balance = snapshot.data ?? 0;
                                return Text(
                                  "${balance.toStringAsFixed(0)} VND",
                                  style: AppWidget.SemiBoldTextFieldStyle(),
                                );
                              },
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
                  Text("Chọn mệnh giá", style: AppWidget.SemiBoldTextFieldStyle()),
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
                  const SizedBox(height: 20),

                  // Custom amount input
                  Text(
                    "Hoặc nhập số tiền khác",
                    style: AppWidget.SemiBoldTextFieldStyle(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(

                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: "Poppins",
                      ),
                      suffixText: "VND",
                      suffixStyle: const TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF009688),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF009688),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _isCustomAmount = true;
                        });
                      } else {
                        setState(() {
                          _isCustomAmount = false;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 30),
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