import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prm393/services/database.dart';
import 'package:prm393/widget/widget_support.dart';

class FoodReviewsPage extends StatefulWidget {
  final String foodName;

  const FoodReviewsPage({super.key, required this.foodName});

  @override
  State<FoodReviewsPage> createState() => _FoodReviewsPageState();
}

class _FoodReviewsPageState extends State<FoodReviewsPage> {
  Stream<QuerySnapshot>? _reviewsStream;
  int? filterStar; // null = tất cả

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() async {
    final stream = await DatabaseMethods().getReviewsByFoodName(widget.foodName);
    setState(() {
      _reviewsStream = stream;
    });
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text("Đánh giá", style: AppWidget.boldTextFieldStyle()),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reviewsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allReviews = snapshot.data?.docs ?? [];

          // Compute stats from all reviews
          double avgRating = 0;
          Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
          if (allReviews.isNotEmpty) {
            double sum = 0;
            for (final doc in allReviews) {
              final data = doc.data() as Map<String, dynamic>;
              final r = (data["rating"] ?? 0) as int;
              sum += r;
              if (starCounts.containsKey(r)) {
                starCounts[r] = starCounts[r]! + 1;
              }
            }
            avgRating = sum / allReviews.length;
          }

          // Apply filter
          final filtered = filterStar == null
              ? allReviews
              : allReviews.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data["rating"] == filterStar;
                }).toList();

          return Column(
            children: [
              // Summary header
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      widget.foodName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontFamily: "Poppins",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < avgRating.round()
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: Colors.amber,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${allReviews.length} đánh giá",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("Tất cả", null, allReviews.length),
                      _buildFilterChip("5⭐", 5, starCounts[5]!),
                      _buildFilterChip("4⭐", 4, starCounts[4]!),
                      _buildFilterChip("3⭐", 3, starCounts[3]!),
                      _buildFilterChip("2⭐", 2, starCounts[2]!),
                      _buildFilterChip("1⭐", 1, starCounts[1]!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Reviews list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review_outlined,
                                size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              filterStar != null
                                  ? "Không có đánh giá $filterStar sao"
                                  : "Chưa có đánh giá nào",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final data =
                              filtered[index].data() as Map<String, dynamic>;
                          final List images = data["images"] ?? [];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User + date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                              Colors.orange.shade100,
                                          child: Text(
                                            (data["userName"] ?? "?")
                                                .toString()
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.orange.shade800,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          data["userName"] ?? "Ẩn danh",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Poppins",
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _formatDate(data["createdAt"] ?? ""),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Stars
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < (data["rating"] ?? 0)
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                  ),
                                ),

                                // Comment
                                if ((data["comment"] ?? "").isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    data["comment"],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: "Poppins",
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],

                                // Images
                                if (images.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 80,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: images.length,
                                      itemBuilder: (context, imgIdx) {
                                        return GestureDetector(
                                          onTap: () {
                                            _showFullImage(
                                                context, images[imgIdx]);
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                images[imgIdx],
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, int? star, int count) {
    final isSelected = filterStar == star;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          "$label ($count)",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontFamily: "Poppins",
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.orange,
        backgroundColor: Colors.white,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Colors.orange : Colors.grey.shade300,
        ),
        onSelected: (_) {
          setState(() => filterStar = star);
        },
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
