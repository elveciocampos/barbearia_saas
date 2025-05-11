import 'package:barbearia_saas/modules/cliente_agendamentos_screen.dart';
import 'package:barbearia_saas/modules/cliente_perfil_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteHomeScreen extends StatefulWidget {
  const ClienteHomeScreen({super.key});

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  int _currentIndex = 0;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onNavTapped(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildInicioTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('barbearias').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar barbearias.'));
        }

        final barbearias = snapshot.data!.docs;

        if (barbearias.isEmpty) {
          return const Center(child: Text('Nenhuma barbearia encontrada.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: barbearias.length,
          itemBuilder: (context, index) {
            final doc = barbearias[index];
            final data = doc.data() as Map<String, dynamic>;

            final nome = data['nome'] ?? 'Sem nome';
            final imagemUrl = data['fotoCapa'] ?? '';
            final nota = data['nota']?.toString() ?? 'Sem nota';

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  imagemUrl.isNotEmpty
                      ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          imagemUrl,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      )
                      : const SizedBox(
                        height: 160,
                        child: Icon(Icons.image, size: 60),
                      ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(nota),
                            const Spacer(),
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            const Text('2.3 km'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/agendar',
                                arguments: doc.id,
                              );
                            },
                            child: const Text('Agendar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAgendamentosTab() {
    return const Center(child: Text('Tela de agendamentos (em construção)'));
  }

  Widget _buildPerfilTab() {
    return const Center(child: Text('Tela de perfil (em construção)'));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildInicioTab(),
      _buildAgendamentosTab(),
      _buildPerfilTab(),
      const ClienteAgendamentosScreen(),
      const ClientePerfilScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agendamentos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
