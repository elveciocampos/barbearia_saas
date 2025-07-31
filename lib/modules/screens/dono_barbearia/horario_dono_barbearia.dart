import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HorarioDonoBarbearia extends StatelessWidget {
  const HorarioDonoBarbearia({super.key});

  Future<void> editarHorario(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (doc.exists && doc.data()?['userType'] == 'dono') {
      final currentHorario = doc.data()?['horario'] ?? '08:00 - 18:00';
      final controller = TextEditingController(text: currentHorario);

      final result = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Editar Horário'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Ex: 08:00 - 18:00',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  child: const Text('Salvar'),
                ),
              ],
            ),
      );

      if (result != null && result.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'horario': result});
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apenas donos podem editar o horário.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Image.network(
                'https://images.unsplash.com/photo-1549271568-e87e07c5406b?...',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, João!',
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: const Color(0xFF14181B),
                  ),
                ),
                Text(
                  'Administrador',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF677681),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF14181B),
            ),
            onPressed: () => print('Notificações'),
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE3E7ED)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.store_rounded,
                          color: Color(0xFFF83B46),
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Status da Barbearia',
                          style: GoogleFonts.sora(
                            fontWeight: FontWeight.w600,
                            fontSize: 26,
                            color: const Color(0xFF14181B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE3E7ED)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Barbearia Clássica',
                        style: GoogleFonts.sora(
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          color: const Color(0xFF14181B),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6BBD78),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'ABERTA',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<DocumentSnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .snapshots(),
                    builder: (context, snapshot) {
                      String horario = '08:00 - 18:00';
                      if (snapshot.hasData && snapshot.data!.data() != null) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        horario = data['horario'] ?? horario;
                      }
                      return InkWell(
                        onTap: () => editarHorario(context),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF677681),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Horário: $horario',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF677681),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xFF677681),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF677681),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hoje: Segunda-feira, 15 Jan',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF677681),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE3E7ED)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Controle de Funcionamento',
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: const Color(0xFF14181B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatusCard(
                    title: 'Abrir Barbearia',
                    subtitle: 'Iniciar atendimento aos clientes',
                    buttonText: 'ABRIR',
                    buttonColor: const Color(0xFF6BBD78),
                    onPressed: () => print('Abrir barbearia'),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusCard(
                    title: 'Fechar Barbearia',
                    subtitle: 'Encerrar atendimento do dia',
                    buttonText: 'FECHAR',
                    buttonColor: const Color(0xFFF83B46),
                    onPressed: () => print('Fechar barbearia'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF14181B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF677681),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              minimumSize: const Size(36, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
