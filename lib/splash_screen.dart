import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _token; // Variável para armazenar o token

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _printDebugToken();
  }

  Future<void> _printDebugToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken(true);
      debugPrint('🔐 Debug App Check token: $token');
      if (!mounted) return;
      setState(() {
        _token = token;
      });
    } catch (e) {
      debugPrint('Erro ao obter token do App Check: $e');
      if (!mounted) return;
      setState(() {
        _token = 'Erro ao obter token';
      });
    }
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Simula splash/loading

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {
      // Usuário não autenticado — vai para login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Usuário autenticado — busca tipo no Firestore
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!mounted) return;

    if (!userDoc.exists) {
      // Usuário autenticado mas sem documento — manda para login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final userData = userDoc.data();
    final userType = userData?['userType'];

    if (userType == 'barbeiro') {
      Navigator.pushReplacementNamed(context, '/barbeiro');
    } else if (userType == 'cliente') {
      Navigator.pushReplacementNamed(context, '/cliente');
    } else if (userType == 'dono') {
      Navigator.pushReplacementNamed(context, '/dono');
    } else {
      Navigator.pushReplacementNamed(context, '/user_type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            if (_token != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '🔐 Debug App Check token:\n$_token',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
