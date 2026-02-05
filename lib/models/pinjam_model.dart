class PeminjamanModel {
  final String? id;
  final String namaPeminjam;
  final String idBarang;
  final String namaBarang;
  final String tglPinjam;
  final String status; // 'Menunggu', 'Disetujui', 'Selesai'

  PeminjamanModel({
    this.id,
    required this.namaPeminjam,
    required this.idBarang,
    required this.namaBarang,
    required this.tglPinjam,
    this.status = 'Menunggu',
  });

  Map<String, dynamic> toMap() {
    return {
      'nama_peminjam': namaPeminjam,
      'barang_id': idBarang,
      'nama_barang': namaBarang,
      'tgl_pinjam': tglPinjam,
      'status': status,
    };
  }
}