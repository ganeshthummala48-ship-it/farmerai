import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  bool loading = true;
  List<Map<String, dynamic>> marketData = [];
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final prices = await ApiService.fetchMarketPrices(
        state: 'Telangana',
        district: 'Hyderabad',
        commodity: 'Rice',
      );

      final weather = await ApiService.fetchWeather('Hyderabad');

      if (!mounted) return;

      setState(() {
        marketData = List<Map<String, dynamic>>.from(prices);
        weatherData = weather;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tempKelvin = weatherData?['main']?['temp'];
    final tempCelsius = tempKelvin != null
        ? (tempKelvin - 273.15).toStringAsFixed(1)
        : '--';

    final weatherDescription =
        weatherData?['weather']?[0]?['description']?.toString().toUpperCase() ??
            'WEATHER DATA';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices & Weather'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                loading = true;
              });
              loadData();
            },
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🌦 WEATHER CARD
                  if (weatherData != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.cloud,
                          color: Colors.blue,
                        ),
                        title: Text(weatherDescription),
                        subtitle: Text('Temperature: $tempCelsius °C'),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 📊 MARKET PRICES HEADER
                  const Text(
                    'Today’s Market Prices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 📉 EMPTY STATE
                  if (marketData.isEmpty)
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Market price data will be displayed once government API authorization is completed.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                  else

                    // 📈 MARKET LIST
                    ...marketData.map(
                      (item) => Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.agriculture,
                            color: Colors.green,
                          ),
                          title: Text(item['commodity'] ?? ''),
                          subtitle: Text(
                            'Market: ${item['market'] ?? ''}\n'
                            'Date: ${item['arrival_date'] ?? ''}',
                          ),
                          trailing: Text(
                            '₹ ${item['modal_price'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
