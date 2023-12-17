import 'package:flutter/material.dart';
import 'package:photosmarter/providers/options_provider.dart';
import 'package:provider/provider.dart';

class ScanOptions extends StatefulWidget {
  const ScanOptions({super.key});

  @override
  State<ScanOptions> createState() => _ScanOptionsState();
}

class _ScanOptionsState extends State<ScanOptions> {
  String _capitalize(String subject) {
    return subject.replaceFirst(subject[0], subject[0].toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final optionsProvider = context.watch<OptionsProvider?>();

    final typesDropdown = DropdownMenu(
        expandedInsets: const EdgeInsets.all(8.0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        label: const Text('Format'),
        initialSelection: optionsProvider?.type,
        dropdownMenuEntries: Types.values.map((key) {
          return DropdownMenuEntry(
            value: key,
            label: key.name.toUpperCase(),
          );
        }).toList(),
        onSelected: (value) {
          if (value != null) {
            optionsProvider?.type = value;
          }
        });

    final dimensionsDropdown = DropdownMenu(
        expandedInsets: const EdgeInsets.all(8.0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        label: const Text('Paper size'),
        initialSelection: optionsProvider?.dimension,
        dropdownMenuEntries: Dimensions.values.map((key) {
          return DropdownMenuEntry(
            value: key,
            label: _capitalize(key.name),
          );
        }).toList(),
        onSelected: (value) {
          if (value != null) {
            optionsProvider?.dimension = value;
          }
        });

    final resolutionsDropdown = DropdownMenu(
        expandedInsets: const EdgeInsets.all(8.0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        label: const Text('Resolution'),
        initialSelection: optionsProvider?.resolution,
        dropdownMenuEntries: Resolutions.values.map((key) {
          return DropdownMenuEntry(
            value: key,
            label: _capitalize(key.name),
          );
        }).toList(),
        onSelected: (value) {
          if (value != null) {
            optionsProvider?.resolution = value;
          }
        });

    final colorsDropdown = DropdownMenu(
        expandedInsets: const EdgeInsets.all(8.0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        label: const Text('Color preference'),
        initialSelection: optionsProvider?.color,
        dropdownMenuEntries: Color.values.map((key) {
          return DropdownMenuEntry(
            value: key,
            label: _capitalize(key.name),
          );
        }).toList(),
        onSelected: (value) {
          if (value != null) {
            optionsProvider?.color = value;
          }
        });

    final qualitySlider = Slider(
        label: 'Quality',
        min: 0.0,
        max: 100.0,
        divisions: 10,
        value: optionsProvider?.quality ?? 80.0,
        onChanged: (value) {
          optionsProvider?.quality = value;
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
