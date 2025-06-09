import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DevTestScreen extends StatelessWidget {
  const DevTestScreen({super.key});

  Future<void> popularDados(BuildContext context) async {
    final usersRef = FirebaseFirestore.instance.collection('users');

    try {
      await usersRef.doc('usuario_teste').set({
        'nome': 'João da Silva',
        'email': 'joao@email.com',
        'tipo': 'usuario',
      });

      await usersRef.doc('admin_teste').set({
        'nome': 'Maria Admin',
        'email': 'admin@email.com',
        'tipo': 'admin',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Dados populados com sucesso!')),
        );
      }
    } catch (e, stack) {
      debugPrint('Erro ao popular dados: $e');
      debugPrint('Stack: $stack');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao popular dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tela de Testes')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Popular dados no Firestore'),
          onPressed: () async => await popularDados(context),
        ),
      ),
    );
  }
}
