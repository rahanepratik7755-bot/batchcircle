import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PremiumScreen extends StatelessWidget {
  final int userId;
  const PremiumScreen({super.key, required this.userId});

  Future<void> _fakeBuy(BuildContext context, String plan) async {
    final res = await http.post(
      Uri.parse('https://your-api-url.com/api/subscriptions/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'productId': plan,
        'transactionId': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        'purchaseToken': 'TOKEN_DEMO',
      }),
    );
    if (res.statusCode == 200 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('प्रीमियम ॲक्टिव्हेट झाले!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BatchCircle Premium'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.workspace_premium, size: 70, color: Colors.amber),
            const SizedBox(height: 12),
            const Text('अमर्यादित Campus AI आणि सर्व ग्रुप्स ॲक्सेस करा', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Card(
              child: ListTile(
                title: const Text('मासिक प्लॅन'),
                subtitle: const Text('₹२९ / महिना'),
                trailing: ElevatedButton(onPressed: () => _fakeBuy(context, 'batchcircle_monthly_sub'), child: const Text('निवडा')),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('वार्षिक प्लॅन'),
                subtitle: const Text('₹२९९ / वर्ष'),
                trailing: ElevatedButton(onPressed: () => _fakeBuy(context, 'batchcircle_yearly_sub'), child: const Text('निवडा')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
