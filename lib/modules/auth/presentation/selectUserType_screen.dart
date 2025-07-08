import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectUserTypeScreen extends StatefulWidget {
  const SelectUserTypeScreen({super.key});

  @override
  State<SelectUserTypeScreen> createState() => _SelectUserTypeScreenState();
}

class _SelectUserTypeScreenState extends State<SelectUserTypeScreen> {
  Widget buildCard({
    required IconData icon,
    required Color iconBg,
    Color? iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor ?? Colors.black, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToFillUserData(String userType) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FillUserDataScreen(userType: userType)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1E88E5),
      scaffoldBackgroundColor: const Color.fromARGB(255, 244, 243, 243),
      colorScheme: const ColorScheme.light(
        primary: Color.fromARGB(255, 132, 26, 253),
        secondary: Color.fromARGB(255, 19, 239, 129),
        tertiary: Color.fromARGB(255, 232, 127, 40),
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
      ),
    );

    return Theme(
      data: customTheme,
      child: Scaffold(
        backgroundColor: customTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Como deseja usar o app?',
                  style: GoogleFonts.interTight(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: customTheme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Escolha o tipo de perfil ideal para você.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: customTheme.textTheme.bodySmall?.color?.withOpacity(
                      0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildCard(
                          icon: Icons.store,
                          iconBg: customTheme.colorScheme.primary,
                          iconColor: Colors.white,
                          title: 'Dono da barbearia',
                          subtitle: 'Gerencie sua barbearia e barbeiros',
                          onTap: () => navigateToFillUserData('owner'),
                        ),
                        const SizedBox(height: 16),
                        buildCard(
                          icon: Icons.content_cut,
                          iconBg: customTheme.colorScheme.tertiary,
                          iconColor: Colors.white,
                          title: 'Barbeiro',
                          subtitle: 'Ofereça seus serviços profissionais',
                          onTap: () => navigateToFillUserData('barber'),
                        ),
                        const SizedBox(height: 16),
                        buildCard(
                          icon: Icons.person,
                          iconBg: customTheme.colorScheme.secondary,
                          iconColor: Colors.white,
                          title: 'Cliente',
                          subtitle: 'Agende cortes e cuidados pessoais',
                          onTap: () => navigateToFillUserData('client'),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info,
                                    size: 20,
                                    color: customTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Informações importantes',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: customTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Donos podem gerenciar múltiplos barbeiros\n'
                                '• Barbeiros podem trabalhar em várias barbearias\n'
                                '• Clientes podem agendar com qualquer barbeiro',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: customTheme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32, top: 16),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Ação do botão se quiser
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customTheme.primaryColor,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Continuar',
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Já tem uma conta? ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: customTheme.textTheme.bodySmall?.color,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navegar para login
                            },
                            child: Text(
                              'Fazer login',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: customTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FillUserDataScreen extends StatefulWidget {
  final String userType;

  const FillUserDataScreen({super.key, required this.userType});

  @override
  State<FillUserDataScreen> createState() => _FillUserDataScreenState();
}

class _FillUserDataScreenState extends State<FillUserDataScreen> {
  final _formKey = GlobalKey<FormState>();
  int step = 0;

  String getTitle() {
    switch (widget.userType) {
      case 'owner':
        return 'Dados do Dono da Barbearia';
      case 'barber':
        return 'Dados do Barbeiro';
      case 'client':
        return 'Dados do Cliente';
      default:
        return 'Preencha seus dados';
    }
  }

  Widget buildStepContent() {
    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nome completo'),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Informe seu nome'
                          : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe seu e-mail';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Informe seu telefone'
                          : null,
            ),
            const SizedBox(height: 16),
            if (widget.userType == 'owner')
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nome da barbearia',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe o nome da barbearia'
                            : null,
              ),
            if (widget.userType == 'barber')
              TextFormField(
                decoration: const InputDecoration(labelText: 'Especialidade'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe sua especialidade'
                            : null,
              ),
          ],
        );
      case 2:
        return Center(
          child: Text(
            'Revisão dos dados\n(implemente aqui a revisão ou confirmação)',
            style: GoogleFonts.inter(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (step < 2) {
        setState(() => step++);
      } else {
        // Aqui pode salvar dados e seguir para próximo passo da navegação
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cadastro finalizado!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1E88E5),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E88E5),
        secondary: Color(0xFF64B5F6),
        tertiary: Color(0xFF90CAF9),
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
      ),
    );

    return Theme(
      data: customTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            getTitle(),
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: customTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        backgroundColor: customTheme.scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(child: buildStepContent()),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customTheme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: nextStep,
                  child: Text(step < 2 ? 'Continuar' : 'Finalizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
