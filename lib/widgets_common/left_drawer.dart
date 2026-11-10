import 'package:emotic/core/routes.dart';
import 'package:emotic/widgets_common/emotic_logo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_localizations.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Center(
              child: EmoticLogo(),
            ),
          ),
          ListTile(
            title: const Text("Emoticons"),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.emoticonsPage);
            },
          ),
          ListTile(
            title: const Text("Emotipics"),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.emotipicsPage);
            },
          ),
          ListTile(
            title: const Text("Fancy Text"),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.fancyTextPage);
            },
          ),
          ListTile(
            title: const Text(l10n.settings),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.settingsPage);
            },
          ),
          ListTile(
            title: const Text(l10n.about),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.aboutPage);
            },
          ),
        ],
      ),
    );
  }
}
