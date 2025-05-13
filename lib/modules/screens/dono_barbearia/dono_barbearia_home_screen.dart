import 'package:barbearia_saas/modules/agenda_screen.dart';
import 'package:barbearia_saas/modules/screens/barbeiro/barbeiro_dashboard_content.dart';
import 'package:barbearia_saas/modules/cadastrar_agendamento_screen.dart';
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

  final List<Widget> _screens = [
    const BarbeiroDashboardContent(),
    const AgendaScreen(),
    const PerfileScreen(),
  ];

  String? barbeariaId;

  @override
  void initState() {
    super.initState();
    _loadBarbeariaId();
    // Adiciona categorias de teste ao carregar a tela
    _adicionarCategoriasTeste();
  }

  // Função para carregar o id da barbearia (você pode pegar isso do usuário logado ou outra lógica)
  void _loadBarbeariaId() async {
    // Aqui você deve carregar o barbeariaId a partir do Firebase ou outra lógica.
    // Vamos supor que ele seja recuperado dessa forma:
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Substitua isso pelo método correto de carregar o ID da barbearia
      barbeariaId =
          user.uid; // Exemplo: o UID do usuário pode ser o ID da barbearia
    }
  }

  // Função para adicionar categorias de teste no Firestore
  void _adicionarCategoriasTeste() async {
    if (barbeariaId == null) return;

    // Referência à coleção de categorias da barbearia
    final categoriasRef = FirebaseFirestore.instance
        .collection('barbearias')
        .doc(barbeariaId!)
        .collection('categorias');

    // Lista de categorias de teste
    List<String> categoriasTeste = [
      'Corte Masculino',
      'Corte Feminino',
      'Barba',
      'Corte de Cabelo Infantil',
    ];

    for (var categoria in categoriasTeste) {
      // Verifica se a categoria já existe
      final existingCategory =
          await categoriasRef.where('nome', isEqualTo: categoria).get();

      if (existingCategory.docs.isEmpty) {
        // Adiciona a nova categoria no Firestore
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
