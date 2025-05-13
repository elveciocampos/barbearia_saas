import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserTypeScreen extends StatefulWidget {
  const UserTypeScreen({super.key});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  bool _loading = false;

  Future<void> _setUserType(String type) async {
    setState(() {
      _loading = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Usuário não autenticado, vai para cadastro com o tipo
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/signup', arguments: type);
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      await userDocRef.update({'userType': type});

      if (!mounted) return;

      if (type == 'barbeiro') {
        Navigator.pushReplacementNamed(context, '/barbeiro_home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao definir tipo de usuário: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha seu tipo de usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _loading
                ? const CircularProgressIndicator()
                : Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _setUserType('barbeiro'),
                      child: const Text('Sou Barbeiro'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _setUserType('cliente'),
                      child: const Text('Sou Cliente'),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
