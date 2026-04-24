import 'package:flutter/material.dart';

class TripDetailPage extends StatelessWidget {
  final Map<String, String> trip;

  const TripDetailPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Detail'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spot',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip['spot'] ?? '--',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  const Text(
                    'Date & Time',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(trip['dateTime'] ?? '--'),

                  const SizedBox(height: 16),
                  const Text(
                    'Condition',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(trip['condition'] ?? '--'),

                  const SizedBox(height: 16),
                  const Text(
                    'Catch Result',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(trip['result'] ?? '--'),

                  const SizedBox(height: 16),
                  const Text(
                    'Notes',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (trip['notes'] == null || trip['notes']!.isEmpty)
                        ? 'No notes added'
                        : trip['notes']!,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}