import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:prm393/pages/profile.dart';
import 'package:prm393/pages/wallet.dart';

import 'home.dart';
import 'order.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BottomNavState();
  }
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;
  late List<Widget> pages;
  late Widget currentPage;
  late Home homePage;
  late Wallet walletPage;
  late Order orderPage;
  late Profile profilePage;

  @override
  void initState() {
    homePage = Home();
    walletPage = Wallet();
    orderPage = Order();
    profilePage = Profile();
    pages = [homePage, walletPage, orderPage, profilePage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F1F1F) : Colors.black,
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.wallet, color: Colors.white),
          Icon(Icons.shopping_bag_outlined, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
      ),
      body: pages[currentIndex],
    );
  }
}
