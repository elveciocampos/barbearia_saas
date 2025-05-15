import 'package:barbearia_saas/modules/screens/barbeiro/barbeiro_cadastrar_horarios_screen.dart';
import 'package:barbearia_saas/modules/screens/barbeiro/barbeiro_gerenciar_horarios_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BarbeiroHomeScreen extends StatefulWidget {
  const BarbeiroHomeScreen({super.key});

  @override
  State<BarbeiroHomeScreen> createState() => _BarbeiroHomeScreenState();
}

class _BarbeiroHomeScreenState extends State<BarbeiroHomeScreen> {
  int _paginaSelecionada = 0;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  final List<Widget> _paginas = [];

  @override
  void initState() {
    super.initState();
    _paginas.addAll([_buildDashboard(), _buildGerenciarHorarios()]);
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bem-vindo, Barbeiro!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: const [
              _DashboardCard(icon: Icons.schedule, title: 'Horários'),
              _DashboardCard(icon: Icons.cut, title: 'Serviços'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGerenciarHorarios() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Usuário não autenticado.'));
    }

    return GerenciarHorariosScreen(barbeiroUid: uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Barbeiro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _paginas[_paginaSelecionada],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaSelecionada,
        onTap: (index) {
          setState(() {
            _paginaSelecionada = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Horários',
          ),
        ],
      ),
      floatingActionButton:
          _paginaSelecionada == 1
              ? FloatingActionButton(
                onPressed: () async {
                  final resultado = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CadastrarHorariosScreen(),
                    ),
                  );
                  if (resultado != null && mounted) {
                    setState(() {}); // Recarrega após cadastro
                  }
                },
                tooltip: 'Adicionar horário',
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _DashboardCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
