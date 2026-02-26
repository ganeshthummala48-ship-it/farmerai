import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen>
    with SingleTickerProviderStateMixin {
  String soilType = 'Black';
  String season = 'Kharif';
  String water = 'Medium';

  bool loading = false;

  List<dynamic> predictions = [];

  late AnimationController _controller;
  late Animation<double> _fade;

  final soils = ['Black', 'Alluvial', 'Loamy', 'Clay', 'Sandy'];
  final seasons = ['Kharif', 'Rabi', 'Zaid'];
  final rainfalls = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getRecommendation() async {
    print("Button clicked");

    setState(() {
      loading = true;
      predictions.clear();
    });

    final uri = Uri.parse('http://10.0.2.2:8000/recommend-crop');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "soil": soilType,
          "season": season,
          "rainfall": water
        }),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['top_crops'] != null) {
          setState(() {
            predictions = data['top_crops'];
          });

          _controller.forward(from: 0);
        }
      }
    } catch (e) {
      debugPrint("API Error: $e");
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Soil Type'),
            DropdownButtonFormField<String>(
              value: soilType,
              items: soils
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => soilType = value!),
            ),

            const SizedBox(height: 16),

            const Text('Season'),
            DropdownButtonFormField<String>(
              value: season,
              items: seasons
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => season = value!),
            ),

            const SizedBox(height: 16),

            const Text('Rainfall Level'),
            DropdownButtonFormField<String>(
              value: water,
              items: rainfalls
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => water = value!),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : getRecommendation,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Get Recommendation'),
              ),
            ),

            const SizedBox(height: 30),

            if (predictions.isNotEmpty)
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: predictions.map((item) {
                    return Card(
                      elevation: 6,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "🥇 Rank ${item['rank']} - ${item['crop']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Image.asset(
                              cropImage(item['crop']),
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: item['confidence'] / 100,
                              minHeight: 8,
                            ),
                            const SizedBox(height: 6),
                            Text("Confidence: ${item['confidence']}%"),
                            const SizedBox(height: 8),
                            Text(
                              item['description'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
