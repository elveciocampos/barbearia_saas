import 'package:barbearia_saas/modules/screens/dono_barbearia/adicionar_categorias_screen.dart';
import 'package:barbearia_saas/modules/screens/dono_barbearia/gerenciar_categorias.dart';
import 'package:barbearia_saas/modules/screens/dono_barbearia/gerenciar_servicos_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonoBarbeariaHomeScreen extends StatefulWidget {
  const DonoBarbeariaHomeScreen({super.key});

  @override
  State<DonoBarbeariaHomeScreen> createState() =>
      _DonoBarbeariaHomeScreenState();
}

class _DonoBarbeariaHomeScreenState extends State<DonoBarbeariaHomeScreen> {
  int _selectedIndex = 0;
  String? barbeariaId;

  @override
  void initState() {
    super.initState();
    _loadBarbeariaId();
  }

  void _loadBarbeariaId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        barbeariaId = user.uid;
      });
      await _adicionarCategoriasTeste(user.uid);
    }
  }

  Future<void> _adicionarCategoriasTeste(String barbeariaId) async {
    final categoriasRef = FirebaseFirestore.instance
        .collection('barbearias')
        .doc(barbeariaId)
        .collection('categorias');

    List<String> categoriasTeste = [
      'Corte Masculino',
      'Corte Feminino',
      'Barba',
      'Corte de Cabelo Infantil',
    ];

    for (var categoria in categoriasTeste) {
      final existingCategory =
          await categoriasRef.where('nome', isEqualTo: categoria).get();

      if (existingCategory.docs.isEmpty) {
        await categoriasRef.add({'nome': categoria});
      }
    }
  }

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
    if (barbeariaId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Administrador'),
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
            // Card Serviços
            GestureDetector(
              onTap: () {
                if (barbeariaId != null && barbeariaId!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => GerenciarServicosScreen(
                            barbeariaId: barbeariaId!,
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Barbearia ID não encontrado.'),
                    ),
                  );
                }
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
                      'Serviços',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            // Card Categorias
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GerenciarCategoriasScreen(),
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
                    Icon(Icons.category, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Categorias',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            // Card Barbeiros
            GestureDetector(
              onTap: () {
                // Navegação para a tela Barbeiros (implementar depois)
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
                    Icon(Icons.person, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Barbeiros',
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
