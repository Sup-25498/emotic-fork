import 'package:emotic/core/entities/emoticon.dart';
import 'package:emotic/widgets_common/delete_confirmation.dart';
import 'package:emotic/widgets_common/read_list_of_string_from_user.dart';
import 'package:emotic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

sealed class BottomSheetResult {
  final NewOrModifyEmoticon newOrModifyEmoticon;
  const BottomSheetResult({
    required this.newOrModifyEmoticon,
  });
}

class DeleteEmoticon extends BottomSheetResult {
  const DeleteEmoticon({required super.newOrModifyEmoticon});
}

class UpdateEmoticon extends BottomSheetResult {
  const UpdateEmoticon({required NewOrModifyEmoticon updatedEmoticon})
      : super(newOrModifyEmoticon: updatedEmoticon);
}

class AddEmoticon extends BottomSheetResult {
  const AddEmoticon({required NewOrModifyEmoticon newEmoticon})
      : super(newOrModifyEmoticon: newEmoticon);
}

class TagClicked extends BottomSheetResult {
  final String tag;
  const TagClicked({
    required super.newOrModifyEmoticon,
    required this.tag,
  });
}

class UpdateEmoticonBottomSheet extends StatefulWidget {
  const UpdateEmoticonBottomSheet({
    super.key,
    required this.allTags,
    required this.isEditMode,
    required this.newOrModifyEmoticon,
  });
  final bool isEditMode;
  final NewOrModifyEmoticon newOrModifyEmoticon;
  final List<String> allTags;

  @override
  State<UpdateEmoticonBottomSheet> createState() =>
      _UpdateEmoticonBottomSheetState();
}

class _UpdateEmoticonBottomSheetState extends State<UpdateEmoticonBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TextEditingController emoticonTextController;
  late final AnimationController animationController;
  bool readOnlyMode = true;
  Map<String, bool> tagsSelection = {};
  @override
  void initState() {
    super.initState();
    emoticonTextController = TextEditingController(
      text: widget.newOrModifyEmoticon.text,
    );
    animationController = AnimationController(vsync: this);
    tagsSelection = Map.fromEntries(
      widget.allTags.map(
        (tag) => MapEntry(
          tag,
          widget.newOrModifyEmoticon.emoticonTags.contains(tag),
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    emoticonTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmallScreen = screenHeight < 640;
    return BottomSheet(
      animationController: animationController,
      showDragHandle: true,
      enableDrag: false,
      constraints: BoxConstraints.expand(
        height: isSmallScreen ? screenHeight : screenHeight * 0.7,
      ),
      onClosing: () {},
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                switch ((widget.isEditMode, readOnlyMode)) {
                  (true, true) => l10n.emoticon,
                  (true, false) => l10n.modify_emoticon,
                  (false, _) => l10n.add_emoticon1,
                },
              ),
              SizedBox(
                height: isSmallScreen ? 10 : 20,
              ),
              TextField(
                readOnly: readOnlyMode && widget.isEditMode,
                controller: emoticonTextController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text(l10n.emoticon),
                ),
              ),
              SizedBox(
                height: isSmallScreen ? 15 : 30,
              ),
              Text(
                switch ((widget.isEditMode, readOnlyMode)) {
                  (true, true) => l10n.tags,
                  (true, false) => l10n.modify_tags,
                  (false, _) => l10n.add_tags,
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TagsSelection(
                isSmallScreen: isSmallScreen,
                tagsSelection: readOnlyMode && widget.isEditMode
                    ? tagsSelection
                    : {
                        ...tagsSelection,
                        "+": false,
                      },
                onSelect: (tag, selected) async {
                  if (tag == "+") {
                    final newTags = await readTags(context);
                    if (newTags != null) {
                      setState(
                        () {
                          tagsSelection.addEntries(
                            newTags.map(
                              (newTag) => MapEntry(newTag, true),
                            ),
                          );
                        },
                      );
                    }
                  } else if (readOnlyMode && widget.isEditMode) {
                    Navigator.pop<BottomSheetResult>(
                      context,
                      TagClicked(
                        newOrModifyEmoticon: widget.newOrModifyEmoticon,
                        tag: tag,
                      ),
                    );
                  } else {
                    setState(() {
                      tagsSelection[tag] = selected;
                    });
                  }
                },
              ),
              const Spacer(
                flex: 1,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ...switch ((widget.isEditMode, readOnlyMode)) {
                    (true, true) => [
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              readOnlyMode = false;
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: Text(l10n.edit),
                        ),
                      ],
                    (true, false) => [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.only(),
                          ),
                          onPressed: () async {
                            if (await confirmDeletionDialog(context,
                                        titleText: l10n.deleteEmoticon_confirm) ==
                                    true &&
                                context.mounted) {
                              Navigator.pop<BottomSheetResult>(
                                context,
                                DeleteEmoticon(
                                  newOrModifyEmoticon:
                                      widget.newOrModifyEmoticon,
                                ),
                              );
                            }
                          },
                          child: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const Spacer(
                          flex: 10,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(l10n.cancel),
                        ),
                        const Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: 20,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            final updatedEmoticon = NewOrModifyEmoticon(
                              text: emoticonTextController.text,
                              emoticonTags: tagsSelection.entries
                                  .where(
                                    (tag) => tag.value,
                                  )
                                  .map(
                                    (e) => e.key,
                                  )
                                  .toList(),
                              oldEmoticon:
                                  widget.newOrModifyEmoticon.oldEmoticon,
                            );

                            Navigator.pop<BottomSheetResult>(
                              context,
                              UpdateEmoticon(
                                updatedEmoticon: updatedEmoticon,
                              ),
                            );
                          },
                          child: Text(l10n.save),
                        )
                      ],
                    (false, _) => [
                        const Spacer(
                          flex: 10,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(l10n.cancel),
                        ),
                        const Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: 20,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            final newEmoticon = NewOrModifyEmoticon(
                              text: emoticonTextController.text,
                              emoticonTags: tagsSelection.entries
                                  .where(
                                    (tag) => tag.value,
                                  )
                                  .map(
                                    (e) => e.key,
                                  )
                                  .toList(),
                              oldEmoticon: null,
                            );

                            Navigator.pop<BottomSheetResult>(
                              context,
                              AddEmoticon(
                                newEmoticon: newEmoticon,
                              ),
                            );
                          },
                          child: Text(l10n.add),
                        )
                      ]
                  },
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class TagsSelection extends StatefulWidget {
  final bool isSmallScreen;
  final Map<String, bool> tagsSelection;
  final void Function(String tag, bool selected) onSelect;
  const TagsSelection({
    super.key,
    required this.isSmallScreen,
    required this.tagsSelection,
    required this.onSelect,
  });

  @override
  State<TagsSelection> createState() => _TagsSelectionState();
}

class _TagsSelectionState extends State<TagsSelection> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.isSmallScreen ? 6 : 4,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 5.0,
          runSpacing: 5.0,
          children: widget.tagsSelection.keys
              .map(
                (tag) => FilterChip(
                  label: Text(tag),
                  selected: widget.tagsSelection[tag] ?? false,
                  onSelected: (selected) => widget.onSelect(tag, selected),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
