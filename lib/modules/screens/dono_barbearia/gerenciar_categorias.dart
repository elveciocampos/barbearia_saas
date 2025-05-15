import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerenciarCategoriasScreen extends StatefulWidget {
  const GerenciarCategoriasScreen({super.key});

  @override
  _GerenciarCategoriasScreenState createState() =>
      _GerenciarCategoriasScreenState();
}

class _GerenciarCategoriasScreenState extends State<GerenciarCategoriasScreen> {
  List<String> categorias = [];
  String?
  barbeariaId; // Este valor precisa ser obtido de algum lugar, talvez da tela anterior ou via autenticação

  @override
  void initState() {
    super.initState();
    // Defina o barbeariaId aqui ou obtenha via autenticação, etc.
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    if (barbeariaId == null) {
      // Pode adicionar uma lógica de erro aqui se o barbeariaId for nulo
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('barbearias')
            .doc(barbeariaId)
            .collection('categorias')
            .get();

    setState(() {
      categorias =
          snapshot.docs.map((doc) => doc['nome'] as String).toList()..sort();
    });
  }

  Future<void> _adicionarCategoria(String nome) async {
    if (barbeariaId == null) {
      // Lógica para erro se barbeariaId for nulo
      return;
    }

    final categoriaRef = FirebaseFirestore.instance
        .collection('barbearias')
        .doc(barbeariaId)
        .collection('categorias');

    await categoriaRef.add({'nome': nome});
    await _loadCategorias();
  }

  Future<void> _excluirCategoria(String nome) async {
    if (barbeariaId == null) {
      // Lógica para erro se barbeariaId for nulo
      return;
    }

    final categoriaRef = FirebaseFirestore.instance
        .collection('barbearias')
        .doc(barbeariaId)
        .collection('categorias');

    final categoriaDoc =
        await categoriaRef.where('nome', isEqualTo: nome).get();
    for (var doc in categoriaDoc.docs) {
      await doc.reference.delete();
    }

    await _loadCategorias();
  }

  void _abrirModalNovaCategoria() {
    final nomeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[100],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Adicionar Nova Categoria',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nomeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Categoria',
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final nome = nomeCtrl.text.trim();
                    if (nome.isEmpty || categorias.contains(nome)) return;

                    await _adicionarCategoria(nome);
                    nomeCtrl.clear(); // Limpa o campo após adicionar
                    Navigator.pop(context);
                  },
                  child: const Text('Adicionar Categoria'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        backgroundColor: Colors.black87,
      ),
      body:
          categorias.isEmpty
              ? const Center(child: Text('Nenhuma categoria cadastrada.'))
              : ListView.builder(
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final categoria = categorias[index];
                  return ListTile(
                    title: Text(categoria),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Excluir Categoria'),
                                content: const Text(
                                  'Tem certeza que deseja excluir esta categoria?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          await _excluirCategoria(categoria);
                        }
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirModalNovaCategoria,
        icon: const Icon(Icons.add),
        label: const Text('Nova Categoria'),
        backgroundColor: Colors.black87,
      ),
    );
  }
}
