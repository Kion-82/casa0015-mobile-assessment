import 'package:cloud_firestore/cloud_firestore.dart';

class SpotService {
  final CollectionReference<Map<String, dynamic>> _spotsCollection =
  FirebaseFirestore.instance.collection('saved_spots');

  Future<bool> addSpot(String spotName) async {
    final trimmedName = spotName.trim();

    if (trimmedName.isEmpty) {
      return false;
    }

    final existing = await _spotsCollection
        .where('name', isEqualTo: trimmedName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return false;
    }

    await _spotsCollection.add({
      'name': trimmedName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSavedSpotsStream() {
    return _spotsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteSpot(String documentId) async {
    await _spotsCollection.doc(documentId).delete();
  }
}