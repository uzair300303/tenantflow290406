import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tenantflow/pages/auth_page.dart';
import 'package:provider/provider.dart';
import 'package:tenantflow/pages/tenant_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme(bool value) {
    setState(() => _isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel(_isDarkMode, toggleTheme)),
        ChangeNotifierProvider(create: (_) => TenantProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TenantFlow',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.blue.shade50,
          textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.grey[850],
          textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
        ),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: AuthPage(),
      ),
    );
  }
}

class ThemeModel with ChangeNotifier {
  bool _isDarkMode;
  final Function(bool) toggleTheme;

  ThemeModel(this._isDarkMode, this.toggleTheme);

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    toggleTheme(value);
    notifyListeners();
  }
}