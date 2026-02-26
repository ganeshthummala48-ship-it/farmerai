import 'package:flutter/material.dart';
import '../widgets/home_card.dart';
import 'crop_screen.dart';
import 'market_screen.dart';
import 'disease_screen.dart';
import 'assistant_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmerAI'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            HomeCard(
              title: 'Crop\nRecommendation',
              icon: Icons.agriculture,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CropScreen(),
                  ),
                );
              },
            ),

            HomeCard(
              title: 'Market\nPrices',
              icon: Icons.currency_rupee,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MarketScreen(),
                  ),
                );
              },
            ),

            HomeCard(
              title: 'Disease\nDetection',
              icon: Icons.bug_report,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiseaseScreen(),
                  ),
                );
              },
            ),

            HomeCard(
              title: 'Prediction\nHistory',
              icon: Icons.history,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryScreen(), // ✅ NO const
                  ),
                );
              },
            ),

            HomeCard(
              title: 'Ask\nFarmerAI',
              icon: Icons.smart_toy,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIAssistantScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
