import 'package:barbearia_saas/modules/screens/barbeiro/barbeiro_dashboard_content.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // <-- Import adicionado
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'splash_screen.dart';
import 'modules/auth/presentation/login_screen.dart';
import 'modules/auth/presentation/signup_screen.dart';
import 'modules/appointment/appointment_screen.dart';
import 'modules/screens/clientes/cliente_home_screen.dart';
import 'modules/screens/dono_barbearia/dono_barbearia_dashboard.dart';
import 'modules/cadastro_barbearia_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (!e.toString().contains(
      'A Firebase App named "[DEFAULT]" already exists',
    )) {
      rethrow;
    }
  }

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF3B82F6),
        secondary: const Color(0xFF64748B),
        surface: const Color(0xFF1E1E1E),
        error: Colors.redAccent,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );

    return MaterialApp(
      title: 'Barbearia SaaS',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/appointment': (context) => const AppointmentScreen(),
        '/cliente': (context) => const ClienteHomeScreen(),
        '/barbeiro': (context) => const BarbeiroDashboardContent(),
        '/dono': (context) => const DonoBarbeariaDashboard(),
        '/cadastro_barbearia': (context) => const CadastroBarbeariaScreen(),
      },
    );
  }
}
