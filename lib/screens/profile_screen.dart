import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_doorbell_app/models/user_profile.dart';
import 'package:smart_doorbell_app/services/auth_service.dart';
import 'package:smart_doorbell_app/services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  late TextEditingController _nameController;
  bool _isLoading = true;
  String? _email; // To store and display email

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _email = currentUser.email; // Get email from FirebaseAuth User
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final profile = await firestoreService.getUserProfile(currentUser.uid);
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile?.name ?? currentUser.displayName ?? '';
          _isLoading = false;
        });
      }
    } else {
      // Should not happen if ProfileScreen is accessed after login
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found. Please re-login.')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) return; // Should not happen if loaded correctly

    final updatedProfile = UserProfile(
      uid: _userProfile!.uid,
      email: _userProfile!.email, // Email is not changed here
      name: _nameController.text.trim(),
      photoUrl: _userProfile!.photoUrl, // Photo URL management not implemented yet
    );

    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    try {
      await firestoreService.updateUserProfile(updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() {
          _userProfile = updatedProfile; // Update local state
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // Added SingleChildScrollView for smaller screens
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _userProfile?.photoUrl != null
                          ? NetworkImage(_userProfile!.photoUrl!)
                          : null,
                      child: _userProfile?.photoUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Email: ${_email ?? 'N/A'}', // Display stored email
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      await authService.signOut();
                      // AuthWrapper will handle navigation
                    },
                    child: const Text('Logout', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}
