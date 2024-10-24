import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'qr_code_page.dart';

class RewardsPage extends StatefulWidget {
  final Map<String, dynamic> customer;

  const RewardsPage({super.key, required this.customer});

  @override
  RewardsPageState createState() => RewardsPageState();
}

class RewardsPageState extends State<RewardsPage> {
  List<Map<String, dynamic>> rewards = [];
  List<Map<String, dynamic>> redeemedRewards = []; // Redeemed rewards list

  @override
  void initState() {
    super.initState();
    fetchRewards();
    fetchRedeemedRewards(); // Fetch redeemed rewards
  }

  Future<void> fetchRewards() async {
      try {
          final response =
              await http.get(Uri.parse('http://192.168.1.20:3000/rewards'));

          if (response.statusCode == 200) {
              final List<dynamic> data = json.decode(response.body);
              if (mounted) {
                  setState(() {
                      rewards = data.map((reward) {
                          // เพิ่ม redeemQuantity เริ่มต้นเป็น 1
                          reward['redeemQuantity'] = 1; 
                          return reward as Map<String, dynamic>;
                      }).toList();
                  });
              }
          } else {
              if (mounted) {
                  showErrorSnackBar('Unable to fetch rewards');
              }
          }
      } catch (e) {
          if (mounted) {
              showErrorSnackBar('Error occurred: $e');
          }
      }
  }


  Future<void> fetchRedeemedRewards() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.34:3000/redeemed/${widget.customer['customer_id']}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          // Sort redeemed rewards from latest to oldest
          data.sort((a, b) => DateTime.parse(b['redemption_date'])
              .compareTo(DateTime.parse(a['redemption_date'])));

          setState(() {
            redeemedRewards =
                data.map((reward) => reward as Map<String, dynamic>).toList();
          });
        }
      } else {
        if (mounted) {
          showErrorSnackBar('Unable to fetch redeemed rewards');
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar('Error occurred: $e');
      }
    }
  }

  Future<void> fetchCustomerData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.34:3000/customer/${widget.customer['customer_id']}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            widget.customer['points_balance'] =
                data['customer']['points_balance']; // Update total points
          });
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar('Error occurred: $e');
      }
    }
  }

  Future<void> redeemReward(int rewardId, int pointsUsed, int redeemQuantity) async {
      // รหัสนี้จะต้องใช้ redeemQuantity ด้วย
      try {
          final response = await http.post(
              Uri.parse('http://192.168.1.34:3000/api/redeem'),
              headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode({
                  'customer_id': widget.customer['customer_id'],
                  'reward_id': rewardId,
                  'points_used': pointsUsed,
                  'quantity': redeemQuantity, // ส่งจำนวนที่ต้องการแลกไปด้วย
              }),
          );

          if (response.statusCode == 200) {
              if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reward redeemed successfully')),
                  );

                  // Fetch fresh data to refresh the UI
                  await fetchCustomerData(); // Refresh customer data
                  await fetchRewards(); // Refresh rewards after redemption
                  await fetchRedeemedRewards(); // Refresh redeemed rewards after redemption
              }
          } else {
              if (mounted) {
                  showErrorSnackBar('Error redeeming reward');
              }
          }
      } catch (e) {
          if (mounted) {
              showErrorSnackBar('Error occurred: $e');
          }
      }
  }


  void showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showRewardDetails(Map<String, dynamic> reward, int redeemQuantity) {
    final int totalPoints = widget.customer['points_balance'];
    final int pointsRequired = reward['points_required'] * redeemQuantity; // คำนวณแต้มที่ใช้ตามจำนวนรางวัล

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reward Details: ${reward['reward_name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reward['description']),
              const SizedBox(height: 16),
              Text('Your total points: $totalPoints'),
              Text('Points required: $pointsRequired'),
              Text('Redeeming: $redeemQuantity items'), // แสดงจำนวนรางวัลที่ต้องการแลก
              const SizedBox(height: 16),
              reward['image'] != null
                  ? Image.network(
                      'http://192.168.1.34:3000/uploads/${reward['image']}',
                      height: 150,
                    )
                  : const Text('No image available'),
            ],
          ),
          actions: <Widget>[
              TextButton(
                  onPressed: () {
                      Navigator.of(context).pop(); // ปิดหน้าต่าง
                  },
                  child: const Text('Cancel'),
              ),
              ElevatedButton(
                  onPressed: () {
                      // เรียกใช้ฟังก์ชันแลกของรางวัลพร้อมส่งจำนวนที่ต้องการแลกไปด้วย
                      redeemReward(reward['reward_id'], pointsRequired, redeemQuantity); // ส่ง redeemQuantity ไปด้วย
                      if (mounted) {
                          Navigator.of(context).pop(); // ปิดหน้าต่าง
                      }
                  },
                  child: const Text('Redeem'),
              ),
          ],
        );
      },
    );
  }

void _showRedeemedRewards() async {
  await fetchRedeemedRewards();
  if (!mounted) return;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Redeemed Rewards',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.green,
          ),
        ),
        content: redeemedRewards.isEmpty
            ? const Text(
                'No rewards redeemed yet',
                style: TextStyle(fontSize: 18),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  itemCount: redeemedRewards.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final redeemedReward = redeemedRewards[index];
                    final DateTime redemptionDate =
                        DateTime.parse(redeemedReward['redemption_date'])
                            .add(const Duration(hours: 7)); // Adjust for timezone
                    final String formattedDate =
                        DateFormat('dd/MM/yyyy HH:mm').format(redemptionDate);

                    String statusThai;
                    Color statusColor;
                    if (redeemedReward['status'] == 'completed') {
                      statusThai = 'Completed';
                      statusColor = Colors.green;
                    } else if (redeemedReward['status'] == 'pending') {
                      statusThai = 'Pending';
                      statusColor = Colors.orange;
                    } else {
                      statusThai = redeemedReward['status'];
                      statusColor = Colors.red;
                    }

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      child: ListTile(
                        leading: const Icon(
                          Icons.card_giftcard,
                          color: Colors.orange,
                          size: 40,
                        ),
                        title: Text(
                          redeemedReward['reward_name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: ${redeemedReward['redemption_id']}',
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(redeemedReward['description']),
                              const SizedBox(height: 4),
                              Text(
                                'Time: $formattedDate',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Quantity redeemed: ${redeemedReward['quantity'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // ปุ่มดู QR Code
                              TextButton(
                                onPressed: () {
                                  // ไปยังหน้า QR Code โดยใช้ redemption_id
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => QrCodePage(
                                        qrData: redeemedReward['redemption_id'].toString(), // ส่ง redemption_id ไปยัง QR code
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Show QR Code'),
                              ),
                            ],
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: statusColor,
                              size: 25,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              statusThai,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final int totalPoints = widget.customer['points_balance'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Redemption'),
        backgroundColor: Colors.green,
      ),
      body: rewards.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView.builder(
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    final int availableQuantity = reward['quantity'];
                    
                    // Use reward's stored redeemQuantity to track quantity
                    int redeemQuantity = reward['redeemQuantity'];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reward['reward_name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            reward['image'] != null
                                ? Image.network(
                                    'http://192.168.1.34:3000/uploads/${reward['image']}',
                                    height: 150,
                                  )
                                : const Text('No image available'),
                            const SizedBox(height: 8),
                            Text(reward['description']),
                            const SizedBox(height: 8),
                            Text(
                              'Points required: ${reward['points_required']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Available quantity: $availableQuantity',
                              style: const TextStyle(color: Colors.blue),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (redeemQuantity > 1) {
                                      setState(() {
                                        // Update the redeemQuantity in the rewards list
                                        rewards[index]['redeemQuantity']--;
                                      });
                                    }
                                  },
                                ),
                                Text(
                                  reward['redeemQuantity'].toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    if (redeemQuantity < availableQuantity) {
                                      setState(() {
                                        // Update the redeemQuantity in the rewards list
                                        rewards[index]['redeemQuantity']++;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showRewardDetails(reward, reward['redeemQuantity']);
                              },
                              child: const Text('Details / Redeem'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 27, 168, 72),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.star, color: Colors.white),
                      onPressed: _showRedeemedRewards,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Card(
                    color: Colors.yellow[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(
                        'Your points: $totalPoints',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}