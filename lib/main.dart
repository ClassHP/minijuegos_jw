import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'main_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  final LocalStorage _storage = LocalStorage('main_data');
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeData _theme(Brightness brightness) {
    const MaterialColor primary = Colors.blue;
    const MaterialColor secondary = Colors.purple;
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primary,
        accentColor: secondary,
        brightness: brightness,
        backgroundColor: brightness == Brightness.light ? Colors.white : Colors.grey[800],
      ).copyWith(
        secondary: secondary,
      ),
      appBarTheme: const AppBarTheme(color: primary),
    );
  }

  @override
  void initState() {
    super.initState();
    _storage.ready.then((value) {
      var theme = _storage.getItem('theme');
      if (theme != null) {
        setState(() {
          _themeMode = theme == 0 ? ThemeMode.light : ThemeMode.dark;
        });
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Minijuegos JW',
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark), // standard dark theme
      themeMode: _themeMode, // device controls theme
      routerConfig: MainRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }

  bool _darkModeOn() {
    return Theme.of(context).brightness == Brightness.dark || _themeMode == ThemeMode.dark;
  }

  /// MyApp.of(context).toggleTheme();
  void toggleTheme() {
    setState(() {
      _themeMode = _darkModeOn() ? ThemeMode.light : ThemeMode.dark;
    });
    saveTheme(_themeMode);
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
  }

  saveTheme(ThemeMode mode) {
    _storage.setItem('theme', mode == ThemeMode.light ? 0 : 1);
  }
}
