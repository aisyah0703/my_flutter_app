import 'package:flutter/material.dart';
// Import halaman-halaman Anda di sini
import 'admin_list.dart';
import 'admin_form.dart';
import 'logout_admin.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  // Daftar halaman yang akan tampil di dalam Navbar
  final List<Widget> _pages = [
    const AdminListPage(), // Index 0 (Halaman yang Anda kirim tadi)
    const Center(
      child: Text("Halaman Petugas"),
    ), // Ganti dengan PetugasListPage()
    const Center(
      child: Text("Halaman Peminjam"),
    ), // Ganti dengan PeminjamListPage()
    const Center(
      child: Text("Halaman Profil/Logout"),
    ), // Ganti dengan LogoutAdmin()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai index yang dipilih di Navbar
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A3668),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Alat'),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Petugas'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Peminjam'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
