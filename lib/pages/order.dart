
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prm393/services/database.dart';
import 'package:prm393/services/shared_pref.dart';
import 'package:prm393/services/wallet_service.dart';
import 'package:prm393/widget/widget_support.dart';
import 'package:latlong2/latlong.dart';
import 'package:prm393/pages/location_picker.dart';
class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? id;
  int total = 0, amount2 = 0;
  final WalletService _walletService = WalletService();
  LatLng? deliveryLocation;

  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          amount2 = total;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  ontheload()async{
    await getthesharedpref();
    foodStream= await DatabaseMethods().getFoodCart(id!);
    setState(() {

    });
  }

  @override
  void initState() {
    ontheload();
    startTimer();
    super.initState();
  }

  Stream? foodStream;

  Widget foodCart() {
    return StreamBuilder(
        stream: foodStream,
        builder: (context, AsyncSnapshot snapshot) {
          total = 0;
          return snapshot.hasData
              ? ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                total = total + int.parse(ds["Total"]);
                return Dismissible(
                  key: Key(ds.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                    margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete_outline, color: Colors.white, size: 30),
                  ),
                  onDismissed: (_) async {
                    await DatabaseMethods().removeCartItem(id!, ds.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${ds["Name"]} đã bị xóa khỏi giỏ hàng"),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                  margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          // Quantity badge
                          Container(
                            height: 90,
                            width: 40,
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text(
                                ds["Quantity"],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.0),
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ds["Image"].toString().startsWith("base64,")
                                ? Image.memory(
                                    base64Decode(ds["Image"].toString().substring(7)),
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  )
                                : ds["Image"].toString().startsWith("http")
                                    ? Image.network(
                                        ds["Image"],
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        ds["Image"].toString().replaceAll("file:///", ""),
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                          SizedBox(width: 12.0),
                          // Name + Options + Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ds["Name"],
                                  style: AppWidget.SemiBoldTextFieldStyle(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if ((ds.data() as Map<String, dynamic>).containsKey("Options") && ds["Options"].toString().isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    ds["Options"],
                                    style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: "Poppins"),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                SizedBox(height: 4),
                                Text(
                                  "\$" + ds["Total"],
                                  style: AppWidget.boldTextFieldStyle(),
                                ),
                              ],
                            ),
                          ),
                          // Delete button
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              await DatabaseMethods().removeCartItem(id!, ds.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${ds["Name"]} đã bị xóa khỏi giỏ hàng"),
                                    backgroundColor: Colors.redAccent,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ));
              })
              : CircularProgressIndicator();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
                elevation: 2.0,
                child: Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Center(
                        child: Text(
                          "Food Cart",
                          style: AppWidget.HeadLineTextFieldStyle(),
                        )))),
            SizedBox(
              height: 20.0,
            ),
            Container(
                height: MediaQuery.of(context).size.height/2,
                child: foodCart()),
            Spacer(),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Price",
                    style: AppWidget.boldTextFieldStyle(),
                  ),
                  Text(
                    "\$"+ total.toString(),
                    style: AppWidget.SemiBoldTextFieldStyle(),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deliveryLocation != null 
                        ? "Vị trí: ${deliveryLocation!.latitude.toStringAsFixed(4)}, ${deliveryLocation!.longitude.toStringAsFixed(4)}"
                        : "Chưa chọn vị trí giao hàng",
                      style: AppWidget.SemiBoldTextFieldStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final LatLng? result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LocationPicker()),
                      );
                      if (result != null) {
                        setState(() {
                          deliveryLocation = result;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    child: Text(deliveryLocation == null ? "Chọn vị trí" : "Thay đổi", style: const TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () async {
                int cartTotal = amount2;

                if (cartTotal == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.orange,
                      content: Text(
                        "Giỏ hàng trống. Vui lòng thêm món ăn!",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                  return;
                }

                if (deliveryLocation == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.orange,
                      content: Text(
                        "Vui lòng chọn vị trí giao hàng!",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                  return;
                }

                // Đọc số dư THỰC TẾ từ Firestore thay vì SharedPreference
                int walletBalance = await _walletService.getCurrentBalance();

                if (walletBalance < cartTotal) {
                  // Số dư không đủ
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                        "Số dư không đủ (${walletBalance.toStringAsFixed(0)} VND). Vui lòng nạp thêm để tiếp tục!",
                        style: TextStyle(fontSize: 16),
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  // Đủ tiền → trừ tiền qua WalletService
                  bool success = await _walletService.deductBalance(
                    amount: cartTotal,
                    orderId: "order_${DateTime.now().millisecondsSinceEpoch}",
                  );
                  if (!mounted) return;
                  if (success) {
                    // Lưu đơn hàng vào Firestore trước khi xóa giỏ
                    final cartRef = FirebaseFirestore.instance
                        .collection("users")
                        .doc(id!)
                        .collection("Cart");
                    final cartSnapshot = await cartRef.get();
                    List<Map<String, dynamic>> items = cartSnapshot.docs
                        .map((doc) => doc.data())
                        .toList();

                    await DatabaseMethods().saveOrder({
                      "userId": id,
                      "items": items,
                      "totalAmount": cartTotal,
                      "status": "completed",
                      "deliveryLat": deliveryLocation!.latitude,
                      "deliveryLng": deliveryLocation!.longitude,
                      "createdAt": DateTime.now().toIso8601String(),
                    });

                    // Xóa giỏ hàng sau khi đã lưu đơn hàng
                    await DatabaseMethods().clearFoodCart(id!);
                    int newBalance = walletBalance - cartTotal;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Đặt hàng thành công! Số dư còn lại: ${newBalance} VND",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          "Đặt hàng thất bại. Vui lòng thử lại!",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }
                }
              },

              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.black, borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: Center(
                    child: Text(
                      "CheckOut",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}