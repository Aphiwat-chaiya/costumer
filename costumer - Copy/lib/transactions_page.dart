import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionsPage extends StatefulWidget {
  final int customerId;

  const TransactionsPage({super.key, required this.customerId});

  @override
  TransactionsPageState createState() => TransactionsPageState();
}

class TransactionsPageState extends State<TransactionsPage> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _totalPoints = 0;
  double _totalDividend = 0.0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th_TH', null).then((_) {
      _fetchTransactions();
    });
  }

  Future<void> _fetchTransactions({int page = 1}) async {
    final url = 'http://10.0.2.2:3000/transactions/${widget.customerId}?page=$page';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          if (page == 1) {
            _transactions = data['transactions'];
          } else {
            _transactions.addAll(data['transactions']);
          }
          _isLoading = false;

          _totalPoints = _transactions.fold<int>(
            0,
            (sum, transaction) => sum + (transaction['points_earned'] as int? ?? 0),
          );
          _totalDividend = _transactions.fold<double>(
            0.0,
            (sum, transaction) => sum + (transaction['amount'] * 0.01),
          );

          _transactions.sort((a, b) =>
              DateTime.parse(b['transaction_date']).compareTo(DateTime.parse(a['transaction_date'])));
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'ไม่สามารถโหลดข้อมูลธุรกรรมได้: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ไม่สามารถโหลดข้อมูลธุรกรรมได้: $e';
      });
    }
  }

  double _getFontSize(int points) {
    if (points >= 100000) {
      return 12.0;
    } else if (points >= 10000) {
      return 14.0;
    } else if (points >= 1000) {
      return 16.0;
    } else {
      return 18.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('ประวัติการทำรายการ'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchTransactions,
              ),
            ],
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.blueGrey.shade100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'คะแนนสะสมทั้งหมด',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '฿$_totalPoints',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.blueGrey.shade100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ปันผลทั้งหมด',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '฿${_totalDividend.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8.0),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_transactions.isEmpty) {
                  return const Center(child: Text('ท่านยังไม่ทำธุรกรรม'));
                }

                final transaction = _transactions[index];
                final transactionDate = DateTime.parse(transaction['transaction_date']);
                final formattedDate = DateFormat('d MMM yyyy', 'th_TH').format(transactionDate);
                final formattedTime = DateFormat('HH:mm', 'th_TH').format(transactionDate);
                final pointsEarned = transaction['points_earned'] ?? 0;
                final amount = transaction['amount'];
                final dividend = (amount * 0.01).toStringAsFixed(2);

                return Card(
                  color: Colors.white70,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$pointsEarned P.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: _getFontSize(pointsEarned),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    title: Text(
                      'น้ำมัน: ${transaction['fuel_type_name']} | จำนวนเงิน: ฿${transaction['amount']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('รหัสธุรกรรม: ${transaction['transaction_id']}', style: const TextStyle(color: Colors.blue)),
                        Text('วันที่: $formattedDate', style: const TextStyle(color: Colors.black87)),
                        Text('เวลาที่ทำรายการ: $formattedTime น.', style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                    trailing: Text(
                      'ปันผล: ฿$dividend',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                );
              },
              childCount: _transactions.length,
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                          ElevatedButton(
                            onPressed: _fetchTransactions,
                            child: const Text('ลองใหม่'),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
