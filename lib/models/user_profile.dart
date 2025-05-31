class UserProfile {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;

  UserProfile({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid, // uid is the document ID, not in the map
      name: map['name'] as String?,
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // uid is not included here as it's used as the document ID
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
