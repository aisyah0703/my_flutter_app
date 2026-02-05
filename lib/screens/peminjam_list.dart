import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/pinjam_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/pinjam_model.dart';

class PeminjamDashboard extends StatefulWidget {
  const PeminjamDashboard({super.key});

  @override
  State<PeminjamDashboard> createState() => _PeminjamDashboardState();
}

class _PeminjamDashboardState extends State<PeminjamDashboard> {
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // --- HEADER BIRU MELENGKUNG (Sesuai Gambar) ---
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1A3668),
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
                      backgroundColor: Color(0xFF4A90E2),
                      child: Text('D', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Davita123', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('peminjam', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Center(
                  child: Text(
                    'hallo mau sewa alat apa ????',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 15),
                // Search Bar Putih
                Container(
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'cari nama barang...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- TAB KATEGORI ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab('semua kategori', true),
                _buildTab('komputer', false),
                _buildTab('jaringan', false),
              ],
            ),
          ),

          // --- LIST BARANG ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildItemCard('Laptop', 'Komputer', true),
                _buildItemCard('Keyboard', 'Komputer', true),
                _buildItemCard('Mouse', 'Komputer', true),
                _buildItemCard('Lan Tester', 'Jaringan', true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4A90E2) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A90E2)),
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFF4A90E2), fontSize: 12)),
    );
  }

  Widget _buildItemCard(String title, String category, bool available) {
    return GestureDetector(
      onTap: () => _prosesPinjam(title), // Klik untuk pinjam
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 14),
                      const SizedBox(width: 5),
                      const Text('Tersedia', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA CREATE (PROSES PINJAM) ---
  Future<void> _prosesPinjam(String namaBarang) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pinjam'),
        content: Text('Apakah anda ingin meminjam $namaBarang?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Pinjam')),
        ],
      ),
    );

    if (confirm == true) {
      final pinjamData = PeminjamanModel(
        namaPeminjam: 'Davita123',
        idBarang: 'B001', // Contoh ID
        namaBarang: namaBarang,
        tglPinjam: DateTime.now().toString(),
      );

      await _supabase.from('peminjaman').insert(pinjamData.toMap());
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permintaan pinjam $namaBarang berhasil dikirim!')),
      );
    }
  }
}