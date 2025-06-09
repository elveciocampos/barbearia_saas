import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CadastroBarbeariaScreen extends StatefulWidget {
  const CadastroBarbeariaScreen({super.key});

  @override
  State<CadastroBarbeariaScreen> createState() =>
      _CadastroBarbeariaScreenState();
}

class _CadastroBarbeariaScreenState extends State<CadastroBarbeariaScreen> {
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _horariosController = TextEditingController();
  bool _loading = false;

  final List<String> categoriasPadrao = [
    'Corte',
    'Barba',
    'Sobrancelha',
    'Pacote',
    'Coloração',
    'Hidratação',
  ];

  Future<void> _adicionarCategoriasPadrao(String barbeariaId) async {
    final categoriasRef = FirebaseFirestore.instance
        .collection('barbearias')
        .doc(barbeariaId)
        .collection('categorias');

    for (final nome in categoriasPadrao) {
      await categoriasRef.add({'nome': nome});
    }
  }

  Future<void> _cadastrarBarbearia() async {
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final barbeariaRef =
          FirebaseFirestore.instance.collection('barbearias').doc();

      // Estrutura dos dados para salvar a barbearia
      final horarios = {
        'Segunda': '09:00 - 18:00',
        'Terça': '09:00 - 18:00',
        'Quarta': '09:00 - 18:00',
        'Quinta': '09:00 - 18:00',
        'Sexta': '09:00 - 18:00',
        'Sábado': '09:00 - 14:00',
        'Domingo': 'Fechado',
      };

      final linksUteis = [
        {'titulo': 'Instagram', 'url': 'https://instagram.com/sua_barbearia'},
        {'titulo': 'WhatsApp', 'url': 'https://wa.me/55999999999'},
      ];

      final galeriaImagens = [
        'https://link1.com/foto1.jpg',
        'https://link2.com/foto2.jpg',
        'https://link3.com/foto3.jpg',
      ];

      // Salvando dados no Firestore
      await barbeariaRef.set({
        'nome': _nomeController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'email': _emailController.text.trim(),
        'horarios': horarios, // Horários de funcionamento
        'links_uteis': linksUteis, // Links úteis
        'galeria': galeriaImagens, // Galeria de imagens
        'status': 'ativa',
        'donoUid': user.uid,
      });

      // Atualizando o documento do usuário com o ID da barbearia
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'barbeariaId': barbeariaRef.id},
      );

      // Adiciona categorias padrão após criar a barbearia
      await _adicionarCategoriasPadrao(barbeariaRef.id);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dono');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar barbearia: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Barbearia')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Barbearia',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _horariosController,
                decoration: const InputDecoration(
                  labelText: 'Horários de Funcionamento',
                  hintText: 'Ex: Seg-Sex 09:00-18:00, Sáb 09:00-14:00',
                ),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _cadastrarBarbearia,
                    child: const Text('Cadastrar Barbearia'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
