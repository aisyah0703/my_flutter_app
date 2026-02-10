import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetugasDashboard extends StatefulWidget {
  final int currentIndex; // Menentukan tab mana yang aktif dari wrapper

  const PetugasDashboard({super.key, required this.currentIndex});

  @override
  State<PetugasDashboard> createState() => _PetugasDashboardState();
}

class _PetugasDashboardState extends State<PetugasDashboard> {
  final supabase = Supabase.instance.client;
  int _activeTabPeminjam =
      0; // Tab internal: 0=Pengembalian, 1=Selesai, 2=Denda

  // --- LOGIKA DATABASE ---

  // Fungsi untuk update status (Setuju/Tolak) langsung ke Supabase
  Future<void> _updateStatus(int id, String statusBaru) async {
    try {
      await supabase
          .from('peminjaman')
          .update({'status': statusBaru})
          .eq('id', id);
      // Pesan sukses singkat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil mengubah status ke $statusBaru")),
      );
    } catch (e) {
      debugPrint("Error Update: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeaderBiru(), // Memanggil Header (Bagian atas biru)
          Expanded(
            child: widget.currentIndex == 0
                ? _buildTabBeranda() // Jika index 0 tampilkan Beranda
                : _buildTabPeminjam(), // Jika index 1 tampilkan List Peminjam
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HELPER WIDGETS (Satu per satu untuk menghindari error)
  // =========================================================

  // 1. Header Biru dengan Search Bar
  Widget _buildHeaderBiru() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF1A3668),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text("A", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Petugas123",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Petugas",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.notifications, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "cari nama barang.....",
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Tab Beranda (Statistik & Persetujuan Real-time)
  Widget _buildTabBeranda() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard("10", "Peminjam", Icons.person, Colors.green),
              _buildStatCard("3", "Pengembalian", Icons.refresh, Colors.red),
              _buildStatCard("4", "Menunggu", Icons.access_time, Colors.blue),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            "Menunggu Persetujuan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // StreamBuilder mengambil data 'Menunggu' dari database
          StreamBuilder(
            stream: supabase
                .from('peminjaman')
                .stream(primaryKey: ['id'])
                .eq('status', 'Menunggu'),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final listData = snapshot.data!;
              if (listData.isEmpty)
                return const Center(child: Text("Tidak ada pengajuan"));

              return Column(
                children: listData
                    .map(
                      (item) => _buildApprovalCard(
                        item['id'],
                        item['nama_peminjam'],
                        item['nama_barang'],
                        item['tgl_pinjam'],
                        "Sewa ${item['jumlah']}",
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // 3. Tab Peminjam dengan Filter Internal
  Widget _buildTabPeminjam() {
    return Column(
      children: [
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInternalTabItem("Pengembalian", 0),
            _buildInternalTabItem("Selesai", 1),
            _buildInternalTabItem("Denda", 2),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) => _buildMainBorrowerCard(),
          ),
        ),
      ],
    );
  }

  // 4. Kartu Persetujuan (Beranda)
  Widget _buildApprovalCard(
    int id,
    String nama,
    String barang,
    String tanggal,
    String info,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      tanggal,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                barang,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(id, 'Disetujui'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Setuju"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(id, 'Ditolak'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Tolak"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Kartu Detail Peminjam (Tab Peminjam)
  Widget _buildMainBorrowerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mouse, size: 30, color: Colors.grey),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "clara sunde",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "peminjam@gmail.com",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          const Text("mouse", style: TextStyle(fontWeight: FontWeight.bold)),
          const Text(
            "Kembali: 15/01/2026",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          _activeTabPeminjam == 2
              ? ElevatedButton(
                  onPressed: () {},
                  child: const Text("Validasi Pembayaran"),
                )
              : Row(
                  children: [
                    _statusChip("Terlambat", Colors.red),
                    const SizedBox(width: 5),
                    _statusChip("Menunggu", Colors.orange),
                  ],
                ),
        ],
      ),
    );
  }

  // Helper UI kecil
  Widget _buildStatCard(String val, String label, IconData icon, Color col) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: col, size: 16),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildInternalTabItem(String label, int index) {
    bool active = _activeTabPeminjam == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabPeminjam = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String text, Color col) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: col.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: col, fontSize: 8)),
    );
  }
}
