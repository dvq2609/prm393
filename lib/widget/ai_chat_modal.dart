import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prm393/services/ai_service.dart';
import 'package:prm393/pages/details.dart';
import 'dart:convert';

class AiChatBottomSheet extends StatefulWidget {
  const AiChatBottomSheet({Key? key}) : super(key: key);

  @override
  _AiChatBottomSheetState createState() => _AiChatBottomSheetState();
}

class _AiChatBottomSheetState extends State<AiChatBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final GeminiAIService _aiService = GeminiAIService();

  List<Map<String, dynamic>> _menuItems = [];
  final List<Map<String, String>> _chatHistory = [];
  Map<String, dynamic>? _suggestedItem;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMenuAndInitChat();
  }

  Future<void> _loadMenuAndInitChat() async {
    setState(() => _isLoading = true);
    // Fetch menu
    List<Map<String, dynamic>> items = [];
    final categories = ["Ice-cream", "Pizza", "Salad", "Burger"];
    for (String cat in categories) {
      try {
        final snap = await FirebaseFirestore.instance.collection(cat).get();
        for (var doc in snap.docs) {
          var data = doc.data();
          data['id'] = doc.id;
          data['category'] = cat;
          items.add(data);
        }
      } catch (e) {
        print('Error loading $cat: $e');
      }
    }
    _menuItems = items;

    // Initial prompt
    await _askAI(
      "Gợi ý ngẫu nhiên 1 món ăn cực kỳ hấp dẫn để khách chốt đơn ngay lúc này.",
    );
  }

  Future<void> _askAI(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      _chatHistory.add({"role": "user", "text": userMessage});
      _isLoading = true;
      _suggestedItem = null;
      _controller.clear();
    });

    final aiResult = await _aiService.askForFoodSuggestion(
      userMessage,
      _menuItems,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (aiResult != null && aiResult.containsKey("message")) {
        _chatHistory.add({
          "role": "ai",
          "text": aiResult["message"].toString(),
        });

        // Find the matched item
        if (aiResult.containsKey("name")) {
          try {
            _suggestedItem = _menuItems.firstWhere((item) {
              String itemName = item['Name'].toString().toLowerCase();
              String aiName = aiResult["name"].toString().toLowerCase();
              return itemName.contains(aiName) || aiName.contains(itemName);
            });
          } catch (e) {
            print("Món AI chọn không có trong menu chính xác.");
          }
        }
      } else {
        _chatHistory.add({
          "role": "ai",
          "text": "Hệ thống AI đang bận quá, bạn thử lại sau nha!",
        });
      }
    });
  }

  void _goToDetails() {
    if (_suggestedItem == null) return;
    Navigator.pop(context); // Đóng Bottom Sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Details(
          name: _suggestedItem!["Name"],
          price: _suggestedItem!["Price"].toString(),
          image: _suggestedItem!["Image"],
          detail: _suggestedItem!["Detail"] ?? "Món này siêu ngon, thử ngay bạn nhé!",
          sizes: _suggestedItem!.containsKey("Sizes") ? _suggestedItem!["Sizes"] : null,
          toppings: _suggestedItem!.containsKey("Toppings") ? _suggestedItem!["Toppings"] : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                " Gợi ý món",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final msg = _chatHistory[index];
                bool isUser = msg["role"] == "user";
                // Only show user messages if they typed it manually, ignore the initial random trigger
                if (isUser &&
                    index == 0 &&
                    msg["text"]!.contains("Gợi ý ngẫu nhiên 1 món ăn")) {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.orange.shade100
                          : Colors.grey.shade100,
                      border: isUser
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isUser
                            ? const Radius.circular(15)
                            : const Radius.circular(0),
                        bottomRight: isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(color: Colors.orange),
            ),

          if (_suggestedItem != null)
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.orange.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildImage(_suggestedItem!["Image"]),
                ),
                title: Text(
                  _suggestedItem!["Name"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "\$${_suggestedItem!["Price"]}",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: _goToDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Xem Chi Tiết"),
                ),
              ),
            ),

          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Không ưng? Thử đòi món khác đi...",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: _askAI,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.orange,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: () => _askAI(_controller.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(dynamic imageData) {
    try {
      if (imageData.toString().startsWith("base64,")) {
        return Image.memory(
          base64Decode(imageData.toString().substring(7)),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        );
      } else if (imageData.toString().startsWith("http")) {
        return Image.network(
          imageData.toString(),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        );
      } else {
        return Image.asset(
          imageData.toString().replaceAll("file:///", ""),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      return Container(
        width: 60,
        height: 60,
        color: Colors.grey.shade200,
        child: const Icon(Icons.fastfood, color: Colors.grey),
      );
    }
  }
}
