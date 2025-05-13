import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../selecionar_barbeiro_horario_screen.dart';

class InicioTab extends StatelessWidget {
  const InicioTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('barbearias').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhuma barbearia encontrada.'));
        }

        final barbearias = snapshot.data!.docs;

        return ListView.builder(
          itemCount: barbearias.length,
          itemBuilder: (context, index) {
            final doc = barbearias[index];
            final data = doc.data() as Map<String, dynamic>;

            final barbeariaId = doc.id;
            final nome = data['nome'] ?? 'Sem nome';
            final endereco = data['endereco'] ?? 'Sem endereço';
            final foto = data['foto'] ?? '';
            final avaliacao = data['avaliacao']?.toDouble() ?? 4.5;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child:
                        foto.isNotEmpty
                            ? Image.network(
                              foto,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              height: 160,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image, size: 50),
                              ),
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          endereco,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Text(avaliacao.toStringAsFixed(1)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SelecionarBarbeiroHorarioScreen(
                                        barbeariaId: barbeariaId,
                                      ),
                                ),
                              );
                            },
                            child: const Text('Agendar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
