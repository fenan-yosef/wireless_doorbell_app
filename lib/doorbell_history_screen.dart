import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure this is imported

class DoorbellHistoryScreen extends StatelessWidget {
  const DoorbellHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Re-instantiate Firestore for this widget to ensure it's accessible.
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doorbell History'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream to fetch all doorbell events, ordered by newest first
        stream: _firestore
            .collection('doorbell_events')
            .orderBy('triggeredAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No doorbell events yet.'));
          }

          // Display the list of doorbell events
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final deviceId = data['deviceId'] ?? 'N/A';
              final location = data['location'] ?? 'N/A';
              final timestamp = data['triggeredAt'] as Timestamp?;
              final dateTime = timestamp?.toDate();
              final formattedTime = dateTime != null
                  ? '${dateTime.toLocal().hour}:${dateTime.toLocal().minute}:${dateTime.toLocal().second} - ${dateTime.toLocal().day}/${dateTime.toLocal().month}/${dateTime.toLocal().year}'
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location: $location',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Device ID: $deviceId',
                        style:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Time: $formattedTime',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
