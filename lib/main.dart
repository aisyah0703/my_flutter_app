import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/admin_form.dart';
import 'package:flutter_application_1/screens/logout_petugas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import semua file yang dibutuhkan
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_list.dart';
import 'screens/petugas_list.dart';
import 'screens/peminjam_list.dart';
import 'screens/logout_admin.dart';
import 'screens/petugas_form.dart';

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
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        // INI KUNCINYA: Admin masuk ke Wrapper Admin, Petugas masuk ke Wrapper Petugas
        '/admin_dashboard': (context) => const AdminMainWrapper(),
        '/petugas_dashboard': (context) => const PetugasMainWrapper(),
      },
    );
  }
}

// ---------------------------------------------------------
// 1. WRAPPER KHUSUS ADMIN (Hanya 4 Menu: Alat, Petugas, Peminjam, Profil)
// ---------------------------------------------------------
class AdminMainWrapper extends StatefulWidget {
  const AdminMainWrapper({super.key});
  @override
  State<AdminMainWrapper> createState() => _AdminMainWrapperState();
}

class _AdminMainWrapperState extends State<AdminMainWrapper> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(),
    const AdminListPage(), // Menu Alat
    const AdminPetugasList(), // Menu Petugas
    const AdminRiwayatList(), // Menu Peminjam
    const LogoutAdmin(), // Menu Profil/Logout
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A3668),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'beranda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Alat'),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Petugas'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Peminjam'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 2. WRAPPER KHUSUS PETUGAS (Hanya 4 Menu: Beranda, Peminjam, Status, Profil)
// ---------------------------------------------------------
class PetugasMainWrapper extends StatefulWidget {
  const PetugasMainWrapper({super.key});
  @override
  State<PetugasMainWrapper> createState() => _PetugasMainWrapperState();
}

class _PetugasMainWrapperState extends State<PetugasMainWrapper> {
  int _currentIndex = 0;
  // Di dalam PetugasMainWrapper (main.dart)
  final List<Widget> _pages = [
    const PetugasDashboard(
      nama: 'Petugas',
      mode: 'beranda',
      barang: '',
      jumlah: '',
    ), // Mode Beranda
    const PetugasDashboard(
      nama: 'Petugas',
      mode: 'peminjam',
      barang: '',
      jumlah: '',
    ), // Mode Peminjam
    const Center(child: Text("Halaman Status")),
    const LogoutPetugas(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Peminjam'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
