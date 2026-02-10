import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ===========================================================================
// MAIN DASHBOARD PETUGAS
// ===========================================================================
class PetugasDashboard extends StatefulWidget {
  final int currentIndex;
  const PetugasDashboard({super.key, required this.currentIndex});

  @override
  State<PetugasDashboard> createState() => _PetugasDashboardState();
}

class _PetugasDashboardState extends State<PetugasDashboard> {
  final supabase = Supabase.instance.client;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeaderBiru(),
          Expanded(child: _pilihHalaman(_currentIndex)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF142E5A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Peminjam"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Status"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _pilihHalaman(int index) {
    switch (index) {
      case 0:
        return const Center(child: Text("Halaman Beranda"));
      case 1:
        return const TabDataPeminjam();
      case 2:
        return const TabStatus();
      case 3:
        return const Center(child: Text("Halaman Profil"));
      default:
        return const TabDataPeminjam();
    }
  }

  Widget _buildHeaderBiru() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 35),
      decoration: const BoxDecoration(
        color: Color(0xFF142E5A),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF4A90E2),
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
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Petugas",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.notifications, color: Colors.white),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "cari nama barang....",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// TAB 2: DATA PEMINJAM (DENGAN PENANGANAN ERROR NULL)
// ===========================================================================
class TabDataPeminjam extends StatefulWidget {
  const TabDataPeminjam({super.key});

  @override
  State<TabDataPeminjam> createState() => _TabDataPeminjamState();
}

class _TabDataPeminjamState extends State<TabDataPeminjam> {
  final supabase = Supabase.instance.client;

  String activeLabel = 'Pengembalian';
  String statusFilter = 'Disetujui';

  void _changeTab(String label, String status) {
    setState(() {
      activeLabel = label;
      statusFilter = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFilterButton("Pengembalian", "Disetujui"),
              _buildFilterButton("Selesai", "Selesai"),
              _buildFilterButton("Denda", "Denda"),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('peminjaman')
                .stream(primaryKey: ['id'])
                .eq('status', statusFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text("Terjadi kesalahan: ${snapshot.error}"),
                );
              }

              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    "Data $activeLabel Kosong",
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: list.length,
                itemBuilder: (context, index) => _buildCardDinamis(list[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, String value) {
    bool isActive = activeLabel == label;
    return InkWell(
      onTap: () => _changeTab(label, value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF5D9CEC)
              : Colors.black.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black45,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardDinamis(Map<String, dynamic> item) {
    // --- PENANGANAN DATA NULL AGAR TIDAK ERROR ---
    String namaPeminjam = item['nama_peminjam']?.toString() ?? "Tanpa Nama";
    String email = item['email']?.toString() ?? "Email tidak tersedia";
    String namaBarang = item['nama_barang']?.toString() ?? "Barang";
    String tglKembali = item['tgl_kembali']?.toString() ?? "-";
    String tglTenggat = item['tgl_tenggat']?.toString() ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.mouse, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaPeminjam,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (activeLabel == 'Selesai')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _badgeKecil("Selesai", Colors.green),
                      const SizedBox(height: 4),
                      _badgeKecil("Lunas", Colors.green),
                    ],
                  ),
                const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.6),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaBarang,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Tanggal Kembali : $tglKembali",
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
                Text(
                  "Tanggal Tenggat : $tglTenggat",
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: _buildFooterKondisional(item),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterKondisional(Map<String, dynamic> item) {
    if (activeLabel == 'Pengembalian') {
      return Row(
        children: [
          _labelStatus(
            "⚠️ Terlambat: 1 Hari",
            const Color(0xFFFFEAEA),
            Colors.red,
          ),
          const SizedBox(width: 10),
          _labelStatus(
            "🕒 Menunggu Persetujuan",
            const Color(0xFFFFF4E5),
            Colors.orange,
          ),
        ],
      );
    } else if (activeLabel == 'Denda') {
      return Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF142E5A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: const Text(
            "Validasi Pembayaran",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _badgeKecil(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      border: Border.all(color: color, width: 0.8),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
    ),
  );

  Widget _labelStatus(String text, Color bg, Color textCol) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textCol,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

// ===========================================================================
// TAB 3: STATUS (LAPORAN)
// ===========================================================================
class TabStatus extends StatelessWidget {
  const TabStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(25),
      children: [
        _buildReportCard(
          "Laporan Peminjam",
          "Daftar semua data peminjaman",
          Icons.access_time,
        ),
        const SizedBox(height: 20),
        _buildReportCard(
          "Laporan Kembali",
          "Daftar perangkat telah kembali",
          Icons.check_circle_outline,
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 40, color: Colors.black87),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print, color: Colors.white, size: 18),
            label: const Text(
              "Cetak Laporan",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D9CEC),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
