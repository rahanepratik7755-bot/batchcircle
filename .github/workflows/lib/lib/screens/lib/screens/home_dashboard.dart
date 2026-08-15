import 'package:flutter/material.dart';
import 'campus_ai_screen.dart';
import 'id_verification_screen.dart';
import 'premium_screen.dart';

class HomeDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeDashboard({super.key, required this.userData});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BatchCircle • ${widget.userData['course_name'] ?? ''}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IDVerificationScreen(userId: widget.userData['id']))),
          ),
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: Colors.amber),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumScreen(userId: widget.userData['id']))),
          ),
        ],
      ),
      body: _tabIndex == 0 ? _buildCirclesTab() : CampusAIScreen(courseName: widget.userData['course_name'] ?? 'General'),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: Colors.indigo,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: 'Year Circles'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Campus AI'),
        ],
      ),
    );
  }

  Widget _buildCirclesTab() {
    final groups = ['1st Year Circle', '2nd Year Circle', '3rd Year Circle', 'Official Faculty Board'];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (ctx, i) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.groups, color: Colors.white)),
          title: Text(groups[i], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Verified Batch Chat'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {},
        ),
      ),
    );
  }
}
