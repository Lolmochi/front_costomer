import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> customer;

  const HomePage({super.key, required this.customer});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<String> _newsImages = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomerData();
    _fetchActiveImages(); // เรียกใช้ฟังก์ชันนี้เมื่อเริ่มต้น
  }

  Future<void> _fetchCustomerData() async {
    final url =
        'http://192.168.1.34:3000/customers/${widget.customer['customer_id']}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final updatedCustomer = json.decode(response.body);
        setState(() {
          widget.customer['points_balance'] =
              updatedCustomer['customer']['points_balance'];
        });
      }
    } catch (e) {
      // Handle exceptions if needed
    }
  }

  Future<void> _fetchActiveImages() async {
    const url = 'http://192.168.1.34:3000/get_active_images';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List newsData = json.decode(response.body);
        setState(() {
          _newsImages = List<String>.from(newsData.map((image) => image['image_url']));
        });
      } else {
        // Handle the case where the server returns an error
        print('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load images: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.customer['first_name']}'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: _buildNewsImages(), // เรียกใช้ฟังก์ชันแสดงรูปภาพ
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'รายการ',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildNewsImages() {
    if (_newsImages.isEmpty) {
      return const Center(
        child: Text('No news images available.'),
      );
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: _newsImages.length,
        controller: PageController(viewportFraction: 0.8),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                _newsImages[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
