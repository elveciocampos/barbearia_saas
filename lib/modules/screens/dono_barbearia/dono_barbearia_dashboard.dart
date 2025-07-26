import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DonoBarbeariaDashboard extends StatelessWidget {
  const DonoBarbeariaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('d \'de\' MMMM', 'pt_BR').format(DateTime.now());

    final agendamentos = [
      {
        'nome': 'Carlos Silva',
        'servico': 'Corte + Barba',
        'hora': '14:30',
        'valor': 'R\$ 45,00',
        'avatarUrl':
            'https://images.unsplash.com/photo-1499952127939-9bbf5af6c51c',
      },
      {
        'nome': 'Roberto Santos',
        'servico': 'Corte Social',
        'hora': '15:00',
        'valor': 'R\$ 40,00',
        'avatarUrl':
            'https://images.unsplash.com/photo-1494708001911-679f5d15a946',
      },
    ];

    Widget buildCard(Color color, IconData icon, String value, String label) {
      return Expanded(
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            color: color,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget buildConfigCard(
      BuildContext context,
      IconData icon,
      String label,
      Color color,
      VoidCallback onTap,
    ) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F5F9),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoje, $today',
                    style: const TextStyle(
                      color: Color(0xFF636F81),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'Barbearia Elite',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Ícone de Notificações
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              color: Colors.black87,
              onPressed: () {},
            ),

            // Ícone de Configurações
            IconButton(
              icon: const Icon(Icons.settings),
              color: Colors.black87,
              onPressed: () {},
            ),

            // Ícone de Logout
            IconButton(
              icon: const Icon(Icons.logout),
              color: const Color.fromARGB(255, 0, 0, 0),
              tooltip: 'Sair',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Deseja sair?'),
                        content: const Text('Você será desconectado da conta.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2797FF),
                            ),
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),

            const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1566416440105-6c36b6919a2e',
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOPO: Avatar + Nome do usuário
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Saudação e nome do usuário
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bem-vindo de volta,',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<DocumentSnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              'Carregando...',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            );
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text(
                              'Usuário',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            );
                          }

                          final nome = snapshot.data!.get('nome') ?? 'Usuário';

                          return Text(
                            nome,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24), // Espaçamento depois do topo
              // Cards de estatísticas
              Row(
                children: [
                  buildCard(
                    const Color(0xFF27AE52),
                    Icons.attach_money,
                    'R\$ 2.450',
                    'Receita Hoje',
                  ),
                  const SizedBox(width: 12),
                  buildCard(
                    const Color(0xFF2797FF),
                    Icons.event,
                    '18',
                    'Agendamentos Hoje',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  buildCard(
                    const Color(0xFFFC964D),
                    Icons.schedule,
                    '3',
                    'Pendentes',
                  ),
                  const SizedBox(width: 12),
                  buildCard(
                    const Color(0xFF1D242C),
                    Icons.people,
                    '127',
                    'Clientes Ativos',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lista de agendamentos
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Próximos Agendamentos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      itemCount: agendamentos.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final a = agendamentos[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    a['avatarUrl']!,
                                  ),
                                  radius: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a['nome']!,
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 6, 6, 6),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        a['servico']!,
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            134,
                                            134,
                                            134,
                                          ),
                                        ),
                                      ),

                                      Text(
                                        '${a['hora']} - ${a['valor']}',
                                        style: const TextStyle(
                                          color: Color(0xFF2797FF),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Título "Configurações"
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Configurações',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cards de configuração com altura aumentada
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 250,
                      child: GestureDetector(
                        onTap: () {
                          // ação ao clicar em "Vincular Barbeiros"
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2797FF),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Vincular Barbeiros',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 250,
                      child: GestureDetector(
                        onTap: () {
                          // ação ao clicar em "Horários de Abertura"
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF27AE52),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.access_time_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Horários de Abertura',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Espaço extra para rolagem
            ],
          ),
        ),
      ),

      // BOTÕES FIXADOS NO RODAPÉ
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Novo Agendamento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2797FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.bar_chart_rounded),
                label: const Text('Relatório'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2797FF),
                  side: const BorderSide(color: Color(0xFF2797FF)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
