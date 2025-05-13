import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/bloc/auth_bloc.dart';

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
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          // Keep border visible for readOnly fields
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(Icons.edit, color: colors.onSurfaceVariant),
                    onPressed: () {
                      // TODO: Implement Username edit functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Edit Username Tapped (Not Implemented)',
                          ),
                        ),
                      );
                    },
                  ),
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
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(Icons.edit, color: colors.onSurfaceVariant),
                    onPressed: () {
                      // TODO: Implement Email edit functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit Email Tapped (Not Implemented)'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Change Password Button (styled like a form field)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: InkWell(
                onTap: () {
                  // TODO: Implement change password functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Change Password Tapped (Not Implemented)'),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: styledInputDecoration(
                    labelText: 'Password',
                    iconData: Icons.lock_outline,
                  ).copyWith(contentPadding: EdgeInsets.zero),
                  // Adjust padding for InputDecorator
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16.0,
                    ),
                    child: Row(
                      children: [
                        //SizedBox(width: 12), // Space for icon is handled by prefixIcon in _styledInputDecoration
                        Expanded(
                          child: Text(
                            '••••••••',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                        // Changed icon
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
