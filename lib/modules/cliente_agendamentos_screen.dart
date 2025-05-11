import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteAgendamentosScreen extends StatelessWidget {
  const ClienteAgendamentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String barbeariaId =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('agendamentos')
                .where('barbeariaId', isEqualTo: barbeariaId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar agendamentos.'));
          }

          final agendamentos = snapshot.data!.docs;

          if (agendamentos.isEmpty) {
            return const Center(child: Text('Nenhum agendamento encontrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: agendamentos.length,
            itemBuilder: (context, index) {
              final doc = agendamentos[index];
              final data = doc.data() as Map<String, dynamic>;

              final tipoServico = data['tipoServico'] ?? 'Sem serviço';
              final horario = (data['horario'] as Timestamp).toDate();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipoServico,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Horário: ${horario.toString()}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
