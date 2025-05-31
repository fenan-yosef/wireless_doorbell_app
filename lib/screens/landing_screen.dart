import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_doorbell_app/providers/app_mode_provider.dart';
import 'package:smart_doorbell_app/models/app_mode.dart';
import 'package:smart_doorbell_app/screens/hardware_mode_screen.dart';
import 'package:smart_doorbell_app/screens/login_screen.dart'; // Will be replaced by AuthWrapper for direct nav
import 'package:smart_doorbell_app/screens/auth_wrapper.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Doorbell'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Provider.of<AppModeProvider>(context, listen: false).setMode(AppMode.hardware);
                print('Hardware mode selected');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HardwareModeScreen()),
                );
              },
              child: const Text('Act as Hardware'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<AppModeProvider>(context, listen: false).setMode(AppMode.mobile);
                print('Mobile mode selected, navigating to AuthWrapper');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthWrapper()),
                );
              },
              child: const Text('Act as Mobile'),
            ),
          ],
        ),
      ),
    );
  }
}
