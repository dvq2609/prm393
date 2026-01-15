import 'package:flutter/material.dart';
import 'package:prm393/widget/widget_support.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WalletState();
  }
}

class _WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Thêm dòng này cho Column tổng
        children: [
          Container(
            margin: EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Container(
                  child: Text("Wallet", style: AppWidget.boldTextFieldStyle()),
                ),
                Container(
                  // padding: EdgeInsets.symmetric(vertical: 30),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: Color(0xFFF2F2F2)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "images/wallet.png",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your wallet",
                                style: AppWidget.boldTextFieldStyle(),
                              ),
                              Text(
                                "\$100",
                                style: AppWidget.SemiBoldTextFieldStyle(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Thêm dòng này cho Column tổng
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Text("Add money", style: AppWidget.SemiBoldTextFieldStyle()),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {

                        },
                        child: Container(
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "\$100",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Container(
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "\$300",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Container(
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "\$500",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Container(
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "\$700",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30,),
          Container(
            margin: EdgeInsets.only(left: 50),
            padding: EdgeInsets.only(left: 90, right: 90, top: 10,bottom: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.blue),

            child: Text("Add money",style: AppWidget.boldTextFieldStyle(),),
          )
        ],

      ),
    );
  }
}
