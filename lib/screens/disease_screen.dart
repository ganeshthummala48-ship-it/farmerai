import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import 'package:farmer_ai/screens/disease_result_screen.dart';
import 'package:farmer_ai/screens/history_screen.dart';

class DiseaseScreen extends StatefulWidget {
  const DiseaseScreen({super.key});

  @override
  State<DiseaseScreen> createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  File? imageFile;
  bool loading = false;

  final ImagePicker _picker = ImagePicker();

  // 📸 Pick image
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  // 🔍 Analyze image
  Future<void> analyzeImage() async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() => loading = true);
    String disease = 'Unknown Disease';
    String? aiExplanation;
    String recommendation =
        'The image could not be analyzed. Please try again.';
    double confidence = 0.0;
    Map<String, dynamic>? treatment;

    final uri =
        Uri.parse('http://10.0.2.2:8000/detect-disease'); // backend IP

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile!.path),
      );

      final streamedResponse = await request.send();
      final body = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(body);
        disease = data['disease'] ?? disease;
        recommendation = data['recommendation'] ?? recommendation;
        confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
        treatment = data['treatment'];
        aiExplanation: data['ai_explanation'];
        // ✅ SAVE TO HISTORY ONLY AFTER SUCCESS
        final box = Hive.box('historyBox');
        box.add({
          'imagePath': imageFile!.path,
          'disease': disease,
          'confidence': confidence,
          'date': DateTime.now().toString(),
          'treatment': treatment,
        });

        debugPrint("API RESPONSE: $data");
      } else {
        debugPrint("Server error: ${streamedResponse.statusCode}");
      }
    } catch (e) {
      debugPrint("API ERROR: $e");
    }

    setState(() => loading = false);

    // ➡️ Navigate to result screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiseaseResultScreen(
          disease: disease,
          confidence: confidence,
          recommendation: recommendation,
          treatment: treatment,
          aiExplanation: aiExplanation,
        ),
      ),
    );
  }

  // 🧱 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Detection'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Prediction History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(), // ❌ no const
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (imageFile != null)
              Image.file(
                imageFile!,
                height: 220,
              )
            else
              Container(
                height: 220,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Text('No image selected'),
                ),
              ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text('Gallery'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : analyzeImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Analyze Disease',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
