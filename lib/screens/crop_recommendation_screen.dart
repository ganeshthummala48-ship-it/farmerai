import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen>
    with SingleTickerProviderStateMixin {
  String soil = 'Loamy';
  String season = 'Kharif';
  String rainfall = 'High';

  bool loading = false;

  List<Map<String, dynamic>> predictions = [];

  final soils = ['Loamy', 'Clay', 'Sandy', 'Alluvial', 'Black'];
  final seasons = ['Kharif', 'Rabi', 'Zaid'];
  final rainfalls = ['Low', 'Medium', 'High'];

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> recommendCrop() async {
    setState(() {
      loading = true;
      predictions.clear();
    });

    final uri = Uri.parse('http://10.95.58.73:8000/recommend-crop');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'soil': soil,
          'season': season,
          'rainfall': rainfall,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔁 Supports BOTH single and top-3 responses
        if (data['top_crops'] != null) {
          predictions = List<Map<String, dynamic>>.from(data['top_crops']);
        } else {
          predictions = [
            {
              'crop': data['recommended_crop'],
              'confidence': data['confidence'],
            }
          ];
        }

        _controller.forward(from: 0);
      }
    } catch (e) {
      debugPrint("API error: $e");
    }

    setState(() => loading = false);
  }

  String cropImage(String crop) {
    return 'assets/crops/${crop.toLowerCase()}.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Recommendation'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dropdown('Soil Type', soil, soils, (v) => setState(() => soil = v)),
            _dropdown(
                'Season', season, seasons, (v) => setState(() => season = v)),
            _dropdown('Rainfall', rainfall, rainfalls,
                (v) => setState(() => rainfall = v)),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : recommendCrop,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Recommend Crop'),
              ),
            ),

            const SizedBox(height: 30),

            if (predictions.isNotEmpty)
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🌾 Top Recommended Crops",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...predictions.map(_cropCard),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cropCard(Map<String, dynamic> item) {
    final crop = item['crop'];
    final confidence = item['confidence'];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                cropImage(crop),
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Confidence: ${confidence.toStringAsFixed(2)}%",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}
