import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_doorbell_app/models/doorbell_event.dart';
import 'package:smart_doorbell_app/services/auth_service.dart';
import 'package:smart_doorbell_app/services/firestore_service.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:smart_doorbell_app/screens/profile_screen.dart';
import 'package:smart_doorbell_app/screens/settings_screen.dart';

class MobileModeDashboard extends StatelessWidget {
  const MobileModeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              print('Logout button pressed');
              await authService.signOut();
              // AuthWrapper will handle navigation to LoginScreen.
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: 200, // Adjust height as needed for notification area
            child: StreamBuilder<List<DoorbellEvent>>(
              stream: firestoreService.getRecentDoorbellEvents(limit: 3),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No recent activity.'));
                }
                final events = snapshot.data!;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: const Icon(Icons.notifications_active),
                        title: Text(event.details ?? 'Doorbell Ring'),
                        subtitle: Text(DateFormat.yMMMd().add_jm().format(event.timestamp)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Full Doorbell History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DoorbellEvent>>(
              stream: firestoreService.getDoorbellEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No history available.'));
                }
                final events = snapshot.data!;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      leading: const Icon(Icons.doorbell_share),
                      title: Text(event.details ?? 'Doorbell Ring'),
                      subtitle: Text(DateFormat.yMMMd().add_jm().format(event.timestamp)),
                      onTap: () {
                        print('History item ${event.id} tapped');
                        // TODO: Navigate to event details or show more info
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
