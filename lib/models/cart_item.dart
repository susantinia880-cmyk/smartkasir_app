import 'produk.dart';

class CartItem {
  final Produk produk;
  int jumlah;

  CartItem({
    required this.produk,
    this.jumlah = 1,
  });

  double get totalHarga => produk.hargaJual * jumlah;
}