import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BarbeiroSelecionarServicos extends StatefulWidget {
  const BarbeiroSelecionarServicos({super.key});

  @override
  State<BarbeiroSelecionarServicos> createState() =>
      _BarbeiroSelecionarServicosState();
}

class _BarbeiroSelecionarServicosState
    extends State<BarbeiroSelecionarServicos> {
  String? barbeariaId;
  String? barbeiroId;
  bool _carregando = true;
  final Set<String> _servicosSelecionados = {};
  final Set<String> _servicosOriginais = {};
  final Map<String, String> _categoriasCache = {};

  @override
  void initState() {
    super.initState();
    _carregarBarbeariaId();
  }

  Future<void> _carregarBarbeariaId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final data = userDoc.data();

    if (data != null && data['barbeariaId'] != null) {
      barbeiroId = user.uid;
      barbeariaId = data['barbeariaId'];
      await _carregarServicosSelecionados();
      await _carregarCategorias();
    }

    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _carregarServicosSelecionados() async {
    final query =
        await FirebaseFirestore.instance
            .collection('barbeiro_servicos')
            .where('barbeiroId', isEqualTo: barbeiroId)
            .get();

    for (var doc in query.docs) {
      final id = doc['servicoId'];
      _servicosSelecionados.add(id);
      _servicosOriginais.add(id);
    }
  }

  Future<void> _carregarCategorias() async {
    final servicosSnapshot =
        await FirebaseFirestore.instance
            .collection('servicos')
            .where('barbeariaId', isEqualTo: barbeariaId)
            .get();

    final categoriaIds =
        servicosSnapshot.docs
            .map((doc) => (doc.data()['categoria'] ?? ''))
            .whereType<String>()
            .toSet()
            .toList();

    if (categoriaIds.isEmpty) return;

    final catSnapshot =
        await FirebaseFirestore.instance
            .collection('categorias')
            .where(FieldPath.documentId, whereIn: categoriaIds)
            .get();

    for (var doc in catSnapshot.docs) {
      _categoriasCache[doc.id] = doc.data()['nome'] ?? 'Sem categoria';
    }
  }

  Future<void> _salvarServicos() async {
    final ref = FirebaseFirestore.instance.collection('barbeiro_servicos');

    final toRemove = _servicosOriginais.difference(_servicosSelecionados);
    final toAdd = _servicosSelecionados.difference(_servicosOriginais);

    for (var id in toRemove) {
      final snapshot =
          await ref
              .where('barbeiroId', isEqualTo: barbeiroId)
              .where('servicoId', isEqualTo: id)
              .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }

    for (var id in toAdd) {
      await ref.add({
        'barbeiroId': barbeiroId,
        'servicoId': id,
        'barbeariaId': barbeariaId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    _servicosOriginais
      ..clear()
      ..addAll(_servicosSelecionados);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviços atualizados com sucesso!')),
      );
    }
  }

  Future<void> _sugerirNovoServico() async {
    final nomeCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Sugerir Novo Serviço'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome do serviço'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Enviar'),
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance
                    .collection('sugestoes_servicos')
                    .add({
                      'barbeiroId': barbeiroId,
                      'barbeariaId': barbeariaId,
                      'nome': nomeCtrl.text.trim(),
                      'descricao': descCtrl.text.trim(),
                      'status': 'pendente',
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sugestão enviada com sucesso!'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (barbeariaId == null) {
      return const Scaffold(
        body: Center(child: Text('Erro ao carregar barbearia.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Serviços'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _sugerirNovoServico,
            tooltip: 'Sugerir novo serviço',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('servicos')
                      .where('barbeariaId', isEqualTo: barbeariaId)
                      .orderBy('nome')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar serviços.'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final servicos = snapshot.data?.docs ?? [];

                if (servicos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum serviço encontrado.'),
                  );
                }

                return ListView.builder(
                  itemCount: servicos.length,
                  itemBuilder: (context, index) {
                    final doc = servicos[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final nome = data['nome'] ?? '';
                    final descricao = data['descricao'] ?? '';
                    final preco =
                        (data['preco'] is num)
                            ? (data['preco'] as num).toStringAsFixed(2)
                            : '0.00';
                    final categoriaId = data['categoria'];
                    final selecionado = _servicosSelecionados.contains(doc.id);
                    final nomeCategoria =
                        _categoriasCache[categoriaId] ?? 'Sem categoria';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: CheckboxListTile(
                        value: selecionado,
                        isThreeLine: true,
                        title: Text(nome),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(descricao),
                            const SizedBox(height: 4),
                            Text('Categoria: $nomeCategoria'),
                            Text(
                              'R\$ $preco',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val!) {
                              _servicosSelecionados.add(doc.id);
                            } else {
                              _servicosSelecionados.remove(doc.id);
                            }
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _salvarServicos,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Alterações'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
