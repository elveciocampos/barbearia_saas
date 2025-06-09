import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdicionarCategoriaScreen extends StatefulWidget {
  final String? categoriaId;

  const AdicionarCategoriaScreen({super.key, this.categoriaId});

  @override
  State<AdicionarCategoriaScreen> createState() =>
      _AdicionarCategoriaScreenState();
}

class _AdicionarCategoriaScreenState extends State<AdicionarCategoriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();

  bool _isSalvando = false;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoriaId != null) {
      _carregarCategoria();
    }
  }

  Future<void> _carregarCategoria() async {
    setState(() => _carregando = true);

    final doc =
        await FirebaseFirestore.instance
            .collection('categorias')
            .doc(widget.categoriaId)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nomeController.text = data['nome'] ?? '';
    }

    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _salvarCategoria() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSalvando = true);

    try {
      final dados = {
        'nome': _nomeController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final ref = FirebaseFirestore.instance.collection('categorias');

      if (widget.categoriaId == null) {
        dados['createdAt'] = FieldValue.serverTimestamp();
        await ref.add(dados);
      } else {
        await ref.doc(widget.categoriaId).update(dados);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.categoriaId == null
                ? 'Categoria adicionada com sucesso!'
                : 'Categoria atualizada com sucesso!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar categoria: $e')));
    } finally {
      if (mounted) setState(() => _isSalvando = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoriaId == null
              ? 'Adicionar Categoria'
              : 'Editar Categoria',
        ),
        backgroundColor: Colors.black87,
      ),
      body:
          _carregando
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da categoria',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Informe o nome'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSalvando ? null : _salvarCategoria,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:
                            _isSalvando
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  widget.categoriaId == null
                                      ? 'Salvar Categoria'
                                      : 'Atualizar Categoria',
                                  style: const TextStyle(fontSize: 16),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
