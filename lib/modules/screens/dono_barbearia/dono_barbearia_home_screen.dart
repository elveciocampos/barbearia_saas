import 'package:barbearia_saas/modules/agenda_screen.dart';
import 'package:barbearia_saas/modules/cadastrar_agendamento_screen.dart';
import 'package:barbearia_saas/modules/screens/dono_barbearia/gerenciar_servicos_screen.dart';
import 'package:barbearia_saas/modules/screens/dono_barbearia/dono_perfil_screen.dart';
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

  List<Widget> get _screens => [
    GerenciarServicosScreen(barbeariaId: barbeariaId ?? ''),
    const AgendaScreen(),
    const PerfileScreen(),
  ];

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
      body: _screens[_selectedIndex],
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text('Novo Agendamento'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CadastrarAgendamentoScreen(),
                    ),
                  );
                },
                backgroundColor: Colors.black87,
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.grey[100],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Serviços',
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
