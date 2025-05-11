import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AgendarScreen extends StatefulWidget {
  const AgendarScreen({super.key});

  @override
  State<AgendarScreen> createState() => _AgendarScreenState();
}

class _AgendarScreenState extends State<AgendarScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _barbeiroSelecionado;
  String? _servicoSelecionado;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  bool _carregando = false;

  // 🔁 Mock de barbeiros e serviços (substituir por dados reais do Firestore)
  final List<Map<String, String>> _barbeiros = [
    {'id': 'barbeiro1', 'nome': 'João'},
    {'id': 'barbeiro2', 'nome': 'Carlos'},
  ];

  final List<String> _servicos = [
    'Corte Simples',
    'Corte + Barba',
    'Sobrancelha',
  ];

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: agora,
      firstDate: agora,
      lastDate: agora.add(const Duration(days: 30)),
    );
    if (data != null) {
      setState(() => _dataSelecionada = data);
    }
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() => _horaSelecionada = hora);
    }
  }

  Future<void> _criarAgendamento() async {
    if (!_formKey.currentState!.validate() ||
        _dataSelecionada == null ||
        _horaSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não autenticado')));
      return;
    }

    final dataHora = DateTime(
      _dataSelecionada!.year,
      _dataSelecionada!.month,
      _dataSelecionada!.day,
      _horaSelecionada!.hour,
      _horaSelecionada!.minute,
    );

    setState(() => _carregando = true);

    try {
      final agendamento = {
        'clienteId': user.uid,
        'barbeariaId': 'barbearia1', // ID fixo temporário — depois puxar real
        'barbeiroId': _barbeiroSelecionado,
        'servico': _servicoSelecionado,
        'dataHora': Timestamp.fromDate(dataHora),
        'confirmado': false,
        'cancelado': false,
        'criadoEm': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('agendamentos')
          .add(agendamento);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento criado com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao agendar: $e')));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Horário')),
      body:
          _carregando
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _barbeiroSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Barbeiro',
                        ),
                        items:
                            _barbeiros.map((b) {
                              return DropdownMenuItem(
                                value: b['id'],
                                child: Text(b['nome']!),
                              );
                            }).toList(),
                        onChanged:
                            (val) => setState(() => _barbeiroSelecionado = val),
                        validator:
                            (val) =>
                                val == null ? 'Selecione um barbeiro' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _servicoSelecionado,
                        decoration: const InputDecoration(labelText: 'Serviço'),
                        items:
                            _servicos.map((s) {
                              return DropdownMenuItem(value: s, child: Text(s));
                            }).toList(),
                        onChanged:
                            (val) => setState(() => _servicoSelecionado = val),
                        validator:
                            (val) =>
                                val == null ? 'Selecione um serviço' : null,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          _dataSelecionada == null
                              ? 'Selecionar Data'
                              : 'Data: ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selecionarData,
                      ),
                      ListTile(
                        title: Text(
                          _horaSelecionada == null
                              ? 'Selecionar Horário'
                              : 'Horário: ${_horaSelecionada!.format(context)}',
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: _selecionarHora,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _criarAgendamento,
                        child: const Text('Confirmar Agendamento'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
