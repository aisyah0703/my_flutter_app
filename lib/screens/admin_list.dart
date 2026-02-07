import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      theme: ThemeData(useMaterial3: true),
      home: const AdminListPage(),
    );
  }
}

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  final supabase = Supabase.instance.client;
  String selectedCategory = 'semua kategori';
  String searchQuery = "";

  // Stream data dari tabel 'alat' secara realtime
  late final Stream<List<Map<String, dynamic>>> _productStream = supabase
      .from('alat')
      .stream(primaryKey: ['id_alat']);

  // Fungsi Hapus Produk
  Future<void> _deleteProduct(int id) async {
    await supabase.from('alat').delete().match({'id_alat': id});
  }

  // Fungsi Tambah Produk Baru dengan Kategori
  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final stokController = TextEditingController();
    int? kategoriId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Alat Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama Alat"),
            ),
            TextField(
              controller: stokController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Jumlah Stok"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Pilih Kategori"),
              items: const [
                DropdownMenuItem(value: 1, child: Text("Komputer")),
                DropdownMenuItem(value: 2, child: Text("Jaringan")),
              ],
              onChanged: (value) => kategoriId = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && kategoriId != null) {
                await supabase.from('alat').insert({
                  'nama_alat': nameController.text,
                  'stok_total': int.parse(stokController.text),
                  'stok_tersedia': int.parse(stokController.text),
                  'id_kategori': kategoriId,
                  'url_gambar': '', // Bisa diisi URL gambar default
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          _categoryTabs(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _productStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Tidak ada data produk"));
                }

                final allProducts = snapshot.data!;

                // LOGIKA FILTER: Pencarian + Kategori
                final filtered = allProducts.where((p) {
                  final matchSearch = p['nama_alat']
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());

                  bool matchCat = true;
                  if (selectedCategory == 'komputer') {
                    matchCat = p['id_kategori'] == 1;
                  } else if (selectedCategory == 'jaringan') {
                    matchCat = p['id_kategori'] == 2;
                  }

                  return matchSearch && matchCat;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _productCard(filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _header(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          padding: const EdgeInsets.only(top: 50, left: 25, right: 25),
          decoration: const BoxDecoration(
            color: Color(0xFF1A3668),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF4A90E2),
                    child: Text(
                      "D",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Admin123",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("admin", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "hallo admin, Semangat bekerja !",
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
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
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: const InputDecoration(
                hintText: "cari nama barang....",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryTabs() {
    final tabs = ['semua kategori', 'komputer', 'jaringan'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs.map((t) {
          final active = selectedCategory == t;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = t),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF1A3668) : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFF1A3668)),
              ),
              child: Text(
                t,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF1A3668),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> p) {
    String labelKategori = p['id_kategori'] == 1
        ? "Komputer"
        : (p['id_kategori'] == 2 ? "Jaringan" : "Umum");

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: p['url_gambar'] == null || p['url_gambar'] == ""
                  ? const Icon(Icons.image, color: Colors.grey)
                  : Image.network(
                      p['url_gambar'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['nama_alat'] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  labelKategori,
                  style: const TextStyle(
                    color: Color(0xFF1A3668),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Stok: ${p['stok_tersedia'] ?? 0}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 12),
                    SizedBox(width: 5),
                    Text(
                      "Tersedia",
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              _actionBtn(Icons.edit, "Edit", Colors.blue, () {}),
              const SizedBox(height: 6),
              _actionBtn(
                Icons.delete,
                "Hapus",
                Colors.red,
                () => _deleteProduct(p['id_alat']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        padding: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: "cat",
          backgroundColor: const Color(0xFFAEE2FF),
          onPressed: () {},
          child: const Icon(Icons.grid_view, color: Colors.black),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: "add",
          backgroundColor: const Color(0xFFAEE2FF),
          onPressed: _showAddProductDialog,
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ],
    );
  }
}
