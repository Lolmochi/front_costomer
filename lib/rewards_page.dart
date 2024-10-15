import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
            rewards =
                data.map((reward) => reward as Map<String, dynamic>).toList();
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
            'http://192.168.1.20:3000/redeemed/${widget.customer['customer_id']}'),
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
            'http://192.168.1.20:3000/customer/${widget.customer['customer_id']}'),
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

  Future<void> redeemReward(int rewardId, int pointsUsed) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.20:3000/api/redeem'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'customer_id': widget.customer['customer_id'],
          'reward_id': rewardId,
          'points_used': pointsUsed,
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

  void _showRewardDetails(Map<String, dynamic> reward) {
    final int totalPoints = widget.customer['points_balance'];
    final int pointsRequired = reward['points_required'];

    if (!mounted) return; // Check mounted before showing the dialog

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
              const SizedBox(height: 16),
              reward['image'] != null
                  ? Image.network(
                      'http://192.168.1.20:3000/uploads/${reward['image']}',
                      height: 150,
                    )
                  : const Text('No image available'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Call the redeemReward function
                redeemReward(reward['reward_id'], pointsRequired);
                if (mounted) {
                  Navigator.of(context).pop(); // Close the dialog
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
    if (!mounted) return; // Check mounted before showing the dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Redeemed Rewards',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.green, // Green header
            ),
          ),
          content: redeemedRewards.isEmpty
              ? const Text(
                  'No rewards redeemed yet',
                  style: TextStyle(fontSize: 18), // Larger font
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    itemCount: redeemedRewards.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey, // Divider color
                      thickness: 1.0, // Divider thickness
                    ),
                    itemBuilder: (context, index) {
                      final redeemedReward = redeemedRewards[index];
                      final DateTime redemptionDate =
                          DateTime.parse(redeemedReward['redemption_date'])
                              .add(const Duration(hours: 7)); // Adjust for timezone
                      final String formattedDate =
                          DateFormat('dd/MM/yyyy HH:mm').format(redemptionDate);

                      // Convert status to Thai
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
                        elevation: 4, // Add shadow to the card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                        color: Colors.white, // Card background color
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        child: ListTile(
                          leading: const Icon(
                            Icons.card_giftcard,
                            color: Colors.orange, // Change icon color
                            size: 40, // Icon size
                          ),
                          title: Text(
                            redeemedReward['reward_name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18, // Larger title font
                              color: Colors.black87, // Title text color
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
                                    color: Colors.blueGrey, // ID text color
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic, // Italic style
                                  ),
                                ),
                                const SizedBox(height: 4), // Line spacing
                                Text(redeemedReward['description']),
                                const SizedBox(height: 4),
                                Text(
                                  'Time: $formattedDate',
                                  style: const TextStyle(
                                    color: Colors.green, // Time text color
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Status: $statusThai',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
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
                                    'http://192.168.1.20:3000/uploads/${reward['image']}',
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
                            ElevatedButton(
                              onPressed: () {
                                _showRewardDetails(
                                    reward); // Show reward details
                              },
                              child: const Text('Details / Redeem'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                      onPressed: _showRedeemedRewards, // Show redeemed rewards
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
