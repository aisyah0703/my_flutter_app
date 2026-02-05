import 'package:flutter/material.dart';

class PetugasDashboard extends StatelessWidget {
  const PetugasDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // --- HEADER BIRU ---
          Container(
            height: 180,
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF4A90E2),
                          child: Text('A', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Petugas123', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('Petugas', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.notifications, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'cari nama barang....',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // --- KARTU STATISTIK ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard('10', 'Peminjam', Icons.person, Colors.green),
                    _buildStatCard('3', 'Pengembalian', Icons.refresh, Colors.red),
                    _buildStatCard('4', 'Menunggu', Icons.info_outline, Colors.blue),
                  ],
                ),

                const SizedBox(height: 25),
                const Text('Menunggu Persetujuan', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // --- DAFTAR MENUNGGU PERSETUJUAN ---
                _buildApprovalCard('Pellaa', 'Pinjam 27 - 30 januari 2026', 'laptop', 'Sewa 1'),
                _buildApprovalCard('Claraa', 'Pinjam 28 - 29 januari 2026', 'Mouse', 'Sewa 3'),

                const SizedBox(height: 25),
                const Text('Pengembalian Hari ini', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // --- DAFTAR PENGEMBALIAN ---
                _buildReturnCard('Elingga', 'Lan tester', 'Kembali, 27 Januari 2026', true),
                _buildReturnCard('Rara aramita', 'Crimping', 'Kembali, 27 Januari 2026', false),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'peminjam'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'status'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // Widget Kartu Statistik Kecil
  Widget _buildStatCard(String value, String title, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Widget Kartu Persetujuan (Sesuai Gambar)
  Widget _buildApprovalCard(String name, String date, String item, String sewa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item, style: const TextStyle(fontSize: 12)),
                  Text(sewa, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Setuju', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Tolak', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Widget Kartu Pengembalian
  Widget _buildReturnCard(String name, String item, String date, bool isLate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(item, style: const TextStyle(fontSize: 11)),
                Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            children: [
              if (isLate) const Text('Terlambat', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                child: const Text('Selesai', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}