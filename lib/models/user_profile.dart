import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? bio;
  final int level;
  final int xp;
  final String? role;
  final String? character;

  UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.bio,
    this.level = 1,
    this.xp = 0,
    this.role,
    this.character,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserProfile(
      uid: doc.id,
      displayName: data?['displayName'] as String?,
      email: data?['email'] as String?,
      bio: data?['bio'] as String?,
      level: data?['level'] as int? ?? 1,
      xp: data?['xp'] as int? ?? 0,
      role: data?['role'] as String?,
      character: data?['character'] as String?,
    );
  }
}
