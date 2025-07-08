import 'package:barbearia_saas/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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
  } // <-- Fechamento do método _cadastrarBarbearia

  @override
  Widget build(BuildContext context) {
    // Aqui você deve colocar o build para a tela CadastroBarbeariaScreen
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro Barbearia')),
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : Text('Formulário de cadastro aqui'),
      ),
    );
  }
}

// Agora fora da classe, defina o main e outras classes normalmente

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro com Máscara e Rotas',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/',
      routes: {
        '/': (context) => const CadastrarBarbearia(),
        '/success': (context) => const SuccessPage(),
      },
    );
  }
}

class CadastrarBarbearia extends StatefulWidget {
  const CadastrarBarbearia({Key? key}) : super(key: key);

  @override
  CadastrarBarbeariaState createState() => CadastrarBarbeariaState();
}

class CadastrarBarbeariaState extends State<CadastrarBarbearia> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _nomeFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _cpfFocus = FocusNode();
  final _senhaFocus = FocusNode();
  final _confirmarSenhaFocus = FocusNode();

  // Máscara para CPF
  final _cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();

    _nomeFocus.dispose();
    _emailFocus.dispose();
    _cpfFocus.dispose();
    _senhaFocus.dispose();
    _confirmarSenhaFocus.dispose();

    super.dispose();
  }

  String? _validateNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu nome completo.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu e-mail.';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  String? _validateCPF(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu CPF.';
    }
    // Remove máscara para validar só os números
    final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) {
      return 'CPF deve conter 11 números.';
    }
    if (!_validarCPF(cpf)) {
      return 'CPF inválido.';
    }
    return null;
  }

  bool _validarCPF(String cpf) {
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;

    List<int> digits = cpf.split('').map(int.parse).toList();

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }
    int firstCheck = 11 - (sum % 11);
    if (firstCheck >= 10) firstCheck = 0;
    if (digits[9] != firstCheck) return false;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += digits[i] * (11 - i);
    }
    int secondCheck = 11 - (sum % 11);
    if (secondCheck >= 10) secondCheck = 0;
    if (digits[10] != secondCheck) return false;

    return true;
  }

  String? _validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma senha.';
    }
    if (value.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres.';
    }
    return null;
  }

  String? _validateConfirmarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme a senha.';
    }
    if (value != _senhaController.text) {
      return 'As senhas não conferem.';
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushReplacementNamed(context, '/success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija os erros no formulário.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                focusNode: _nomeFocus,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: _validateNome,
                onFieldSubmitted:
                    (_) => FocusScope.of(context).requestFocus(_emailFocus),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
                onFieldSubmitted:
                    (_) => FocusScope.of(context).requestFocus(_cpfFocus),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cpfController,
                focusNode: _cpfFocus,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  border: OutlineInputBorder(),
                  hintText: '000.000.000-00',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [_cpfMaskFormatter],
                textInputAction: TextInputAction.next,
                validator: _validateCPF,
                onFieldSubmitted:
                    (_) => FocusScope.of(context).requestFocus(_senhaFocus),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _senhaController,
                focusNode: _senhaFocus,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: _validateSenha,
                onFieldSubmitted:
                    (_) => FocusScope.of(
                      context,
                    ).requestFocus(_confirmarSenhaFocus),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _confirmarSenhaController,
                focusNode: _confirmarSenhaFocus,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: _validateConfirmarSenha,
                onFieldSubmitted: (_) => _submitForm(),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sucesso'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Cadastro realizado com sucesso!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
