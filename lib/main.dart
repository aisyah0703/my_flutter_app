import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORT SEMUA SCREEN ---
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_list.dart';
import 'screens/admin_form.dart';
import 'screens/petugas_list.dart';
import 'screens/peminjam_list.dart';
import 'screens/logout_admin.dart';
import 'screens/logout_petugas.dart';
import 'screens/peminjam_list.dart'; // Import Dashboard Peminjam
import 'screens/logout_peminjam.dart'; // Import Logout Peminjam (jika ada)

// --- FUNGSI UTAMA (MAIN) ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Database Supabase
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
        '/admin_dashboard': (context) => const AdminMainWrapper(),
        '/petugas_dashboard': (context) => const PetugasMainWrapper(),
        '/peminjam_dashboard': (context) =>
            const PeminjamMainWrapper(), // Jalur ke Peminjam
      },
    );
  }
}

// ---------------------------------------------------------
// 1. WRAPPER KHUSUS ADMIN
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
    const AdminListPage(),
    const AdminPetugasList(),
    const AdminRiwayatList(),
    const LogoutAdmin(),
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
            label: 'Beranda',
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
// 2. WRAPPER KHUSUS PETUGAS
// ---------------------------------------------------------
class PetugasMainWrapper extends StatefulWidget {
  const PetugasMainWrapper({super.key});
  @override
  State<PetugasMainWrapper> createState() => _PetugasMainWrapperState();
}

class _PetugasMainWrapperState extends State<PetugasMainWrapper> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const PetugasDashboard(currentIndex: 0),
      const PetugasDashboard(currentIndex: 1),
      const Center(child: Text("Halaman Status")),
      const LogoutPetugas(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A3668),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Peminjam'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. WRAPPER KHUSUS PEMINJAM (BARU)
// ---------------------------------------------------------
class PeminjamMainWrapper extends StatefulWidget {
  const PeminjamMainWrapper({super.key});

  @override
  State<PeminjamMainWrapper> createState() => _PeminjamMainWrapperState();
}

class _PeminjamMainWrapperState extends State<PeminjamMainWrapper> {
  int _currentIndex = 0;

  // Halaman untuk Peminjam
  final List<Widget> _pages = [
    const PeminjamDashboard(), // Index 0: Dashboard/Pilih Alat
    const Center(child: Text("halaman produk")), // Index 1: Riwayat
    const LogoutPeminjam(), // Index 2: Profil (Bisa ganti LogoutPeminjam)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan IndexedStack agar data di dashboard tidak reset saat pindah tab
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A3668), // Biru gelap tema aplikasi
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
