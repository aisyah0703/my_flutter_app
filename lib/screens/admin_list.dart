import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pastikan URL dan Anon Key sesuai dengan project Supabase Anda
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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1A3668),
      ),
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

  // Stream untuk mendapatkan data secara Realtime
  late final Stream<List<Map<String, dynamic>>> _productStream = supabase
      .from('alat')
      .stream(primaryKey: ['id_alat'])
      .order('id_alat', ascending: false);

  // Fungsi Ambil Gambar
  Future<XFile?> _pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
  }

  // Fungsi Upload Gambar ke Storage
  Future<String?> _uploadToStorage(XFile pickedFile) async {
    try {
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

  // Fungsi Hapus Data
  Future<void> _deleteProduct(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Hapus Data",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Apakah Anda yakin ingin menghapus alat ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await supabase.from('alat').delete().match({'id_alat': id});
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data berhasil dihapus")),
                  );
                }
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menghapus: $e")),
                  );
              }
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // Form Tambah & Edit
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

    // Inisialisasi ID Kategori (menangani ID 1, 2, atau 4)
    int? kategoriId;
    if (isEdit) {
      kategoriId = product['id_kategori'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Modal
                Container(
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A3668),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isEdit ? "Edit Data Alat" : "Tambah Alat Baru",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Input Gambar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
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
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () async {
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
                      icon: const Icon(Icons.edit, size: 20),
                    ),
                  ],
                ),

                _buildInputField(
                  "Nama Alat",
                  nameController,
                  "Contoh: Router Mikrotik",
                ),
                _buildInputField(
                  "Stok Total",
                  stokController,
                  "Masukkan angka",
                  isNumber: true,
                ),

                // Dropdown Kategori
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
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButtonFormField<int>(
                        value: kategoriId,
                        hint: const Text("Pilih Kategori"),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Komputer")),
                          DropdownMenuItem(value: 2, child: Text("Jaringan")),
                          DropdownMenuItem(value: 4, child: Text("Perkakas")),
                        ],
                        onChanged: (v) => kategoriId = v,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildInputField(
                  "Spesifikasi",
                  spesifikasiController,
                  "Detail alat...",
                  maxLines: 3,
                ),

                const SizedBox(height: 20),

                // Tombol Simpan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3668),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            stokController.text.isEmpty ||
                            kategoriId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Lengkapi semua field!"),
                            ),
                          );
                          return;
                        }

                        try {
                          String? finalUrl = isEdit
                              ? product['url_gambar']
                              : "";
                          if (pickedFile != null) {
                            finalUrl = await _uploadToStorage(pickedFile!);
                          }

                          final data = {
                            'nama_alat': nameController.text,
                            'stok_total': int.parse(stokController.text),
                            'stok_tersedia': isEdit
                                ? product['stok_tersedia']
                                : int.parse(stokController.text),
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
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                        }
                      },
                      child: Text(isEdit ? "Simpan Perubahan" : "Tambah Data"),
                    ),
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

  // Widget TextField Reusable
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
          Text(" $label", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormAlat(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _header(),
          _categoryTabs(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _productStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final list = snapshot.data!.where((p) {
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
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  itemBuilder: (context, i) => _productCard(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Header & Search
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF1A3668),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text(
            "ADMIN PANEL",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Cari alat...",
              prefixIcon: const Icon(Icons.search),
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

  // Tabs Kategori
  Widget _categoryTabs() {
    final tabs = ['semua kategori', 'komputer', 'jaringan'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Row(
        children: tabs
            .map(
              (t) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(t),
                  selected: selectedCategory == t,
                  onSelected: (val) => setState(() => selectedCategory = t),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // Kartu Produk
  Widget _productCard(Map<String, dynamic> p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (p['url_gambar'] != null && p['url_gambar'] != "")
              ? Image.network(
                  p['url_gambar'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.image, size: 50),
        ),
        title: Text(
          p['nama_alat'] ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Stok: ${p['stok_tersedia']} / ${p['stok_total']}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showFormAlat(product: p),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProduct(p['id_alat']),
            ),
          ],
        ),
      ),
    );
  }
}
