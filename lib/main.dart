import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'splash_screen.dart';
import 'modules/auth/presentation/login_screen.dart';
import 'modules/auth/presentation/signup_screen.dart';
import 'modules/appointment/appointment_screen.dart';
import 'modules/screens/clientes/cliente_home_screen.dart';
import 'modules/screens/barbeiro/barbeiro_home_screen.dart';
import 'modules/screens/dono_barbearia/dono_barbearia_home_screen.dart';
import 'modules/select_user_type_screen.dart';
import 'modules/cadastro_barbearia_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Erro ao inicializar o Firebase: $e");
  }

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
        '/signup': (context) => const SignupScreen(),
        '/appointment': (context) => const AppointmentScreen(),
        '/cliente': (context) => const ClienteHomeScreen(),
        '/barbeiro': (context) => const BarbeiroHomeScreen(),
        '/dono': (context) => const DonoBarbeariaHomeScreen(),
        '/user_type': (context) => const UserTypeScreen(),
        '/cadastro_barbearia': (context) => const CadastroBarbeariaScreen(),
      },
    );
  }
}
