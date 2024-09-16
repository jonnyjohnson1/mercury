import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USER INFO METHODS

  Future<void> createUser(String userId, String name) async {
    try {
      // Set the document data with the specified userId
      await _db.collection('user').doc(userId).set({
        'userId': userId,
        'name': name,
        'created': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
