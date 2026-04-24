import 'package:flutter/material.dart';
import 'log_trip.dart';

class SpotsPage extends StatefulWidget {
  final void Function(Map<String, String>) onSaveTrip;

  const SpotsPage({super.key, required this.onSaveTrip});

  @override
  State<SpotsPage> createState() => _SpotsPageState();
}

class _SpotsPageState extends State<SpotsPage> {
  final TextEditingController _searchController = TextEditingController();

  String? selectedSpot;
  String weather = '--';
  String temperature = '--';
  String wind = '--';
  String tide = '--';
  String sunrise = '--';
  String sunset = '--';
  String summary = '--';

  final List<String> savedSpots = [];

  void searchSpot() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    setState(() {
      selectedSpot = query;
      weather = 'Partly Cloudy';
      temperature = '15°C';
      wind = '10 mph SW';
      tide = 'Mid tide';
      sunrise = '06:03';
      sunset = '19:52';
      summary = 'Fair conditions for a short fishing session.';
    });
  }

  void saveCurrentSpot() {
    if (selectedSpot == null) {
      return;
    }

    if (!savedSpots.contains(selectedSpot)) {
      setState(() {
        savedSpots.add(selectedSpot!);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location saved')),
      );
    }
  }

  void loadSavedSpot(String spot) {
    _searchController.text = spot;
    searchSpot();
  }

  void deleteSavedSpot(String spot) {
    setState(() {
      savedSpots.remove(spot);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved spot removed')),
    );
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
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: searchSpot,
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
                        onPressed: selectedSpot == null ? null : saveCurrentSpot,
                        child: const Text('Save Spot'),
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
                                  initialDateTime: getCurrentDateTimeString(),
                                  initialCondition: getCurrentConditionString(),
                                  onSaveTrip: widget.onSaveTrip,
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
        if (savedSpots.isEmpty)
          Card(
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
          )
        else
          ...savedSpots.map(
            (spot) => Card(
              child: ListTile(
                leading: const Icon(Icons.place),
                title: Text(spot),
                // trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  loadSavedSpot(spot);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    deleteSavedSpot(spot);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}