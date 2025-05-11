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
      // Buscar usuário por e-mail
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

      // Atualiza o barbeiro com o ID da barbearia e o status
      await _firestore.collection('users').doc(uid).update({
        'barbeariaId': _barbeariaId,
        'userType': 'barbeiro',
        'status': 'ativo', // Adiciona o campo de status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barbeiro vinculado com sucesso!')),
      );
      _emailController.clear();
      setState(() {}); // Atualiza a lista
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
      // Confirmação de exclusão
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
        // Atualiza o usuário removendo a barbearia
        await _firestore.collection('users').doc(uid).update({
          'barbeariaId': FieldValue.delete(), // Remove o ID da barbearia
          'userType': FieldValue.delete(), // Remove o tipo de usuário
          'status': FieldValue.delete(), // Remove o status
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
      // Altera o status do barbeiro
      await _firestore.collection('users').doc(uid).update({
        'status': novoStatus, // Atualiza o status para "inativo" ou "ativo"
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
                      final uid = docs[index].id; // ID do barbeiro
                      final status =
                          data['status'] ?? 'ativo'; // Obtém o status

                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(data['nome'] ?? 'Sem nome'),
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
