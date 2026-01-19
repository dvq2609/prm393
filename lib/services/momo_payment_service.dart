import 'package:momo_payment_flutter/momo_payment_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MomoPaymentService {
  late MomoPayment _momoPayment;

  // Credentials from prompt/reference
  final String _partnerCode = "MOMO";
  final String _accessKey = "F8BBA842ECF85";
  final String _secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";

  MomoPaymentService() {
    _initMomo();
  }

  void _initMomo() {
    _momoPayment = MomoPayment(
      partnerCode: _partnerCode,
      accessKey: _accessKey,
      secretKey: _secretKey,
      isTestMode:
          true, // Using Test environment as implied by "test-payment.momo.vn"
      isDebug: true,
    );
  }

  Future<MomoPaymentResponse> createPayment({
    required int amount,
    required String orderInfo,
    required Function(String status) onStatusUpdate,
  }) async {
    try {
      final orderId = 'Order_${DateTime.now().millisecondsSinceEpoch}';
      final requestId = 'Request_${DateTime.now().millisecondsSinceEpoch}';

      final paymentInfo = MomoPaymentInfo(
        orderId: orderId,
        orderInfo: orderInfo,
        amount: amount,
        redirectUrl: 'momopayment://return', // Standard redirect verify
        ipnUrl: 'https://example.com/ipn', // Placeholder IPN
        extraData: '',
        requestId: requestId,
        requestType: 'captureWallet',
        lang: 'vi',
      );

      // onStatusUpdate('Đang tạo giao dịch...');

      final response = await _momoPayment.createPayment(paymentInfo);

      if (response.payUrl != null && response.payUrl!.isNotEmpty) {
        // onStatusUpdate('Đang mở trang thanh toán...');
        final Uri url = Uri.parse(response.payUrl!);
        // Launch in external browser to ensure Web QR flow
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          onStatusUpdate('Không thể mở trình duyệt: ${response.payUrl}');
        }
      } else {
        onStatusUpdate(
          'Lỗi: ${response.message ?? "Không nhận được link thanh toán"}',
        );
      }
      return response;
    } catch (e) {
      onStatusUpdate('Lỗi ngoại lệ: $e');
      rethrow;
    }
  }

  Future<MomoPaymentResponse> checkStatus({
    required String orderId,
    required String requestId,
  }) async {
    return await _momoPayment.checkStatus(
      orderId: orderId,
      requestId: requestId,
    );
  }
}
