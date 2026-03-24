import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class GeminiAIService {
  static const String _apiKey = 'AIzaSyAYbRHwG7Nf9p21OCUpH6cXunAHjrGZ2sw';

  // Khởi tạo model
  late final GenerativeModel _model;

  GeminiAIService() {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  /// Hỏi AI tư vấn món ăn dựa trên thời gian và mảng danh sách món ăn
  Future<Map<String, dynamic>?> askForFoodSuggestion(
    String userPrompt,
    List<Map<String, dynamic>> menuItems,
  ) async {
    try {
      // 1. Quét Menu thành chuỗi chữ
      final menuString = menuItems
          .map((item) {
            String idInfo = item['id'] != null ? "ID: ${item['id']}" : "";
            return "- Món: ${item['Name'] ?? 'Không rõ'}, Giá: \$${item['Price'] ?? 0} $idInfo";
          })
          .join('\n');

      final systemPrompt =
          """
Bạn là một trợ lý ảo siêu thân thiện bán đồ ăn tại một quán ăn.
Nhiệm vụ của bạn là tư vấn đúng MỘT món ăn phù hợp nhất từ Menu để giải quyết nhu cầu của khách hàng.
Menu hiện tại:
$menuString

QUAN TRỌNG NHẤT: BÁN PHẢI TRẢ VỀ JSON HỢP LỆ VÀ KHÔNG KÈM THEO BẤT KỲ CHỮ NÀO KHÁC Ở NGOÀI JSON. KHÔNG markdown, KHÔNG blockcode. Cấu trúc:
{
  "name": "TÊN_MÓN",
  "price": GIÁ_TIỀN,
  "message": "Một câu sale đồ ăn cực mượt, trúng tim đen của khách."
}
Ngữ cảnh: Bây giờ là ${DateTime.now().hour} giờ.
""";

      // 2. Gửi cho Gemini
      final content = [
        Content.text("$systemPrompt\n\nÝ muốn của khách: $userPrompt"),
      ];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) return null;

      // 3. Gọt rửa chuỗi và Ép kiểu JSON
      String output = response.text!.trim();
      if (output.startsWith("```json"))
        output = output.substring(7);
      else if (output.startsWith("```"))
        output = output.substring(3);
      if (output.endsWith("```"))
        output = output.substring(0, output.length - 3);

      final Map<String, dynamic> result = jsonDecode(output.trim());
      return result;
    } catch (e, stackTrace) {
      print("========= LỖI TỪ GEMINI =========");
      print(e.toString());
      print(stackTrace.toString());
      print("=================================");
      return null;
    }
  }
}
