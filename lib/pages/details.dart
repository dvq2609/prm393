import 'package:flutter/material.dart';
import 'package:prm393/widget/widget_support.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailsState();
  }
}

class _DetailsState extends State<Details> {
  int a = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50, left: 20),
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
            Image.asset("images/salad2.png",width: MediaQuery.of(context).size.height/2.5,fit: BoxFit.fill,),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mediterraenan", style: AppWidget.SemiBoldTextFieldStyle(),),
                    Text("Mediterraenan", style: AppWidget.boldTextFieldStyle(),),
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: ()
                  {
                   if(a >1){
                     --a;
                   }

                    setState(() {

                    });
                  },
                  child: Container(

                    decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.remove,color: Colors.white),
                  ),
                ),
                SizedBox(width: 12,),
                Text(a.toString(), style: AppWidget.boldTextFieldStyle(),),
                SizedBox(width: 12,),
                GestureDetector(
                  onTap: ()
                  {
                    ++a;
                    setState(() {

                    });
                  },
                  child: Container(

                    decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.add,color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text("Description", style: AppWidget.boldTextFieldStyle(),),
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",style: AppWidget.SemiBoldTextFieldStyle(),maxLines: 3,),
            SizedBox(height: 15,),
            Row(children: [
              Text("Delivery time ", style: AppWidget.boldTextFieldStyle(),),
              SizedBox(width: 20,),
              Icon(Icons.alarm,color: Colors.black45,),
              Text("30 minutes", style: AppWidget.boldTextFieldStyle(),)
            ],),
            SizedBox(height: 100,),

            Padding(padding:const EdgeInsets.only(bottom: 40),child: Row(children: [
              Column(
                children: [
                  Text("Total price", style: AppWidget.boldTextFieldStyle(),),
                  Text("\$28", style: AppWidget.boldTextFieldStyle(),),
                ],
              ),
              SizedBox(width: 150,),

              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Text("Add to cart",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                    GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(3),

                            child: Icon(Icons.shopping_cart_outlined,color: Colors.white,))
                    )
                    ]
                ),
              )
            ],),)

          ],
        ),
      ),
    );
  }
}
