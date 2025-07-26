import 'package:barbearia_saas/modules/auth/presentation/login_screen.dart';
import 'package:barbearia_saas/modules/screens/barbeiro/barbeiro_gerenciar_horarios_screen.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('BarbeiroDashboardContent');

class BarbeiroDashboardContent extends StatelessWidget {
  const BarbeiroDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2797FF),
        automaticallyImplyLeading: false,
        title: Text(
          'Painel do Barbeiro',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    _logger.info('Gerenciar horários clicado');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GerenciarHorariosAppBar(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    _logger.info('Configurações clicadas');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const Placeholder(
                              child: Text('Botão apertado como rota'),
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white, size: 24),
                  onPressed: () {
                    _logger.info('Logout clicado');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2797FF), Color(0xFF2C5AA0)],
              stops: [0, 1],
              begin: AlignmentDirectional(1, -1),
              end: AlignmentDirectional(-1, 1),
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Perfil
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1559453252-1634e4c59f20?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTMxNDUyMjF8&ixlib=rb-4.1.0&q=80&w=1080',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'João Silva',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Barbeiro Profissional',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xCCFFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD700),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(127 avaliações)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Color(0xCCFFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Lista de solicitações
                Column(
                  children: [
                    buildSolicitacaoCard(context),
                    buildSolicitacaoCard(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSolicitacaoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x1A000000),
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                CircleAvatar(backgroundColor: Color(0xFF00C851), radius: 4),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'NOVA SOLICITAÇÃO',
                    style: TextStyle(
                      color: Color(0xFF00C851),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  'há 2 min',
                  style: TextStyle(
                    color: Color(0xFF636F81),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1531314888229-c4b4682c3118',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Carlos Mendes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Corte + Barba',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF636F81),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.schedule_rounded,
                            color: Color(0xFF2797FF),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Hoje, 15:30',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2797FF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEBEE),
                      foregroundColor: const Color(0xFFEE4444),
                      side: const BorderSide(color: Color(0xFFEE4444)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _logger.info('Rejeitado'),
                    child: const Text('Rejeitar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C851),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _logger.info('Aceito'),
                    child: const Text('Aceitar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
