import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prm393/pages/details.dart';
import 'package:prm393/widget/widget_support.dart';
import 'package:prm393/services/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool iceCream = false, pizza = false, salad = false, burger = false;
  
  Stream? fooditemStream;
  
  Future<void> ontheload()async{
    fooditemStream = await DatabaseMethods().getFoodItem("Pizza");
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
        return snapshot.hasData
            ? ListView.builder(
              padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Details(
                            name: ds["Name"],
                            price: ds["Price"],
                            image: ds["Image"],
                            detail: ds["Detail"],
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
                                child: Image.network(
                                  ds["Image"],
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of( context).size.width - 200,
                            child: Text(
                              ds["Name"],
                              style: AppWidget.SemiBoldTextFieldStyle(),
                            )),
                            SizedBox(height: 5.0),
                            Container(
                              width: MediaQuery.of( context).size.width - 200,
                            child: Text(
                              "Honey goat cheese",
                              style: AppWidget.LightTextFieldStyle(),
                            )),
                            SizedBox(height: 5.0),
                            Container(
                              width: MediaQuery.of( context).size.width - 200,
                            child: Text("\$" + ds["Price"],style: AppWidget.SemiBoldTextFieldStyle())),
                          ],
                        ),
                      ],
                    ),
                )
                ),
              ),
                  );
                }
              ):CircularProgressIndicator();
            },
          );
    }

  Widget allItems() {
    return StreamBuilder(
      stream: fooditemStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
              padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Details(
                            name: ds["Name"],
                            price: ds["Price"],
                            image: ds["Image"],
                            detail: ds["Detail"],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        elevation: 5.0,
                        child: Container(
                          padding: EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  ds["Image"],
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                ds["Name"],
                                style: AppWidget.SemiBoldTextFieldStyle(),
                              ),
                              Text(
                                "Fresh and healthy",
                                style: AppWidget.LightTextFieldStyle(),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "\$"+ds["Price"],
                                style: AppWidget.SemiBoldTextFieldStyle(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              ):CircularProgressIndicator();
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
                Text('Home', style: AppWidget.boldTextFieldStyle()),
                Container(
                  margin: EdgeInsets.only(right: 20),
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.shopping_cart, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("Delicious Food", style: AppWidget.HeadLineTextFieldStyle()),
            Text(
              "Discover and get great food",
              style: AppWidget.LightTextFieldStyle(),
            ),
            SizedBox(height: 20.0),
            Container(margin: EdgeInsets.only(right: 20), child: showItem()),
            SizedBox(height: 30.0),
            Container(
              height: 270,
              child: allItems()),
              SizedBox(height: 30.0,),
              Container(
                margin: EdgeInsets.only(right: 20),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "images/salad4.png",
                          height: 120,
                          width: 130,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              "Mix Veg Salad",
                              style: AppWidget.SemiBoldTextFieldStyle(),
                            ),
                            Text(
                              "Delicious and healthy",
                              style: AppWidget.LightTextFieldStyle(),
                            ),
                            SizedBox(height: 3),
                            Text("\$20", style: AppWidget.SemiBoldTextFieldStyle()),
                          ],
                        ),
                      ],
                    ),
                )
                ),
              ),
              SizedBox(height: 30.0),
              allItemsVertically(),
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
            iceCream = true;
            pizza = false;
            salad = false;
            burger = false;
            fooditemStream = await DatabaseMethods().getFoodItem("Ice-cream");
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
            iceCream = false;
            pizza = true;
            salad = false;
            burger = false;
            fooditemStream = await DatabaseMethods().getFoodItem("Pizza");
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
            iceCream = false;
            pizza = false;
            salad = true;
            burger = false;
            fooditemStream = await DatabaseMethods().getFoodItem("Salad");
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
            iceCream = false;
            pizza = false;
            salad = false;
            burger = true;
            fooditemStream = await DatabaseMethods().getFoodItem("Burger");
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

  Widget showList() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Details(
                        name: "Mix Veg Salad",
                        price: "20",
                        image: "images/salad4.png",
                        detail: "Delicious and healthy",
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(2),
                  child: Material(
                    borderRadius: BorderRadius.circular(5),
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            "images/salad2.png",
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            "Veggie Taco Hash",
                            style: AppWidget.SemiBoldTextFieldStyle(),
                          ),
                          Text(
                            "Fresh and healthy",
                            style: AppWidget.LightTextFieldStyle(),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "\$25",
                            style: AppWidget.SemiBoldTextFieldStyle(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Details(
                        name: "Mix Veg Salad",
                        price: "20",
                        image: "images/salad4.png",
                        detail: "Delicious and healthy",
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(2),
                  child: Material(
                    borderRadius: BorderRadius.circular(5),
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            "images/salad3.png",
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            "Mix Veg Salad",
                            style: AppWidget.SemiBoldTextFieldStyle(),
                          ),
                          Text(
                            "Delicious and healthy",
                            style: AppWidget.LightTextFieldStyle(),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "\$20",
                            style: AppWidget.SemiBoldTextFieldStyle(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Details(
                  name: "Mix Veg Salad",
                  price: "20",
                  image: "images/salad4.png",
                  detail: "Delicious and healthy",
                ),
              ),
            );
          },
          child: Container(
            child: Material(
              borderRadius: BorderRadius.circular(5),
              elevation: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "images/salad4.png",
                    height: 120,
                    width: 130,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Text(
                        "Mix Veg Salad",
                        style: AppWidget.SemiBoldTextFieldStyle(),
                      ),
                      Text(
                        "Delicious and healthy",
                        style: AppWidget.LightTextFieldStyle(),
                      ),
                      SizedBox(height: 3),
                      Text("\$20", style: AppWidget.SemiBoldTextFieldStyle()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
