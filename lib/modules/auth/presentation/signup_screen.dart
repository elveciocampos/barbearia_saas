import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Campos extras para Dono de Barbearia
  final _barbershopNameController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _addressController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String? _userType;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _barbershopNameController.dispose();
    _cpfCnpjController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _toggleConfirmPassword() {
    setState(() {
      _showConfirmPassword = !_showConfirmPassword;
    });
  }

  String mapUserType(String userType) {
    switch (userType) {
      case 'Dono de Barbearia':
        return 'dono';
      case 'Barbeiro Profissional':
        return 'barbeiro';
      case 'Cliente':
        return 'cliente';
      default:
        return 'indefinido';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o tipo de usuário')),
      );
      return;
    }

    final userTypeMapped = mapUserType(_userType!);

    if (userTypeMapped == 'dono') {
      if (_barbershopNameController.text.isEmpty ||
          _cpfCnpjController.text.isEmpty ||
          _addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha todos os campos da barbearia'),
          ),
        );
        return;
      }
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = credential.user!.uid;

      final userData = {
        'nome': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _phoneController.text.trim(),
        'userType': userTypeMapped,
        'isCliente': userTypeMapped == 'cliente',
        'isDono': userTypeMapped == 'dono',
        'isBarbeiro': userTypeMapped == 'barbeiro',
        'createdAt': Timestamp.now(),
      };

      if (userTypeMapped == 'dono') {
        userData.addAll({
          'nomeBarbearia': _barbershopNameController.text.trim(),
          'cpfCnpj': _cpfCnpjController.text.trim(),
          'endereco': _addressController.text.trim(),
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      _goToDashboard(userTypeMapped);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao criar conta: $e')));
    }
  }

  void _goToDashboard(String tipo) {
    if (tipo == 'cliente') {
      Navigator.pushReplacementNamed(context, '/cliente');
    } else if (tipo == 'barbeiro') {
      Navigator.pushReplacementNamed(context, '/barbeiro');
    } else if (tipo == 'dono') {
      Navigator.pushReplacementNamed(context, '/dono');
    } else {
      Navigator.pushReplacementNamed(context, '/user_type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2797FF),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cadastrar Barbearia Pro',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: const Color(0xFF161C24),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crie sua conta e faça parte da nossa comunidade de profissionais.',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: const Color(0xFF161C24),
                  ),
                ),
                const SizedBox(height: 24),

                // Tipo de usuário
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Usuário',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: const Color(0xFF161C24),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...[
                      'Dono de Barbearia',
                      'Barbeiro Profissional',
                      'Cliente',
                    ].map((tipo) {
                      final selected = _userType == tipo;
                      return InkWell(
                        onTap: () => setState(() => _userType = tipo),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: tipo,
                              groupValue: _userType,
                              activeColor: const Color(0xFF2797FF),
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                    (states) =>
                                        states.contains(MaterialState.selected)
                                            ? const Color(0xFF2797FF)
                                            : const Color(0xFFB0C5D9),
                                  ),
                              onChanged:
                                  (val) => setState(() => _userType = val),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tipo,
                              style: GoogleFonts.manrope(
                                fontWeight:
                                    selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                fontSize: 14,
                                color: const Color(0xFF161C24),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                // Campos comuns
                buildTextField(
                  'Nome completo',
                  'Digite seu nome completo',
                  _nameController,
                  Icons.person,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  'Telefone',
                  'Digite seu telefone',
                  _phoneController,
                  Icons.phone,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  'E-mail',
                  'Digite seu e-mail',
                  _emailController,
                  Icons.email,
                  keyboard: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  'Senha',
                  'Digite sua senha',
                  _passwordController,
                  Icons.lock,
                  obscure: !_showPassword,
                  toggleObscure: _togglePassword,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  'Confirmar Senha',
                  'Confirme sua senha',
                  _confirmPasswordController,
                  Icons.lock_outline,
                  obscure: !_showConfirmPassword,
                  toggleObscure: _toggleConfirmPassword,
                ),

                // Campos extras para Dono de Barbearia
                if (_userType == 'Dono de Barbearia') ...[
                  const SizedBox(height: 16),
                  buildTextField(
                    'Nome da Barbearia',
                    'Digite o nome da barbearia',
                    _barbershopNameController,
                    Icons.store,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    'CPF ou CNPJ',
                    'Digite o CPF ou CNPJ',
                    _cpfCnpjController,
                    Icons.badge,
                    keyboard: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    'Endereço da Barbearia',
                    'Digite o endereço da barbearia',
                    _addressController,
                    Icons.location_on,
                  ),
                ],

                const SizedBox(height: 24),

                // Botão Criar Conta
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2797FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Criar Conta',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Link para login
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Já tem uma conta? ',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF161C24),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Fazer login',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFF2797FF),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 0, 107, 246),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          style: GoogleFonts.manrope(
            color: const Color.fromARGB(255, 0, 106, 245),
            fontSize: 10,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(
              color: const Color.fromARGB(128, 0, 0, 0),
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF2797FF)),
            suffixIcon:
                toggleObscure != null
                    ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 18,
                      ),
                      onPressed: toggleObscure,
                    )
                    : null,
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            border: InputBorder.none,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Campo obrigatório';
            }
            return null;
          },
        ),
      ],
    );
  }
}
