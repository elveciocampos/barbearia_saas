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
  final _formKey = GlobalKey<FormState>();
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
    if (user != null && mounted) {
      setState(() {
        barbeariaId = user.uid;
      });
    }
  }

  Future<void> _salvarCategoria() async {
    if (!_formKey.currentState!.validate()) return;
    if (barbeariaId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Barbearia não encontrada')));
      return;
    }

    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();

    try {
      await _firestore.collection('categorias').add({
        'nome': nome,
        'descricao': descricao,
        'barbeariaId': barbeariaId,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Categoria "$nome" criada com sucesso!')),
      );

      _nomeController.clear();
      _descricaoController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar categoria: $e')));
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Categoria',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe o nome'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe a descrição'
                            : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvarCategoria,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Salvar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
