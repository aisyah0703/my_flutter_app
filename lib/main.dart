import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/admin_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// --- IMPORT SCREENS (Pastikan file ini ada di project Anda) ---
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_list.dart';
import 'screens/petugas_list.dart';
import 'screens/peminjam_list.dart';
import 'screens/logout_admin.dart';
import 'screens/logout_petugas.dart';
import 'screens/logout_peminjam.dart';

const Color kNavyColor = Color(0xFF1A3668);
const Color kGreenColor = Color(0xFF5BA66B);
const Color kBlueLight = Color(0xFF5D9CEC);
const Color kOrangeColor = Color(0xFFF39C12);

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
      title: 'Aplikasi Peminjaman Alat',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: kNavyColor,
        colorScheme: ColorScheme.fromSeed(seedColor: kNavyColor),
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
// 1. ADMIN WRAPPER
// ===========================================================================
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
        selectedItemColor: kNavyColor,
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
// 2. PETUGAS WRAPPER (DENGAN PEMANGGILAN PENGEMBALIAN)
// ===========================================================================
class PetugasMainWrapper extends StatefulWidget {
  const PetugasMainWrapper({super.key});

  @override
  State<PetugasMainWrapper> createState() => _PetugasMainWrapperState();
}

class _PetugasMainWrapperState extends State<PetugasMainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PetugasDashboard(),
    const TabDataPeminjam(),
    const TabStatus(),
    const LogoutPlaceholder(), // Ganti dengan widget logout Anda
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kNavyColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Peminjam'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ===========================================================================
// 2. DASHBOARD PETUGAS
// ===========================================================================
class PetugasDashboard extends StatelessWidget {
  const PetugasDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderPetugas()),
          SliverToBoxAdapter(child: _buildStatistikPetugas(supabase)),

          // SEKSI 1: ANTREAN PERSETUJUAN
          _buildSliverTitle("Antrean Persetujuan Pinjam"),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('peminjaman')
                .stream(primaryKey: ['id'])
                .eq('status', 'Menunggu'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              final list = snapshot.data ?? [];
              if (list.isEmpty) return _buildEmptyState("Tidak ada antrean");

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _CardPersetujuan(data: list[index]),
                  ),
                  childCount: list.length,
                ),
              );
            },
          ),

          // SEKSI 2: VERIFIKASI PENGEMBALIAN
          _buildSliverTitle(
            "Verifikasi Pengembalian Alat",
            color: kOrangeColor,
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('peminjaman')
                .stream(primaryKey: ['id'])
                .eq('status', 'Menunggu Verifikasi Kembali'),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const SliverToBoxAdapter(child: SizedBox());
              final list = snapshot.data!;
              if (list.isEmpty)
                return _buildEmptyState("Belum ada pengembalian");

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _CardVerifikasiKembali(data: list[index]),
                  ),
                  childCount: list.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _buildSliverTitle(String text, {Color color = Colors.black}) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ),
      );

  Widget _buildEmptyState(String text) => SliverToBoxAdapter(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    ),
  );

  Widget _buildHeaderPetugas() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: kNavyColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white24,
            child: Icon(Icons.badge, color: Colors.white),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, Petugas",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "Staff Operasional",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikPetugas(SupabaseClient supabase) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('peminjaman').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statBox(
                "Dipinjam",
                data.where((e) => e['status'] == 'Disetujui').length.toString(),
                Colors.blue,
              ),
              _statBox(
                "Menunggu",
                data.where((e) => e['status'] == 'Menunggu').length.toString(),
                kOrangeColor,
              ),
              _statBox(
                "Selesai",
                data.where((e) => e['status'] == 'Selesai').length.toString(),
                kGreenColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statBox(String label, String val, Color color) => Container(
    width: 105,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
    ),
    child: Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    ),
  );
}

// ===========================================================================
// 3. TAB PEMINJAM & LAPORAN
// ===========================================================================
class TabDataPeminjam extends StatelessWidget {
  const TabDataPeminjam({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peminjam Aktif"),
        backgroundColor: kNavyColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('peminjaman')
            .stream(primaryKey: ['id'])
            .eq('status', 'Disetujui'),
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];
          if (list.isEmpty)
            return const Center(child: Text("Tidak ada peminjaman aktif"));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.person, color: kNavyColor),
                title: Text(
                  list[index]['nama_peminjam'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Alat: ${list[index]['nama_barang']}\nKembali: ${list[index]['tgl_kembali']}",
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TabStatus extends StatelessWidget {
  const TabStatus({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Riwayat"),
        backgroundColor: kNavyColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('peminjaman')
            .stream(primaryKey: ['id'])
            .order('tgl_pinjam', ascending: false),
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(list[index]['nama_barang']),
              subtitle: Text("Peminjam: ${list[index]['nama_peminjam']}"),
              trailing: Text(
                list[index]['status'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: list[index]['status'] == 'Selesai'
                      ? kGreenColor
                      : Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===========================================================================
// 4. CARD COMPONENTS & LOGIC
// ===========================================================================
class _CardPersetujuan extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CardPersetujuan({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                data['nama_barang'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Peminjam: ${data['nama_peminjam']}\nJumlah: ${data['jumlah']} Unit",
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async => await Supabase.instance.client
                        .from('peminjaman')
                        .update({'status': 'Ditolak'})
                        .eq('id', data['id']),
                    child: const Text("Tolak"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => BottomSheetPersetujuan(data: data),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreenColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Setujui"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardVerifikasiKembali extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CardVerifikasiKembali({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: ListTile(
        title: Text(
          data['nama_barang'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Dari: ${data['nama_peminjam']}\nDenda: Rp ${data['denda'] ?? 0}",
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle, color: kGreenColor, size: 30),
          onPressed: () async {
            await Supabase.instance.client
                .from('peminjaman')
                .update({'status': 'Selesai'})
                .eq('id', data['id']);
            await Supabase.instance.client.rpc(
              'tambah_stok',
              params: {'id_barang': data['id_alat'], 'jml': data['jumlah']},
            );
          },
        ),
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
      padding: EdgeInsets.fromLTRB(
        25,
        25,
        25,
        MediaQuery.of(context).viewInsets.bottom + 25,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Konfirmasi Persetujuan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Divider(height: 30),
          ListTile(
            tileColor: Colors.grey.shade100,
            title: Text(
              selectedDate == null
                  ? "Pilih Tanggal Kembali"
                  : DateFormat('dd MMMM yyyy').format(selectedDate!),
            ),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => selectedDate = date);
            },
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavyColor,
                foregroundColor: Colors.white,
              ),
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
                      await Supabase.instance.client.rpc(
                        'kurangi_stok',
                        params: {
                          'id_barang': widget.data['id_alat'],
                          'jml': widget.data['jumlah'],
                        },
                      );
                      if (mounted) Navigator.pop(context);
                    },
              child: const Text("KONFIRMASI"),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutPlaceholder extends StatelessWidget {
  const LogoutPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      onPressed: () => Supabase.instance.client.auth.signOut(),
      child: const Text("Logout"),
    ),
  );
}

// ===========================================================================
// 3. PEMINJAM WRAPPER (DASHBOARD & LOGIKA KERANJANG)
// ===========================================================================
class PeminjamMainWrapper extends StatefulWidget {
  const PeminjamMainWrapper({super.key});
  @override
  State<PeminjamMainWrapper> createState() => _PeminjamMainWrapperState();
}

class _PeminjamMainWrapperState extends State<PeminjamMainWrapper> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> keranjangAlat = [];

  void tambahKeKeranjang(Map<String, dynamic> alat) {
    setState(() {
      bool sudahAda = keranjangAlat.any(
        (item) => item['id_alat'] == alat['id_alat'],
      );
      if (!sudahAda) {
        var itemBaru = Map<String, dynamic>.from(alat);
        itemBaru['qty'] = 1;
        keranjangAlat.add(itemBaru);
      }
    });
  }

  void hapusDariKeranjang(int idAlat) {
    setState(
      () => keranjangAlat.removeWhere((item) => item['id_alat'] == idAlat),
    );
  }

  void bersihkanKeranjang() {
    setState(() => keranjangAlat.clear());
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      PeminjamDashboard(
        keranjang: keranjangAlat,
        onTambah: tambahKeKeranjang,
        onHapus: hapusDariKeranjang,
        onClear: bersihkanKeranjang,
        // Callback untuk pindah tab setelah checkout
        onCheckoutSuccess: () => setState(() => _currentIndex = 1),
      ),
      const RiwayatPeminjaman(),
      const LogoutPeminjam(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kNavyColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Status Pinjam',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ===========================================================================
// 2. DASHBOARD & KATALOG
// ===========================================================================
class PeminjamDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> keranjang;
  final Function(Map<String, dynamic>) onTambah;
  final Function(int) onHapus;
  final VoidCallback onClear;
  final VoidCallback onCheckoutSuccess;

  const PeminjamDashboard({
    super.key,
    required this.keranjang,
    required this.onTambah,
    required this.onHapus,
    required this.onClear,
    required this.onCheckoutSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: keranjang.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FormKonfirmasiPinjam(listAlat: keranjang),
                  ),
                );
                // Jika pengajuan berhasil dikirim
                if (result == true) {
                  onClear();
                  onCheckoutSuccess();
                }
              },
              backgroundColor: kNavyColor,
              label: Text(
                "Pinjam ${keranjang.length} Alat",
                style: const TextStyle(color: Colors.white),
              ),
              icon: const Icon(
                Icons.shopping_cart_checkout,
                color: Colors.white,
              ),
            )
          : null,
      body: Column(
        children: [
          _buildHeaderPeminjam(),
          const Padding(
            padding: EdgeInsets.fromLTRB(25, 20, 25, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Katalog Alat",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('alat').stream(primaryKey: ['id_alat']),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final list = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final alat = list[index];
                    bool available = (alat['stok_tersedia'] ?? 0) > 0;
                    bool isInCart = keranjang.any(
                      (item) => item['id_alat'] == alat['id_alat'],
                    );
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: kNavyColor.withOpacity(0.05),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.construction,
                                  size: 40,
                                  color: kNavyColor,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alat['nama_alat'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                ),
                                Text(
                                  "Stok: ${alat['stok_tersedia']}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: available
                                      ? () => isInCart
                                            ? onHapus(alat['id_alat'])
                                            : onTambah(alat)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: !available
                                        ? Colors.grey
                                        : (isInCart
                                              ? Colors.redAccent
                                              : kNavyColor),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(
                                      double.infinity,
                                      35,
                                    ),
                                  ),
                                  child: Text(
                                    available
                                        ? (isInCart ? "Batal" : "Pilih")
                                        : "Habis",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPeminjam() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: kNavyColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, Peminjam",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "Pilih alat yang ingin dipinjam",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 3. FORM PENGAJUAN PINJAM
// ===========================================================================
class FormKonfirmasiPinjam extends StatefulWidget {
  final List<Map<String, dynamic>> listAlat;
  const FormKonfirmasiPinjam({super.key, required this.listAlat});
  @override
  State<FormKonfirmasiPinjam> createState() => _FormKonfirmasiPinjamState();
}

class _FormKonfirmasiPinjamState extends State<FormKonfirmasiPinjam> {
  final _namaController = TextEditingController();
  DateTime tglPinjam = DateTime.now();
  DateTime tglKembali = DateTime.now().add(const Duration(days: 3));
  final supabase = Supabase.instance.client;

  Future<void> _submitData() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama peminjam wajib diisi!")),
      );
      return;
    }

    try {
      for (var alat in widget.listAlat) {
        await supabase.from('peminjaman').insert({
          'nama_peminjam': _namaController.text,
          'nama_barang': alat['nama_alat'],
          'id_alat': alat['id_alat'],
          'jumlah': alat['qty'],
          'status': 'Menunggu',
          'tgl_pinjam': tglPinjam.toIso8601String(),
          'tgl_kembali': tglKembali.toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengajuan Berhasil Dikirim!")),
        );
        Navigator.pop(
          context,
          true,
        ); // Mengirim nilai true agar dashboard tahu ini berhasil
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengajukan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Pengajuan Pinjam"),
        backgroundColor: kNavyColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informasi Peminjam",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap Peminjam",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Daftar Alat",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...widget.listAlat
                .map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item['nama_alat']),
                      trailing: Text("Qty: ${item['qty']}"),
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _dateTile("Tgl Pinjam", tglPinjam, () {})),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateTile("Tgl Kembali", tglKembali, () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: tglKembali,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) setState(() => tglKembali = date);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavyColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text(
                "KIRIM PENGAJUAN",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 4. RIWAYAT & STATUS PINJAM
// ===========================================================================
class RiwayatPeminjaman extends StatelessWidget {
  const RiwayatPeminjaman({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Status Peminjaman"),
        backgroundColor: kNavyColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('peminjaman')
            .stream(primaryKey: ['id'])
            .order('tgl_pinjam', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          if (list.isEmpty)
            return const Center(child: Text("Belum ada riwayat peminjaman"));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final status = item['status'];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    item['nama_barang'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Status: $status"),
                  trailing: status == 'Disetujui'
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kOrangeColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FormPengembalian(data: item),
                            ),
                          ),
                          child: const Text("Kembalikan"),
                        )
                      : _buildStatusLabel(status),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    Color color = Colors.grey;
    if (status == 'Menunggu') color = kOrangeColor;
    if (status == 'Selesai') color = kGreenColor;
    if (status == 'Ditolak') color = Colors.red;
    if (status == 'Menunggu Verifikasi Kembali') color = Colors.blue;
    return Text(
      status,
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
    );
  }
}

// ===========================================================================
// 5. FORM PENGEMBALIAN
// ===========================================================================
class FormPengembalian extends StatefulWidget {
  final Map<String, dynamic> data;
  const FormPengembalian({super.key, required this.data});
  @override
  State<FormPengembalian> createState() => _FormPengembalianState();
}

class _FormPengembalianState extends State<FormPengembalian> {
  int denda = 0;
  bool isLate = false;

  @override
  void initState() {
    super.initState();
    _hitungDenda();
  }

  void _hitungDenda() {
    DateTime tglKembali = DateTime.parse(widget.data['tgl_kembali']);
    DateTime hariIni = DateTime.now();
    if (hariIni.isAfter(tglKembali)) {
      int selisih = hariIni.difference(tglKembali).inDays;
      if (selisih > 0) {
        setState(() {
          isLate = true;
          denda = selisih * 10000;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konfirmasi Pengembalian"),
        backgroundColor: kNavyColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildDetailCard(),
            const Spacer(),
            const Text(
              "Dengan menekan tombol di bawah, Anda menyatakan telah mengembalikan alat ke petugas.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavyColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await Supabase.instance.client
                      .from('peminjaman')
                      .update({
                        'status': 'Menunggu Verifikasi Kembali',
                        'denda': denda,
                        'tgl_dikembalikan': DateTime.now().toIso8601String(),
                      })
                      .eq('id', widget.data['id']);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Berhasil! Silakan serahkan alat ke petugas.",
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "KIRIM PENGEMBALIAN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          _rowInfo("Alat", widget.data['nama_barang']),
          _rowInfo(
            "Tenggat",
            DateFormat(
              'dd MMM yyyy',
            ).format(DateTime.parse(widget.data['tgl_kembali'])),
          ),
          const Divider(),
          if (isLate)
            _rowInfo(
              "Denda Keterlambatan",
              "Rp ${NumberFormat('#,###').format(denda)}",
              color: Colors.red,
            ),
          if (!isLate)
            const Text(
              "Status: Tepat Waktu",
              style: TextStyle(color: kGreenColor, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String val, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            val,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 6. PROFIL & LOGOUT
// ===========================================================================
class LogoutPeminjam extends StatelessWidget {
  const LogoutPeminjam({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Biru dengan lengkungan di bawah
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D2149),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(150),
                      bottomRight: Radius.circular(150),
                    ),
                  ),
                ),
                const Positioned(
                  top: 60,
                  child: Text(
                    'PROFIL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8DA9D4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Center(
                      child: Text(
                        'P',
                        style: TextStyle(
                          fontSize: 60,
                          color: Color(0xFF0D2149),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Bagian Form Data Profil
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  _buildProfileField("Nama", "Peminjam123"),
                  const SizedBox(height: 20),
                  _buildProfileField("Email", "Peminjam@gmail.com"),
                  const SizedBox(height: 20),
                  _buildProfileField("Sebagai", "Peminjam"),
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Tombol Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: ElevatedButton(
                onPressed: () {
                  // Kembali ke Login dan menghapus semua riwayat navigasi
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2149),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "Logout",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget pendukung untuk menampilkan label dan isi data profil
  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0D2149),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB3E5FC), width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
