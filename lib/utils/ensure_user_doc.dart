import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Ensures a user document exists in Firestore for the current user.
/// If the document does not exist, creates it with default fields.
/// If it exists, only updates `updatedAt` (merge, does not overwrite xp/badges).
Future<void> ensureUserDoc() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final doc = await docRef.get();
  final now = DateTime.now();
  if (!doc.exists) {
    await docRef.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'xp': 0,
      'scanCount': 0,
      'badges': [],
      'character': 'Leafy',
      'createdAt': now,
      'updatedAt': now,
    });
  } else {
    await docRef.set({
      'updatedAt': now,
    }, SetOptions(merge: true));
  }
}
