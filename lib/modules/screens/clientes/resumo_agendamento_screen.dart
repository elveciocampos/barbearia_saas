import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResumoAgendamentoScreen extends StatelessWidget {
  final String barbeariaId;
  final String barbeiroId;
  final String barbeiroNome;
  final String? barbeiroFoto;
  final String servicoId;
  final String servicoNome;
  final double servicoPreco;
  final DateTime horario;

  const ResumoAgendamentoScreen({
    super.key,
    required this.barbeariaId,
    required this.barbeiroId,
    required this.barbeiroNome,
    this.barbeiroFoto,
    required this.servicoId,
    required this.servicoNome,
    required this.servicoPreco,
    required this.horario,
  });

  String formatarDataHora(DateTime dataHora) {
    final formatador = DateFormat('dd/MM/yyyy HH:mm');
    return formatador.format(dataHora);
  }

  void _confirmarAgendamento(BuildContext context) {
    // Aqui você pode salvar no Firebase ou abrir o WhatsApp
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Agendamento confirmado!'),
            content: const Text('Você será redirecionado em breve.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumo do Agendamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        barbeiroFoto != null
                            ? NetworkImage(barbeiroFoto!)
                            : null,
                    child:
                        barbeiroFoto == null
                            ? const Icon(Icons.person, size: 28)
                            : null,
                  ),
                  title: Text(
                    barbeiroNome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Barbeiro escolhido'),
                ),
                const Divider(),

                // Serviço
                ListTile(
                  leading: const Icon(Icons.cut),
                  title: Text(servicoNome),
                  subtitle: Text('R\$ ${servicoPreco.toStringAsFixed(2)}'),
                ),

                // Horário
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Horário agendado'),
                  subtitle: Text(formatarDataHora(horario)),
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirmar Agendamento'),
                  onPressed: () => _confirmarAgendamento(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
