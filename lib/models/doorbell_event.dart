import 'package:cloud_firestore/cloud_firestore.dart';

class DoorbellEvent {
  final String id;
  final DateTime timestamp;
  final String? userId; // Optional: ID of the user who was notified or involved
  final String? details; // Optional: e.g., "Front door", "Motion detected"

  DoorbellEvent({
    required this.id,
    required this.timestamp,
    this.userId,
    this.details,
  });

  // Factory constructor to create a DoorbellEvent from a Firestore document
  factory DoorbellEvent.fromMap(Map<String, dynamic> map, String id) {
    return DoorbellEvent(
      id: id,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'] as String?,
      details: map['details'] as String?,
    );
  }

  // Method to convert a DoorbellEvent instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp), // Convert DateTime to Firestore Timestamp
      'userId': userId,
      'details': details,
    };
  }
}
