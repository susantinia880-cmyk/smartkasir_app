import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> keranjangAwal;
  final Function() onCheckoutSuccess;

  const CartPage({
    super.key,
    required this.keranjangAwal,
    required this.onCheckoutSuccess,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<CartItem> _keranjangBelanja;
  String _metodePembayaranPilih = 'Tunai';
  final TextEditingController _uangBayarController = TextEditingController();

  final List<String> _metodeList = ['Tunai', 'QRIS', 'Transfer Bank', 'Kartu Debit'];

  @override
  void initState() {
    super.initState();
    _keranjangBelanja = widget.keranjangAwal;
  }

  @override
  void dispose() {
    _uangBayarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    double totalBelanja = _keranjangBelanja.fold(
      0,
      (sum, item) => sum + (item.produk.hargaJual * item.jumlah),
    );

    double uangBayar = double.tryParse(_uangBayarController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    double kembalian = uangBayar - totalBelanja;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang & Proses Pembayaran'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: _keranjangBelanja.isEmpty
          ? const Center(
              child: Text(
                'Keranjang masih kosong',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _keranjangBelanja.length,
                    itemBuilder: (context, index) {
                      final item = _keranjangBelanja[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(item.produk.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${formatRupiah.format(item.produk.hargaJual)} x ${item.jumlah}',
                          ),
                          trailing: Text(
                            formatRupiah.format(item.produk.hargaJual * item.jumlah),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Metode Pembayaran:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _metodePembayaranPilih,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _metodeList.map((String metode) {
                      return DropdownMenuItem<String>(
                        value: metode,
                        child: Text(metode),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _metodePembayaranPilih = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_metodePembayaranPilih == 'Tunai') ...[
                    const Text(
                      'Masukkan Uang Pembayaran (Tunai):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _uangBayarController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 50000',
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Uang Kembalian:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            kembalian >= 0 ? formatRupiah.format(kembalian) : 'Uang Belum Cukup',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: kembalian >= 0 ? Colors.blue[800] : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: _keranjangBelanja.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Pembayaran (Omzet):', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        formatRupiah.format(totalBelanja),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      if (_metodePembayaranPilih == 'Tunai' && uangBayar < totalBelanja) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Uang pembayaran tunai masih kurang!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      widget.onCheckoutSuccess();

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Pembayaran Berhasil!'),
                            content: Text(
                              'Metode: $_metodePembayaranPilih\n'
                              'Total Belanja: ${formatRupiah.format(totalBelanja)}\n'
                              '${_metodePembayaranPilih == 'Tunai' ? 'Uang Bayar: ${formatRupiah.format(uangBayar)}\nKembalian: ${formatRupiah.format(kembalian)}\n' : ''}'
                              '\nTransaksi telah sukses dicatat ke omzet.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Proses Pembayaran'),
                  ),
                ],
              ),
            ),
    );
  }
}