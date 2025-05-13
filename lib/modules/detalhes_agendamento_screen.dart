import 'package:flutter/material.dart';

class DetalhesAgendamentoPage extends StatelessWidget {
  final String cliente;
  final String hora;
  final String servico;
  final String telefone;
  final String status;
  final String observacoes;

  const DetalhesAgendamentoPage({
    super.key,
    required this.cliente,
    required this.hora,
    required this.servico,
    required this.telefone,
    required this.status,
    required this.observacoes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Agendamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: $cliente'),
            Text('Horário: $hora'),
            Text('Serviço: $servico'),
            Text('Telefone: $telefone'),
            Text('Status: $status'),
            if (observacoes.isNotEmpty) Text('Observações: $observacoes'),
          ],
        ),
      ),
    );
  }
}
