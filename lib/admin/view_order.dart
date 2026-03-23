import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prm393/services/database.dart';
import 'package:prm393/widget/widget_support.dart';

class ViewOrder extends StatefulWidget {
  const ViewOrder({super.key});

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  Stream<QuerySnapshot>? _ordersStream;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    final stream = await DatabaseMethods().getAllOrders();
    setState(() {
      _ordersStream = stream;
    });
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đơn hàng", style: AppWidget.boldTextFieldStyle()),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Lỗi tải dữ liệu: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "Chưa có đơn hàng nào",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade500,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            );
          }

          // Chỉ lấy những đơn có ít nhất 1 item
          final orders = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final items = (data["items"] as List<dynamic>?) ?? [];
            return items.isNotEmpty;
          }).toList();

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "Chưa có đơn hàng nào",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade500,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final List items =
                  (data["items"] as List<dynamic>?) ?? [];
              final String status = data["status"] ?? "unknown";
              final String date = _formatDate(data["createdAt"] ?? "");
              final String userId =
                  (data["userId"] as String? ?? "").substring(
                      0,
                      (data["userId"] as String? ?? "").length > 8
                          ? 8
                          : (data["userId"] as String? ?? "").length);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "User: $userId...",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == "completed"
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status == "completed"
                                  ? "✅ Hoàn thành"
                                  : status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: status == "completed"
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Items
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.fastfood_outlined,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item["Name"] ?? "",
                                            style: AppWidget.SemiBoldTextFieldStyle(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if ((item as Map<String, dynamic>).containsKey("Options") && item["Options"].toString().isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(left: 24, top: 4),
                                        child: Text(
                                          item["Options"],
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: "Poppins"),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            Row(
                              children: [
                                Text(
                                  "x${item["Quantity"]}",
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontFamily: "Poppins"),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "\$${item["Total"]}",
                                  style: AppWidget.boldTextFieldStyle(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),

                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
