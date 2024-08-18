import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<Response<dynamic>> _scan(String fileName) async {
    final optionsProvider = context.read<OptionsProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    final formData = FormData.fromMap({
      'type': optionsProvider.type.name.toUpperCase(),
      'dimension': optionsProvider.dimension.name.capitalize(),
      'resolution': optionsProvider.resolution.name.capitalize(),
      'quality': optionsProvider.quality.toString(),
      'color': optionsProvider.color.name.capitalize(),
      'download': optionsProvider.directDownload ? 'on' : 'off',
      'fileName': fileName,
    });

    final response = await dio.post(
      '${settingsProvider.baseUrl}/api/scan',
      options: Options(
        headers: {
          'Accept': optionsProvider.directDownload
              ? 'application/pdf, image/jpeg'
              : 'application/json',
        },
        responseType: optionsProvider.directDownload
            ? ResponseType.bytes
            : ResponseType.json,
      ),
      data: formData,
    );

    return response;
  }

  void _showSnackBar(
    String content, {
    Color? backgroundColor,
    Color? textColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    ));
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

  Future<void> _saveFileLocally(Response<dynamic> response) async {
    final theme = Theme.of(context);

    final safeFileName =
        response.headers['x-photosmarter-filename']?.firstOrNull;
    if (safeFileName == null) {
      _showSnackBar(
        'No file name provided by server',
        backgroundColor: theme.colorScheme.errorContainer,
        textColor: theme.colorScheme.onErrorContainer,
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$safeFileName');
    if (await file.exists()) {
      _showSnackBar(
        'File $safeFileName already exists',
        backgroundColor: theme.colorScheme.errorContainer,
        textColor: theme.colorScheme.onErrorContainer,
      );
      return;
    }
    await file.writeAsBytes(response.data);

    _showSnackBar(
      'File saved as $safeFileName',
      backgroundColor: theme.colorScheme.primaryContainer,
      textColor: theme.colorScheme.onPrimaryContainer,
      action: SnackBarAction(
        label: 'Open',
        textColor: theme.colorScheme.onPrimaryContainer,
        // TODO: why can the file not be opened?
        onPressed: () => OpenFile.open(file.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
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
                    await HapticFeedback.heavyImpact();

                    final fileName = await _promptFileName();
                    if (fileName == null) {
                      return;
                    }

                    setState(() {
                      _isScanning = true;
                    });

                    try {
                      final response = await _scan(fileName);

                      final contentType =
                          response.headers['content-type']?.firstOrNull;
                      if (contentType?.contains('application/json') != true) {
                        await _saveFileLocally(response);
                      } else {
                        final result = ScanResult.fromJson(response.data);
                        _showSnackBar(
                          result.message,
                          backgroundColor: result.success
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.errorContainer,
                          textColor: result.success
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onErrorContainer,
                        );
                      }

                      await HapticFeedback.vibrate();
                    } catch (error) {
                      _showSnackBar(
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
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                })),
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
