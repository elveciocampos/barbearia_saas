import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdicionarServicoScreen extends StatefulWidget {
  final String barbeariaId;
  final String? servicoId; // ← novo parâmetro

  const AdicionarServicoScreen({
    super.key,
    required this.barbeariaId,
    this.servicoId,
  });

  @override
  State<AdicionarServicoScreen> createState() => _AdicionarServicoScreenState();
}

class _AdicionarServicoScreenState extends State<AdicionarServicoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();

  String? _categoriaSelecionada;
  bool _isSalvando = false;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    if (widget.servicoId != null) {
      _carregarServico();
    }
  }

  Future<void> _carregarServico() async {
    setState(() => _carregando = true);
    final doc =
        await FirebaseFirestore.instance
            .collection('barbearias')
            .doc(widget.barbeariaId)
            .collection('servicos')
            .doc(widget.servicoId)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nomeController.text = data['nome'] ?? '';
      _descricaoController.text = data['descricao'] ?? '';
      _precoController.text = (data['preco'] ?? '').toString();
      _categoriaSelecionada = data['categoria'];
    }

    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria')),
      );
      return;
    }

    setState(() => _isSalvando = true);

    try {
      final preco =
          double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0;

      final dados = {
        'nome': _nomeController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'preco': preco,
        'categoria': _categoriaSelecionada,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final ref = FirebaseFirestore.instance
          .collection('barbearias')
          .doc(widget.barbeariaId)
          .collection('servicos');

      if (widget.servicoId == null) {
        dados['createdAt'] = FieldValue.serverTimestamp();
        await ref.add(dados);
      } else {
        await ref.doc(widget.servicoId).update(dados);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.servicoId == null
                ? 'Serviço adicionado com sucesso!'
                : 'Serviço atualizado com sucesso!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar serviço: $e')));
    } finally {
      if (mounted) setState(() => _isSalvando = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriasRef = FirebaseFirestore.instance.collection('categorias');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.servicoId == null ? 'Adicionar Serviço' : 'Editar Serviço',
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
                          labelText: 'Nome do serviço',
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _precoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Preço (R\$)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Informe o preço';
                          final preco = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          if (preco == null) return 'Preço inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: categoriasRef.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Erro ao carregar categorias: ${snapshot.error}',
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final categorias = snapshot.data!.docs;

                          if (categorias.isEmpty) {
                            return const Text('Nenhuma categoria cadastrada.');
                          }

                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Categoria',
                              border: OutlineInputBorder(),
                            ),
                            value: _categoriaSelecionada,
                            items:
                                categorias.map((cat) {
                                  final catData =
                                      cat.data() as Map<String, dynamic>;
                                  final nome = catData['nome'] ?? 'Sem nome';
                                  return DropdownMenuItem<String>(
                                    value: cat.id,
                                    child: Text(nome),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              setState(() => _categoriaSelecionada = val);
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Selecione uma categoria'
                                        : null,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSalvando ? null : _salvarServico,
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
                                  widget.servicoId == null
                                      ? 'Salvar Serviço'
                                      : 'Atualizar Serviço',
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
