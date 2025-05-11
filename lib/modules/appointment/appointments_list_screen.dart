import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentsListScreen extends StatelessWidget {
  const AppointmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Agendamentos')),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('agendamentos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar agendamentos'));
          }

          final agendamentos = snapshot.data!.docs;
          return ListView.builder(
            itemCount: agendamentos.length,
            itemBuilder: (context, index) {
              final agendamento = agendamentos[index];
              return ListTile(
                title: Text(agendamento['data_hora']),
                subtitle: Text(agendamento['uid_barbeiro']),
              );
            },
          );
        },
      ),
    );
  }
}
