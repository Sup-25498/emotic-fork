import 'package:emotic/core/app_theme.dart';
import 'package:emotic/core/constants.dart';
import 'package:emotic/core/init_setup.dart';
import 'package:emotic/core/settings.dart';
import 'package:emotic/cubit/settings_cubit.dart';
import 'package:emotic/pages/settings_page_widgets/export_selection_dialog.dart';
import 'package:emotic/pages/settings_page_widgets/list_tile_heading.dart';
import 'package:emotic/widgets_common/show_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:emotic/core/open_root_scaffold_drawer.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => SettingsCubit(
        emoticonsRepository: sl(),
        settingsRepository: sl(),
        imageRepository: sl(),
        globalProgressPipe: sl(),
      ),
      child: BlocBuilder<GlobalSettingsCubit, GlobalSettingsState>(
        builder: (context, globalSettingstate) {
          switch (globalSettingstate) {
            case GlobalSettingsLoaded(:final settings):
              return BlocConsumer<SettingsCubit, SettingsState>(
                listener: (context, state) async {
                  switch (state) {
                    case SettingsLoaded(:final snackBarMessage)
                        when snackBarMessage != null:
                      if (context.mounted) {
                        showSnackBar(context, text: snackBarMessage);
                      }
                    case SettingsLoaded(:final alertMessage)
                        when alertMessage != null:
                      if (context.mounted) {
                        showAlertDialog(
                          context,
                          title: Text(l10n.error),
                          content: alertMessage,
                          onPressed: () {},
                        );
                      }
                    default:
                      break;
                  }
                },
                builder: (context, state) {
                  switch (state) {
                    case SettingsLoaded():
                      return SafeArea(
                        child: Scaffold(
                          appBar: AppBar(
                            title: Text(l10n.settings),
                            leading: DrawerButton(
                              onPressed: context.openRootScaffoldDrawer,
                            ),
                          ),
                          body: ListView(
                            children: [
                              const ListTileHeading(
                                text: Text(l10n.manage_data),
                              ),
                              ListTile(
                                title: Text(l10n.restore_all),
                                onTap: () async {
                                  await context
                                      .read<SettingsCubit>()
                                      .loadEmoticonsFromAsset();
                                },
                              ),
                              ListTile(
                                title: Text(l10n.clear_all),
                                onTap: () async {
                                  final shouldClear = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(l10n.confirm),
                                      content: Text(
                                        l10n.clear_all_confirm,
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(l10n.no),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(l10n.yes),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (shouldClear == true && context.mounted) {
                                    await context
                                        .read<SettingsCubit>()
                                        .clearAllData();
                                  }
                                },
                              ),
                              const Divider(),
                              const ListTileHeading(
                                text: Text(l10n.backup_restore),
                              ),
                              ListTile(
                                title: Text(l10n.import),
                                onTap: () async {
                                  showAlertDialog(
                                    context,
                                    title: Text(l10n.import_warning),
                                    content: Text(l10n.import_warning_content_a)
                                        Text(l10n.import_warning_content_b)
                                        Text(l10n.import_warning_content_c),
                                    onPressed: () async {
                                      if (context.mounted) {
                                        await context
                                            .read<SettingsCubit>()
                                            .importData();
                                      }
                                      if (context.mounted) {
                                        await context
                                            .read<GlobalSettingsCubit>()
                                            .refreshSettings();
                                      }
                                    },
                                  );
                                },
                              ),
                              ListTile(
                                title: Text(l10n.export),
                                onTap: () async {
                                  final exportConfig =
                                      await exportConfirmationDialog(context);
                                  switch (exportConfig) {
                                    case null:
                                      break;
                                    default:
                                      await context
                                          .read<SettingsCubit>()
                                          .exportData(
                                            exportConfig: exportConfig,
                                          );
                                  }
                                },
                              ),
                              const Divider(),
                              const ListTileHeading(text: Text(l10n.theme_ui)),
                              ListTile(
                                title: Text(l10n.theme_mode),
                                trailing: DropdownMenu(
                                  initialSelection: settings.emoticThemeMode,
                                  onSelected: (emoticThemeMode) async {
                                    await context
                                        .read<GlobalSettingsCubit>()
                                        .saveSettings(
                                          settings.copyWith(
                                            emoticThemeMode: emoticThemeMode,
                                          ),
                                        );
                                  },
                                  dropdownMenuEntries: [
                                    DropdownMenuEntry(
                                      value: EmoticThemeMode.system,
                                      label: Text(l10n.system),
                                    ),
                                    DropdownMenuEntry(
                                      value: EmoticThemeMode.light,
                                      label: Text(l10n.light),
                                    ),
                                    DropdownMenuEntry(
                                      value: EmoticThemeMode.dark,
                                      label: Text(l10n.dark),
                                    ),
                                    DropdownMenuEntry(
                                      value: EmoticThemeMode.black,
                                      label: Text(l10n.black),
                                    ),
                                  ],
                                ),
                              ),
                              ListTile(
                                title: Text(l10n.emoticon_text_size),
                                trailing: DropdownMenu(
                                  initialSelection: settings.emoticonsTextSize,
                                  onSelected: (textSize) async {
                                    await context
                                        .read<GlobalSettingsCubit>()
                                        .changeEmoticonsFontSize(
                                          newSize: textSize,
                                        );
                                  },
                                  dropdownMenuEntries: [
                                    null,
                                    ...Iterable.generate(
                                      emoticonsTextSizeUpperLimit -
                                          emoticonsTextSizeLowerLimit +
                                          1,
                                      (index) =>
                                          index + emoticonsTextSizeLowerLimit,
                                    )
                                  ].map(
                                    (e) {
                                      if (e == null) {
                                        return DropdownMenuEntry(
                                          value: null,
                                          label: Text(l10n.default),
                                        );
                                      } else {
                                        return DropdownMenuEntry(
                                          value: e,
                                          label: e.toString(),
                                        );
                                      }
                                    },
                                  ).toList(),
                                ),
                              ),
                              ListTile(
                                title: Text(l10n.emotipics_column_count),
                                trailing: DropdownMenu(
                                  initialSelection:
                                      settings.emotipicsColumnCount,
                                  onSelected: (colCount) async {
                                    await context
                                        .read<GlobalSettingsCubit>()
                                        .changeEmotipicsColCount(
                                          colCount: colCount,
                                        );
                                  },
                                  dropdownMenuEntries: [
                                    null,
                                    ...Iterable.generate(
                                      emotipicsColCountUpperLimit -
                                          emotipicsColCountLowerLimit +
                                          1,
                                      (index) =>
                                          index + emotipicsColCountLowerLimit,
                                    )
                                  ].map(
                                    (e) {
                                      if (e == null) {
                                        return DropdownMenuEntry(
                                          value: null,
                                          label: Text(l10n.auto),
                                        );
                                      } else {
                                        return DropdownMenuEntry(
                                          value: e,
                                          label: e.toString(),
                                        );
                                      }
                                    },
                                  ).toList(),
                                ),
                              ),
                              ListTile(
                                title: Text(l10n.fancy_text_size),
                                trailing: DropdownMenu(
                                  initialSelection: settings.fancyTextSize,
                                  onSelected: (textSize) async {
                                    await context
                                        .read<GlobalSettingsCubit>()
                                        .changeFancyTextFontSize(
                                          newSize: textSize,
                                        );
                                  },
                                  dropdownMenuEntries: [
                                    null,
                                    ...Iterable.generate(
                                      fancyTextSizeUpperLimit -
                                          fancyTextSizeLowerLimit +
                                          1,
                                      (index) =>
                                          index + fancyTextSizeLowerLimit,
                                    )
                                  ].map(
                                    (e) {
                                      if (e == null) {
                                        return DropdownMenuEntry(
                                          value: null,
                                          label: Text(l10n.default),
                                        );
                                      } else {
                                        return DropdownMenuEntry(
                                          value: e,
                                          label: e.toString(),
                                        );
                                      }
                                    },
                                  ).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    case SettingsInitial():
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case SettingsLoading(:final loadingMessage):
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(
                              height: 20,
                            ),
                            Visibility(
                              visible: loadingMessage != null,
                              child: Text(loadingMessage ?? ""),
                            ),
                          ],
                        ),
                      );
                    case SettingsProgressBar(
                        :final currentProgress,
                        :final outOf,
                        :final message,
                      ):
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(message),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.5,
                            child: LinearProgressIndicator(
                              value: outOf == null
                                  ? null
                                  : currentProgress / outOf,
                            ),
                          ),
                        ],
                      );
                  }
                },
              );
            case GlobalSettingsInitial():
            case GlobalSettingsLoading():
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
