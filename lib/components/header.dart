import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canPop = Navigator.canPop(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading:
          canPop
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: colorScheme.onSurface,
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Back',
              )
              : null,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                'https://hd2.tudocdn.net/1142397?w=824&h=494'),
            radius: 20,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
