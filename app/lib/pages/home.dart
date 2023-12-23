import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photosmarter/components/scan_options.dart';
import 'package:photosmarter/extensions/string_formatting.dart';
import 'package:photosmarter/models/scan_result.dart';
import 'package:photosmarter/pages/settings.dart';
import 'package:photosmarter/providers/options_provider.dart';
import 'package:photosmarter/providers/settings_provider.dart';
import 'package:provider/provider.dart';

final dio = Dio();

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isScanning = false;

  Future<ScanResult> _scan(
      String baseUrl, String fileName, OptionsProvider optionsProvider) async {
    final formData = FormData.fromMap({
      'type': optionsProvider.type.name.toUpperCase(),
      'dimension': optionsProvider.dimension.name.capitalize(),
      'resolution': optionsProvider.resolution.name.capitalize(),
      'quality': optionsProvider.quality.toString(),
      'color': optionsProvider.color.name.capitalize(),
      'fileName': fileName,
    });

    final response = await dio.post(
      '$baseUrl/api/scan',
      data: formData,
    );

    return ScanResult.fromJson(response.data);
  }

  SnackBar _createSnackBar(
    String content, {
    Color? backgroundColor,
    Color? textColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Text(content, style: TextStyle(color: textColor)),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 8.0,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      duration: duration ?? const Duration(seconds: 5),
      action: action,
    );
  }

  Future<String?> _promptFileName() async {
    final fileNameController = TextEditingController();

    final fileName = await showDialog<TextEditingValue?>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'File name',
                      ),
                      controller: fileNameController,
                      autofocus: true),
                  const SizedBox(height: 16.0),
                  Text('Leave empty to use the current timestamp.',
                      style: Theme.of(context).textTheme.labelMedium),
                ]),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, fileNameController.value),
                child: const Text('OK'),
              ),
            ],
          );
        });

    return fileName?.text;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        scrolledUnderElevation: 3.0,
        actions: <Widget>[
          Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
                onPressed: !_isScanning
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsPage()),
                        );
                      }
                    : null,
              )),
        ],
      ),
      body: const ScanOptions(),
      floatingActionButton: Visibility(
          visible: settingsProvider.baseUrl != '',
          child: FloatingActionButton.extended(
            onPressed: !_isScanning
                ? () async {
                    final optionsProvider = context.read<OptionsProvider>();

                    final fileName = await _promptFileName();
                    if (fileName == null) {
                      return;
                    }

                    setState(() {
                      _isScanning = true;
                    });

                    try {
                      final result = await _scan(
                          settingsProvider.baseUrl, fileName, optionsProvider);

                      messenger.showSnackBar(
                        _createSnackBar(
                          result.message,
                          backgroundColor: result.success
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.errorContainer,
                          textColor: result.success
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onErrorContainer,
                        ),
                      );
                    } catch (error) {
                      messenger.showSnackBar(
                        _createSnackBar(
                          'Scan failed, is the address correct?',
                          backgroundColor: theme.colorScheme.errorContainer,
                          textColor: theme.colorScheme.onErrorContainer,
                          action: SnackBarAction(
                              label: 'Details',
                              textColor: theme.colorScheme.onErrorContainer,
                              onPressed: () => showDialog<TextEditingValue?>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Text(error.toString()),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  })),
                        ),
                      );
                    } finally {
                      setState(() {
                        _isScanning = false;
                      });
                    }
                  }
                : null,
            enableFeedback: true,
            icon: !_isScanning
                ? const Icon(Icons.document_scanner_outlined)
                : Container(
                    width: 24.0,
                    height: 24.0,
                    padding: const EdgeInsets.all(2.0),
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.onPrimaryContainer,
                      strokeWidth: 2,
                    ),
                  ),
            label: const Text('Scan'),
            extendedIconLabelSpacing: 8.0,
          )),
    );
  }
}
