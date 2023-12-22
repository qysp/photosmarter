import 'package:flutter/material.dart';
import 'package:photosmarter/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _baseUrlTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    _baseUrlTextController.text = settingsProvider.baseUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        scrolledUnderElevation: 3.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _baseUrlTextController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Server address'),
              keyboardType: TextInputType.url,
              onChanged: (value) {
                settingsProvider.baseUrl = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
