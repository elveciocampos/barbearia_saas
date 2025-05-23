import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdicionarCategoriaScreen extends StatefulWidget {
  const AdicionarCategoriaScreen({super.key});

  @override
  State<AdicionarCategoriaScreen> createState() =>
      _AdicionarCategoriaScreenState();
}

class _AdicionarCategoriaScreenState extends State<AdicionarCategoriaScreen> {
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? barbeariaId;

  @override
  void initState() {
    super.initState();
    _getBarbeariaId();
  }

  Future<void> _getBarbeariaId() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        barbeariaId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Categoria'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Categoria'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final nome = _nomeController.text.trim();
                final descricao = _descricaoController.text.trim();

                if (nome.isNotEmpty &&
                    descricao.isNotEmpty &&
                    barbeariaId != null) {
                  await _firestore.collection('categorias').add({
                    'nome': nome,
                    'descricao': descricao,
                    'barbeariaId': barbeariaId,
                    'criadoEm': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Categoria "$nome" criada com sucesso!'),
                    ),
                  );

                  _nomeController.clear();
                  _descricaoController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, preencha todos os campos'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
              child: const Text('Salvar'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Categorias Cadastradas:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  barbeariaId == null
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder<QuerySnapshot>(
                        stream:
                            _firestore
                                .collection('categorias')
                                .where('barbeariaId', isEqualTo: barbeariaId)
                                .orderBy('criadoEm')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('Nenhuma categoria cadastrada.'),
                            );
                          }

                          final categorias = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: categorias.length,
                            itemBuilder: (context, index) {
                              var categoria =
                                  categorias[index].data()
                                      as Map<String, dynamic>;
                              String nome = categoria['nome'];
                              String descricao = categoria['descricao'];

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(nome),
                                  subtitle: Text(descricao),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (_) => AlertDialog(
                                              title: const Text(
                                                'Excluir Categoria',
                                              ),
                                              content: const Text(
                                                'Tem certeza que deseja excluir esta categoria?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Excluir'),
                                                ),
                                              ],
                                            ),
                                      );

                                      if (confirm == true) {
                                        await _firestore
                                            .collection('categorias')
                                            .doc(categorias[index].id)
                                            .delete();

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Categoria excluída com sucesso!',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
