import 'package:flutter/material.dart';

class AdminListPage extends StatelessWidget {
  const AdminListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background abu-abu sangat muda
      body: Column(
        children: [
          // --- HEADER BIRU MELENGKUNG ---
          Stack(
            children: [
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A3668), // Warna biru gelap sesuai gambar
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Color(0xFF4A90E2),
                          child: Text('D', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Admin123', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('admin', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'hallo admin, Semangat bekerja !',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              // --- SEARCH BAR (Floating) ---
              Positioned(
                bottom: 20,
                left: 30,
                right: 30,
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'cari nama barang....',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- TAB KATEGORI ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryTab('semua kategori', true),
                _buildCategoryTab('komputer', false),
                _buildCategoryTab('jaringan', false),
              ],
            ),
          ),

          // --- LIST DATA ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildProductCard('Laptop', 'Komputer', 'Tersedia', 'assets/images/laptop.png'),
                _buildProductCard('Keyboard', 'Komputer', 'Tersedia', 'assets/images/keyboard.png'),
                _buildProductCard('Mouse', 'Komputer', 'Tersedia', 'assets/images/mouse.png'),
                _buildProductCard('Lan Tester', 'Jaringan', 'Tersedia', 'assets/images/lan_tester.png'),
              ],
            ),
          ),
        ],
      ),
      
      // --- FLOATING ACTION BUTTON (Sesuai Gambar) ---
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            onPressed: () {},
            backgroundColor: const Color(0xFFADD8E6),
            child: const Icon(Icons.grid_view, color: Colors.black),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            onPressed: () {},
            backgroundColor: const Color(0xFFADD8E6),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A3668),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pengguna'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // Widget Helper untuk Tab Kategori
  Widget _buildCategoryTab(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4A90E2) : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF4A90E2)),
      ),
      child: Text(
        title,
        style: TextStyle(color: isActive ? Colors.white : const Color(0xFF4A90E2), fontSize: 12),
      ),
    );
  }

  // Widget Helper untuk Card Produk
  Widget _buildProductCard(String name, String cat, String status, String imgPath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Image.asset(imgPath, width: 60, height: 60, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 60)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(cat, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 14),
                    const SizedBox(width: 5),
                    Text(status, style: const TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildActionButton(Icons.edit, 'Edit', Colors.blue),
              const SizedBox(height: 5),
              _buildActionButton(Icons.delete_outline, 'Hapus', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}