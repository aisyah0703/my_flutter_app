import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  final ImagePicker _picker = ImagePicker();

  // ================== DATA ==================
  List<Map<String, dynamic>> allProducts = [
    {
      'id': 1,
      'name': 'Laptop',
      'cat': 'komputer',
      'stok': '10',
      'desc': 'High end laptop',
      'status': 'Tersedia',
      'img': null,
    },
    {
      'id': 2,
      'name': 'Keyboard',
      'cat': 'komputer',
      'stok': '5',
      'desc': 'Mechanical keyboard',
      'status': 'Tersedia',
      'img': null,
    },
    {
      'id': 3,
      'name': 'Mouse',
      'cat': 'komputer',
      'stok': '20',
      'desc': 'Gaming mouse',
      'status': 'Tersedia',
      'img': null,
    },
    {
      'id': 4,
      'name': 'Lan Tester',
      'cat': 'jaringan',
      'stok': '8',
      'desc': 'Tester kabel LAN',
      'status': 'Tersedia',
      'img': null,
    },
    {
      'id': 5,
      'name': 'Crimping tools',
      'cat': 'jaringan',
      'stok': '6',
      'desc': 'Tang crimping',
      'status': 'Tersedia',
      'img': null,
    },
    {
      'id': 6,
      'name': 'Kabel LAN',
      'cat': 'jaringan',
      'stok': '50',
      'desc': 'Cat 6',
      'status': 'Tersedia',
      'img': null,
    },
  ];

  List<Map<String, dynamic>> categories = [
    {'name': 'komputer'},
    {'name': 'jaringan'},
  ];

  String selectedCategory = 'semua kategori';
  String searchQuery = "";

  // ================== FILTER ==================
  List<Map<String, dynamic>> get filteredProducts {
    return allProducts.where((p) {
      final matchCat =
          selectedCategory == 'semua kategori' || p['cat'] == selectedCategory;
      final matchSearch = p['name'].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return matchCat && matchSearch;
    }).toList();
  }

  // ================== IMAGE PICKER ==================
  Future<File?> _pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img == null) return null;
    return File(img.path);
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(),
          _categoryTabs(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredProducts.length,
              itemBuilder: (_, i) => _productCard(filteredProducts[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: "cat",
            backgroundColor: const Color(0xFFAEE2FF),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryPage(categories: categories),
                ),
              );
            },
            child: const Icon(Icons.grid_view, color: Colors.black),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "add",
            backgroundColor: const Color(0xFFAEE2FF),
            onPressed: () => _showFormModal(),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // ================== HEADER ==================
  Widget _header() {
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
                children: const [
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================== CATEGORY ==================
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

  // ================== PRODUCT CARD ==================
  Widget _productCard(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
            child: p['img'] == null
                ? const Icon(Icons.image, color: Colors.grey)
                : Image.file(p['img'], fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  p['cat'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Row(
                  children: const [
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
              _actionBtn(
                Icons.edit,
                "Edit",
                Colors.blue,
                () => _showFormModal(product: p),
              ),
              const SizedBox(height: 6),
              _actionBtn(
                Icons.delete,
                "Hapus",
                Colors.red,
                () => _deleteProduct(p['id']),
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

  // ================== MODAL ==================
  void _showFormModal({Map<String, dynamic>? product}) {
    final isEdit = product != null;

    final nameCtrl = TextEditingController(
      text: isEdit ? product!['name'] : "",
    );
    final stokCtrl = TextEditingController(
      text: isEdit ? product!['stok'] : "",
    );
    final descCtrl = TextEditingController(
      text: isEdit ? product!['desc'] : "",
    );

    String category = isEdit ? product!['cat'] : 'komputer';
    File? image = isEdit ? product!['img'] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (_, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final img = await _pickImage();
                    if (img != null) setModal(() => image = img);
                  },
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: image == null
                        ? const Icon(Icons.image, size: 60)
                        : Image.file(image!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),
                _input("Nama", nameCtrl),
                _input("Stok", stokCtrl),
                DropdownButtonFormField<String>(
                  value: category,
                  items: const [
                    DropdownMenuItem(
                      value: 'komputer',
                      child: Text("komputer"),
                    ),
                    DropdownMenuItem(
                      value: 'jaringan',
                      child: Text("jaringan"),
                    ),
                  ],
                  onChanged: (v) => setModal(() => category = v!),
                  decoration: const InputDecoration(labelText: "Kategori"),
                ),
                _input("Deskripsi", descCtrl),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3668),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () {
                    setState(() {
                      if (isEdit) {
                        final i = allProducts.indexWhere(
                          (e) => e['id'] == product!['id'],
                        );
                        allProducts[i] = {
                          ...product!,
                          'name': nameCtrl.text,
                          'stok': stokCtrl.text,
                          'desc': descCtrl.text,
                          'cat': category,
                          'img': image,
                        };
                      } else {
                        allProducts.add({
                          'id': DateTime.now().millisecondsSinceEpoch,
                          'name': nameCtrl.text,
                          'stok': stokCtrl.text,
                          'desc': descCtrl.text,
                          'cat': category,
                          'status': 'Tersedia',
                          'img': image,
                        });
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text(isEdit ? "Simpan" : "Tambah"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void _deleteProduct(int id) {
    setState(() => allProducts.removeWhere((e) => e['id'] == id));
  }
}

// ================== CATEGORY PAGE ==================
class CategoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  const CategoryPage({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kategori")),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.folder),
          title: Text(categories[i]['name']),
        ),
      ),
    );
  }
}
