import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/admin_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORT SCREENS (Pastikan file ini ada di folder lib/screens/) ---
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_list.dart';
import 'screens/petugas_list.dart';
import 'screens/peminjam_list.dart';
import 'screens/logout_admin.dart';
import 'screens/logout_petugas.dart';
import 'screens/logout_peminjam.dart';

// ===========================================================================
// MAIN ENTRY POINT
// ===========================================================================
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
      title: 'Aplikasi Peminjaman Alat',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1A3668),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3668)),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin_dashboard': (context) => const AdminMainWrapper(),
        '/petugas_dashboard': (context) => const PetugasMainWrapper(),
        '/peminjam_dashboard': (context) => const PeminjamMainWrapper(),
      },
    );
  }
}

// ===========================================================================
// 1. WRAPPER NAVIGASI ADMIN
// ===========================================================================
class AdminMainWrapper extends StatefulWidget {
  const AdminMainWrapper({super.key});
  @override
  State<AdminMainWrapper> createState() => _AdminMainWrapperState();
}

class _AdminMainWrapperState extends State<AdminMainWrapper> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(), // Bisa diganti DashboardPage()
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

// ===========================================================================
// 2. WRAPPER NAVIGASI PETUGAS
// ===========================================================================
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
      const PetugasDashboard(
        currentIndex: 0,
      ), // Dashboard Utama & Peminjam terintegrasi
      const TabDataPeminjam(), // Data Anggota
      const TabStatus(), // Laporan & Status
      const LogoutPetugas(), // Profil
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A3668),
        unselectedItemColor: Colors.grey,
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

// ===========================================================================
// 3. WRAPPER NAVIGASI PEMINJAM
// ===========================================================================
class PeminjamMainWrapper extends StatefulWidget {
  const PeminjamMainWrapper({super.key});
  @override
  State<PeminjamMainWrapper> createState() => _PeminjamMainWrapperState();
}

class _PeminjamMainWrapperState extends State<PeminjamMainWrapper> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const PeminjamDashboard(),
    const Center(child: Text("Daftar Produk")),
    const LogoutPeminjam(),
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

// ===========================================================================
// CORE COMPONENT: PETUGAS DASHBOARD (UI BERANDA)
// ===========================================================================
class PetugasDashboard extends StatefulWidget {
  final int currentIndex;
  const PetugasDashboard({super.key, required this.currentIndex});
  @override
  State<PetugasDashboard> createState() => _PetugasDashboardState();
}

class _PetugasDashboardState extends State<PetugasDashboard> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (widget.currentIndex == 1) {
      return const Center(child: Text("Halaman Data Anggota Peminjam"));
    }
    return _buildTabBeranda();
  }

  Widget _buildHeader() {
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
                child: Text("P"),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, Petugas",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Staff Operasional",
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
              hintText: "Cari data peminjaman...",
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

  Widget _buildTabBeranda() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatistik(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Text(
            "Menunggu Persetujuan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('peminjaman')
                .stream(primaryKey: ['id'])
                .eq('status', 'Menunggu'),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final list = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: list.length,
                itemBuilder: (context, index) => _CardPersetujuan(
                  data: list[index],
                  onApprove: () => _showModal(list[index]),
                  onReject: () async => await supabase
                      .from('peminjaman')
                      .update({'status': 'Ditolak'})
                      .eq('id', list[index]['id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatistik() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('peminjaman').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          final data = snapshot.data ?? [];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(
                data.where((e) => e['status'] == 'Disetujui').length.toString(),
                "Dipinjam",
                Colors.green,
              ),
              _statItem(
                data.where((e) => e['status'] == 'Selesai').length.toString(),
                "Kembali",
                Colors.red,
              ),
              _statItem(
                data.where((e) => e['status'] == 'Menunggu').length.toString(),
                "Antre",
                Colors.blue,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statItem(String val, String label, Color col) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: col,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showModal(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetPersetujuan(data: data),
    );
  }
}

// ===========================================================================
// CORE COMPONENT: TAB STATUS (LAPORAN)
// ===========================================================================
class TabStatus extends StatelessWidget {
  const TabStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderStatus(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(25),
            children: [
              _ItemCardStatus(
                judul: "card peminjam",
                deskripsi: "Laporan daftar peminjam perangkat",
                iconData: Icons.access_time,
                filter: "Disetujui",
              ),
              const SizedBox(height: 20),
              _ItemCardStatus(
                judul: "card pengembalian",
                deskripsi: "Laporan daftar perangkat yang dikembalikan",
                iconData: Icons.check_circle_outline,
                filter: "Selesai",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF1A3668),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Text(
        "STATUS LAPORAN",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

// ===========================================================================
// UI HELPER COMPONENTS (Card, Modal, Detail)
// ===========================================================================

class _CardPersetujuan extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onApprove, onReject;
  const _CardPersetujuan({
    required this.data,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin, size: 40, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['nama_peminjam'] ?? "-",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Barang: ${data['nama_barang']}",
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                "Qty: ${data['jumlah']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Setuju",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    "Tolak",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemCardStatus extends StatelessWidget {
  final String judul, deskripsi, filter;
  final IconData iconData;
  const _ItemCardStatus({
    required this.judul,
    required this.deskripsi,
    required this.iconData,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
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
              Icon(iconData, size: 45),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      deskripsi,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HalamanListDetail(filter: filter, title: judul),
                ),
              ),
              icon: const Icon(Icons.print, size: 18, color: Colors.white),
              label: const Text(
                "Cetak Laporan",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D9CEC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HalamanListDetail extends StatelessWidget {
  final String filter, title;
  const HalamanListDetail({
    super.key,
    required this.filter,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1A3668),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('peminjaman')
            .stream(primaryKey: ['id'])
            .eq('status', filter),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                title: Text(list[index]['nama_peminjam']),
                subtitle: Text(list[index]['nama_barang']),
                trailing: Text(
                  filter,
                  style: TextStyle(
                    color: filter == "Selesai" ? Colors.green : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BottomSheetPersetujuan extends StatefulWidget {
  final Map<String, dynamic> data;
  const BottomSheetPersetujuan({super.key, required this.data});
  @override
  State<BottomSheetPersetujuan> createState() => _BottomSheetPersetujuanState();
}

class _BottomSheetPersetujuanState extends State<BottomSheetPersetujuan> {
  DateTime? selectedDate;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Konfirmasi Pinjaman",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ListTile(
            title: const Text("Tentukan Tanggal Kembali"),
            subtitle: Text(
              selectedDate == null
                  ? "Klik untuk pilih"
                  : selectedDate.toString().split(' ')[0],
            ),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => selectedDate = date);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectedDate == null
                ? null
                : () async {
                    await Supabase.instance.client
                        .from('peminjaman')
                        .update({
                          'status': 'Disetujui',
                          'tgl_kembali': selectedDate!.toIso8601String(),
                        })
                        .eq('id', widget.data['id']);
                    Navigator.pop(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3668),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              "KONFIRMASI SEKARANG",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
