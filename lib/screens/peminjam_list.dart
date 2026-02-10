import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Pastikan sudah tambah intl di pubspec.yaml

// ==========================================================
// 1. DASHBOARD PEMINJAM (BERANDA)
// ==========================================================
class PeminjamDashboard extends StatefulWidget {
  const PeminjamDashboard({super.key});

  @override
  State<PeminjamDashboard> createState() => _PeminjamDashboardState();
}

class _PeminjamDashboardState extends State<PeminjamDashboard> {
  final _supabase = Supabase.instance.client;

  // Fungsi ambil data dari tabel 'alat'
  Future<List<Map<String, dynamic>>> fetchAlat() async {
    final response = await _supabase.from('alat').select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(), // Header Biru Gelap
          _buildCategoryTabs(), // Tab Kategori
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAlat(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Data alat kosong"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return _buildProductCard(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 25, right: 25, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF1A3668),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text('D', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Davita123',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'peminjam',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'hallo mau sewa alat apa ????',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 15),
          TextField(
            decoration: InputDecoration(
              hintText: 'cari nama barang....',
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _categoryBtn("Semua Kategori", true),
          _categoryBtn("komputer", false),
          _categoryBtn("jaringan", false),
        ],
      ),
    );
  }

  Widget _categoryBtn(String label, bool active) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF1A3668) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF1A3668)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: active ? Colors.white : const Color(0xFF1A3668),
        fontSize: 12,
      ),
    ),
  );

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailAlat(item: item)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_alat'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item['kategori'] ?? 'Kategori',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'Tersedia',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 2. DETAIL ALAT
// ==========================================================
class DetailAlat extends StatelessWidget {
  final Map<String, dynamic> item;
  const DetailAlat({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3668),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const Expanded(
            child: Icon(Icons.build_circle, size: 120, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_alat'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Stok : ${item['stok']}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 15),
                Text(
                  "Spesifikasi : ${item['deskripsi'] ?? 'Alat ini digunakan untuk keperluan praktek.'}",
                ),
                const Divider(height: 30),
                const Text(
                  "Notes :",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _noteRow("jangan merusak barang"),
                _noteRow("jangan menjual barang"),
                _noteRow("mengembalikan tepat waktu"),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFCC),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormPengajuan(item: item),
                    ),
                  ),
                  child: const Text(
                    "Pinjam",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteRow(String t) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        const Icon(Icons.warning, size: 16, color: Color(0xFF1A3668)),
        const SizedBox(width: 10),
        Text(t, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

// ==========================================================
// 3. FORM PENGGUNAAN (DISELESAIKAN)
// ==========================================================
class FormPengajuan extends StatefulWidget {
  final Map<String, dynamic> item;
  const FormPengajuan({super.key, required this.item});

  @override
  State<FormPengajuan> createState() => _FormPengajuanState();
}

class _FormPengajuanState extends State<FormPengajuan> {
  final _supabase = Supabase.instance.client;
  final _jmlController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? tglPinjam;
  DateTime? tglKembali;

  Future<void> _kirimData() async {
    if (_jmlController.text.isEmpty || tglPinjam == null) return;
    try {
      await _supabase.from('peminjaman').insert({
        'nama_peminjam': 'Davita123',
        'nama_barang': widget.item['nama_alat'],
        'jumlah': int.parse(_jmlController.text),
        'tgl_pinjam': tglPinjam.toString(),
        'tgl_kembali': tglKembali.toString(),
        'notes': _noteController.text,
        'status': 'Menunggu',
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Berhasil diajukan!")));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3668),
      appBar: AppBar(
        title: const Text(
          "Form Pengajuan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView(
          children: [
            const Text(
              "Data Barang yang anda Pinjam",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _inputLabel("Alat"),
            TextField(
              controller: TextEditingController(text: widget.item['nama_alat']),
              enabled: false,
              decoration: _inputDeco(),
            ),
            _inputLabel("Jumlah Alat"),
            TextField(
              controller: _jmlController,
              keyboardType: TextInputType.number,
              decoration: _inputDeco(),
            ),
            _inputLabel("Tanggal pinjam"),
            _dateBox(tglPinjam, (d) => setState(() => tglPinjam = d)),
            _inputLabel("Tanggal pengembalian"),
            _dateBox(tglKembali, (d) => setState(() => tglKembali = d)),
            _inputLabel("Data peminjam"),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: _inputDeco(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3668),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _kirimData,
              child: const Text(
                "+ Ajukan Peminjaman",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER UNTUK MENGHINDARI ERROR BORDERSIDE ---
  Widget _inputLabel(String l) => Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 8),
    child: Text(
      l,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );

  InputDecoration _inputDeco() => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF1A3668)),
    ),
  );

  Widget _dateBox(DateTime? dt, Function(DateTime) onPick) => InkWell(
    onTap: () async {
      final p = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2027),
      );
      if (p != null) onPick(p);
    },
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dt == null
                ? "Pilih Tanggal"
                : DateFormat('EEEE, d MMMM yyyy').format(dt),
            style: TextStyle(color: dt == null ? Colors.grey : Colors.black),
          ),
          const Icon(Icons.calendar_month, color: Colors.grey),
        ],
      ),
    ),
  );
}
