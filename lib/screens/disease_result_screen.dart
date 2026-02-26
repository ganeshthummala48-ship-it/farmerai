import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DiseaseResultScreen extends StatelessWidget {
  final String disease;
  final double confidence;
  final String recommendation;
  final Map<String, dynamic>? treatment;
  final String? aiExplanation;

  const DiseaseResultScreen({
    super.key,
    required this.disease,
    required this.confidence,
    required this.recommendation,
    this.treatment,
    this.aiExplanation,
  });

  Color _confidenceColor(double value) {
    if (value >= 80) return Colors.green;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildLottie(String disease) {
    if (disease.toLowerCase().contains('healthy')) {
      return Lottie.asset('assets/lottie/healthy.json', height: 180);
    } else if (disease.toLowerCase().contains('unknown')) {
      return Lottie.asset('assets/lottie/unknown.json', height: 180);
    } else {
      return Lottie.asset('assets/lottie/disease.json', height: 180);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showTreatment =
        treatment != null && !disease.toLowerCase().contains('healthy');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Disease Analysis Result"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "🌿 Crop Disease Prediction",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(child: _buildLottie(disease)),
                const SizedBox(height: 24),

                const Text(
                  "Detected Disease",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(disease),

                const SizedBox(height: 20),

                const Text(
                  "Prediction Confidence",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: confidence / 100,
                        color: _confidenceColor(confidence),
                        backgroundColor: Colors.grey.shade300,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${confidence.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _confidenceColor(confidence),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  "Recommended Action",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(recommendation),

                // ================== 💊 PESTICIDE SECTION ==================
                if (showTreatment) ...[
                  const SizedBox(height: 24),

                  const Text(
                    "Pesticide Recommendation",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Card(
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("💊 Chemical: ${treatment!['pesticide']}"),
                          const SizedBox(height: 4),
                          Text("📏 Dosage: ${treatment!['dosage']}"),
                          const SizedBox(height: 4),
                          Text("🌱 Organic Option: ${treatment!['organic']}"),
                          const SizedBox(height: 8),
                          Text(
                            "⚠️ Precaution: ${treatment!['precaution']}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (aiExplanation != null && aiExplanation!.isNotEmpty) ...[
  const SizedBox(height: 20),
  const Text(
    "AI Expert Advice",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
  ),
  const SizedBox(height: 10),
  Text(
    aiExplanation!,
    style: const TextStyle(fontSize: 14),
  ),
],

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "ℹ️ Note:\nThis prediction is generated using a deep learning model. "
                    "Pesticide usage should follow government-approved guidelines. "
                    "For severe cases, consult an agricultural expert.",
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Analyze Another Image"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
