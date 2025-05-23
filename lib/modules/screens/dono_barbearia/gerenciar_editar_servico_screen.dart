import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdicionarEditarServicoScreen extends StatefulWidget {
  final String barbeariaId;
  final String? servicoId; // se nulo, é adicionar, senão editar
  final Map<String, dynamic>? servicoData;

  const AdicionarEditarServicoScreen({
    super.key,
    required this.barbeariaId,
    this.servicoId,
    this.servicoData,
  });

  @override
  State<AdicionarEditarServicoScreen> createState() =>
      _AdicionarEditarServicoScreenState();
}

class _AdicionarEditarServicoScreenState
    extends State<AdicionarEditarServicoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _precoController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.servicoData?['nome'] ?? '',
    );
    _precoController = TextEditingController(
      text:
          widget.servicoData?['preco'] != null
              ? widget.servicoData!['preco'].toString()
              : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;

    final nome = _nomeController.text.trim();
    final preco = double.tryParse(_precoController.text.trim()) ?? 0.0;

    final servicosCollection = FirebaseFirestore.instance
        .collection('barbearias')
        .doc(widget.barbeariaId)
        .collection('servicos');

    try {
      if (widget.servicoId == null) {
        // adicionar novo serviço
        await servicosCollection.add({'nome': nome, 'preco': preco});
      } else {
        // editar serviço existente
        await servicosCollection.doc(widget.servicoId).update({
          'nome': nome,
          'preco': preco,
        });
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar serviço: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.servicoId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Serviço' : 'Adicionar Serviço'),
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
                decoration: const InputDecoration(labelText: 'Nome do Serviço'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do serviço';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o preço';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Informe um valor numérico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarServico,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                ),
                child: Text(
                  isEditing ? 'Salvar Alterações' : 'Adicionar Serviço',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
