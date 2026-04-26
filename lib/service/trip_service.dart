import 'package:cloud_firestore/cloud_firestore.dart';

class TripService {
  final CollectionReference<Map<String, dynamic>> _tripsCollection =
  FirebaseFirestore.instance.collection('trips');

  Future<void> addTrip(Map<String, String> trip) async {
    await _tripsCollection.add({
      'spot': trip['spot'] ?? '',
      'dateTime': trip['dateTime'] ?? '',
      'condition': trip['condition'] ?? '',
      'result': trip['result'] ?? '',
      'notes': trip['notes'] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTripsStream() {
    return _tripsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteTrip(String documentId) async {
    await _tripsCollection.doc(documentId).delete();
  }
}