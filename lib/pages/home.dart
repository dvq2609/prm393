import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prm393/services/database.dart';
import 'package:prm393/widget/widget_support.dart';
import 'package:prm393/pages/details.dart';
import 'package:prm393/widget/ai_chat_modal.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool iceCream = false, pizza = false, salad = false, burger = false;

  Stream? fooditemStream;

  Future<void> ontheload() async {
    fooditemStream = await DatabaseMethods().getAllFoodItems();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  Widget allItemsVertically() {
    return StreamBuilder(
      stream: fooditemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        List<DocumentSnapshot> allDocs = [];
        if (snapshot.data is QuerySnapshot) {
          allDocs = (snapshot.data as QuerySnapshot).docs;
        } else if (snapshot.data is List) {
          allDocs = snapshot.data as List<DocumentSnapshot>;
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: allDocs.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = allDocs[index];
            return GestureDetector(
              onTap: () {
                Map<String, dynamic> data = ds.data() as Map<String, dynamic>;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Details(
                      name: ds["Name"],
                      price: ds["Price"],
                      image: ds["Image"],
                      detail: ds["Detail"],
                      sizes: data.containsKey("Sizes") ? data["Sizes"] : null,
                      toppings: data.containsKey("Toppings")
                          ? data["Toppings"]
                          : null,
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: 20, bottom: 20.0),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: ds["Image"].toString().startsWith("base64,")
                              ? Image.memory(
                                  base64Decode(
                                    ds["Image"].toString().substring(7),
                                  ),
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                )
                              : ds["Image"].toString().startsWith("http")
                              ? Image.network(
                                  ds["Image"],
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  ds["Image"].toString().replaceAll(
                                    "file:///",
                                    "",
                                  ),
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 200,
                              child: Text(
                                ds["Name"],
                                style: AppWidget.SemiBoldTextFieldStyle(),
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Container(
                              width: MediaQuery.of(context).size.width - 200,
                              child: Text(
                                ds["Detail"],
                                style: AppWidget.LightTextFieldStyle(),
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Container(
                              width: MediaQuery.of(context).size.width - 200,
                              child: Text(
                                "\$" + ds["Price"],
                                style: AppWidget.SemiBoldTextFieldStyle(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50, left: 20, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trang chủ', style: AppWidget.boldTextFieldStyle()),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AiChatBottomSheet(),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 20),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Khám phá và thưởng thức món ăn ngon",
              style: AppWidget.LightTextFieldStyle(),
            ),
            SizedBox(height: 20.0),
            Container(margin: EdgeInsets.only(right: 20), child: showItem()),
            SizedBox(height: 30.0),
            Expanded(child: allItemsVertically()),
          ],
        ),
      ),
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () async {
            if (iceCream) {
              iceCream = false;
              fooditemStream = await DatabaseMethods().getAllFoodItems();
            } else {
              iceCream = true;
              pizza = false;
              salad = false;
              burger = false;
              fooditemStream = await DatabaseMethods().getFoodItem("Ice-cream");
            }
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: iceCream ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(10),
              child: Image.asset(
                "images/ice-cream.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: iceCream ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            if (pizza) {
              pizza = false;
              fooditemStream = await DatabaseMethods().getAllFoodItems();
            } else {
              iceCream = false;
              pizza = true;
              salad = false;
              burger = false;
              fooditemStream = await DatabaseMethods().getFoodItem("Pizza");
            }
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: pizza ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(10),
              child: Image.asset(
                "images/pizza.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: pizza ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            if (salad) {
              salad = false;
              fooditemStream = await DatabaseMethods().getAllFoodItems();
            } else {
              iceCream = false;
              pizza = false;
              salad = true;
              burger = false;
              fooditemStream = await DatabaseMethods().getFoodItem("Salad");
            }
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: salad ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(10),
              child: Image.asset(
                "images/salad.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: salad ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            if (burger) {
              burger = false;
              fooditemStream = await DatabaseMethods().getAllFoodItems();
            } else {
              iceCream = false;
              pizza = false;
              salad = false;
              burger = true;
              fooditemStream = await DatabaseMethods().getFoodItem("Burger");
            }
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: burger ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(10),
              child: Image.asset(
                "images/burger.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: burger ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
