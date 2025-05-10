import 'package:flutter/material.dart';
import 'package:ketchapp_flutter/app/themes/app_colors.dart'; // Import app_colors

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final List<String> _subjects = []; // Lista delle materie

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 40),
      // Add padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // Center content vertically
        crossAxisAlignment: CrossAxisAlignment.center,
        // Center content horizontally
        children: [
          // Icon Placeholder (Styled like WelcomePage icons)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1), // Use accent color background
              shape: BoxShape.circle, // Make it circular like WelcomePage
            ),
            child: Icon(
              Icons.menu_book, // Example: Use a relevant icon
              size: 60.0, // Slightly smaller than WelcomePage main icons
              color: colors.primary, // Use accent color for icon
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'Select Your Subjects',
            style: textTheme.headlineSmall?.copyWith(
              // Use headlineSmall for page titles
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            'Add the subjects you need to study for your plan.',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurface.withOpacity(0.8), // Match text opacity
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40), // Space before button/list
          // Add Subject Button (Styled like WelcomePage 'Done')
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Subject'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              // Make button wider
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ), // Match WelcomePage radius
              ),
              textStyle: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).copyWith(
              // Remove splash/highlight like WelcomePage
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            ),
            onPressed: () async {
              final subjectName = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  String input = '';
                  return AlertDialog(
                    title: const Text('Add Subject'), // Keep title simple
                    content: TextField(
                      onChanged: (value) {
                        input = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter subject name', // Updated hint text
                      ),
                      autofocus: true, // Focus the text field immediately
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onSurface.withOpacity(
                            0.6,
                          ), // Muted cancel
                        ),
                        child: const Text('Cancel'), // Updated text
                      ),
                      TextButton(
                        onPressed: () {
                          if (input.trim().isNotEmpty) {
                            // Only pop if not empty
                            Navigator.of(context).pop(input.trim());
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              colors.primary, // Use accent color for confirm
                        ),
                        child: const Text('Add'), // Updated text
                      ),
                    ],
                  );
                },
              );

              if (subjectName != null && subjectName.isNotEmpty) {
                setState(() {
                  if (!_subjects.contains(subjectName)) {
                    // Avoid duplicates
                    _subjects.add(subjectName);
                  }
                });
              }
            },
          ),
          const SizedBox(height: 24), // Space between button and list
          // Subject List (Improved Styling)
          Expanded(
            // Allow list to take remaining space
            child:
                _subjects.isEmpty
                    ? Center(
                      child: Text(
                        'No subjects added yet.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      // Important if inside another Column without Expanded
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        return Card(
                          // Use Card for better visual separation
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          color: colors.surfaceVariant.withOpacity(0.5),
                          // Subtle background
                          elevation: 0,
                          // No shadow to match flat style
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: colors.outline.withOpacity(0.2),
                              width: 1,
                            ), // Subtle border
                          ),
                          child: ListTile(
                            title: Text(
                              _subjects[index],
                              style: textTheme.bodyLarge?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            trailing: IconButton(
                              // Add delete button
                              icon: Icon(
                                Icons.delete_outline,
                                color: colors.onSurfaceVariant.withOpacity(0.7),
                              ),
                              onPressed: () {
                                setState(() {
                                  _subjects.removeAt(index);
                                });
                              },
                              tooltip: 'Remove Subject',
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
