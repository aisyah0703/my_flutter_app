import 'package:flutter/material.dart';
import 'admin_list.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Halaman LENGKAP: Dashboard, Produk, Pengguna, Riwayat/Laporan, Profil
  final List<Widget> _pages = const [
    DashboardPage(),
    AdminListPage(),
    AdminPetugasList(),
    AdminRiwayatList(), // HALAMAN LAPORAN YANG BARU DITAMBAHKAN
    Center(child: Text("Profil")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A3668),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Pengguna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// --- HALAMAN RIWAYAT / LAPORAN (PENAMBAHAN BARU) ---
class AdminRiwayatList extends StatefulWidget {
  const AdminRiwayatList({super.key});

  @override
  State<AdminRiwayatList> createState() => _AdminRiwayatListState();
}

class _AdminRiwayatListState extends State<AdminRiwayatList> {
  String selectedFilter = "Semua";
  final List<String> filters = [
    "Semua",
    "Dipinjam",
    "Kembali",
    "Terlambat",
    "Rusak",
  ];

  List<Map<String, dynamic>> riwayat = [
    {
      "item": "Laptop",
      "type": "Komputer",
      "date": "Kembali, 1 februari 2026",
      "status": "Terlambat",
    },
    {
      "item": "Lan tester",
      "type": "Jaringan",
      "date": "Kembali, 1 februari 2026",
      "status": "Dikembalikan",
    },
    {
      "item": "Keyboard",
      "type": "Komputer",
      "date": "Kembali, 1 februari 2026",
      "status": "Rusak",
    },
    {
      "item": "Mouse",
      "type": "Komputer",
      "date": "Kembali, 1 februari 2026",
      "status": "Dipinjam",
    },
  ];

  void _confirmDelete(int index) {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF102647),
                    ),
                    onPressed: () {
                      setState(() => riwayat.removeAt(index));
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Iya",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 40,
              left: 25,
              right: 25,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF102647),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF6DA4D9),
                      child: Text(
                        "A",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Admin123",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "admin",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      color: Colors.orangeAccent,
                      size: 60,
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Riwayat\nPeminjaman",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "cari nama barang...",
                      icon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab Filter Status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              children: filters
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                        label: Text(
                          f,
                          style: TextStyle(
                            color: selectedFilter == f
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        selected: selectedFilter == f,
                        selectedColor: const Color(0xFF4A89C5),
                        backgroundColor: Colors.grey.shade200,
                        onSelected: (val) => setState(() => selectedFilter = f),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: riwayat.length,
              itemBuilder: (context, index) =>
                  _buildRiwayatCard(riwayat[index], index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> data, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['item'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  data['type'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  data['date'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data['status'],
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _actionBtn(
                Icons.delete,
                "Hapus",
                Colors.red.shade50,
                Colors.red,
                () => _confirmDelete(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String txt,
    Color bg,
    Color clr,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: clr),
            const SizedBox(width: 4),
            Text(
              txt,
              style: TextStyle(
                color: clr,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN PENGGUNA (ADMIN PETUGAS) ---
class AdminPetugasList extends StatefulWidget {
  const AdminPetugasList({super.key});

  @override
  State<AdminPetugasList> createState() => _AdminPetugasListState();
}

class _AdminPetugasListState extends State<AdminPetugasList> {
  List<Map<String, dynamic>> users = [
    {
      "name": "Admin123",
      "email": "admin123@gmail.com",
      "isOnline": true,
      "role": "Admin",
    },
    {
      "name": "Petugas123",
      "email": "petugas123@gmail.com",
      "isOnline": false,
      "role": "Petugas",
    },
  ];

  void _confirmDelete(int index) {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => users.removeAt(index));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF102647),
                    ),
                    child: const Text(
                      "Iya",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openForm({Map<String, dynamic>? data, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormPage(
          userData: data,
          onSave: (newData) {
            setState(() {
              if (index != null) {
                users[index] = newData;
              } else {
                users.add(newData);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 40,
              left: 25,
              right: 25,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF102647),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF6DA4D9),
                      child: Text(
                        "A",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Admin123",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "admin",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.group,
                      color: Colors.orangeAccent,
                      size: 60,
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Daftar\nPengguna",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: users.length,
              itemBuilder: (context, index) =>
                  _buildUserCard(users[index], index),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFFBDE0FE),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  user['email'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _openForm(data: user, index: index),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(index),
          ),
        ],
      ),
    );
  }
}

// --- HALAMAN FORM (TAMBAH/EDIT) ---
class UserFormPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>) onSave;
  const UserFormPage({super.key, this.userData, required this.onSave});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  String selectedRole = 'Petugas';

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      nameController.text = widget.userData!['name'];
      emailController.text = widget.userData!['email'];
      selectedRole = widget.userData!['role'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            color: const Color(0xFF102647),
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _inputLabel("Nama"),
                  TextField(
                    controller: nameController,
                    decoration: _inputDecoration("Masukkan Nama"),
                  ),
                  const SizedBox(height: 20),
                  _inputLabel("Email"),
                  TextField(
                    controller: emailController,
                    decoration: _inputDecoration("Masukkan Email"),
                  ),
                  const SizedBox(height: 20),
                  _inputLabel("Sebagai"),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: _inputDecoration(""),
                    items: ['Admin', 'Petugas']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedRole = v!),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Batal",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF102647),
                          ),
                          onPressed: () {
                            widget.onSave({
                              "name": nameController.text,
                              "email": emailController.text,
                              "isOnline": false,
                              "role": selectedRole,
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            widget.userData == null ? "Tambah" : "Simpan",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputLabel(String txt) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      txt,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF102647),
      ),
    ),
  );
  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}

// --- DASHBOARD PAGE (KODE ASLI ANDA) ---
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _banner(),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  "Grafik Peminjan Bulanan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 25),
              _chart(),
              const SizedBox(height: 35),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: const [
                  _StatCard(title: "Total Alat", value: "6"),
                  _StatCard(title: "Dipinjam", value: "2"),
                  _StatCard(title: "Tersedia", value: "6"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFF6DA4D9),
          child: Text("A", style: TextStyle(fontSize: 26, color: Colors.black)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Aisyah Najwa",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("admin", style: TextStyle(color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  Widget _banner() {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF6DA4D9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.face, size: 80, color: Colors.white),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "Semangat Bekerja\nhari ini !!",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chart() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            _Bar(height: 45, label: "januari"),
            _Bar(height: 75, label: "februari"),
            _Bar(height: 85, label: "maret"),
            _Bar(height: 115, label: "mei"),
            _Bar(height: 75, label: "juni"),
            _Bar(height: 35, label: "juli"),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "(perbulan)",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final String label;
  const _Bar({required this.height, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF102647),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2, size: 40, color: Color(0xFF102647)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
