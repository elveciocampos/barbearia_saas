import 'package:barbearia_saas/modules/screens/dono_barbearia/gerenciar_editar_servico_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerenciarServicosScreen extends StatefulWidget {
  final String barbeariaId;

  const GerenciarServicosScreen({super.key, required this.barbeariaId});

  @override
  State<GerenciarServicosScreen> createState() =>
      _GerenciarServicosScreenState();
}

class _GerenciarServicosScreenState extends State<GerenciarServicosScreen> {
  @override
  Widget build(BuildContext context) {
    final servicosCollection = FirebaseFirestore.instance
        .collection('barbearias')
        .doc(widget.barbeariaId)
        .collection('servicos');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Serviços'),
        backgroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: servicosCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final servicosDocs = snapshot.data?.docs ?? [];

          if (servicosDocs.isEmpty) {
            return const Center(child: Text('Nenhum serviço cadastrado.'));
          }

          return ListView.builder(
            itemCount: servicosDocs.length,
            itemBuilder: (context, index) {
              final servico = servicosDocs[index];
              final data = servico.data() as Map<String, dynamic>;

              final nome = data['nome'] ?? '';
              final preco = data['preco'] ?? 0.0;

              return ListTile(
                title: Text(nome),
                subtitle: Text('R\$ ${preco.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AdicionarEditarServicoScreen(
                            barbeariaId: widget.barbeariaId,
                            servicoId: servico.id,
                            servicoData: data,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AdicionarEditarServicoScreen(
                    barbeariaId: widget.barbeariaId,
                  ),
            ),
          );
        },
      ),
    );
  }
}
