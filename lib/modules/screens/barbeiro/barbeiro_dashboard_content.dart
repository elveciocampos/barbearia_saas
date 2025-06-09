import 'package:barbearia_saas/modules/screens/dono_barbearia/adicionar_categorias_screen.dart';
import 'package:flutter/material.dart';
import 'package:barbearia_saas/modules/screens/dono_barbearia/gerenciar_barbeiros_screen.dart';

class BarbeiroDashboardContent extends StatelessWidget {
  const BarbeiroDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard do Barbeiro'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildCard(
              context,
              icon: Icons.people,
              title: 'Barbeiros',
              subtitle: 'Gerenciar equipe',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GerenciarBarbeirosScreen(),
                    ),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar para a tela de adicionar nova categoria
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => const Text(
                    'Adicionar outra tela',
                  ), // Tela de adicionar categoria
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Categoria'),
        backgroundColor: Colors.black87,
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.black87,
              ), // Cor do ícone para combinar com o tema
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Cor do título
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
