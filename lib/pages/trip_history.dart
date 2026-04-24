import 'package:flutter/material.dart';
import 'trip_detail.dart';

class TripHistoryPage extends StatelessWidget {
  final List<Map<String, String>> trips;

  const TripHistoryPage({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  Icon(Icons.history, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No trip history yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your saved fishing trips will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];

        return Card(
          child: ListTile(
            title: Text(trip['spot'] ?? '--'),
            subtitle: Text(
              '${trip['dateTime'] ?? '--'}\n'
                  '${trip['result'] ?? '--'} · ${trip['condition'] ?? '--'}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TripDetailPage(trip: Map<String, String>.from(trip)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}