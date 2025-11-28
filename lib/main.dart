import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/welcome_screen.dart';
import 'Screens/navigationscreens/notification_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // If Firebase initialization fails, log and continue — Firestore calls will fail until fixed.
    // Ensure your platform firebase config files (google-services.json / GoogleService-Info.plist)
    // or generated firebase_options.dart are present.
    debugPrint('Firebase initializeApp error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF648DDB), // highlight color
          primary: const Color(0xFF648DDB),
          secondary: Colors.red,
          background: Colors.white,
        ),
        useMaterial3: false,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF648DDB),
            shadowColor: Colors.black26,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        ),
      ),

      // define initial route and routes
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/notifications': (context) => const NotificationScreen(),
      },

      // If you prefer to start directly on another screen, just change `initialRoute`
      // or comment it out and use `home:` instead.
    );
  }
}
