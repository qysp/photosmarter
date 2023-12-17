import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photosmarter/components/scan_options.dart';
import 'package:photosmarter/entities/scan_result.dart';
import 'package:photosmarter/providers/options_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<ScanResult> _scan(OptionsProvider? optionsProvider) async {
    const baseUrl = 'http://localhost:3000';
    final map = <String, dynamic>{
      'type': optionsProvider?.type,
      'dimension': optionsProvider?.dimension,
      'resolution': optionsProvider?.resolution,
      'quality': optionsProvider?.quality,
      'color': optionsProvider?.color,
      // TODO: 'fileName'
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/scan'),
      body: map,
    );

    final body = jsonDecode(response.body);
    return ScanResult.fromJson(body);
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  // TODO: Settings
                },
              )),
        ],
      ),
      body: const ScanOptions(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // TODO: Disable button
          final optionsProvider = context.read<OptionsProvider?>();
          // TODO: Toast message with result
          await _scan(optionsProvider);
        },
        enableFeedback: true,
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scan'),
        extendedIconLabelSpacing: 8.0,
      ),
    );
  }
}
