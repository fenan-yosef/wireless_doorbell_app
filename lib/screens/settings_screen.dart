import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_doorbell_app/providers/app_mode_provider.dart';
import 'package:smart_doorbell_app/models/app_mode.dart';
import 'package:smart_doorbell_app/screens/hardware_mode_screen.dart';
import 'package:smart_doorbell_app/screens/auth_wrapper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AppModeProvider>(
          builder: (context, appModeProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Operating Mode',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                RadioListTile<AppMode>(
                  title: const Text('Act as Hardware'),
                  value: AppMode.hardware,
                  groupValue: appModeProvider.currentMode,
                  onChanged: (AppMode? newValue) {
                    if (newValue != null && newValue != appModeProvider.currentMode) {
                      appModeProvider.setMode(newValue);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HardwareModeScreen()),
                        (route) => false, // Clears the entire stack
                      );
                    }
                  },
                ),
                RadioListTile<AppMode>(
                  title: const Text('Act as Mobile User'),
                  value: AppMode.mobile,
                  groupValue: appModeProvider.currentMode,
                  onChanged: (AppMode? newValue) {
                    if (newValue != null && newValue != appModeProvider.currentMode) {
                      appModeProvider.setMode(newValue);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthWrapper()),
                         (route) => false, // Clears the entire stack
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Current mode: ${appModeProvider.currentMode.toString().split('.').last}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                // Add other settings here if needed
              ],
            );
          },
        ),
      ),
    );
  }
}
