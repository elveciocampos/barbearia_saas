import 'package:barbearia_saas/modules/screens/barbeiro/barbeiro_selecionarServicos_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BarbeiroDashboardContent extends StatefulWidget {
  const BarbeiroDashboardContent({super.key});

  @override
  State<BarbeiroDashboardContent> createState() =>
      _BarbeiroDashboardContentState();
}

class _BarbeiroDashboardContentState extends State<BarbeiroDashboardContent> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Barbeiro'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // Card Agenda
            GestureDetector(
              onTap: () {
                // Ação futura
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.calendar_today, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Minha Agenda',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            // Card Perfil
            GestureDetector(
              onTap: () {
                // Ação futura
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.person_outline, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Meu Perfil',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            // Card Serviços
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BarbeiroSelecionarServicos(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.content_cut, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Meus Serviços',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
