import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photosmarter/extensions/string_formatting.dart';
import 'package:photosmarter/providers/options_provider.dart';
import 'package:photosmarter/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class ScanOptions extends StatefulWidget {
  const ScanOptions({super.key});

  @override
  State<ScanOptions> createState() => _ScanOptionsState();
}

class _ScanOptionsState extends State<ScanOptions> {
  @override
  Widget build(BuildContext context) {
    final optionsProvider = context.watch<OptionsProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final typesDropdown = DropdownMenu(
        expandedInsets: const EdgeInsets.all(8.0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        label: const Text('Format'),
        initialSelection: optionsProvider.type,
        dropdownMenuEntries: Types.values.map((key) {
          return DropdownMenuEntry(
            value: key,
            label: key.name.toUpperCase(),
          );
        }).toList(),
        enableFilter: false,
        enableSearch: false,
        onSelected: (value) {
          if (value != null) {
            optionsProvider.type = value;
          }
        });

    final dimensionsDropdown = DropdownMenu(
        expandedInsets: const EdgeInsets.all(8.0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        label: const Text('Paper size'),
        initialSelection: optionsProvider.dimension,
        dropdownMenuEntries: Dimensions.values.map((key) {
          return DropdownMenuEntry(
            value: key,
            label: key.name.capitalize(),
          );
        }).toList(),
        enableFilter: false,
        enableSearch: false,
        onSelected: (value) {
          if (value != null) {
            optionsProvider.dimension = value;
          }
        });

    final resolutionsDropdown = DropdownMenu(
        expandedInsets: const EdgeInsets.all(8.0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        label: const Text('Resolution'),
        initialSelection: optionsProvider.resolution,
        dropdownMenuEntries: Resolutions.values.map((key) {
          return DropdownMenuEntry(
            value: key,
            label: key.name.capitalize(),
          );
        }).toList(),
        enableFilter: false,
        enableSearch: false,
        onSelected: (value) {
          if (value != null) {
            optionsProvider.resolution = value;
          }
        });

    final colorsDropdown = DropdownMenu(
        expandedInsets: const EdgeInsets.all(8.0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        label: const Text('Color preference'),
        initialSelection: optionsProvider.color,
        dropdownMenuEntries: ColorPreferences.values.map((key) {
          return DropdownMenuEntry(
            value: key,
            label: key.name.capitalize(),
          );
        }).toList(),
        enableFilter: false,
        enableSearch: false,
        onSelected: (value) {
          if (value != null) {
            optionsProvider.color = value;
          }
        });

    final qualitySlider = Slider(
        label: 'Quality (${optionsProvider.quality.toInt()}%)',
        min: 0.0,
        max: 100.0,
        divisions: 10,
        value: optionsProvider.quality,
        onChanged: (value) {
          optionsProvider.quality = value;
          HapticFeedback.selectionClick();
        });

    final children = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: typesDropdown,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: dimensionsDropdown,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: resolutionsDropdown,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: colorsDropdown,
      ),
      qualitySlider,
    ];

    if (settingsProvider.isDirectDownloadAllowed) {
      final directDownload = CheckboxListTile(
          title: const Text('Direct download'),
          value: optionsProvider.directDownload,
          onChanged: (value) {
            if (value != null) {
              optionsProvider.directDownload = value;
            }
          });

      children.add(directDownload);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
