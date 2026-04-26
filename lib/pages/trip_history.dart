import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../service/trip_service.dart';
import 'trip_detail.dart';

class TripHistoryPage extends StatelessWidget {
  const TripHistoryPage({super.key});

  Future<void> deleteTrip(
      BuildContext context,
      TripService tripService,
      String documentId,
      ) async {
    try {
      await tripService.deleteTrip(documentId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete trip: $e')),
      );
    }
  }

  Widget buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Column(
            children: [
              Icon(Icons.history, size: 54, color: Colors.grey),
              SizedBox(height: 14),
              Text(
                'No trip history yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D2B3E),
                ),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripService = TripService();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: tripService.getTripsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  'Error loading trips: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return buildEmptyState();
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Saved Trips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2B3E),
              ),
            ),
            const SizedBox(height: 12),
            ...docs.map((doc) {
              final data = doc.data();

              final trip = <String, String>{
                'spot': (data['spot'] ?? '').toString(),
                'dateTime': (data['dateTime'] ?? '').toString(),
                'condition': (data['condition'] ?? '').toString(),
                'result': (data['result'] ?? '').toString(),
                'notes': (data['notes'] ?? '').toString(),
              };

              final result = trip['result'] ?? '';
              final bool caught = result.toLowerCase().contains('caught') &&
                  !result.toLowerCase().contains('no');

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: caught
                          ? Colors.green.withOpacity(0.14)
                          : Colors.red.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      caught
                          ? Icons.sentiment_satisfied_alt
                          : Icons.sentiment_dissatisfied,
                      color: caught ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    trip['spot']!.isEmpty ? '--' : trip['spot']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2B3E),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${trip['dateTime']!.isEmpty ? '--' : trip['dateTime']}\n'
                          '${trip['result']!.isEmpty ? '--' : trip['result']} · '
                          '${trip['condition']!.isEmpty ? '--' : trip['condition']}',
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripDetailPage(trip: trip),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      deleteTrip(
                        context,
                        tripService,
                        doc.id,
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}