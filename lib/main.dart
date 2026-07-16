import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart'; // Jalur import ke splash screen
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found. Please create one based on .env.example");
  }

  await Supabase.initialize(
    url: 'https://mjbpjtwlgwytiolvlkhn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1qYnBqdHdsZ3d5dGlvbHZsa2huIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5Mjg3NzQsImV4cCI6MjA5NTUwNDc3NH0.LO2KtSX2pvrFuQXVw5BPwvsONc0yTmNy-P_EcVcsd90',
  );

  await ThemeProvider().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider().themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Titik Kumpul',
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.light,
              surface: const Color(0xFFF8FAFC),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.dark,
              surface: const Color(0xFF0B101E),
            ),
            scaffoldBackgroundColor: const Color(0xFF0B101E),
          ),
          // 🔥 Pintu masuk pertama langsung ke Splash Screen
          home: const SplashScreen(),
        );
      }
    );
  }
}