import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prm393/pages/bottom_nav.dart';
import 'package:prm393/pages/forget_password.dart';
import 'package:prm393/pages/sign_up.dart';
import 'package:prm393/widget/widget_support.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String email = "";
  String password = "";
  final _formKey = GlobalKey<FormState>();

  login() async {
    if (password.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Đăng nhập thành công",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Poppins",
                fontSize: 20,
              ),
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Sai tài khoản hoặc mật khẩu",
              style: AppWidget.boldTextFieldStyle(),
            ),
          ),
        );
      }
    }
  }

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

                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 30),
                            Text(
                              "Đăng nhập",
                              style: AppWidget.boldTextFieldStyle(),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child: TextFormField(
                                controller: emailController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Hãy nhập email của bạn";
                                  }
                                  return null;
                                },
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
                              child: TextFormField(
                                obscureText: true,
                                controller: passwordController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Hãy nhập mật khẩu của bạn";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "Mật khẩu",
                                  hintStyle: AppWidget.SemiBoldTextFieldStyle(),
                                  suffixIcon: Icon(Icons.password_rounded),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgetPassword(),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 20, right: 20),
                                alignment: AlignmentDirectional.topEnd,
                                child: Text(
                                  "Quên mật khẩu?",
                                  style: AppWidget.boldTextFieldStyle(),
                                ),
                              ),
                            ),
                            SizedBox(height: 100),
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    email = emailController.text;
                                    password = passwordController.text;
                                  });
                                }
                                login();
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 50,
                                  right: 50,
                                  top: 10,
                                  bottom: 10,
                                ),

                                decoration: BoxDecoration(
                                  color: Color(0xFFff5c30),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Đăng nhập",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                  },
                  child: Text(
                    "Đăng kí tài khoản mới",
                    style: TextStyle(fontSize: 20, fontFamily: "Poppins"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
