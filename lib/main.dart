import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_fall_2024_0/firebase_options.dart';
import 'package:todo_fall_2024_0/screen/router/router_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Default theme is BlueGrey
  ThemeData _currentTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  // Define multiple themes
  final Map<String, ThemeData> _themes = {
    'BlueGrey': ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    ),
    'Pink': ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.pink,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    ),
    'Green': ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO Fall 2024',
      theme: _currentTheme,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TODO Fall 2024'),
          actions: [
            // Dropdown menu to select a theme
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                icon: const Icon(Icons.color_lens), // Display a theme icon
                hint: const Text("Theme"), // Label before selection
                onChanged: (String? newTheme) {
                  if (newTheme != null) {
                    setState(() {
                      _currentTheme = _themes[newTheme]!;
                    });
                  }
                },
                items: _themes.keys.map((String themeName) {
                  return DropdownMenuItem<String>(
                    value: themeName,
                    child: Text(themeName),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        body: const RouterScreen(),
      ),
    );
  }
}
