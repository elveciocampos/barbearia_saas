import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GerenciarHorariosScreen extends StatelessWidget {
  final String barbeiroUid;

  const GerenciarHorariosScreen({super.key, required this.barbeiroUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horários do Barbeiro')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(barbeiroUid)
                .collection('horarios')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum horário encontrado.'));
          }

          final horarios = snapshot.data!.docs;

          return ListView.builder(
            itemCount: horarios.length,
            itemBuilder: (context, index) {
              final horario = horarios[index];
              final horarioId = horario.id;
              final dia = horario['dia'];
              final inicio = horario['inicio'];
              final fim = horario['fim'];

              return ListTile(
                title: Text('$dia: $inicio - $fim'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _mostrarDialogoEdicao(
                          context,
                          horarioId,
                          dia,
                          inicio,
                          fim,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(barbeiroUid)
                            .collection('horarios')
                            .doc(horarioId)
                            .delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDialogoEdicao(
    BuildContext context,
    String horarioId,
    String dia,
    String inicio,
    String fim,
  ) {
    final inicioController = TextEditingController(text: inicio);
    final fimController = TextEditingController(text: fim);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Editar horário - $dia'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: inicioController,
                  decoration: const InputDecoration(labelText: 'Início'),
                ),
                TextField(
                  controller: fimController,
                  decoration: const InputDecoration(labelText: 'Fim'),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Salvar'),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(barbeiroUid)
                      .collection('horarios')
                      .doc(horarioId)
                      .update({
                        'inicio': inicioController.text,
                        'fim': fimController.text,
                      });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }
}
