import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GerenciarBarbeirosScreen extends StatefulWidget {
  const GerenciarBarbeirosScreen({super.key});

  @override
  State<GerenciarBarbeirosScreen> createState() =>
      _GerenciarBarbeirosScreenState();
}

class _GerenciarBarbeirosScreenState extends State<GerenciarBarbeirosScreen> {
  final _emailController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool _loading = false;

  String get _barbeariaId => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _vincularBarbeiro() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();

    try {
      final query =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado.')),
        );
        return;
      }

      final doc = query.docs.first;
      final uid = doc.id;

      await _firestore.collection('users').doc(uid).update({
        'barbeariaId': _barbeariaId,
        'userType': 'barbeiro',
        'status': 'ativo',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barbeiro vinculado com sucesso!')),
      );
      _emailController.clear();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deletarBarbeiro(String uid) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Excluir Barbeiro'),
              content: const Text(
                'Tem certeza de que deseja excluir este barbeiro?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Excluir'),
                ),
              ],
            ),
      );

      if (confirm == true) {
        await _firestore.collection('users').doc(uid).update({
          'barbeariaId': FieldValue.delete(),
          'userType': FieldValue.delete(),
          'status': FieldValue.delete(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barbeiro excluído com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir barbeiro: $e')));
    }
  }

  Future<void> _alterarStatus(String uid, String novoStatus) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'status': novoStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status alterado para $novoStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao alterar status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Barbeiros')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail do barbeiro',
              ),
            ),
            const SizedBox(height: 12),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _vincularBarbeiro,
                  child: const Text('Vincular Barbeiro'),
                ),
            const SizedBox(height: 24),
            const Text('Barbeiros vinculados:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('users')
                        .where('barbeariaId', isEqualTo: _barbeariaId)
                        .where('userType', isEqualTo: 'barbeiro')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Text('Nenhum barbeiro vinculado.');
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final uid = docs[index].id;
                      final status = data['status'] ?? 'ativo';
                      final nome = data['nome']?.toString().trim();

                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          nome?.isNotEmpty == true
                              ? nome!
                              : '(Sem nome cadastrado)',
                        ),
                        subtitle: Text(data['email'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(status),
                            IconButton(
                              icon: Icon(
                                status == 'ativo'
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color:
                                    status == 'ativo'
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              onPressed: () {
                                final novoStatus =
                                    status == 'ativo' ? 'inativo' : 'ativo';
                                _alterarStatus(uid, novoStatus);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletarBarbeiro(uid),
                            ),
                          ],
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
