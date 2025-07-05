import 'package:flutter/material.dart';

class AddFriendsDialog extends StatefulWidget {
  final List<String> selectedFriends;
  final Function(String) onFriendSelected;

  const AddFriendsDialog({
    required this.selectedFriends,
    required this.onFriendSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<AddFriendsDialog> createState() => _AddFriendsDialogState();
}

class _AddFriendsDialogState extends State<AddFriendsDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode =
      FocusNode();
  final List<String> _allFriends = [
    'Alice Wonderland',
    'Bob The Builder',
    'Charlie Brown',
    'David Copperfield',
    'Eve Harrington',
    'Fiona Gallagher',
    'George Costanza',
    'Harry Potter',
    'Ivy Dickens',
    'Jack Sparrow',
    'Katherine Pierce',
    'Leo Fitz',
  ];
  List<String> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _filteredFriends = _allFriends;
    _searchController.addListener(_filterFriends);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFriends);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends =
          _allFriends.where((friend) {
            return friend.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      titlePadding: const EdgeInsets.only(
        top: 24.0,
        left: 24.0,
        right: 24.0,
        bottom: 0,
      ),
      titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
        color: colors.onSurface,
      ),
      title: const Text('Add Friends'),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search friends...',
                hintStyle: TextStyle(color: colors.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                isDense: true,
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child:
                  _filteredFriends.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No friends found.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredFriends.length,
                        itemBuilder: (BuildContext context, int index) {
                          final friend = _filteredFriends[index];
                          final isSelected = widget.selectedFriends.contains(
                            friend,
                          );
                          return ListTile(
                            title: Text(
                              friend,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 6.0,
                            ),
                            trailing:
                                isSelected
                                    ? Icon(
                                      Icons.check_circle_rounded,
                                      color: colors.primary,
                                    )
                                    : Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: colors.outline,
                                    ),
                            onTap: () {
                              if (!isSelected) {
                                widget.onFriendSelected(friend);
                                Navigator.pop(context);
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            tileColor: Colors.transparent,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
