import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Warna desain
const Color kNavyColor = Color(0xFF1A3668);
const Color kGreenColor = Color(0xFF5BA66B);

// --- DASHBOARD TETAP SAMA (TIDAK DIKURANGI) ---
class PeminjamDashboard extends StatefulWidget {
  const PeminjamDashboard({super.key});

  @override
  State<PeminjamDashboard> createState() => _PeminjamDashboardState();
}

class _PeminjamDashboardState extends State<PeminjamDashboard> {
  final _supabase = Supabase.instance.client;
  String searchQuery = "";

  Future<List<Map<String, dynamic>>> fetchAlat() async {
    var query = _supabase.from('alat').select();
    if (searchQuery.isNotEmpty) {
      query = query.ilike('nama_alat', '%$searchQuery%');
    }
    final response = await query.order('nama_alat', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildCategoryTabs(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAlat(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) =>
                      _buildProductCard(snapshot.data![index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Header melengkung
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
      decoration: const BoxDecoration(
        color: kNavyColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text("D", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Davita123",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text("peminjam", style: TextStyle(color: Colors.white70)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.notifications, color: Colors.white),
            ],
          ),
          const SizedBox(height: 30),
          TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            decoration: InputDecoration(
              hintText: "cari nama barang....",
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: ["Semua Kategori", "Komputer", "Jaringan"].map((label) {
          bool isSelected = label == "Semua Kategori";
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ActionChip(
              label: Text(
                label,
                style: TextStyle(color: isSelected ? Colors.white : kNavyColor),
              ),
              backgroundColor: isSelected ? kNavyColor : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: kNavyColor),
              ),
              onPressed: () {},
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.laptop_mac, size: 50, color: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_alat'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text("-", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: kNavyColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormPengajuan(item: item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kNavyColor,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: "Produk"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    );
  }
}

// --- FORM PENGAJUAN (Sesuai Desain image_e4559f.png) ---
class FormPengajuan extends StatefulWidget {
  final Map<String, dynamic> item;
  const FormPengajuan({super.key, required this.item});

  @override
  State<FormPengajuan> createState() => _FormPengajuanState();
}

class _FormPengajuanState extends State<FormPengajuan> {
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController(text: "1");
  DateTime? tglPinjam;
  DateTime? tglTenggat;

  // Logika simpan menggunakan kolom 'tgl_tenggat'
  Future<void> _submit() async {
    if (tglPinjam == null || tglTenggat == null || _namaController.text.isEmpty)
      return;

    try {
      await Supabase.instance.client.from('peminjaman').insert({
        'nama_peminjam': _namaController.text,
        'nama_barang': widget.item['nama_alat'],
        'jumlah': int.tryParse(_jumlahController.text) ?? 1,
        'tgl_pinjam': tglPinjam!.toIso8601String(),
        'tgl_tenggat': tglTenggat!.toIso8601String(),
        'status': 'Menunggu',
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessPage(
              alat: widget.item['nama_alat'],
              jml: _jumlahController.text,
              tglP: tglPinjam!,
              tglT: tglTenggat!,
              nama: _namaController.text,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kNavyColor,
        elevation: 0,
        title: const Text(
          "Form Pengajuan",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: kNavyColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data Barang yang anda Pinjam",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  _label("Alat"),
                  _input(initial: widget.item['nama_alat'], enabled: false),
                  _label("Jumlah Alat"),
                  _input(controller: _jumlahController),
                  _label("Tanggal pinjam"),
                  _dateBox(tglPinjam, (d) => setState(() => tglPinjam = d)),
                  _label("Tanggal pengembalian"),
                  _dateBox(tglTenggat, (d) => setState(() => tglTenggat = d)),
                  _label("Data peminjam"),
                  const Text(
                    "( sertakan nama , kelas, dan nomer telepon)",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  _input(controller: _namaController, maxLines: 3),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNavyColor,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "+ Ajukan Peminjaman",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 5),
    child: Text(
      t,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    ),
  );

  Widget _input({
    String? initial,
    TextEditingController? controller,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller ?? TextEditingController(text: initial),
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dateBox(DateTime? d, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black45),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              d == null
                  ? "Pilih Tanggal"
                  : DateFormat('EEEE, d MMMM yyyy').format(d),
            ),
            const Icon(Icons.calendar_month_outlined),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN SUKSES (Sesuai image_e3cdda.png) ---
class SuccessPage extends StatelessWidget {
  final String alat, jml, nama;
  final DateTime tglP, tglT;
  const SuccessPage({
    super.key,
    required this.alat,
    required this.jml,
    required this.tglP,
    required this.tglT,
    required this.nama,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                color: kNavyColor,
                child: const Center(
                  child: Text(
                    "Pengajuan Berhasil",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 70),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  children: [
                    _tile("Alat", alat),
                    _tile("Jumlah Alat", jml),
                    _tile(
                      "Tanggal pinjam",
                      DateFormat('EEEE, d MMMM yyyy').format(tglP),
                    ),
                    _tile(
                      "Tanggal pengembalian",
                      DateFormat('EEEE, d MMMM yyyy').format(tglT),
                    ),
                    _tile("Data peminjam", nama),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: kGreenColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "silahkan tunggu pengajuan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 130,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: kGreenColor,
              child: Icon(Icons.check, color: Colors.white, size: 70),
            ),
          ),
          Positioned(
            top: 45,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(String l, String v) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        l,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 5, bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(v),
      ),
    ],
  );
}
