import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgendamentosTab extends StatelessWidget {
  const AgendamentosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('Usuário não autenticado.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('agendamentos')
              .where('clienteId', isEqualTo: uid)
              .orderBy('data', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final agendamentos = snapshot.data?.docs ?? [];

        if (agendamentos.isEmpty) {
          return const Center(
            child: Text('Você ainda não fez nenhum agendamento.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: agendamentos.length,
          itemBuilder: (context, index) {
            final data = agendamentos[index].data() as Map<String, dynamic>;
            final nomeServico = data['servico'] ?? 'Serviço';
            final nomeBarbeiro = data['barbeiro'] ?? 'Barbeiro';
            final dataHora = data['data']?.toDate();

            final dataFormatada =
                dataHora != null
                    ? '${dataHora.day}/${dataHora.month}/${dataHora.year} às ${dataHora.hour}:${dataHora.minute.toString().padLeft(2, '0')}'
                    : 'Sem data';

            return Card(
              child: ListTile(
                title: Text(nomeServico),
                subtitle: Text('$nomeBarbeiro\n$dataFormatada'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
