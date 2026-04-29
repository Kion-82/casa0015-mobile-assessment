import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/weather.dart';
import '../service/spot_service.dart';
import 'log_trip.dart';

class SpotsPage extends StatefulWidget {
  final Future<void> Function(Map<String, String>) onSaveTrip;

  const SpotsPage({super.key, required this.onSaveTrip});

  @override
  State<SpotsPage> createState() => _SpotsPageState();
}

class _SpotsPageState extends State<SpotsPage> {
  final TextEditingController _searchController = TextEditingController();

  final WeatherService _weatherService = WeatherService();
  final SpotService _spotService = SpotService();

  String? selectedSpot;
  String weather = '--';
  String temperature = '--';
  String wind = '--';
  String tide = '--';
  String sunrise = '--';
  String sunset = '--';
  String summary = '--';

  bool isLoading = false;
  bool isSavingSpot = false;
  String? errorMessage;

  Future<void> searchSpot() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _weatherService.fetchWeatherForPlace(query);

      setState(() {
        selectedSpot = data.locationName;
        weather = data.weather;
        temperature = data.temperature;
        wind = data.wind;
        tide = data.tide;
        sunrise = data.sunrise;
        sunset = data.sunset;
        summary = buildFishingSummary(
          weatherText: data.weather,
          windText: data.wind,
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Something went wrong')),
      );
    }
  }

  String buildFishingSummary({
    required String weatherText,
    required String windText,
  }) {
    final lowerWeather = weatherText.toLowerCase();
    final windValue = extractWindSpeed(windText);

    if (lowerWeather.contains('thunderstorm') ||
        lowerWeather.contains('snow') ||
        windValue >= 25) {
      return 'Poor conditions. Strong wind or unsettled weather may make fishing uncomfortable.';
    }

    if (lowerWeather.contains('rain') || windValue >= 15) {
      return 'Fair conditions. Fishable, but wind or rain may affect comfort and casting.';
    }

    return 'Good conditions for a short fishing session.';
  }

  double extractWindSpeed(String windText) {
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(windText);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  Future<void> saveCurrentSpot() async {
    if (selectedSpot == null) {
      return;
    }

    setState(() {
      isSavingSpot = true;
    });

    try {
      final added = await _spotService.addSpot(selectedSpot!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added ? 'Location saved' : 'Location already saved'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save location: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingSpot = false;
        });
      }
    }
  }

  void loadSavedSpot(String spot) {
    _searchController.text = spot;
    searchSpot();
  }

  Future<void> deleteSavedSpot(String documentId) async {
    try {
      await _spotService.deleteSpot(documentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved spot removed')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove saved spot: $e')),
      );
    }
  }

  String getCurrentDateTimeString() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String getCurrentConditionString() {
    return '$weather, $temperature, Wind $wind, Tide $tide';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget buildSavedSpotsSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _spotService.getSavedSpotsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading saved spots: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Icon(Icons.bookmark_border, size: 40, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No saved spots yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Search for a fishing location and save it here later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final spotName = (data['name'] ?? '').toString();

            return Card(
              child: ListTile(
                leading: const Icon(Icons.place),
                title: Text(spotName),
                subtitle: const Text('Tap to load current conditions'),
                onTap: () {
                  loadSavedSpot(spotName);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    deleteSavedSpot(doc.id);
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search fishing spot',
                  hintText: 'Enter a place name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => searchSpot(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isLoading ? null : searchSpot,
              child: const Text('Search'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spot Conditions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (isLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 12),
                ],
                if (errorMessage != null) ...[
                  Text(
                    'Error: $errorMessage',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                ],
                Text('Location: ${selectedSpot ?? 'No spot selected'}'),
                const SizedBox(height: 8),
                Text('Weather: $weather'),
                Text('Temperature: $temperature'),
                Text('Wind: $wind'),
                Text('Tide: $tide'),
                Text('Sunrise: $sunrise'),
                Text('Sunset: $sunset'),
                Text('Summary: $summary'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: selectedSpot == null || isSavingSpot
                            ? null
                            : saveCurrentSpot,
                        child: Text(isSavingSpot ? 'Saving...' : 'Save Spot'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedSpot == null
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                appBar: AppBar(
                                  title: const Text('Log a Trip'),
                                ),
                                body: LogTripPage(
                                  initialSpotName: selectedSpot,
                                  initialDateTime:
                                  getCurrentDateTimeString(),
                                  initialCondition:
                                  getCurrentConditionString(),
                                  onSaveTrip: widget.onSaveTrip,
                                  closeOnSave: true,
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('Log Trip Here'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Saved Spots',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        buildSavedSpotsSection(),
      ],
    );
  }
}