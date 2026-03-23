import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle boldTextFieldStyle() {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
    );
  }
  static TextStyle HeadLineTextFieldStyle() {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
    );
  }
  static TextStyle LightTextFieldStyle() {
    return TextStyle(
      color: Colors.grey, // Grey works on both dark and light
      fontSize: 15,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    );
  }
  static TextStyle SemiBoldTextFieldStyle(){
    return TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    );
  }
}
