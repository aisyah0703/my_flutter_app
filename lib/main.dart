import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Pastikan path import ini benar
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_list.dart';
import 'screens/admin_form.dart'; // File yang berisi MainNavigation & Dashboard
import 'screens/petugas_list.dart';
import 'screens/peminjam_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3668)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),

      home: const SplashScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        // PERBAIKAN DI SINI:
        // Gunakan MainNavigation agar muncul Dashboard + Bottom Nav
        '/admin_dashboard': (context) => const MainNavigation(),
        '/petugas_dashboard': (context) => const PetugasDashboard(),
        '/peminjam_dashboard': (context) => const PeminjamDashboard(),
      },
    );
  }
}
