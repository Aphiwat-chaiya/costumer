import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RewardsPage extends StatefulWidget {
  final Map<String, dynamic> customer;

  const RewardsPage({super.key, required this.customer});

  @override
  RewardsPageState createState() => RewardsPageState();
}

class RewardsPageState extends State<RewardsPage> {
  List<Map<String, dynamic>> rewards = [];

  @override
  void initState() {
    super.initState();
    fetchRewards();
  }

  Future<void> fetchRewards() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/rewards'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            rewards = data.map((reward) => reward as Map<String, dynamic>).toList();
          });
        }
      } else {
        // Handle the error here
        if (mounted) {
          showErrorSnackBar('ไม่สามารถดึงข้อมูลรางวัลได้');
        }
      }
    } catch (e) {
      // Catch any exceptions from the http call
      if (mounted) {
        showErrorSnackBar('เกิดข้อผิดพลาด: $e');
      }
    }
  }

  Future<void> redeemReward(int rewardId, int pointsUsed) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/redeem'),
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
            const SnackBar(content: Text('แลกของรางวัลสำเร็จ')),
          );
          fetchRewards(); // Refresh rewards after redemption
        }
      } else {
        if (mounted) {
          showErrorSnackBar('มีข้อผิดพลาดในการแลกของรางวัล');
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar('เกิดข้อผิดพลาด: $e');
      }
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Redemption'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
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
                  Text(reward['description']),
                  const SizedBox(height: 8),
                  Text(
                    'Points Required: ${reward['points_required']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.customer['points_balance'] >= reward['points_required']) {
                        redeemReward(reward['reward_id'], reward['points_required']);
                      } else {
                        showErrorSnackBar('ไม่เพียงพอสำหรับแลกของรางวัลนี้');
                      }
                    },
                    child: const Text('Redeem'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
