import 'package:flutter/material.dart';

class TripDetailPage extends StatelessWidget {
  final Map<String, String> trip;

  const TripDetailPage({super.key, required this.trip});

  Widget buildPanel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0277BD)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '--' : value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D2B3E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spot = trip['spot'] ?? '--';
    final dateTime = trip['dateTime'] ?? '--';
    final condition = trip['condition'] ?? '--';
    final result = trip['result'] ?? '--';
    final notes = trip['notes'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Detail'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.phishing, color: Color(0xFF0277BD)),
                    SizedBox(width: 8),
                    Text(
                      'Fishing Trip',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D2B3E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                buildDetailRow(
                  icon: Icons.place_outlined,
                  label: 'Spot',
                  value: spot,
                ),
                const SizedBox(height: 10),
                buildDetailRow(
                  icon: Icons.schedule,
                  label: 'Date & Time',
                  value: dateTime,
                ),
                const SizedBox(height: 10),
                buildDetailRow(
                  icon: Icons.cloud_outlined,
                  label: 'Condition',
                  value: condition,
                ),
                const SizedBox(height: 10),
                buildDetailRow(
                  icon: result == 'Caught'
                      ? Icons.sentiment_satisfied_alt
                      : Icons.sentiment_dissatisfied,
                  label: 'Catch Result',
                  value: result,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          buildPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notes, color: Color(0xFF0277BD)),
                    SizedBox(width: 8),
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D2B3E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notes.isEmpty ? 'No notes added' : notes,
                  style: const TextStyle(
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}