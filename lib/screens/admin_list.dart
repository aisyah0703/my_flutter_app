import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();

  // Stream untuk update data secara otomatis (Realtime)
  late final Stream<List<Map<String, dynamic>>> _productStream = supabase
      .from('alat')
      .stream(primaryKey: ['id_alat']);

  Future<XFile?> _pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
  }

  Future<String?> _uploadToStorage(XFile pickedFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'public/$fileName';

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await supabase.storage.from('alat_images').uploadBinary(path, bytes);
      } else {
        await supabase.storage
            .from('alat_images')
            .upload(path, File(pickedFile.path));
      }
      return supabase.storage.from('alat_images').getPublicUrl(path);
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  Future<void> _deleteProduct(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "HAPUS",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Apakah anda yakin ingin menghapus ?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3668),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await supabase.from('alat').delete().match({
                        'id_alat': id,
                      });
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text("Iya"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFormAlat({Map<String, dynamic>? product}) {
    final bool isEdit = product != null;
    XFile? pickedFile;
    Uint8List? webImage;

    final nameController = TextEditingController(
      text: isEdit ? product['nama_alat'] : "",
    );
    final stokController = TextEditingController(
      text: isEdit ? product['stok_total'].toString() : "",
    );
    final spesifikasiController = TextEditingController(
      text: isEdit ? product['spesifikasi'] : "",
    );
    int? kategoriId = isEdit ? product['id_kategori'] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A3668),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: (webImage != null)
                              ? Image.memory(webImage!, fit: BoxFit.cover)
                              : (isEdit &&
                                    pickedFile == null &&
                                    product['url_gambar'] != null &&
                                    product['url_gambar'] != "")
                              ? Image.network(
                                  product['url_gambar'],
                                  fit: BoxFit.cover,
                                )
                              : (pickedFile != null && !kIsWeb)
                              ? Image.file(
                                  File(pickedFile!.path),
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final res = await _pickImage();
                          if (res != null) {
                            if (kIsWeb) {
                              final bytes = await res.readAsBytes();
                              setModalState(() {
                                webImage = bytes;
                                pickedFile = res;
                              });
                            } else {
                              setModalState(() {
                                pickedFile = res;
                              });
                            }
                          }
                        },
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFF1A3668),
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildInputField("Nama", nameController, "Masukkan Nama"),
                _buildInputField(
                  "Stok",
                  stokController,
                  "Masukkan Stok",
                  isNumber: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        " Kategori",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3668),
                        ),
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<int>(
                        value: kategoriId,
                        hint: const Text("Pilih Kategori"),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("komputer")),
                          DropdownMenuItem(value: 2, child: Text("jaringan")),
                        ],
                        onChanged: (v) => kategoriId = v,
                      ),
                    ],
                  ),
                ),
                _buildInputField(
                  "Spesifikasi",
                  spesifikasiController,
                  "masukan detail spesifikasi",
                  maxLines: 3,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      if (isEdit) ...[
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(0, 50),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Batal"),
                          ),
                        ),
                        const SizedBox(width: 15),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3668),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                          ),
                          onPressed: () async {
                            // Tampilkan loading jika perlu
                            String? finalUrl = isEdit
                                ? product['url_gambar']
                                : "";

                            if (pickedFile != null) {
                              finalUrl = await _uploadToStorage(pickedFile!);
                            }

                            final data = {
                              'nama_alat': nameController.text,
                              'stok_total':
                                  int.tryParse(stokController.text) ?? 0,
                              'stok_tersedia':
                                  int.tryParse(stokController.text) ?? 0,
                              'id_kategori': kategoriId,
                              'spesifikasi': spesifikasiController.text,
                              'url_gambar': finalUrl,
                            };

                            if (isEdit) {
                              await supabase.from('alat').update(data).match({
                                'id_alat': product['id_alat'],
                              });
                            } else {
                              await supabase.from('alat').insert(data);
                            }

                            if (mounted) Navigator.pop(context);
                          },
                          child: Text(isEdit ? "Simpan" : "Tambah"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            " $label",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3668),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.lightBlueAccent),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
        ), // Memberi jarak agar tidak menutupi navbar
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFAEE2FF),
          onPressed: () => _showFormAlat(),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          _header(context),
          _categoryTabs(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _productStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return const Center(child: Text("Data Kosong"));

                final filtered = snapshot.data!.where((p) {
                  final matchSearch = p['nama_alat']
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                  bool matchCat = true;
                  if (selectedCategory == 'komputer')
                    matchCat = p['id_kategori'] == 1;
                  else if (selectedCategory == 'jaringan')
                    matchCat = p['id_kategori'] == 2;
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
      // NAVBAR DIKEMBALIKAN KE TEMPATNYA AGAR TIDAK BERTUMPUK
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A3668),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Produk"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Pengguna"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  // --- Widget Header, CategoryTabs, ProductCard tetap sama secara desain ---
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
          child: const Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
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
                  SizedBox(width: 15),
                  Column(
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
              SizedBox(height: 20),
              Text(
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
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
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
              child: (p['url_gambar'] != null && p['url_gambar'] != "")
                  ? Image.network(
                      p['url_gambar'],
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.image),
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
                const Text(
                  "Tersedia",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _actionBtn(
                Icons.edit,
                "Edit",
                Colors.blue,
                () => _showFormAlat(product: p),
              ),
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
}
