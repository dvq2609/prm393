import 'package:flutter/material.dart';

class Profile  extends StatefulWidget{
  const Profile({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfileState();
  }

}
class _ProfileState extends State<Profile>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        child: Column(children:[
          Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: 45.0, left: 20.0, right: 20.0),
                height: MediaQuery.of(context).size.height/4.3,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(MediaQuery.of(context).size.width, 105.0)
                  )
                ),
              ),
              Center(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/6.5),
                child: Material(
                  elevation:10.0,
                  borderRadius: BorderRadius.circilar(60),
                  child: ClippRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset("images.boy.jpg", height: 120, width: 120, fit: BoxFit.cover)
                  ),
                ),
              ),
              Center(
                child: Padding(padding: EdgeInsets.only(top: 70.0), child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text("DTD", style TextStyle(
                    style: TextStyle(
                      color: Colors.white,
                              fontSize:25.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'
                    ),
                ),)
                ],),)
              )
            ],
          )
    SizedBox(height: 20.0),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
    child: Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 2.0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 15.0, horizontal: 10.0,
    ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
    ),
    child: Row(children: [
      Icon(Icons.person, color: Colors.black,)
      SizedBox(width: 20.0),
      Column(children: [
        crossAxisAlignment: CrossAxisAlignment.start,
        Text("Name", style: TextStyle(
        color: Colors.black, fontSize: 16.0, fontWeight: FontWeigh.bold
    ),),
    Text("DTD", style: TextStyle(
    color: Colors.black, fontSize: 16.0, fontWeight: FontWeigh.bold
    ),),
    ],)
    ],),
    ),
    ),
          )
        ])
      )
    );
    throw UnimplementedError();
  }

}