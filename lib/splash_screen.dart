import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Simula carregamento

    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
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
      } else {
        // Usuário logado, mas sem documento no Firestore
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // Usuário não logado
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
