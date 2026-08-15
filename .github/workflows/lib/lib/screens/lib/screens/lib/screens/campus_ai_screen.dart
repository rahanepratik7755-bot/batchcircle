import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CampusAIScreen extends StatefulWidget {
  final String courseName;
  const CampusAIScreen({super.key, required this.courseName});

  @override
  State<CampusAIScreen> createState() => _CampusAIScreenState();
}

class _CampusAIScreenState extends State<CampusAIScreen> {
  final _ctrl = TextEditingController();
  final List<Map<String, String>> _chat = [
    {'sender': 'ai', 'text': 'मी Campus AI 🎓. तुमच्या अभ्यासाच्या किंवा कोडिंगच्या शंका विचारा.'}
  ];
  bool _loading = false;

  Future<void> _ask() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chat.add({'sender': 'user', 'text': text});
      _loading = true;
    });
    _ctrl.clear();

    try {
      final res = await http.post(
        Uri.parse('https://your-api-url.com/api/campus-ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': text, 'courseName': widget.courseName}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _chat.add({'sender': 'ai', 'text': data['reply']}));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _chat.length,
            itemBuilder: (ctx, i) {
              final isUser = _chat[i]['sender'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.indigo : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_chat[i]['text']!, style: TextStyle(color: isUser ? Colors.white : Colors.black87)),
                ),
              );
            },
          ),
        ),
        if (_loading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(hintText: 'प्रश्न विचारा...', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: _ask, icon: const Icon(Icons.send, color: Colors.indigo)),
            ],
          ),
        ),
      ],
    );
  }
}
