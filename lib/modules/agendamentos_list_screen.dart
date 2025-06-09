import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgendamentosListScreen extends StatelessWidget {
  final String barbeiroId;

  const AgendamentosListScreen({super.key, required this.barbeiroId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('agendamentos')
              .where('barbeiroId', isEqualTo: barbeiroId) // Filtro por barbeiro
              .orderBy('data')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar agendamentos.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum agendamento encontrado.'));
        }

        final agendamentos = snapshot.data!.docs;

        return ListView.builder(
          itemCount: agendamentos.length,
          itemBuilder: (context, index) {
            var agendamento = agendamentos[index];
            return ListTile(
              title: Text(agendamento['cliente']),
              subtitle: Text(
                '${agendamento['servico']} - ${agendamento['hora']}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('agendamentos')
                      .doc(agendamento.id)
                      .delete();
                },
              ),
            );
          },
        );
      },
    );
  }
}
