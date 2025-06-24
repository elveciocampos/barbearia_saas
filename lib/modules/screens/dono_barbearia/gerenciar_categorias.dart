import 'package:barbearia_saas/modules/screens/dono_barbearia/adicionar_categorias_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerenciarCategoriasScreen extends StatelessWidget {
  const GerenciarCategoriasScreen({super.key}); // ✅ Construtor restaurado

  void _confirmarExclusao(BuildContext context, String categoriaId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Excluir categoria'),
            content: const Text(
              'Tem certeza que deseja excluir esta categoria?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('categorias')
                      .doc(categoriaId)
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

  void _navegarParaEditar(BuildContext context, String categoriaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarCategoriaScreen(categoriaId: categoriaId),
      ),
    );
  }

  void _navegarParaAdicionar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdicionarCategoriaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriasRef = FirebaseFirestore.instance.collection('categorias');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        backgroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoriasRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categorias = snapshot.data?.docs ?? [];

          if (categorias.isEmpty) {
            return const Center(child: Text('Nenhuma categoria cadastrada.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categorias.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = categorias[index];
              final dados = doc.data() as Map<String, dynamic>;
              final nome = dados['nome'] ?? 'Sem nome';
              final categoriaId = doc.id;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(nome),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed:
                            () => _navegarParaEditar(context, categoriaId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => _confirmarExclusao(context, categoriaId),
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
        onPressed: () => _navegarParaAdicionar(context),
      ),
    );
  }
}
