import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'transactions_page.dart';
import 'card_page.dart';
import 'rewards_page.dart';
import 'additional_page.dart';

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
    _fetchNewsImages(); // Fetch news images on init
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

  Future<void> _fetchNewsImages() async {
    final url = 'http://192.168.1.34:3000/image_for_new'; // URL ของ backend
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List newsData = json.decode(response.body);
        setState(() {
          _newsImages = List<String>.from(newsData.map((news) => news['image_url']).take(6));
        });
      }
    } catch (e) {
      // Error handling
      print('Failed to load images');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _fetchCustomerData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getPage(int index) {
      switch (index) {
        case 1:
          return TransactionsPage(customerId: widget.customer['customer_id']);
        case 2:
          return CardPage(customer: widget.customer);
        case 3:
          return RewardsPage(customer: widget.customer);
        case 4:
          return AdditionalPage(customer: widget.customer);
        default:
          return Stack(
            children: [
              // Background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/pumpwallpaper.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black38,
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              // Customer info
              Positioned(
                top: 30,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.customer['first_name']} ${widget.customer['last_name']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'เลขสมาชิกสหกรณ์ : ${widget.customer['customer_id']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'เบอร์ : ${widget.customer['phone_number']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'แต้มสะสม: ${widget.customer['points_balance']} แต้ม',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // เพิ่มพื้นที่ว่างก่อนแสดงภาพข่าวสาร
                      _buildNewsImages(), // เรียกใช้ฟังก์ชันแสดงรูปภาพข่าวสาร
                    ],
                  ),
                ),
              ),
            ],
          );
      }
    }

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text('Welcome ${widget.customer['first_name']}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchCustomerData,
                ),
              ],
              backgroundColor: Colors.green,
            )
          : null,
      body: getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'รายการ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'บัตร',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.redeem),
            label: 'แลกรางวัล',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'เพิ่มเติม',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 42, 216, 181),
        unselectedItemColor: const Color.fromARGB(255, 253, 253, 253),
        backgroundColor: const Color.fromARGB(255, 54, 124, 56),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildNewsImages() {
    if (_newsImages.isEmpty) {
      return const Center(
        child: Text(
          'No news images available.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SizedBox(
      height: 200, // กำหนดความสูงของพื้นที่แสดงรูปภาพ
      child: PageView.builder(
        itemCount: _newsImages.length > 6 ? 6 : _newsImages.length, // จำกัดที่ 6 รูป
        controller: PageController(viewportFraction: 0.8), // เลื่อนหน้า
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
