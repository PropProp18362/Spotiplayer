import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'screens/main_screen.dart';
import 'screens/auth_callback_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ensure window manager is initialized for desktop
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
  }
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const SpotiVisualizerApp());
}

class SpotiVisualizerApp extends StatelessWidget {
  const SpotiVisualizerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotiVisualizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.blue,
          inactiveTrackColor: Colors.white.withOpacity(0.3),
          thumbColor: Colors.white,
          overlayColor: Colors.blue.withOpacity(0.2),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.white54;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.blue;
            }
            return Colors.white.withOpacity(0.2);
          }),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.blue,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/auth/callback') == true) {
          // Parse query parameters from the URL
          final uri = Uri.parse(settings.name!);
          final code = uri.queryParameters['code'];
          final error = uri.queryParameters['error'];
          final state = uri.queryParameters['state'];
          
          return MaterialPageRoute(
            builder: (context) => AuthCallbackScreen(
              code: code,
              error: error,
              state: state,
            ),
          );
        }
        
        // Default route
        return MaterialPageRoute(
          builder: (context) => const MainScreen(),
        );
      },
      routes: {
        '/': (context) => const MainScreen(),
      },
    );
  }
}