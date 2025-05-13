import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditarAgendamentoScreen extends StatefulWidget {
  final DocumentSnapshot agendamento;

  const EditarAgendamentoScreen({super.key, required this.agendamento});

  @override
  State<EditarAgendamentoScreen> createState() =>
      _EditarAgendamentoScreenState();
}

class _EditarAgendamentoScreenState extends State<EditarAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _servicoController = TextEditingController();
  final _telefoneController = TextEditingController();
  DateTime? _dataSelecionada;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final dados = widget.agendamento.data() as Map<String, dynamic>;
    _clienteController.text = dados['clienteNome'] ?? '';
    _servicoController.text = dados['servico'] ?? '';
    _telefoneController.text = dados['telefone'] ?? '';
    _dataSelecionada = (dados['data'] as Timestamp).toDate();
  }

  Future<void> _selecionarDataHora() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (data == null) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataSelecionada ?? DateTime.now()),
    );

    if (hora == null) return;

    setState(() {
      _dataSelecionada = DateTime(
        data.year,
        data.month,
        data.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  Future<void> _salvarEdicao() async {
    if (!_formKey.currentState!.validate() || _dataSelecionada == null) return;

    setState(() => _salvando = true);

    await FirebaseFirestore.instance
        .collection('agendamentos')
        .doc(widget.agendamento.id)
        .update({
          'clienteNome': _clienteController.text,
          'servico': _servicoController.text,
          'telefone': _telefoneController.text,
          'data': Timestamp.fromDate(_dataSelecionada!),
        });

    if (mounted) {
      Navigator.pop(context); // Volta após salvar
    }
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _servicoController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Agendamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _clienteController,
                decoration: const InputDecoration(labelText: 'Nome do Cliente'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _servicoController,
                decoration: const InputDecoration(labelText: 'Serviço'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Informe o serviço' : null,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                validator:
                    (v) => v == null || v.isEmpty ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _selecionarDataHora,
                icon: const Icon(Icons.access_time),
                label: Text(
                  _dataSelecionada == null
                      ? 'Selecionar data e hora'
                      : 'Selecionado: ${_dataSelecionada!.day}/${_dataSelecionada!.month} às ${_dataSelecionada!.hour}:${_dataSelecionada!.minute.toString().padLeft(2, '0')}',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvando ? null : _salvarEdicao,
                child:
                    _salvando
                        ? const CircularProgressIndicator()
                        : const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
