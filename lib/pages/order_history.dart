import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prm393/services/database.dart';
import 'package:prm393/services/shared_pref.dart';
import 'package:prm393/widget/widget_support.dart';
import 'package:prm393/pages/order_tracking.dart';
import 'package:latlong2/latlong.dart';
class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  Stream<QuerySnapshot>? _ordersStream;
  String? id;

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  void _loadUserOrders() async {
    id = await SharedPreferenceHelper().getUserId();
    if (id != null) {
      final stream = await DatabaseMethods().getUserOrders(id!);
      setState(() {
        _ordersStream = stream;
      });
    }
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
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text("Lịch sử đơn hàng", style: AppWidget.boldTextFieldStyle()),
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
                    "Bạn chưa có đơn hàng nào",
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

          // Filter empty orders and sort by createdAt manually since we can't combine where + orderby without index
          final orders = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final items = (data["items"] as List<dynamic>?) ?? [];
            return items.isNotEmpty;
          }).toList();

          // Sort descending by date
          orders.sort((a, b) {
            final dateA = (a.data() as Map<String, dynamic>)["createdAt"] ?? "";
            final dateB = (b.data() as Map<String, dynamic>)["createdAt"] ?? "";
            return dateB.compareTo(dateA);
          });

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "Bạn chưa có đơn hàng nào",
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
              final int cartTotal = data["totalAmount"] ?? 0;

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
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontFamily: "Poppins",
                            ),
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
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.fastfood_outlined,
                                    size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  item["Name"] ?? "",
                                  style: AppWidget.SemiBoldTextFieldStyle(),
                                ),
                              ],
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
                    // Total Footer
                    const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng cộng",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins"
                            ),
                          ),
                          Text(
                            "\$$cartTotal",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontFamily: "Poppins"
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (data["deliveryLat"] != null && data["deliveryLng"] != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map, size: 20),
                            label: const Text("Theo dõi lộ trình giao hàng"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12)
                            ),
                            onPressed: () {
                              final double lat = data["deliveryLat"] is int ? (data["deliveryLat"] as int).toDouble() : data["deliveryLat"];
                              final double lng = data["deliveryLng"] is int ? (data["deliveryLng"] as int).toDouble() : data["deliveryLng"];
                              Navigator.push(context, MaterialPageRoute(builder: (context) => OrderTrackingPage(
                                customerLocation: LatLng(lat, lng),
                                shipperLocation: const LatLng(21.0264, 105.8037), // Dummy shipper (Hà Nội Center)
                              )));
                            },
                          ),
                        ),
                      )
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
