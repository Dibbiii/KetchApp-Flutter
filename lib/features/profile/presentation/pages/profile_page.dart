import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/bloc/auth_bloc.dart';

class Achievement {
  final IconData icon;
  final String title;
  final bool isCompleted; // Changed: removed value, added isCompleted

  Achievement({required this.icon, required this.title, required this.isCompleted});
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Helper to create styled InputDecoration for TextFormFields
    InputDecoration styledInputDecoration({
      required String labelText,
      required IconData iconData,
    }) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: textTheme.bodyLarge?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        prefixIcon: Icon(iconData, color: colors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          // Keep border visible for readOnly fields
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      );
    }

    final List<Achievement> achievements = [
      Achievement(icon: Icons.timer_outlined, title: 'Study for 5 hours', isCompleted: true),
      Achievement(icon: Icons.self_improvement_outlined, title: 'Distraction-free session', isCompleted: false),
      Achievement(icon: Icons.leaderboard_outlined, title: 'Top 10 Global Ranking', isCompleted: false),
      Achievement(icon: Icons.check_circle_outline, title: 'Complete all Tomatoes', isCompleted: true),
      Achievement(icon: Icons.whatshot_outlined, title: 'Continue the Streak', isCompleted: false),
      Achievement(icon: Icons.radar_outlined, title: 'Achieve 90% focus rate during the study session', isCompleted: false), // Changed achievement
      Achievement(icon: Icons.share_outlined, title: 'Share your achievements', isCompleted: false),
      Achievement(icon: Icons.star_outline, title: 'Rate the app', isCompleted: false),
    ];

    return Scaffold(
      appBar: AppBar( 
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView( // Changed Center to SingleChildScrollView
        child: Padding( // Added Padding for overall content
          padding: const EdgeInsets.all(20.0), // Consistent padding around the content
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center, // Removed to allow top alignment
            crossAxisAlignment: CrossAxisAlignment.stretch, // To stretch elements like buttons
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 100),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 18,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.edit, size: 10),
                        offset: const Offset(170, -50),
                        // Added offset to position the menu
                        onSelected: (String result) {
                          if (result == 'take_photo') {
                            // TODO: Implement take photo functionality
                          } else if (result == 'library_photo') {
                            // TODO: Implement photo library functionality
                          } else if (result == 'delete_photo') {
                            // TODO: Implement delete photo functionality
                          }
                        },
                        itemBuilder:
                            (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'take_photo',
                            child: ListTile(
                              leading: Icon(Icons.photo_camera),
                              title: Text('Scatta foto'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'library_photo',
                            child: ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Libreria foto'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete_photo',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text(
                                'Elimina foto',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Increased spacing after profile icon section

              // Username Field
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: TextFormField(
                  initialValue: user?.displayName ?? 'Not set',
                  readOnly: true, // Keep readOnly, edit action is via icon
                  style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                  decoration: styledInputDecoration(
                    labelText: 'Username',
                    iconData: Icons.person_outline,
                  ),
                ),
              ),

              // Email Field
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: TextFormField(
                  initialValue: user?.email ?? 'Not available',
                  readOnly: true, // Keep readOnly, edit action is via icon
                  style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                  decoration: styledInputDecoration(
                    labelText: 'Email',
                    iconData: Icons.email_outlined,
                  ),
                ),
              ),

              // Password Field
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: TextFormField(
                  initialValue: '••••••••', // Placeholder for password
                  readOnly: true,
                  obscureText: true,
                  style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                  decoration: styledInputDecoration(
                    labelText: 'Password',
                    iconData: Icons.lock_outline,
                  ).copyWith( // Added copyWith to add suffixIcon
                    suffixIcon: IconButton(
                      icon: Icon(Icons.edit, color: colors.onSurfaceVariant),
                      onPressed: () {
                        // TODO: Implement change password functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Change Password Tapped (Not Implemented Yet)')),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16), // Spacing before Logout button
              
              const SizedBox(height: 32), // Adjusted spacing before Logout button

              // Achievements Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Achievements',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              GridView.builder(
                shrinkWrap: true, // Important to make GridView work inside SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 12.0, // Horizontal space between cards
                  mainAxisSpacing: 12.0, // Vertical space between cards
                  childAspectRatio: 1.2, // Aspect ratio of the cards (width / height)
                ),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  return _buildAchievementCard(context, achievements[index], colors, textTheme);
                },
              ),
              const SizedBox(height: 24), // Spacing after achievements before logout

              ElevatedButton(
                style: ElevatedButton.styleFrom( // Added style for logout button from previous iteration
                  backgroundColor: colors.errorContainer,
                  foregroundColor: colors.onErrorContainer,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement, ColorScheme colors, TextTheme textTheme) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: colors.surfaceContainerLowest, // Or colors.surface for a slightly different shade
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row( // Added Row to display achievement icon and completion status
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(achievement.icon, size: 36.0, color: colors.primary),
                if (achievement.isCompleted)
                  Icon(Icons.check_circle, color: colors.tertiary, size: 24.0) // Changed to tertiary color
                else
                  Icon(Icons.radio_button_unchecked_outlined, color: colors.onSurfaceVariant.withOpacity(0.6), size: 24.0), // Icon for not completed
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              achievement.title,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            // Removed SizedBox and Text for achievement.value as it's no longer part of the class
          ],
        ),
      ),
    );
  }
}
