import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64),
            SizedBox(height: 12),
            Text(
              'Belum ada pengeluaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Ketuk tombol Tambah untuk mencatat pengeluaran pertama Anda.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
