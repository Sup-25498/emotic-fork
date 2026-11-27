import 'package:emotic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<List<String>?> readListOfStringFromUser(
  BuildContext context, {
  required String titleText,
  required String textLabel,
  String? textHint,
  String? positiveButtonText,
}) {
  return showAdaptiveDialog<List<String>?>(
    context: context,
    builder: (context) {
    final l10n = AppLocalizations.of(context)!;
      String newTagsText = "";
      return SimpleDialog(
        title: Text(titleText),
        contentPadding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            maxLines: null,
            autofocus: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              label: Text(textLabel),
              hintText: textHint ?? l10n.add_hint,
            ),
            onChanged: (value) {
              newTagsText = value;
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Builder(
            builder: (context) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        newTagsText.trim().isEmpty
                            ? null
                            : newTagsText
                                .split("\n")
                                .where(
                                  (element) => element.trim().isNotEmpty,
                                )
                                .toList(),
                      );
                    },
                    child: Text(positiveButtonText ?? l10n.add),
                  ),
                ],
              );
            },
          )
        ],
      );
    },
  );
}

Future<List<String>?> readTags(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  return readListOfStringFromUser(
    context,
    titleText: l10n.add_new_tags,
    textLabel: l10n.tags,
    textHint: l10n.add_tag_hint,
  );
}

Future<List<String>?> readEmoticons(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  return readListOfStringFromUser(
    context,
    titleText: l10n.add_new_emoticons,
    textLabel: l10n.emoticons,
    textHint: l10n.add_multiple_hint,
  );
}
