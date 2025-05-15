import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  EditarPerfilScreenState createState() => EditarPerfilScreenState();
}

class EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _picker = ImagePicker();
  File? _imagem;
  String? _imagemUrl;
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _linksController = TextEditingController(); // Campo para Links Úteis
  final _horarioController =
      TextEditingController(); // Campo para Horário de Funcionamento
  List<File> _galeriaImagens = []; // Para armazenar as imagens da galeria
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) return;

      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(usuario.uid)
              .get();

      if (doc.exists) {
        final dados = doc.data();
        if (dados != null) {
          setState(() {
            _nomeController.text =
                dados.containsKey('nome') ? dados['nome'] ?? '' : '';
            _emailController.text =
                dados.containsKey('email') ? dados['email'] ?? '' : '';
            _imagemUrl =
                dados.containsKey('profile_picture')
                    ? dados['profile_picture']
                    : null;
            _linksController.text =
                dados.containsKey('links_uteis')
                    ? dados['links_uteis'] ?? ''
                    : '';
            _horarioController.text =
                dados.containsKey('horario_funcionamento')
                    ? dados['horario_funcionamento'] ?? ''
                    : '';
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados do perfil')),
      );
    }
  }

  Future<void> _selecionarImagem() async {
    final arquivoSelecionado = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (arquivoSelecionado != null) {
      setState(() {
        _imagem = File(arquivoSelecionado.path);
      });
    }
  }

  Future<String?> _enviarImagemParaCloudinary(File imagem) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cloudinary = Cloudinary.full(
        apiKey: CloudinaryConfig.apiKey,
        apiSecret: CloudinaryConfig.apiSecret,
        cloudName: CloudinaryConfig.cloudName,
      );

      final response = await cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: imagem.path,
          fileName: 'perfil_${DateTime.now().millisecondsSinceEpoch}',
          resourceType: CloudinaryResourceType.image,
          folder: 'profile_pictures',
        ),
      );

      if (response.isSuccessful && response.secureUrl != null) {
        return response.secureUrl!;
      } else {
        debugPrint('Erro Cloudinary: ${response.error}');
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao enviar imagem: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao enviar imagem')));
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _salvarPerfil() async {
    final nome = _nomeController.text;
    final email = _emailController.text;
    final linksUteis = _linksController.text;
    final horarioFuncionamento = _horarioController.text;

    String? imagemUrl;
    if (_imagem != null) {
      imagemUrl = await _enviarImagemParaCloudinary(_imagem!);
    }

    try {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .update({
            'nome': nome,
            'email': email,
            if (imagemUrl != null) 'profile_picture': imagemUrl,
            'links_uteis': linksUteis, // Atualiza links úteis
            'horario_funcionamento':
                horarioFuncionamento, // Atualiza horário de funcionamento
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar perfil: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _selecionarImagem,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _imagem != null
                          ? FileImage(_imagem!)
                          : (_imagemUrl != null
                              ? NetworkImage(_imagemUrl!) as ImageProvider
                              : const AssetImage('assets/placeholder.png')),
                  child:
                      (_imagem == null && _imagemUrl == null)
                          ? const Icon(Icons.camera_alt, color: Colors.white)
                          : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _linksController, // Campo para Links Úteis
              decoration: const InputDecoration(labelText: 'Links Úteis'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller:
                  _horarioController, // Campo para Horário de Funcionamento
              decoration: const InputDecoration(
                labelText: 'Horário de Funcionamento',
              ),
            ),
            const SizedBox(height: 16),
            // Galeria de Imagens
            ElevatedButton(
              onPressed: () async {
                final arquivosSelecionados = await _picker.pickMultiImage();
                setState(() {
                  _galeriaImagens =
                      arquivosSelecionados
                          .map((file) => File(file.path))
                          .toList();
                });
              },
              child: const Text('Selecionar Imagens para Galeria'),
            ),
            const SizedBox(height: 16),
            if (_galeriaImagens.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _galeriaImagens.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(_galeriaImagens[index]),
                    );
                  },
                ),
              ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _salvarPerfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Salvar Alterações'),
                ),
          ],
        ),
      ),
    );
  }
}

class CloudinaryConfig {
  static const String apiKey = '298232147574859';
  static const String apiSecret = 'uOgLAp_1f2mJVGod8zpXSm4030o';
  static const String cloudName = 'dpouccu9n';
}
