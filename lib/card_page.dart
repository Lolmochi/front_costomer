import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CardPage extends StatelessWidget {
  final Map<String, dynamic> customer;

  const CardPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'บัตรสะสมแต้ม (สมาชิกสหกรณ์การเกษตร)',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 10,
                child: Container(
                  width: 400,
                  height: 250,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 20, 77, 22),
                        Colors.green.shade300,
                        Colors.green.shade500,
                        const Color.fromARGB(255, 20, 66, 22),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: Text(
                            'ID: ${customer['customer_id']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            '${customer['first_name']} ${customer['last_name']}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // QR Code
                      Positioned(
                        bottom: 50,
                        left: 75,
                        right: 75,
                        child: QrImageView(
                          data: customer['customer_id'].toString(),
                          version: QrVersions.auto,
                          size: 150.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            'Phone: ${customer['phone_number']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '* แสดงบัตรสมาชิกนี้ต่อพนักงานเมื่อทำรายการเติมน้ำมัน เพื่อรับแต้มสะสม *',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
