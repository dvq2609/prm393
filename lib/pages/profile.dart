import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:prm393/services/theme_manager.dart';
import 'package:prm393/pages/login.dart';
import 'package:prm393/pages/order_history.dart';
import 'package:prm393/pages/wallet.dart';
import 'package:prm393/services/shared_pref.dart';
import 'package:prm393/widget/widget_support.dart';
import 'package:prm393/services/audio_manager.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? name, email, profile;
  bool _isMusicEnabled = true;

  getthesharedpref() async {
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    profile = await SharedPreferenceHelper().getUserProfile();
    setState(() {});
  }

  @override
  void initState() {
    getthesharedpref();
    _isMusicEnabled = AudioManager().isMusicEnabled;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 45.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  height: MediaQuery.of(context).size.height / 4.3,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(150, 40),
                    ),
                  ), // Adjusted to a subtle curve
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 6.5,
                    ),
                    child: Material(
                      elevation: 10.0,
                      borderRadius: BorderRadius.circular(60),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: profile == null
                            ? Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Center(
                                  child: Text(
                                    (email ?? "U")[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 60.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              )
                            : Image.memory(
                                base64Decode(profile!),
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 70.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name ?? "User Name",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Text(
              email ?? "email@example.com",
              style: AppWidget.SemiBoldTextFieldStyle(),
            ),
            const SizedBox(height: 30.0),

            // Menu Options
            buildProfileOption(
              icon: Icons.wallet_outlined,
              title: "Ví tiền (Wallet)",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Wallet()),
                );
              },
            ),
            buildProfileOption(
              icon: Icons.history,
              title: "Lịch sử đơn hàng",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderHistory()),
                );
              },
            ),

            _buildDarkModeToggle(context),
            _buildMusicToggle(context),

            buildProfileOption(
              icon: Icons.logout_rounded,
              title: "Đăng xuất",
              onTap: () {
                showLogoutDialog();
              },
              isLogout: true,
            ),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 3.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.dark_mode,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Text(
                  "Chế độ Tối (Dark Mode)",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeManager.themeNotifier,
                builder: (context, currentMode, child) {
                  final isDark = currentMode == ThemeMode.dark ||
                      (currentMode == ThemeMode.system &&
                          MediaQuery.of(context).platformBrightness == Brightness.dark);
                  return Switch(
                    value: isDark,
                    activeColor: Colors.orange,
                    onChanged: (value) {
                      ThemeManager.changeTheme(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMusicToggle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 3.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.music_note,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Text(
                  "Nhạc nền",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Switch(
                value: _isMusicEnabled,
                activeColor: Colors.orange,
                onChanged: (value) {
                  setState(() {
                    _isMusicEnabled = value;
                  });
                  AudioManager().toggleMusic(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          elevation: 3.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 20.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isLogout ? Colors.red : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: isLogout ? Colors.red : (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isLogout
                      ? Colors.red.withOpacity(0.5)
                      : Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Đăng xuất", style: AppWidget.boldTextFieldStyle()),
          content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Hủy",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              child: const Text(
                "Đăng xuất",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
