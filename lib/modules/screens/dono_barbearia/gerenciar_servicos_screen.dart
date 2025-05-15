import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GerenciarServicosScreen extends StatefulWidget {
  const GerenciarServicosScreen({super.key});

  @override
  State<GerenciarServicosScreen> createState() =>
      _GerenciarServicosScreenState();
}

class _GerenciarServicosScreenState extends State<GerenciarServicosScreen> {
  String? barbeariaId;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadBarbeariaId();
  }

  Future<void> _loadBarbeariaId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final id = doc.data()?['barbeariaId'] as String?;

    if (id == null || id.isEmpty) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/cadastro_barbearia');
      }
      return;
    }

    if (mounted) {
      setState(() => barbeariaId = id);
    }
  }

  Future<List<DocumentSnapshot>> _carregarCategorias() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('categorias').get();
    return querySnapshot.docs;
  }

  Future<String?> _uploadImagemParaCloudinary(File imagem) async {
    const cloudName = 'dpouccu9n';
    const uploadPreset = 'categorias';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath('file', imagem.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final jsonData = json.decode(responseData.body);
      return jsonData['secure_url'];
    } else {
      return null;
    }
  }

  void _abrirModalServico({DocumentSnapshot? doc}) async {
    final nomeCtrl = TextEditingController(text: doc?['nome'] ?? '');
    final precoCtrl = TextEditingController(
      text: doc?['preco']?.toString() ?? '',
    );
    final tempoCtrl = TextEditingController(
      text: doc?['tempo']?.toString() ?? '',
    );

    List<DocumentSnapshot> categorias = await _carregarCategorias();
    String? categoriaSelecionada =
        doc?['categoria'] ??
        (categorias.isNotEmpty ? categorias.first.id : null);
    String? imagemAtual = doc?['imagem'];
    File?
    imagemSelecionadaModal; // variável local para imagem selecionada do modal

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[100],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> selecionarImagem() async {
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (picked != null) {
                setModalState(() {
                  imagemSelecionadaModal = File(picked.path);
                });
              }
            }

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
                    Text(
                      doc == null ? 'Novo Serviço' : 'Editar Serviço',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nomeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de corte',
                      ),
                    ),
                    TextField(
                      controller: tempoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tempo (minutos)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: precoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Preço (R\$)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (categorias.isNotEmpty)
                      DropdownButton<String>(
                        value: categoriaSelecionada,
                        onChanged:
                            (newValue) => setModalState(() {
                              categoriaSelecionada = newValue;
                            }),
                        items:
                            categorias
                                .map(
                                  (cat) => DropdownMenuItem<String>(
                                    value: cat.id,
                                    child: Text(cat['nome'] ?? 'Sem nome'),
                                  ),
                                )
                                .toList(),
                        hint: const Text('Selecione uma Categoria'),
                        isExpanded: true,
                      ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: selecionarImagem,
                      child:
                          imagemSelecionadaModal != null
                              ? Image.file(imagemSelecionadaModal!, height: 100)
                              : imagemAtual != null
                              ? Image.network(imagemAtual, height: 100)
                              : Container(
                                height: 100,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Text('Selecionar Imagem'),
                                ),
                              ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final nome = nomeCtrl.text.trim();
                        final tempo =
                            int.tryParse(tempoCtrl.text.replaceAll(',', '')) ??
                            0;
                        final preco =
                            double.tryParse(
                              precoCtrl.text.replaceAll(',', '.'),
                            ) ??
                            0.0;
                        if (nome.isEmpty) return;

                        String? imagemUrl = imagemAtual;
                        if (imagemSelecionadaModal != null) {
                          imagemUrl = await _uploadImagemParaCloudinary(
                            imagemSelecionadaModal!,
                          );
                        }

                        final data = {
                          'nome': nome,
                          'tempo': tempo,
                          'preco': preco,
                          'categoria': categoriaSelecionada,
                          'imagem': imagemUrl,
                        };

                        final servicosCol = FirebaseFirestore.instance
                            .collection('barbearias')
                            .doc(barbeariaId!)
                            .collection('servicos');

                        if (doc == null) {
                          await servicosCol.add(data);
                        } else {
                          await doc.reference.update(data);
                        }

                        if (mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nomeCtrl.dispose();
      precoCtrl.dispose();
      tempoCtrl.dispose();
      // Não reseta imagemSelecionada aqui, pois agora está local ao modal.
    });
  }

  Future<void> _excluirServico(DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Excluir Serviço'),
            content: const Text('Tem certeza que deseja excluir este serviço?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (barbeariaId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Serviços'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('barbearias')
                .doc(barbeariaId!)
                .collection('servicos')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum serviço cadastrado.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading:
                      data['imagem'] != null
                          ? Image.network(
                            data['imagem'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.image_not_supported),
                  title: Text(data['nome'] ?? 'Sem nome'),
                  subtitle: Text(
                    'Tempo: ${data['tempo']} min • R\$ ${data['preco']?.toStringAsFixed(2) ?? '0,00'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () => _abrirModalServico(doc: doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _excluirServico(doc),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModalServico(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Serviço'),
        backgroundColor: Colors.black87,
      ),
    );
  }
}
