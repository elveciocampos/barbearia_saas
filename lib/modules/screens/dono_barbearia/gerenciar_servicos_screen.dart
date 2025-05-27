import 'package:barbearia_saas/modules/screens/dono_barbearia/adicionar_servico_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerenciarServicosScreen extends StatelessWidget {
  final String barbeariaId;

  const GerenciarServicosScreen({super.key, required this.barbeariaId});

  @override
  Widget build(BuildContext context) {
    final servicosRef = FirebaseFirestore.instance
        .collection('barbearias')
        .doc(barbeariaId)
        .collection('servicos');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços cadastrados'),
        backgroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: servicosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final servicos = snapshot.data?.docs ?? [];

          if (servicos.isEmpty) {
            return const Center(child: Text('Nenhum serviço cadastrado.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: servicos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final dados = servicos[index].data() as Map<String, dynamic>;
              final nome = dados['nome'] ?? 'Sem nome';
              final preco = (dados['preco'] ?? 0).toDouble();
              final categoriaId = dados['categoria'] ?? '';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    categoriaId.isNotEmpty
                        ? FutureBuilder<DocumentSnapshot>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('categorias')
                                  .doc(categoriaId)
                                  .get(),
                          builder: (context, catSnapshot) {
                            String nomeCategoria = 'Categoria não encontrada';
                            if (catSnapshot.connectionState ==
                                    ConnectionState.done &&
                                catSnapshot.hasData &&
                                catSnapshot.data!.exists) {
                              final catData =
                                  catSnapshot.data!.data()
                                      as Map<String, dynamic>;
                              nomeCategoria = catData['nome'] ?? 'Sem nome';
                            }

                            return ListTile(
                              title: Text(nome),
                              subtitle: Text(
                                'Categoria: $nomeCategoria\nPreço: R\$ ${preco.toStringAsFixed(2)}',
                              ),
                              isThreeLine: true,
                            );
                          },
                        )
                        : ListTile(
                          title: Text(nome),
                          subtitle: Text(
                            'Categoria: (não definida)\nPreço: R\$ ${preco.toStringAsFixed(2)}',
                          ),
                          isThreeLine: true,
                        ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AdicionarServicoScreen(barbeariaId: barbeariaId),
            ),
          );
        },
      ),
    );
  }
}
