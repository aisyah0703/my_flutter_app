class PeminjamanModel {
  final String namaPeminjam;
  final String namaBarang;
  final int jumlah;
  final String tglPinjam;
  final String tglKembali;
  final String notes;
  final String status;

  PeminjamanModel({
    required this.namaPeminjam,
    required this.namaBarang,
    required this.jumlah,
    required this.tglPinjam,
    required this.tglKembali,
    required this.notes,
    this.status = 'Menunggu',
  });

  // Mengubah data menjadi Map agar bisa dibaca oleh Supabase .insert()
  Map<String, dynamic> toMap() {
    return {
      'nama_peminjam': namaPeminjam,
      'nama_barang': namaBarang,
      'jumlah': jumlah,
      'tgl_pinjam': tglPinjam,
      'tgl_kembali': tglKembali,
      'notes': notes,
      'status': status,
    };
  }
}
