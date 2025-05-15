import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoStartTimer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _buildSettingsOptionTile(
              context,
              icon: Icons.person_outline,
              text: 'EDIT PROFILE',
              onTap: () {
                context.push('/profile');
              },
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            );
          } else if (index == 1) {
            return _buildSettingsOptionTile(
              context,
              icon: Icons.volume_up_outlined,
              text: 'WHITE NOISES',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('WHITE NOISES tapped')),
                );
                // TODO: Navigate to White Noises settings or show dialog
              },
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            );
          } else if (index == 2) {
            return _buildSettingsOptionTile(
              context,
              icon: Icons.check_circle_outline,
              text: 'WORK COMPLETED SOUND',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('WORK COMPLETED SOUND tapped')),
                );
                // TODO: Navigate to sound settings or show dialog
              },
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            );
          } else if (index == 3) {
            return _buildSettingsOptionTile(
              context,
              icon: Icons.alarm_on_outlined,
              text: 'END BREAK SOUND',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('END BREAK SOUND tapped')),
                );
                // TODO: Navigate to sound settings or show dialog
              },
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            );
          } else if (index == 4) {
            return _buildSettingsOptionTile(
              context,
              icon: Icons.timer_outlined,
              text: 'AUTO-START TIMER',
              onTap: () {
                setState(() {
                  _autoStartTimer = !_autoStartTimer;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('AUTO-START TIMER ${_autoStartTimer ? "ON" : "OFF"}')),
                );
              },
              trailing: Switch(
                value: _autoStartTimer,
                onChanged: (bool value) {
                  setState(() {
                    _autoStartTimer = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('AUTO-START TIMER ${_autoStartTimer ? "ON" : "OFF"}')),
                  );
                },
              ),
            );
          }
          return Container();
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
      ),
    );
  }

  Widget _buildSettingsOptionTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(text, style: textTheme.titleMedium),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
