import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatelessWidget {
  final String qrData;

  const QrCodePage({Key? key, required this.qrData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      body: Center(
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 250.0,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
