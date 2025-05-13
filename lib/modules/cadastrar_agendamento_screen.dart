import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart'; // ✅ Importação da máscara

class CadastrarAgendamentoScreen extends StatefulWidget {
  const CadastrarAgendamentoScreen({super.key});

  @override
  State<CadastrarAgendamentoScreen> createState() =>
      _CadastrarAgendamentoScreenState();
}

class _CadastrarAgendamentoScreenState
    extends State<CadastrarAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _servicoController = TextEditingController();
  final _telefoneController = TextEditingController(); // ✅ Adicionado
  DateTime? _dataSelecionada;

  bool _salvando = false;

  Future<void> _salvarAgendamento() async {
    if (!_formKey.currentState!.validate() || _dataSelecionada == null) return;

    setState(() => _salvando = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final usuario =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final barbeariaId = usuario['barbeariaId'];

    await FirebaseFirestore.instance.collection('agendamentos').add({
      'clienteNome': _clienteController.text,
      'servico': _servicoController.text,
      'telefone': _telefoneController.text.replaceAll(
        RegExp(r'\D'),
        '',
      ), // ✅ Remove tudo que não for número
      'data': Timestamp.fromDate(_dataSelecionada!),
      'barbeariaId': barbeariaId,
    });

    if (mounted) {
      Navigator.pop(context); // Volta para a tela anterior
    }
  }

  Future<void> _selecionarDataHora() async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: agora,
      firstDate: agora,
      lastDate: agora.add(const Duration(days: 30)),
    );

    if (data == null) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
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

  @override
  void dispose() {
    _clienteController.dispose();
    _servicoController.dispose();
    _telefoneController.dispose(); // ✅ Libera o controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Agendamento')),
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
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe o nome'
                            : null,
              ),
              TextFormField(
                controller: _servicoController,
                decoration: const InputDecoration(labelText: 'Serviço'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe o serviço'
                            : null,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  MaskedInputFormatter('(##) #####-####'),
                ], // ✅ Máscara aplicada
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe o telefone'
                            : null,
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
                onPressed: _salvando ? null : _salvarAgendamento,
                child:
                    _salvando
                        ? const CircularProgressIndicator()
                        : const Text('Salvar Agendamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
