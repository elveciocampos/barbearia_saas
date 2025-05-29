import 'package:barbearia_saas/modules/screens/dono_barbearia/adicionar_categorias_screen.dart';
import 'package:barbearia_saas/modules/screens/dono_barbearia/adicionar_servico_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerenciarServicosScreen extends StatelessWidget {
  final String barbeariaId;

  const GerenciarServicosScreen({super.key, required this.barbeariaId});

  void _confirmarExclusao(BuildContext context, String servicoId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Excluir serviço'),
            content: const Text('Tem certeza que deseja excluir este serviço?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('barbearias')
                      .doc(barbeariaId)
                      .collection('servicos')
                      .doc(servicoId)
                      .delete();
                },
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Adicionar Categoria',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdicionarCategoriaScreen(),
                ),
              );
            },
          ),
        ],
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

          return ListView.builder(
            itemCount: servicos.length,
            itemBuilder: (context, index) {
              final doc = servicos[index];
              final dados = doc.data() as Map<String, dynamic>;
              final nome = dados['nome'] ?? 'Sem nome';
              final preco = dados['preco'] ?? 0.0;
              final categoria = dados['categoria'] ?? '';
              final servicoId = doc.id;

              return Card(
                child: ListTile(
                  title: Text(nome),
                  subtitle: Text(
                    'Preço: R\$ ${preco.toStringAsFixed(2)}\nCategoria: $categoria',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AdicionarServicoScreen(
                                    barbeariaId: barbeariaId,
                                    servicoId: servicoId,
                                  ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarExclusao(context, servicoId),
                      ),
                    ],
                  ),
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
