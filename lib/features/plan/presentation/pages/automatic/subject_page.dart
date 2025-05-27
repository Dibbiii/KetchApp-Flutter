import 'package:flutter/material.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final List<String> _subjects = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _addSubject() async {
    String? newSubject = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: const Text('Add Subject'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => input = value,
            decoration: const InputDecoration(
              hintText: 'Enter subject name',
              prefixIcon: Icon(Icons.book_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (input.trim().isNotEmpty) {
                  Navigator.pop(context, input.trim());
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (newSubject != null && !_subjects.contains(newSubject)) {
      setState(() {
        _subjects.add(newSubject);
        _listKey.currentState?.insertItem(_subjects.length - 1);
      });
    }
  }

  void _removeSubject(int index) {
    final removed = _subjects[index];
    setState(() {
      _subjects.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildSubjectCard(removed, index, animation),
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  Widget _buildSubjectCard(
    String subject,
    int index,
    Animation<double> animation,
  ) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colors.surfaceVariant,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.15),
            child: Icon(Icons.book, color: colors.primary),
          ),
          title: Text(subject, style: textTheme.bodyLarge),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: colors.error),
            tooltip: 'Remove',
            onPressed: () => _removeSubject(index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row with title and add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Subjects',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Subject',
                onPressed: _addSubject,
                color: colors.primary,
                iconSize: 28,
                padding: const EdgeInsets.all(0),
              ),
            ],
          ),
          Divider(color: colors.outlineVariant, thickness: 1),
          const SizedBox(height: 8),
          Expanded(
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
                    : AnimatedList(
                      key: _listKey,
                      initialItemCount: _subjects.length,
                      itemBuilder:
                          (context, index, animation) => _buildSubjectCard(
                            _subjects[index],
                            index,
                            animation,
                          ),
                    ),
          ),
        ],
      ),
    );
  }
}
