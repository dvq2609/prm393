import 'package:flutter/material.dart';
import 'package:prm393/pages/login.dart';
import 'package:prm393/widget/widget_support.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFff5c30), Color(0xFFe74b1a)],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 3,
              ),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Text(""),
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 90, left: 15),
                  child: Image.asset(
                    "images/logo.png",
                    width: MediaQuery.of(context).size.height / 2.5,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 30),
                          Text("Sign up", style: AppWidget.boldTextFieldStyle()),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Name",
                                hintStyle: AppWidget.SemiBoldTextFieldStyle(),
                                suffixIcon: Icon(Icons.person),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: AppWidget.SemiBoldTextFieldStyle(),
                                suffixIcon: Icon(Icons.email),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: AppWidget.SemiBoldTextFieldStyle(),
                                suffixIcon: Icon(Icons.password_rounded),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),

                          Container(
                            padding: EdgeInsets.only(left: 50,right: 50,top: 10,bottom: 10),

                            decoration: BoxDecoration(
                              color: Color(0xFFff5c30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text("Already have account? Sign in", style: TextStyle(fontSize: 20, fontFamily: "Poppins"),))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
