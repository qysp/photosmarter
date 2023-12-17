import 'package:flutter/material.dart';
import 'package:photosmarter/pages/home.dart';
import 'package:photosmarter/providers/options_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => OptionsProvider()),
        ],
        child: MaterialApp(
          title: 'Photosmarter',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.amber, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          home: const HomePage(title: 'Photosmarter'),
          debugShowCheckedModeBanner: false,
        ));
  }
}
