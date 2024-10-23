import 'package:costumer/login_customer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdditionalPage extends StatelessWidget {
  final Map<String, dynamic> customer;

  const AdditionalPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลเพิ่มเติม'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // Navigation buttons to various pages
            ListTile(
              title: const Text('ข้อมูลส่วนตัว'),
              trailing: const Icon(Icons.person),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(customer: customer)),
                );
              },
            ),
            ListTile(
              title: const Text('การตั้งค่า'),
              trailing: const Icon(Icons.settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('ข้อมูลการใช้งาน'),
              trailing: const Icon(Icons.info),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsagePage()),
                );
              },
            ),
            ListTile(
              title: const Text('ประโยชน์ของแอป'),
              trailing: const Icon(Icons.lightbulb),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BenefitsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('ปันผลรายปี'),
              trailing: const Icon(Icons.attach_money),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DividendsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('ล็อกเอา'),
              trailing: const Icon(Icons.logout),
              onTap: () {
                  _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

  Future<void> _logout(BuildContext context) async {
    // Clear user session data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate back to the login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CustomerLoginPage()),
      (route) => false,
    );
  }

// Profile Page
class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> customer;

  const ProfilePage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ข้อมูลส่วนตัว')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ข้อมูลส่วนตัวของ ${customer['first_name']} ${customer['last_name']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'หมายเลขโทรศัพท์: ${customer['phone_number']}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'แต้มสะสม: ${customer['points_balance']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordPage(customerId: customer['id'])), // ส่ง customerId ไปยังหน้าจอเปลี่ยนรหัสผ่าน
                );
              },
              child: const Text('เปลี่ยนรหัสผ่าน'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Change Password Page
class ChangePasswordPage extends StatefulWidget {
  final String customerId;

  const ChangePasswordPage({super.key, required this.customerId});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    // ตรวจสอบว่ารหัสผ่านใหม่และยืนยันรหัสผ่านตรงกัน
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านใหม่และยืนยันรหัสผ่านไม่ตรงกัน')),
      );
      return;
    }

    // สร้างการเรียก API เพื่อเปลี่ยนรหัสผ่าน
    final url = Uri.parse('http://192.168.1.20:3000/change_password'); // แทนที่ด้วย URL ของคุณ
    final response = await http.post(url, body: {
      'customerId': widget.customerId,
      'oldPassword': _oldPasswordController.text,
      'newPassword': _newPasswordController.text,
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปลี่ยนรหัสผ่านสำเร็จ')),
      );
      Navigator.pop(context); // กลับไปยังหน้าข้อมูลส่วนตัว
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการเปลี่ยนรหัสผ่าน')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เปลี่ยนรหัสผ่าน')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(labelText: 'รหัสผ่านเก่า'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'ยืนยันรหัสผ่านใหม่'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('เปลี่ยนรหัสผ่าน'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//Settings Page
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

// Define the State for the SettingsPage
class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _pointsEarnedEnabled = true;
  bool _pointsUsedEnabled = true;
  bool _newProductNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _pointsEarnedEnabled = prefs.getBool('pointsEarnedEnabled') ?? true;
      _pointsUsedEnabled = prefs.getBool('pointsUsedEnabled') ?? true;
      _newProductNotificationEnabled = prefs.getBool('newProductNotificationEnabled') ?? true;
    });
  }

  

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', _notificationsEnabled);
    prefs.setBool('pointsEarnedEnabled', _pointsEarnedEnabled);
    prefs.setBool('pointsUsedEnabled', _pointsUsedEnabled);
    prefs.setBool('newProductNotificationEnabled', _newProductNotificationEnabled);

    // Show confirmation after saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกการแจ้งเตือนสำเร็จ')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('แจ้งเตือน'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: Colors.teal,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('ได้รับแต้ม'),
            value: _pointsEarnedEnabled,
            onChanged: (bool value) {
              setState(() {
                _pointsEarnedEnabled = value;
              });
            },
            activeColor: Colors.teal,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('ใช้แต้ม'),
            value: _pointsUsedEnabled,
            onChanged: (bool value) {
              setState(() {
                _pointsUsedEnabled = value;
              });
            },
            activeColor: Colors.teal,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('สินค้าใหม่มาแล้ว'),
            value: _newProductNotificationEnabled,
            onChanged: (bool value) {
              setState(() {
                _newProductNotificationEnabled = value;
              });
            },
            activeColor: Colors.teal,
          ),
          const Divider(),
          ElevatedButton(
            onPressed: _saveSettings, // Save all settings at once
            child: const Text('บันทึกการตั้งค่า'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}


// Usage Page
class UsagePage extends StatefulWidget {
  @override
  _UsagePageState createState() => _UsagePageState();
}

class _UsagePageState extends State<UsagePage> {
  String lastUsageDate = '';
  int usageCount = 0;
  String appVersion = '1.0.3';

  @override
  void initState() {
    super.initState();
    loadUsageData();
    updateUsageData();
  }

  // Load usage data from SharedPreferences
  Future<void> loadUsageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastUsageDate = prefs.getString('lastUsageDate') ?? 'ยังไม่เคยใช้งาน';
      usageCount = prefs.getInt('usageCount') ?? 0;
    });
  }

  // Update usage data and save to SharedPreferences
  Future<void> updateUsageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Update the last usage date to the current date
    String currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

    setState(() {
      lastUsageDate = currentDate;
      usageCount++;
    });

    await prefs.setString('lastUsageDate', currentDate);
    await prefs.setInt('usageCount', usageCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ข้อมูลการใช้งาน')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลการใช้งานของคุณ:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              '- ใช้งานล่าสุด: $lastUsageDate',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '- จำนวนครั้งที่ใช้งานแอป: $usageCount ครั้ง',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '- เวอร์ชันแอป: $appVersion',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Benefits Page
class BenefitsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ประโยชน์ของแอป')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ประโยชน์ที่คุณจะได้รับ:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '- สะสมแต้มจากการเติมน้ำมัน',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '- แลกรับของรางวัลพิเศษ',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '- รับปันผลประจำปี',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '- ดูประวัติการทำรายการย้อนหลัง',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Dividends Page
class DividendsPage extends StatefulWidget {
  @override
  _DividendsPageState createState() => _DividendsPageState();
}

class _DividendsPageState extends State<DividendsPage> {
  List<String> years = [];
  Map<String, dynamic> dividendsData = {};
  bool isLoading = true;
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    fetchYears();  // Start fetching years when the widget initializes
  }

  Future<void> fetchYears() async {
    final url = Uri.parse('http://192.168.1.20:3000/annual_dividends/years'); // Replace with your server URL

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          years = data.cast<String>();
          selectedYear = years.isNotEmpty ? years[0] : null; // Auto-select the first year if available
          if (selectedYear != null) {
            fetchDividendsData(selectedYear!); // Fetch dividends for the selected year
          }
        });
      } else {
        throw Exception('Failed to load years');
      }
    } catch (e) {
      print('Error fetching years: $e');
      setState(() {
        isLoading = false;  // Stop loading if there was an error
      });
    }
  }

  Future<void> fetchDividendsData(String year) async {
      final url = Uri.parse('http://192.168.1.20:3000/annual_dividends?year=$year'); // Make sure the query string is correct

      try {
          final response = await http.get(url);

          if (response.statusCode == 200) {
              List<dynamic> data = json.decode(response.body);
              if (data.isNotEmpty) {
                  setState(() {
                      dividendsData = data[0]; // Assuming you want to display the first record
                      isLoading = false; // Stop loading if data is fetched
                  });
              } else {
                  print('No dividends data available for the selected year.');
                  setState(() {
                      isLoading = false; // Stop loading even if there's no data
                  });
              }
          } else {
              print('Failed to load dividends: ${response.statusCode}');
          }
      } catch (e) {
          print('Error fetching dividends: $e');
      }
  }

@override
Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('ปันผลรายปี')),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                            'เลือกปี:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                            value: selectedYear,
                            items: years
                                .map((year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year),
                                ))
                                .toList(),
                            onChanged: (newYear) {
                                setState(() {
                                    selectedYear = newYear;
                                    isLoading = true; // Set loading true
                                });
                                fetchDividendsData(newYear!);
                            },
                        ),
                        const SizedBox(height: 20),
                        Text(
                            'ปันผลของคุณในปี ${selectedYear ?? 'ไม่พบข้อมูล'}:',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                            '- คะแนนที่ใช้ไป: ${dividendsData['points_used'] ?? 'ไม่พบข้อมูล'}',
                            style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                            '- คะแนนที่ได้รับ: ${dividendsData['points_earned'] ?? 'ไม่พบข้อมูล'}',
                            style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                            '- ปันผลที่ได้รับ: ${dividendsData['dividend_amount'] ?? 'ไม่พบข้อมูล'} บาท',
                            style: const TextStyle(fontSize: 18),
                        ),
                    ],
                ),
            ),
    );
 }
}