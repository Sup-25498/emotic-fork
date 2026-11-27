import 'package:emotic/core/routes.dart';
import 'package:emotic/widgets_common/emotic_logo.dart';
import 'package:emotic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            title: Text(l10n.emoticons),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.emoticonsPage);
            },
          ),
          ListTile(
            title: Text(l10n.emotipics),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.emotipicsPage);
            },
          ),
          ListTile(
            title: Text(l10n.fancy_text),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.fancyTextPage);
            },
          ),
          ListTile(
            title: Text(l10n.settings),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.settingsPage);
            },
          ),
          ListTile(
            title: Text(l10n.about),
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
