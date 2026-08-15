import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_dashboard.dart';

class CollegeDiscoveryScreen extends StatefulWidget {
  final int userId;
  const CollegeDiscoveryScreen({super.key, required this.userId});

  @override
  State<CollegeDiscoveryScreen> createState() => _CollegeDiscoveryScreenState();
}

class _CollegeDiscoveryScreenState extends State<CollegeDiscoveryScreen> {
  final _collegeController = TextEditingController();
  final _courseController = TextEditingController();
  String _selectedYear = '1st';
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    if (_collegeController.text.isEmpty || _courseController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('https://your-api-url.com/api/user/update-profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'college_name': _collegeController.text.trim(),
          'course_name': _courseController.text.trim(),
          'academic_year': _selectedYear,
        }),
      );

      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeDashboard(userData: data['user'])),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('कॉलेज व कोर्स निवडा'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _collegeController,
              decoration: const InputDecoration(labelText: 'कॉलेजचे नाव', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'कोर्स (उदा. BCA, BCS, B.Tech)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedYear,
              items: ['1st', '2nd', '3rd', '4th', 'Faculty'].map((y) => DropdownMenuItem(value: y, child: Text('$y Year'))).toList(),
              onChanged: (v) => setState(() => _selectedYear = v!),
              decoration: const InputDecoration(labelText: 'वर्ष / फॅकल्टी', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                    child: const Text('सुरू करा (Join Circle)'),
                  )
          ],
        ),
      ),
    );
  }
}
