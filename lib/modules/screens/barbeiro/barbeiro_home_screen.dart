import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BarbeiroHomeScreen extends StatefulWidget {
  const BarbeiroHomeScreen({super.key});

  @override
  State<BarbeiroHomeScreen> createState() => _BarbeiroHomeScreenState();
}

class _BarbeiroHomeScreenState extends State<BarbeiroHomeScreen> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Barbeiro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: const Center(child: Text('Bem-vindo, Barbeiro!')),
    );
  }
}
