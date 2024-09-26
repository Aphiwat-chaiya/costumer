import 'package:flutter/material.dart';
import 'transactions_page.dart';
import 'card_page.dart';
import 'rewards_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> customer;

  const HomePage({super.key, required this.customer});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
          return RewardsPage(customer: widget.customer); // Update this line
        default:
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 56, 142, 60), // สีเขียวเข้ม
                  Color.fromARGB(255, 200, 230, 201), // สีเขียวอ่อน
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // เพิ่มไอคอนเพื่อให้ข้อมูลดูน่าสนใจขึ้น
                    Row(
                      children: [
                        const Icon(Icons.person, size: 50, color: Colors.white),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.customer['first_name']} ${widget.customer['last_name']}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Customer ID: ${widget.customer['customer_id']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // แสดงข้อมูลเบอร์โทรศัพท์
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 30, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          'Phone: ${widget.customer['phone_number']}',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // แสดงคะแนนสะสม
                    Row(
                      children: [
                        const Icon(Icons.star, size: 30, color: Colors.amber),
                        const SizedBox(width: 10),
                        Text(
                          'Points Balance: ${widget.customer['points_balance']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
      }
    }

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text('Welcome ${widget.customer['first_name']}'),
              backgroundColor: Colors.green,
            )
          : null, // No AppBar for non-Home pages
      body: getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Card',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.redeem),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 42, 216, 181),
        unselectedItemColor: const Color.fromARGB(255, 224, 207, 131),
        backgroundColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
