import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dono_editar_perfil_screen.dart'; // Importando a tela de editar perfil

class PerfileScreen extends StatefulWidget {
  const PerfileScreen({super.key});

  @override
  State<PerfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<PerfileScreen> {
  String? _displayName;
  String? _email;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    // Carregar as informações do usuário (exemplo de carregamento)
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Supondo que você tem a lógica para carregar os dados do usuário
    final user = FirebaseAuth.instance.currentUser;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _displayName = data['nome'] ?? 'Sem nome';
        _email = user.email ?? 'Sem e-mail';
        _photoUrl =
            data['profile_picture'] ??
            'https://res.cloudinary.com/dpouccu9n/image/upload/v1746906475/cat_ujdoeu.png';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  _photoUrl != null && _photoUrl!.isNotEmpty
                      ? NetworkImage(_photoUrl!)
                      : const AssetImage('assets/placeholder.png')
                          as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text('Nome: $_displayName'),
            Text('E-mail: $_email'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navegação local para a tela de editar perfil
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditarPerfilScreen(),
                  ),
                ); // Navega para tela de edição de perfil
              },
              child: const Text('Editar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
