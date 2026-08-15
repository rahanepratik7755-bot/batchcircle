import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class IDVerificationScreen extends StatefulWidget {
  final int userId;
  const IDVerificationScreen({super.key, required this.userId});

  @override
  State<IDVerificationScreen> createState() => _IDVerificationScreenState();
}

class _IDVerificationScreenState extends State<IDVerificationScreen> {
  File? _img;
  bool _uploading = false;

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) setState(() => _img = File(picked.path));
  }

  Future<void> _upload() async {
    if (_img == null) return;
    setState(() => _uploading = true);

    var req = http.MultipartRequest('POST', Uri.parse('https://your-api-url.com/api/user/verify-id'));
    req.fields['userId'] = widget.userId.toString();
    req.files.add(await http.MultipartFile.fromPath('id_card_image', _img!.path));
    var res = await req.send();

    if (res.statusCode == 200 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('आयडी तपासणीसाठी पाठवला आहे!')));
      Navigator.pop(context);
    }
    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('आयडी व्हेरिफिकेशन'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
              child: _img != null ? Image.file(_img!, fit: BoxFit.cover) : const Center(child: Text('आयडी कार्ड सिलेक्ट करा')),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => _pick(ImageSource.camera), child: const Text('कॅमेरा'))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(onPressed: () => _pick(ImageSource.gallery), child: const Text('गॅलरी'))),
              ],
            ),
            const SizedBox(height: 20),
            _uploading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _upload, child: const Text('सबमिट करा')),
          ],
        ),
      ),
    );
  }
}
