import 'package:flutter/material.dart';
import 'package:prm393/widget/widget_support.dart';
import 'package:prm393/services/database.dart';
import 'package:prm393/services/shared_pref.dart';
import 'dart:convert';

class Details extends StatefulWidget {
  String name, price, image, detail;
  List<dynamic>? sizes;
  List<dynamic>? toppings;
  Details({
    Key? key,
    required this.name,
    required this.price,
    required this.image,
    required this.detail,
    this.sizes,
    this.toppings,
  }) : super(key: key);
  // Details({ required this.name, required this.price, required this.image, required this.detail});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailsState();
  }
}

class _DetailsState extends State<Details> {
  int a = 1, basePrice = 0, total = 0;
  String? id;

  int selectedSizeIndex = 0;
  List<bool> selectedToppings = [];
  TextEditingController noteController = TextEditingController();

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
    basePrice = int.parse(widget.price);
    if (widget.toppings != null) {
      selectedToppings = List.generate(widget.toppings!.length, (index) => false);
    }
    _calculateTotal();
  }

  void _calculateTotal() {
    int optionsTotal = 0;
    if (widget.sizes != null && widget.sizes!.isNotEmpty && selectedSizeIndex >= 0 && selectedSizeIndex < widget.sizes!.length) {
      optionsTotal += int.parse(widget.sizes![selectedSizeIndex]["Price"].toString());
    }
    if (widget.toppings != null && widget.toppings!.isNotEmpty) {
      for (int i = 0; i < widget.toppings!.length; i++) {
        if (selectedToppings[i]) {
          optionsTotal += int.parse(widget.toppings![i]["Price"].toString());
        }
      }
    }
    total = (basePrice + optionsTotal) * a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.black,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.image.startsWith("base64,")
                  ? Image.memory(
                      base64Decode(widget.image.substring(7)),
                      width: MediaQuery.of(context).size.height / 2.5,
                      fit: BoxFit.cover,
                    )
                  : widget.image.startsWith("http")
                  ? Image.network(
                      widget.image,
                      width: MediaQuery.of(context).size.height / 2.5,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      widget.image.replaceAll("file:///", ""),
                      width: MediaQuery.of(context).size.height / 2.5,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: AppWidget.SemiBoldTextFieldStyle(),
                    ),
                    Text(widget.name, style: AppWidget.boldTextFieldStyle()),
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    if (a > 1) {
                      --a;
                      _calculateTotal();
                      setState(() {});
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(a.toString(), style: AppWidget.boldTextFieldStyle()),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    ++a;
                    _calculateTotal();
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text("Description", style: AppWidget.boldTextFieldStyle()),
            Text(
              widget.detail,
              style: AppWidget.SemiBoldTextFieldStyle(),
              maxLines: 3,
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Text("Delivery time ", style: AppWidget.boldTextFieldStyle()),
                SizedBox(width: 20),
                Icon(Icons.alarm, color: Colors.black45),
                Text("30 minutes", style: AppWidget.boldTextFieldStyle()),
              ],
            ),
            SizedBox(height: 20),

            // Sizes section
            if (widget.sizes != null && widget.sizes!.isNotEmpty) ...[
              Text("Choose Size", style: AppWidget.SemiBoldTextFieldStyle()),
              SizedBox(height: 10),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.sizes!.length,
                itemBuilder: (context, index) {
                  return RadioListTile<int>(
                    title: Text(widget.sizes![index]["Name"]),
                    subtitle: Text("+ \$${widget.sizes![index]["Price"]}"),
                    value: index,
                    groupValue: selectedSizeIndex,
                    activeColor: Colors.black,
                    onChanged: (int? value) {
                      setState(() {
                        selectedSizeIndex = value!;
                        _calculateTotal();
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20),
            ],

            // Toppings section
            if (widget.toppings != null && widget.toppings!.isNotEmpty) ...[
              Text("Extra Toppings", style: AppWidget.SemiBoldTextFieldStyle()),
              SizedBox(height: 10),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.toppings!.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(widget.toppings![index]["Name"]),
                    subtitle: Text("+ \$${widget.toppings![index]["Price"]}"),
                    value: selectedToppings[index],
                    activeColor: Colors.black,
                    onChanged: (bool? value) {
                      setState(() {
                        selectedToppings[index] = value!;
                        _calculateTotal();
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20),
            ],

            // Note section
            Text("Special Instructions", style: AppWidget.SemiBoldTextFieldStyle()),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: Color(0xFFececf8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: noteController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "E.g. No onions, extra spicy",
                  hintStyle: AppWidget.LightTextFieldStyle(),
                ),
              ),
            ),

            SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total price",
                        style: AppWidget.boldTextFieldStyle(),
                      ),
                      Text(
                        "\$" + total.toString(),
                        style: AppWidget.boldTextFieldStyle(),
                      ),
                    ],
                  ),
                  Spacer(),

                  GestureDetector(
                    onTap: () async {
                      String customNote = noteController.text.trim();
                      String optionsStr = "";
                      
                      if (widget.sizes != null && widget.sizes!.isNotEmpty) {
                        optionsStr += "Size: ${widget.sizes![selectedSizeIndex]["Name"]}";
                      }
                      
                      if (widget.toppings != null && widget.toppings!.isNotEmpty) {
                        List<String> chosenToppings = [];
                        for (int i = 0; i < selectedToppings.length; i++) {
                          if (selectedToppings[i]) {
                            chosenToppings.add(widget.toppings![i]["Name"]);
                          }
                        }
                        if (chosenToppings.isNotEmpty) {
                          optionsStr += (optionsStr.isEmpty ? "" : " | ") + "Toppings: " + chosenToppings.join(", ");
                        }
                      }
                      
                      if (customNote.isNotEmpty) {
                        optionsStr += (optionsStr.isEmpty ? "" : " | ") + "Note: " + customNote;
                      }

                      Map<String, dynamic> addFoodtoCard = {
                        "Name": widget.name,
                        "Quantity": a.toString(),
                        "Total": total.toString(),
                        "Image": widget.image,
                        "Options": optionsStr,
                      };
                      await DatabaseMethods().AddFoodtoCart(addFoodtoCard, id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.orangeAccent,
                          content: Text(
                            "Added to cart",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Add to cart",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                          GestureDetector(
                            child: Container(
                              padding: EdgeInsets.all(3),

                              child: Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}