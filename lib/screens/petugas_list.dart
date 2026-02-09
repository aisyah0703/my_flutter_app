import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PetugasDashboard extends StatefulWidget {
  const PetugasDashboard({
    super.key,
    required String nama,
    required String barang,
    required String jumlah,
  });

  @override
  State<PetugasDashboard> createState() => _PetugasDashboardState();
}

class _PetugasDashboardState extends State<PetugasDashboard> {
  // State Navigasi
  int _currentIndex = 0;
  int _activeTabPeminjam = 0;
  bool _isViewingApprovalList = false;
  bool _isViewingDetailForm = false;
  bool _isSuccessApproved = false;

  // State Baru untuk Validasi Pembayaran
  bool _isValidatingPayment = false;
  bool _isPaymentSuccess = false;

  // State Data Form
  final String _selectedUser = "Clara Sunde";
  DateTime? _tglAmbil;
  DateTime? _tglKembali;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id', null);
  }

  String _format(DateTime? date) {
    if (date == null) return "Pilih Tanggal";
    return DateFormat('EEEE, d MMMM yyyy', 'id').format(date);
  }

  Future<void> _pilihTanggalAmbil(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _tglAmbil = picked;
        _tglKembali = picked.add(const Duration(days: 3));
      });
    }
  }

  // =========================================================
  // LOGIKA DIALOG TOLAK (SESUAI GAMBAR BARU)
  // =========================================================
  void _showTolakDendaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "TOLAK",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 24,
          ),
        ),
        content: const Text(
          "denda keterlambatan pengembalian",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isValidatingPayment = false);
                },
                child: const Text("Iya", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TAMPILAN VALIDASI DENDA (SAMA PERSIS GAMBAR)
  // =========================================================
  Widget _buildValidasiDendaBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderDendaWithEdit(),
          const SizedBox(height: 60),

          if (_isPaymentSuccess) ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 40),
            const Text(
              "Pembayaran diterima",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                _buildInputLabel("Nama", "Clara Sunde"),
                _buildInputLabel("Jumlah", "2"),
                _buildInputLabel("Kembali", "kamis, 3 Februari 2026"),
                _buildInputLabel(
                  "Tenggat pengembalian",
                  "kamis, 3 Februari 2026",
                ),

                const SizedBox(height: 20),
                // Ringkasan Pembayaran Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildRingkasanRow(
                        "Ringkasan Pembayaran",
                        "",
                        isHeader: true,
                      ),
                      const Divider(height: 1),
                      _buildRingkasanRow("Denda Telat", "Rp 5.000"),
                      const Divider(height: 1),
                      _buildRingkasanRow("TOTAL", "Rp 5.000", isBold: true),
                      const Divider(height: 1),
                      _buildRingkasanRow("Metode", "Tunai"),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: _buildBtnAction(
                        "Tolak",
                        Colors.grey[300]!,
                        Colors.black,
                        _showTolakDendaDialog,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildBtnAction(
                        "Terima",
                        const Color(0xFF1A3668),
                        Colors.white,
                        () => setState(() => _isPaymentSuccess = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderDendaWithEdit() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF1A3668),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() {
                _isValidatingPayment = false;
                _isPaymentSuccess = false;
              }),
            ),
          ),
        ),
        Positioned(
          top: 60,
          child: Stack(
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://w7.pngwing.com/pngs/423/530/png-transparent-computer-mouse-logitech-m185-wireless-mouse-optical-mouse-mouse-electronics-mouse-computer-mouse-thumbnail.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A3668),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRingkasanRow(
    String label,
    String value, {
    bool isHeader = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: (isHeader || isBold)
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isHeader ? Colors.black54 : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CODE LAMA (TIDAK DIHAPUS)
  // =========================================================
  Widget _buildBerandaBody() {
    if (_isViewingDetailForm) return _buildDetailFormPersetujuan();
    if (_isViewingApprovalList) {
      return Column(
        children: [
          const SizedBox(height: 50),
          _buildTopNav(
            "Menunggu persetujuan",
            () => setState(() => _isViewingApprovalList = false),
          ),
          const SizedBox(height: 30),
          _buildCardBerandaStyle(
            "Claraa",
            "Mouse",
            "Pinjam 28 - 29 Jan 2026",
            "Sewa 3",
            true,
          ),
        ],
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderBlue(),
          const SizedBox(height: 20),
          _buildStatistikRow(),
          const SizedBox(height: 25),
          _buildSubTitle("Menunggu Persetujuan"),
          _buildCardBerandaStyle(
            "Claraa",
            "Mouse",
            "Pinjam 28 - 29 Jan 2026",
            "Sewa 3",
            true,
          ),
          const SizedBox(height: 15),
          _buildSubTitle("Pengembalian Hari ini"),
          _buildCardBerandaStyle(
            "Elingga",
            "Lan tester",
            "Kembali, 27 Jan 2026",
            "Sewa 1",
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildPeminjamBody() {
    return Column(
      children: [
        _buildHeaderBlue(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabItem("Pengembalian", 0),
            _buildTabItem("Selesai", 1),
            _buildTabItem("Denda", 2),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 2,
            itemBuilder: (context, index) {
              if (_activeTabPeminjam == 0) return _buildCardPengembalian();
              if (_activeTabPeminjam == 1) return _buildCardSelesai();
              return _buildCardDenda();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailFormPersetujuan() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderWithMouseImage(),
          const SizedBox(height: 80),
          if (_isSuccessApproved) ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 10),
            const Text(
              "Pengajuan Disetujui!",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              children: [
                _buildInputLabel("Nama", _selectedUser),
                _buildInputLabel("Jumlah", "2"),
                _buildInputDropdown(
                  "Ambil",
                  _format(_tglAmbil),
                  () => _pilihTanggalAmbil(context),
                ),
                _buildInputDropdown("Kembali", _format(_tglKembali), null),
                _buildInputDropdown(
                  "Tenggat pengembalian",
                  _format(_tglKembali),
                  null,
                ),
                const SizedBox(height: 30),
                if (!_isSuccessApproved)
                  Row(
                    children: [
                      Expanded(
                        child: _buildBtnAction(
                          "Tolak",
                          Colors.grey[300]!,
                          Colors.black,
                          () {},
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildBtnAction(
                          "Setuju",
                          const Color(0xFF1A3668),
                          Colors.white,
                          () => setState(() => _isSuccessApproved = true),
                        ),
                      ),
                    ],
                  )
                else
                  _buildBtnAction("Selesai", Colors.green, Colors.white, () {
                    setState(() {
                      _isViewingDetailForm = false;
                      _isSuccessApproved = false;
                    });
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildCardDenda() => _buildBaseCardPeminjam(
    chips: [_buildStatusChip("💸 Denda Rp 5.000", Colors.red)],
    showBtn: true,
  );

  Widget _buildBaseCardPeminjam({
    required List<Widget> chips,
    bool showBtn = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mouse),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "clara sunde",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "peminjam@gmail.com",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          const Text("mouse", style: TextStyle(fontWeight: FontWeight.bold)),
          const Text(
            "Kembali : 15/01/2026",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(children: chips),
          if (showBtn)
            Align(
              alignment: Alignment.centerRight,
              child: _buildSmallBtn(
                "Validasi Pembayaran",
                const Color(0xFF1A3668),
                () => setState(() => _isValidatingPayment = true),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderBlue() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 25),
      decoration: const BoxDecoration(
        color: Color(0xFF1A3668),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF4A90E2),
                child: Text("P", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Petugas123",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Petugas",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.notifications, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "cari nama barang.....",
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithMouseImage() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 130,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF1A3668),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() => _isViewingDetailForm = false),
            ),
          ),
        ),
        Positioned(
          top: 70,
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: const Center(
              child: Icon(Icons.mouse, size: 60, color: Color(0xFF1A3668)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistikRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard("10", "Peminjam", Colors.green, Icons.person),
          _buildStatCard("3", "Pengembalian", Colors.red, Icons.refresh),
          _buildStatCard("4", "Menunggu", Colors.blue, Icons.access_time),
        ],
      ),
    );
  }

  Widget _buildStatCard(String q, String l, Color c, IconData i) {
    return InkWell(
      onTap: l == "Menunggu"
          ? () => setState(() => _isViewingApprovalList = true)
          : null,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(i, color: c, size: 16),
                const SizedBox(width: 5),
                Text(
                  q,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              l,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBerandaStyle(
    String n,
    String i,
    String t,
    String s,
    bool isApp,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        t,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      i,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      s,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isApp) ...[
                  _buildSmallBtn(
                    "Setuju",
                    const Color(0xFF2E7D32),
                    () => setState(() {
                      _isViewingDetailForm = true;
                      _isSuccessApproved = false;
                    }),
                  ),
                  const SizedBox(width: 20),
                  _buildSmallBtn("Tolak", const Color(0xFFD32F2F), () {}),
                ] else
                  _buildSmallBtn("Selesai", const Color(0xFF2E7D32), () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String t, int i) {
    bool a = _activeTabPeminjam == i;
    return GestureDetector(
      onTap: () => setState(() => _activeTabPeminjam = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: a ? const Color(0xFF4A90E2) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          t,
          style: TextStyle(
            color: a ? Colors.white : Colors.black54,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav(String t, VoidCallback b) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: b,
        ),
        Expanded(
          child: Center(
            child: Text(
              t,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildInputLabel(String l, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3668),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100, width: 1.5),
            ),
            child: Text(
              v,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputDropdown(String l, String v, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3668),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(v, style: const TextStyle(fontSize: 12)),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBtnAction(String t, Color b, Color tx, VoidCallback o) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: b,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 45),
      ),
      onPressed: o,
      child: Text(
        t,
        style: TextStyle(color: tx, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSmallBtn(String l, Color c, VoidCallback o) {
    return ElevatedButton(
      onPressed: o,
      style: ElevatedButton.styleFrom(
        backgroundColor: c,
        minimumSize: const Size(100, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(l, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _buildStatusChip(String l, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(
        l,
        style: TextStyle(color: c, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubTitle(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          t,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildCardPengembalian() => _buildBaseCardPeminjam(
    chips: [
      _buildStatusChip("⚠️ Terlambat 1 Hari", Colors.red),
      const SizedBox(width: 5),
      _buildStatusChip("🕒 Menunggu", Colors.orange),
    ],
  );
  Widget _buildCardSelesai() => _buildBaseCardPeminjam(
    chips: [_buildStatusChip("✅ Dikembalikan", Colors.green)],
  );

  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    if (_isValidatingPayment) {
      currentBody = _buildValidasiDendaBody();
    } else {
      currentBody = _currentIndex == 0
          ? _buildBerandaBody()
          : _buildPeminjamBody();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: currentBody,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
          _isViewingDetailForm = false;
          _isViewingApprovalList = false;
          _isValidatingPayment = false;
          _isPaymentSuccess = false;
        }),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A3668),
        items: const [],
      ),
    );
  }
}
