import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prm393/widget/widget_support.dart';

class ViewTransactions extends StatefulWidget {
  const ViewTransactions({super.key});

  @override
  State<ViewTransactions> createState() => _ViewTransactionsState();
}

class _ViewTransactionsState extends State<ViewTransactions> {
  // Lấy dữ liệu qua CollectionGroup
  Stream<QuerySnapshot> getAllTransactions() {
    return FirebaseFirestore.instance
        .collectionGroup('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Transactions", style: AppWidget.boldTextFieldStyle()),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: getAllTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Lỗi tải dữ liệu. Bạn hãy check Console.\nFirebase có thể yêu cầu tạo Index cho Collection Group Query.\n\nChi tiết lỗi:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "Không có bất kỳ giao dịch nào.",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                int amount = data['amount'] ?? 0;
                String type =
                    data['type'] ?? 'unknown'; // deposit hoặc withdraw
                String orderId = data['orderId'] ?? 'N/A';

                // Format date
                String dateString = 'Unknown date';
                if (data['createdAt'] != null) {
                  Timestamp t = data['createdAt'] as Timestamp;
                  DateTime d = t.toDate();
                  dateString = DateFormat('dd/MM/yyyy HH:mm:ss').format(d);
                }

                // Xác định màu tuỳ loại giao dịch
                Color amountColor = type == 'deposit'
                    ? Colors.green
                    : Colors.red;
                String sign = type == 'deposit' ? '+' : '';

                return Card(
                  elevation: 3.0,
                  margin: const EdgeInsets.only(bottom: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                color: amountColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "$sign$amount VND",
                              style: TextStyle(
                                color: amountColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "OrderID: $orderId",
                          style: AppWidget.LightTextFieldStyle(),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "Date: $dateString",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
