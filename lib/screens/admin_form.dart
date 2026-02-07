import 'package:flutter/material.dart';
import 'admin_list.dart'; // File Produk kamu
import 'logout_admin.dart'; // File Logout kamu

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // DAFTAR HALAMAN (Menggunakan class asli dari file import kamu)
  final List<Widget> _pages = const [
    DashboardPage(),
    AdminListPage(), // Halaman dari admin_list.dart
    AdminPetugasList(),
    AdminRiwayatList(),
    LogoutAdmin(), // Halaman dari logout_admin.dart
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

// ==========================================
// 1. HALAMAN BERANDA (DASHBOARD)
// ==========================================
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER BIRU TUA (Sama persis dengan gambar) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF0D2149), // Biru gelap sesuai gambar
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
                          style: TextStyle(fontSize: 26, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Aisyah Najwa",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "admin",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Semangat Bekerja\nhari ini !!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- BAGIAN GRAFIK ---
            const Text(
              "Grafik Peminjan Bulanan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildChartSection(),

            const SizedBox(height: 40),

            // --- STAT CARD SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _StatCard(title: "Total Alat", value: "6"),
                      _StatCard(title: "Dipinjam", value: "2"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const _StatCard(title: "Tersedia", value: "6"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget Grafik dengan Sumbu dan Garis (Sesuai gambar)
  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      child: Stack(
        children: [
          // Garis-garis Horizontal dan Label Sumbu Y
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              int labelValue = (4 - index) * 10;
              return Row(
                children: [
                  SizedBox(
                    width: 25,
                    child: Text(
                      labelValue.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: Colors.grey[300]),
                  ),
                ],
              );
            }),
          ),
          // Batang Grafik
          Padding(
            padding: const EdgeInsets.only(left: 35, bottom: 20, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _Bar(height: 40, label: "januari"),
                _Bar(height: 65, label: "februari"),
                _Bar(height: 75, label: "maret"),
                _Bar(height: 100, label: "mei"),
                _Bar(height: 65, label: "juni"),
                _Bar(height: 30, label: "juli"),
              ],
            ),
          ),
          // Label Sumbu Y Vertikal
          Positioned(
            left: -35,
            top: 60,
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(-90 / 360),
              child: const Text(
                "jumlah barang terpinjam",
                style: TextStyle(fontSize: 8, color: Colors.grey),
              ),
            ),
          ),
          // Label (perbulan) di bawah
          const Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "(perbulan)",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0D2149),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
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
      width: (MediaQuery.of(context).size.width / 2) - 30,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0D2149), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 24,
              color: Color(0xFF0D2149),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN PENGGUNA (ADMIN PETUGAS LIST)
// ==========================================
class AdminPetugasList extends StatefulWidget {
  const AdminPetugasList({super.key});

  @override
  State<AdminPetugasList> createState() => _AdminPetugasListState();
}

class _AdminPetugasListState extends State<AdminPetugasList> {
  // Data dummy awal
  List<Map<String, dynamic>> users = [
    {
      "name": "Admin123",
      "email": "admin123@gmail.com",
      "role": "Admin",
      "status": "online",
    },
    {
      "name": "Petugas123",
      "email": "petugas123@gmail.com",
      "role": "Petugas",
      "status": "offline",
    },
  ];

  // --- 1. LOGIKA DIALOG HAPUS (SESUAI GAMBAR) ---
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
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9D9D9),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2149),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() => users.removeAt(index));
                      Navigator.pop(context);
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

  // --- 2. LOGIKA FORM TAMBAH & EDIT (MODAL BOTTOM SHEET) ---
  void _showUserForm({int? index}) {
    bool isEdit = index != null;
    TextEditingController nameController = TextEditingController(
      text: isEdit ? users[index]['name'] : "",
    );
    TextEditingController emailController = TextEditingController(
      text: isEdit ? users[index]['email'] : "",
    );
    String selectedRole = isEdit ? users[index]['role'] : "Petugas";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Biru Melengkung
            Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0D2149),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(50),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(Icons.person, size: 45, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Inputan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nama"),
                  _buildTextField(nameController, "Masukkan Nama"),
                  const SizedBox(height: 15),
                  _buildLabel("Email"),
                  _buildTextField(emailController, "Masukkan Email"),
                  const SizedBox(height: 15),
                  _buildLabel("Sebagai"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFBDE0FE)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedRole,
                        items: ["Admin", "Petugas"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRole = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tombol Utama (Tambah/Simpan)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D2149),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          if (isEdit) {
                            users[index] = {
                              "name": nameController.text,
                              "email": emailController.text,
                              "role": selectedRole,
                              "status": "offline",
                            };
                          } else {
                            users.add({
                              "name": nameController.text,
                              "email": emailController.text,
                              "role": selectedRole,
                              "status": "offline",
                            });
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        isEdit ? "Simpan" : "Tambah",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 5, bottom: 5),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF0D2149),
      ),
    ),
  );

  Widget _buildTextField(TextEditingController controller, String hint) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFBDE0FE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0D2149)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 50, 25, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF0D2149),
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
                      radius: 28,
                      backgroundColor: Color(0xFF6DA4D9),
                      child: Text(
                        "A",
                        style: TextStyle(color: Colors.white, fontSize: 24),
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, color: Colors.orangeAccent, size: 60),
                    SizedBox(width: 15),
                    Text(
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
                const SizedBox(height: 25),
                Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: users.length,
              itemBuilder: (context, index) => _buildUserCard(index),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(),
        backgroundColor: const Color(0xFFBDE0FE),
        child: const Icon(Icons.add, color: Colors.black, size: 35),
      ),
    );
  }

  Widget _buildUserCard(int index) {
    bool isOnline = users[index]['status'] == "online";
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  users[index]['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  users[index]['email'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? "online" : "offline",
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline ? Colors.green : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              _actionButton(
                Icons.edit,
                "Edit",
                Colors.blue,
                () => _showUserForm(index: index),
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.delete,
                "Hapus",
                Colors.red,
                () => _confirmDelete(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(6),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
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

// ==========================================
// 3. HALAMAN LAPORAN (ADMIN RIWAYAT LIST)
// ==========================================
class AdminRiwayatList extends StatefulWidget {
  const AdminRiwayatList({super.key});

  @override
  State<AdminRiwayatList> createState() => _AdminRiwayatListState();
}

class _AdminRiwayatListState extends State<AdminRiwayatList> {
  String selectedFilter = "Semua";
  final TextEditingController _searchController = TextEditingController();
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
      "status": "Kembali",
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
    final filteredData = riwayat.where((data) {
      final matchesFilter =
          selectedFilter == "Semua" || data['status'] == selectedFilter;
      final matchesSearch = data['item'].toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      return matchesFilter && matchesSearch;
    }).toList();

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
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: "cari nama barang...",
                      icon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
              itemCount: filteredData.length,
              itemBuilder: (context, index) =>
                  _buildRiwayatCard(filteredData[index], index),
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
              InkWell(
                onTap: () => _confirmDelete(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.delete, size: 12, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        "Hapus",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
