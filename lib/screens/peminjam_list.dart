import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// --- KONSTANTA WARNA ---
const Color kNavyColor = Color(0xFF1A3668);
const Color kGreenColor = Color(0xFF5BA66B);
const Color kOrangeColor = Color(0xFFFF7A00);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pastikan URL dan Anon Key sudah sesuai dengan proyek Supabase Anda
  await Supabase.initialize(
    url: 'https://njvzpnhphwgopndbcnlp.supabase.co',
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // Ganti dengan Anon Key Proyek Anda
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistem Peminjaman Alat',
      theme: ThemeData(
        primaryColor: kNavyColor,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kNavyColor),
      ),
      home: const MainNavigationPeminjam(namaPeminjam: "Siswa Dummy"),
    );
  }
}

// ===========================================================================
// 1. NAVIGASI UTAMA (BOTTOM NAVBAR)
// ===========================================================================
class MainNavigationPeminjam extends StatefulWidget {
  final String namaPeminjam;
  const MainNavigationPeminjam({super.key, required this.namaPeminjam});

  @override
  State<MainNavigationPeminjam> createState() => _MainNavigationPeminjamState();
}

class _MainNavigationPeminjamState extends State<MainNavigationPeminjam> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const PeminjamDashboard(),
      RiwayatPeminjaman(namaPeminjam: widget.namaPeminjam),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: kNavyColor,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: "Katalog",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Status Pinjam",
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 2. DASHBOARD PEMINJAM (KATALOG & KERANJANG)
// ===========================================================================
class PeminjamDashboard extends StatefulWidget {
  const PeminjamDashboard({super.key});
  @override
  State<PeminjamDashboard> createState() => _PeminjamDashboardState();
}

class _PeminjamDashboardState extends State<PeminjamDashboard> {
  final _supabase = Supabase.instance.client;
  String searchQuery = "";
  List<Map<String, dynamic>> keranjangAlat = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
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
              stream: _supabase
                  .from('alat')
                  .stream(primaryKey: ['id_alat'])
                  .order('nama_alat'),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final list = snapshot.data!
                    .where(
                      (item) => item['nama_alat']
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()),
                    )
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _buildItemCard(list[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: keranjangAlat.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: kOrangeColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormPengajuanData(
                      itemSelected: List.from(keranjangAlat),
                    ),
                  ),
                ).then((_) => setState(() => keranjangAlat.clear()));
              },
              label: Text(
                "Lanjutkan (${keranjangAlat.length} Alat)",
                style: const TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.assignment, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: kNavyColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.construction, color: Colors.white),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Peminjaman Alat",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "Pilih alat yang dibutuhkan",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            decoration: InputDecoration(
              hintText: "Cari alat...",
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    bool isAdded = keranjangAlat.any((e) => e['id_alat'] == item['id_alat']);
    bool available = (item['stok_tersedia'] ?? 0) > 0;

    return Card(
      elevation: 0,
      color: isAdded ? kGreenColor.withOpacity(0.1) : Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(
          item['nama_alat'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Stok: ${item['stok_tersedia']} unit"),
        trailing: available
            ? IconButton(
                icon: Icon(
                  isAdded ? Icons.check_circle : Icons.add_circle,
                  color: isAdded ? kGreenColor : kNavyColor,
                ),
                onPressed: () => setState(() {
                  isAdded
                      ? keranjangAlat.removeWhere(
                          (e) => e['id_alat'] == item['id_alat'],
                        )
                      : keranjangAlat.add(item);
                }),
              )
            : const Text(
                "Habis",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

// ===========================================================================
// 3. FORM PENGAJUAN PINJAM
// ===========================================================================
class FormPengajuanData extends StatefulWidget {
  final List<Map<String, dynamic>> itemSelected;
  const FormPengajuanData({super.key, required this.itemSelected});
  @override
  State<FormPengajuanData> createState() => _FormPengajuanDataState();
}

class _FormPengajuanDataState extends State<FormPengajuanData> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  DateTime? tglPinjam;
  DateTime? tglTenggat;
  bool _isLoading = false;

  Future<void> _submitPeminjaman() async {
    if (!_formKey.currentState!.validate() ||
        tglPinjam == null ||
        tglTenggat == null)
      return;
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    try {
      for (var item in widget.itemSelected) {
        await supabase.from('peminjaman').insert({
          'id_alat': item['id_alat'],
          'nama_peminjam': _namaController.text,
          'nama_barang': item['nama_alat'],
          'jumlah': 1,
          'tgl_pinjam': tglPinjam!.toIso8601String(),
          'tgl_kembali': tglTenggat!
              .toIso8601String(), // Kolom tenggat di DB Anda
          'status': 'Menunggu',
        });
      }
      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (c) => SuccessPage(nama: _namaController.text),
          ),
        );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulir Data"),
        backgroundColor: kNavyColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(25),
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: "Nama Lengkap",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    tileColor: Colors.grey[100],
                    title: Text(
                      tglPinjam == null
                          ? "Pilih Tanggal Pinjam"
                          : DateFormat('dd MMM yyyy').format(tglPinjam!),
                    ),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) setState(() => tglPinjam = d);
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    tileColor: Colors.grey[100],
                    title: Text(
                      tglTenggat == null
                          ? "Pilih Tanggal Kembali"
                          : DateFormat('dd MMM yyyy').format(tglTenggat!),
                    ),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) setState(() => tglTenggat = d);
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submitPeminjaman,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNavyColor,
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: const Text(
                      "KIRIM PENGAJUAN",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ===========================================================================
// 4. RIWAYAT PEMINJAMAN DENGAN TOMBOL PENGEMBALIAN
// ===========================================================================
class RiwayatPeminjaman extends StatelessWidget {
  final String namaPeminjam;
  const RiwayatPeminjaman({super.key, required this.namaPeminjam});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Status Pinjam"),
        backgroundColor: kNavyColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('peminjaman')
            .stream(primaryKey: ['id'])
            .eq('nama_peminjam', namaPeminjam),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              bool statusDisetujui = item['status'] == 'Disetujui';

              return Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        item['nama_barang'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Status: ${item['status']}\nTenggat: ${item['tgl_kembali']?.toString().split('T')[0]}",
                      ),
                      trailing: Icon(
                        Icons.circle,
                        color: statusDisetujui ? kGreenColor : kOrangeColor,
                        size: 12,
                      ),
                    ),
                    if (statusDisetujui)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => FormPengembalian(data: item),
                            ),
                          ),
                          icon: const Icon(Icons.assignment_return),
                          label: const Text("KEMBALIKAN ALAT"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNavyColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ===========================================================================
// 5. FORM PENGEMBALIAN (DATABASE SINKRON)
// ===========================================================================
class FormPengembalian extends StatefulWidget {
  final Map<String, dynamic> data;
  const FormPengembalian({super.key, required this.data});
  @override
  State<FormPengembalian> createState() => _FormPengembalianState();
}

class _FormPengembalianState extends State<FormPengembalian> {
  final _supabase = Supabase.instance.client;
  int denda = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hitungDenda();
  }

  void _hitungDenda() {
    DateTime tenggat = DateTime.parse(widget.data['tgl_kembali']);
    DateTime sekarang = DateTime.now();
    if (sekarang.isAfter(tenggat)) {
      int selisih = sekarang.difference(tenggat).inDays;
      setState(() => denda = selisih * 10000); // Denda 10rb/hari
    }
  }

  Future<void> _submitKembali() async {
    setState(() => _isLoading = true);
    try {
      // 1. Simpan ke tabel 'pengembalian' sesuai struktur Anda
      await _supabase.from('pengembalian').insert({
        'id_pinjam': widget.data['id'],
        'tgl_kembali': DateTime.now().toIso8601String(),
        'denda': denda,
        'status_pengembalian': 'Menunggu Verifikasi',
        'id_petugas': null,
      });

      // 2. Update status di tabel 'peminjaman'
      await _supabase
          .from('peminjaman')
          .update({'status': 'Dikembalikan'})
          .eq('id', widget.data['id']);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil Dikembalikan!"),
            backgroundColor: kGreenColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Pengembalian")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Barang"),
                    subtitle: Text(widget.data['nama_barang']),
                    leading: const Icon(Icons.inventory),
                  ),
                  ListTile(
                    title: const Text("Denda"),
                    subtitle: Text("Rp $denda"),
                    leading: const Icon(Icons.money_off, color: Colors.red),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _submitKembali,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreenColor,
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: const Text(
                      "KONFIRMASI SEKARANG",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ===========================================================================
// 6. HALAMAN SUKSES & LAINNYA
// ===========================================================================
class SuccessPage extends StatelessWidget {
  final String nama;
  const SuccessPage({super.key, required this.nama});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: kGreenColor),
            const Text(
              "BERHASIL!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (c) => MainNavigationPeminjam(namaPeminjam: nama),
                ),
                (r) => false,
              ),
              child: const Text("Kembali ke Home"),
            ),
          ],
        ),
      ),
    );
  }
}
