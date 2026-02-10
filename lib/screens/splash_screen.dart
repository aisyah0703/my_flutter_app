import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Pastikan import file login kamu

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Berpindah ke LoginScreen setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih sesuai gambar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo E-LAB BRANTAS
            Image.asset(
              'assets/images/logo.png',
              width: 250, // Ukuran logo lebih besar di splash screen
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
