import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key}); // ❌ no const when navigating

  @override
  Widget build(BuildContext context) {
    final Box historyBox = Hive.box('historyBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction History'),
        backgroundColor: Colors.green,
      ),
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'No history yet',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final dynamic rawItem = box.getAt(index);

              // 🔒 Safety check
              if (rawItem is! Map) return const SizedBox();

              final String imagePath = rawItem['imagePath'] ?? '';
              final String disease = rawItem['disease'] ?? 'Unknown';
              final double confidence =
                  (rawItem['confidence'] as num?)?.toDouble() ?? 0.0;
              final String date = _formatDate(rawItem['date']);

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: ListTile(
                  leading: _buildImage(imagePath),
                  title: Text(
                    disease,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Confidence: ${confidence.toStringAsFixed(2)}%",
                  ),
                  trailing: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🕒 Safe date formatter
  String _formatDate(dynamic rawDate) {
    try {
      final DateTime dt = DateTime.parse(rawDate.toString());
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year} "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }

  /// 🖼️ Safe image loader
  Widget _buildImage(String path) {
    if (path.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 40);
    }

    final file = File(path);
    if (!file.existsSync()) {
      return const Icon(Icons.broken_image, size: 40);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.file(
        file,
        width: 55,
        height: 55,
        fit: BoxFit.cover,
      ),
    );
  }
}
