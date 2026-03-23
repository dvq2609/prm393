import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:prm393/services/database.dart';
import 'package:prm393/services/shared_pref.dart';
import 'package:prm393/widget/widget_support.dart';

class OrderReviewPage extends StatefulWidget {
  final String orderId;
  final List<dynamic> items;

  const OrderReviewPage({
    super.key,
    required this.orderId,
    required this.items,
  });

  @override
  State<OrderReviewPage> createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<OrderReviewPage> {
  // Per-item review data
  Map<int, int> ratings = {};
  Map<int, TextEditingController> commentControllers = {};
  Map<int, List<File>> selectedImages = {};
  Map<int, List<String>> existingNetworkImages = {};
  Map<int, String> reviewIds = {};
  bool isSubmitting = false;
  bool alreadyReviewed = false;
  String? userId;
  String? userName;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.items.length; i++) {
      ratings[i] = 5;
      commentControllers[i] = TextEditingController();
      selectedImages[i] = [];
    }
    _loadData();
  }

  Future<void> _loadData() async {
    userId = await SharedPreferenceHelper().getUserId();
    userName = await SharedPreferenceHelper().getUserName();
    await _checkExistingReview();
  }

  Future<void> _checkExistingReview() async {
    final snap = await DatabaseMethods().getOrderReviews(widget.orderId);
    if (snap.docs.isNotEmpty) {
      if (mounted) {
        setState(() {
          alreadyReviewed = true;
          for (int i = 0; i < widget.items.length; i++) {
            final item = widget.items[i] as Map<String, dynamic>;
            final foodName = item["Name"] ?? "";
            
            try {
              final doc = snap.docs.firstWhere((d) {
                final data = d.data() as Map<String, dynamic>;
                return data['foodName'] == foodName;
              });
              
              final data = doc.data() as Map<String, dynamic>;
              ratings[i] = data['rating'] ?? 5;
              commentControllers[i]!.text = data['comment'] ?? "";
              existingNetworkImages[i] = List<String>.from(data['images'] ?? []);
              reviewIds[i] = doc.id;
            } catch (e) {
              // No previous review for this item (or item name mistmatch)
              existingNetworkImages[i] = [];
            }
          }
        });
      }
    } else {
      for (int i = 0; i < widget.items.length; i++) {
        existingNetworkImages[i] = [];
      }
    }
  }

  Future<void> _pickImages(int index) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 70);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        selectedImages[index]!
            .addAll(pickedFiles.map((f) => File(f.path)).toList());
      });
    }
  }

  void _removeLocalImage(int itemIndex, int imageIndex) {
    setState(() {
      selectedImages[itemIndex]!.removeAt(imageIndex);
    });
  }

  void _removeNetworkImage(int itemIndex, int imageIndex) {
    setState(() {
      existingNetworkImages[itemIndex]!.removeAt(imageIndex);
    });
  }

  Future<List<String>> _uploadImages(List<File> images, String foodName) async {
    List<String> urls = [];
    for (final img in images) {
      final ref = FirebaseStorage.instance.ref().child(
          "reviews/${DateTime.now().millisecondsSinceEpoch}_${urls.length}.jpg");
      await ref.putFile(img);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submitReviews() async {
    setState(() => isSubmitting = true);
    try {
      for (int i = 0; i < widget.items.length; i++) {
        final item = widget.items[i] as Map<String, dynamic>;
        final foodName = item["Name"] ?? "";
        
        List<String> imageUrls = [];
        // Keep existing ones
        if (existingNetworkImages.containsKey(i)) {
          imageUrls.addAll(existingNetworkImages[i]!);
        }
        
        if (selectedImages[i]!.isNotEmpty) {
          final newUrls = await _uploadImages(selectedImages[i]!, foodName);
          imageUrls.addAll(newUrls);
        }

        final reviewData = {
          "orderId": widget.orderId,
          "foodName": foodName,
          "rating": ratings[i],
          "comment": commentControllers[i]!.text.trim(),
          "images": imageUrls,
          "userId": userId ?? "",
          "userName": userName ?? "Ẩn danh",
          "createdAt": DateTime.now().toIso8601String(),
        };
        
        if (reviewIds.containsKey(i)) {
          await DatabaseMethods().updateReview(reviewIds[i]!, reviewData);
        } else {
          await DatabaseMethods().saveReview(reviewData);
        }
      }
      await DatabaseMethods().updateOrderReviewed(widget.orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
                alreadyReviewed ? "Cập nhật đánh giá thành công!" : "Đánh giá thành công!",
                style: const TextStyle(fontSize: 16)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Lỗi: $e", style: const TextStyle(fontSize: 14)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    for (final c in commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text(
          alreadyReviewed ? "Cập nhật đánh giá" : "Đánh giá đơn hàng",
          style: AppWidget.boldTextFieldStyle(),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: _buildReviewForm(),
    );
  }

  Widget _buildReviewForm() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index] as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food name
                    Row(
                      children: [
                        const Icon(Icons.fastfood_outlined,
                            size: 20, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item["Name"] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Star rating
                    const Text("Đánh giá:",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (starIdx) {
                        return GestureDetector(
                          onTap: () {
                            setState(() => ratings[index] = starIdx + 1);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              starIdx < ratings[index]!
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    // Comment
                    const Text("Bình luận:",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: commentControllers[index],
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                          hintText: "Chia sẻ trải nghiệm của bạn...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontFamily: "Poppins",
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Images
                    const Text("Hình ảnh:",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Existing Network Images
                        if (existingNetworkImages.containsKey(index))
                          ...List.generate(
                            existingNetworkImages[index]!.length,
                            (imgIdx) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    existingNetworkImages[index]![imgIdx],
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () => _removeNetworkImage(index, imgIdx),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Newly Selected Local Images
                        ...List.generate(
                          selectedImages[index]!.length,
                          (imgIdx) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImages[index]![imgIdx],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: GestureDetector(
                                  onTap: () => _removeLocalImage(index, imgIdx),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _pickImages(index),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.grey.shade400,
                                  style: BorderStyle.solid),
                            ),
                            child: Icon(Icons.add_photo_alternate_outlined,
                                size: 28, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Submit button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: isSubmitting ? null : _submitReviews,
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      alreadyReviewed ? "Cập nhật đánh giá" : "Gửi đánh giá",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
