import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prm393/widget/widget_support.dart';
import 'dart:convert';
import 'package:prm393/services/database.dart';

class ViewFood extends StatefulWidget {
  const ViewFood({super.key});

  @override
  State<ViewFood> createState() => _ViewFoodState();
}

class _ViewFoodState extends State<ViewFood> {
  Stream<List<DocumentSnapshot>>? fooditemStream;

  @override
  void initState() {
    super.initState();
    getFoodItems();
  }

  getFoodItems() async {
    fooditemStream = await DatabaseMethods().getAllFoodItems();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Food Items", style: AppWidget.boldTextFieldStyle()),
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
        child: StreamBuilder<List<DocumentSnapshot>>(
          stream: fooditemStream,
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
                        "Lỗi tải dữ liệu.\nChi tiết lỗi:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Không có bất kỳ món ăn nào.",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data![index];
                Map<String, dynamic>? data = ds.data() as Map<String, dynamic>?;

                if (data == null) return const SizedBox();

                String category = ds.reference.parent.id;
                String name = data["Name"] ?? "Unknown";
                String price = data["Price"] ?? "0";
                String detail = data["Detail"] ?? "";
                String image = data["Image"] ?? "";

                return Card(
                  elevation: 3.0,
                  margin: const EdgeInsets.only(bottom: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: image.startsWith("base64,")
                              ? Image.memory(
                                  base64Decode(image.substring(7)),
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                )
                              : image.startsWith("http")
                              ? Image.network(
                                  image,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  image.replaceAll("file:///", ""),
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 15.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "\$$price",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                name,
                                style: AppWidget.SemiBoldTextFieldStyle(),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                detail,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showEditDialog(ds.id, category, data);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  GestureDetector(
                                    onTap: () {
                                      _showDeleteDialog(ds.id, category);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  void _showEditDialog(String id, String category, Map<String, dynamic> data) {
    TextEditingController nameCtrl = TextEditingController(text: data["Name"]);
    TextEditingController priceCtrl = TextEditingController(
      text: data["Price"],
    );
    TextEditingController detailCtrl = TextEditingController(
      text: data["Detail"],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Food Info"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Food Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: detailCtrl,
                  decoration: const InputDecoration(labelText: "Detail"),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> updateInfo = {
                  "Name": nameCtrl.text,
                  "Price": priceCtrl.text,
                  "Detail": detailCtrl.text,
                };
                await DatabaseMethods().updateFoodItem(
                  category,
                  id,
                  updateInfo,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Food item updated successfully!"),
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String id, String category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text(
            "Are you sure you want to delete this food item? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await DatabaseMethods().deleteFoodItem(category, id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Food item deleted successfully!"),
                  ),
                );
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
