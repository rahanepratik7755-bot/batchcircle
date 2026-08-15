import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/college_discovery_screen.dart';
import 'screens/home_dashboard.dart';

void main() {
  runApp(const BatchCircleApp());
}

class BatchCircleApp extends StatelessWidget {
  const BatchCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BatchCircle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final res = await http.post(
          Uri.parse('https://your-api-url.com/api/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': account.email,
            'name': account.displayName ?? 'Student',
            'google_id': account.id,
          }),
        );

        if (res.statusCode == 200 || res.statusCode == 201) {
          final data = jsonDecode(res.body);
          final user = data['user'];

          if (mounted) {
            if (user['college_id'] == null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CollegeDiscoveryScreen(userId: user['id'])),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeDashboard(userData: user)),
              );
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.school_rounded, size: 85, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text(
                'BatchCircle',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your College. Your Course. Your Circle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black54),
              ),
              const SizedBox(height: 50),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _handleSignIn,
                      icon: const Icon(Icons.g_mobiledata, size: 30),
                      label: const Text('Google ने साइन-इन करा'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
