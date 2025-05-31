import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For User type
import 'package:smart_doorbell_app/services/auth_service.dart';
import 'package:smart_doorbell_app/screens/login_screen.dart';
import 'package:smart_doorbell_app/screens/mobile_mode_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            // User is logged in
            return const MobileModeDashboard();
          } else {
            // User is not logged in
            return const LoginScreen();
          }
        } else {
          // Handle other states, though active and waiting are primary for auth streams
          return const Scaffold(
            body: Center(
              child: Text('Something went wrong with the auth stream.'),
            ),
          );
        }
      },
    );
  }
}
