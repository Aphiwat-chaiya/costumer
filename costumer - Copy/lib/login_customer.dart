import 'package:costumer/home_page_customer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerLoginPage extends StatefulWidget {
  const CustomerLoginPage({super.key});

  @override
  CustomerLoginPageState createState() => CustomerLoginPageState();
}

class CustomerLoginPageState extends State<CustomerLoginPage> {
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isLoading = false;

  // ฟังก์ชันสำหรับการ Login
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:3000/login/customer'); // URL API ที่จะเรียกใช้งาน
    final body = jsonEncode({
      'customer_id': _customerIdController.text,
      'phone_number': _phoneNumberController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ตรวจสอบว่าหน้ายังถูก mount อยู่หรือไม่
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login สำเร็จ')),
        );
        
        // หลังจาก login สำเร็จ อาจพาไปหน้าหลัก
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(customer: data['customer']),
        ));
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ข้อมูลล็อกอินไม่ถูกต้อง')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('มีข้อผิดพลาดในการเชื่อมต่อ')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _customerIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Customer ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              // ไม่จำเป็นต้องใช้ obscureText สำหรับเบอร์โทรศัพท์
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}

