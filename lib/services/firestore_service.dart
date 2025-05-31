import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For User type and currentUser
import 'package:smart_doorbell_app/models/doorbell_event.dart';
import 'package:smart_doorbell_app/models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Already here, good.

  // Add a new doorbell event to a global collection
  Future<void> addDoorbellEvent(DoorbellEvent event) async {
    try {
      // If event.userId is null, and we want to associate with the current user
      // String? currentUserId = _firebaseAuth.currentUser?.uid;
      // final eventData = event.toMap();
      // if (event.userId == null && currentUserId != null) {
      //   eventData['userId'] = currentUserId; // Stamp with current user ID if not set
      // }

      // Forcing event.id to be null so Firestore auto-generates it.
      // The DoorbellEvent model expects an ID for fromMap, but not for toMap when creating.
      // This is a bit of a workaround based on the current model structure.
      // A cleaner way would be to have a separate model for "new event data" vs "fetched event".
      final Map<String, dynamic> eventData = {
        'timestamp': Timestamp.fromDate(event.timestamp),
        'userId': event.userId, // Use provided userId or it will be null
        'details': event.details,
      };


      await _firestore.collection('doorbell_events').add(eventData);
      print('Doorbell event added successfully.');
    } catch (e) {
      print('Error adding doorbell event: $e');
      // Optionally rethrow or handle as per app's error strategy
      throw e;
    }
  }

  // Get a stream of all doorbell events, ordered by timestamp
  Stream<List<DoorbellEvent>> getDoorbellEvents() {
    return _firestore
        .collection('doorbell_events')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => DoorbellEvent.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      } catch (e) {
        print('Error mapping doorbell events: $e');
        return []; // Return empty list on error or handle differently
      }
    });
  }

  // Get a stream of recent doorbell events, limited by count
  Stream<List<DoorbellEvent>> getRecentDoorbellEvents({int limit = 3}) {
    return _firestore
        .collection('doorbell_events')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => DoorbellEvent.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      } catch (e) {
        print('Error mapping recent doorbell events: $e');
        return []; // Return empty list on error
      }
    });
  }

  // --- User Profile Methods ---

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return UserProfile.fromMap(docSnapshot.data()!, uid);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true));
      print('User profile updated for UID: ${profile.uid}');
    } catch (e) {
      print('Error updating user profile: $e');
      throw e; // Rethrow to allow UI to handle
    }
  }

  Future<void> createUserProfile(User firebaseUser) async {
    try {
      // Check if profile already exists, though updateUserProfile with merge:true handles this.
      // However, we might want to avoid overwriting an existing name with null from displayName
      // if the profile was partially created before. For simplicity now, direct creation.

      final userProfile = UserProfile(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        name: firebaseUser.displayName, // Might be null
        photoUrl: firebaseUser.photoURL, // Might be null
      );
      await updateUserProfile(userProfile); // Uses set with merge:true
      print('User profile created for UID: ${firebaseUser.uid}');
    } catch (e) {
      print('Error creating user profile: $e');
      // Decide if this should throw or be handled silently if profile creation is "best effort"
    }
  }
}
