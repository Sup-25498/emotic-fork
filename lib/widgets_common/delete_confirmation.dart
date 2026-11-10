import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

Future<bool?> confirmDeletionDialog(
  BuildContext context, {
  required String titleText,
}) {
  return showAdaptiveDialog<bool?>(
    context: context,
    builder: (context) {
       final l10n = AppLocalizations.of(context)!;
      return SimpleDialog(
        title: Text(titleText),
        contentPadding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(
            height: 20,
          ),
          Builder(builder: (context) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(l10n.no),
                ),
                const SizedBox(
                  width: 10,
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child: Text(l10n.yes),
                ),
              ],
            );
          })
        ],
      );
    },
  );
}
