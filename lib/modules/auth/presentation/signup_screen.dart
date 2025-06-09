import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();
  String _userType = 'cliente'; // Valor padrão
  bool _loading = false;

  Future<void> _signup() async {
    if (_senhaController.text != _confirmaSenhaController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não coincidem!')));
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text.trim(),
          );

      if (userCredential.user != null) {
        final userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid);

        await userDocRef.set({
          'nome': _nomeController.text.trim(),
          'email': _emailController.text.trim(),
          'userType': _userType,
          'isCliente': _userType == 'cliente',
          if (_userType == 'barbeiro' || _userType == 'dono')
            'barbeariaId': '', // Será preenchido posteriormente
        });

        final userType = _userType;

        if (!mounted) return;

        if (userType == 'barbeiro') {
          Navigator.pushReplacementNamed(context, '/barbeiro_home');
        } else if (userType == 'dono') {
          Navigator.pushReplacementNamed(context, '/dono');
        } else {
          Navigator.pushReplacementNamed(context, '/cliente');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Erro ao criar conta')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmaSenhaController,
                decoration: const InputDecoration(
                  labelText: 'Confirme a Senha',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _userType,
                items: const [
                  DropdownMenuItem(
                    value: 'cliente',
                    child: Text('Sou cliente'),
                  ),
                  DropdownMenuItem(
                    value: 'barbeiro',
                    child: Text('Sou barbeiro'),
                  ),
                  DropdownMenuItem(
                    value: 'dono',
                    child: Text('Sou dono de barbearia'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _userType = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Tipo de usuário'),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Cadastrar'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
