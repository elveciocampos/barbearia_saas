import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PopulateFirestoreScreen extends StatelessWidget {
  const PopulateFirestoreScreen({super.key});

  Future<void> _addMockBarbeiros() async {
    final barbeiros = [
      {
        'nome': 'João Barbeiro',
        'especialidades': ['Corte Social', 'Barba', 'Sobrancelha'],
        'foto_url': 'https://i.pravatar.cc/150?img=1',
        'ativo': true,
      },
      {
        'nome': 'Carlos Fade',
        'especialidades': ['Corte Degradê', 'Pigmentação'],
        'foto_url': 'https://i.pravatar.cc/150?img=2',
        'ativo': true,
      },
      {
        'nome': 'Pedro Tesoura',
        'especialidades': ['Corte Navalhado', 'Corte Infantil'],
        'foto_url': 'https://i.pravatar.cc/150?img=3',
        'ativo': true,
      },
    ];

    for (var barbeiro in barbeiros) {
      await FirebaseFirestore.instance.collection('barbeiros').add(barbeiro);
    }

    debugPrint('Barbeiros mockados adicionados com sucesso!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Firestore')),
      body: Center(
        child: ElevatedButton(
          onPressed: _addMockBarbeiros,
          child: const Text('Adicionar barbeiros mockados'),
        ),
      ),
    );
  }
}
