import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Pastikan path import di bawah ini sesuai dengan lokasi file di folder lib kamu
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart'; 
import 'screens/admin_list.dart'; 
import 'screens/petugas_list.dart'; // Sesuaikan nama class & filenya
import 'screens/peminjam_list.dart';

Future<void> main() async {
  // 1. Inisialisasi binding Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://njvzpnhphwgopndbcnlp.supabase.co',
    anonKey: 'sb_publishable_mr3yGlqywVH03rrar4441A_wX63s8ap',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Lab Brantas',
      theme: ThemeData(
        // Menggunakan primary color biru gelap sesuai desain dashboard
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3668)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      
      // Halaman pertama yang muncul saat aplikasi dibuka
      home: const SplashScreen(),

      // Peta Navigasi Aplikasi
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin_dashboard': (context) => const AdminListPage(),
        '/petugas_dashboard': (context) => const PetugasDashboard(),
        '/peminjam_dashboard': (context) => const PeminjamDashboard(),
      },
    );
  }
}