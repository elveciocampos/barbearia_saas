import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CadastrarHorariosScreen extends StatefulWidget {
  const CadastrarHorariosScreen({super.key});

  @override
  State<CadastrarHorariosScreen> createState() =>
      _CadastrarHorariosScreenState();
}

class _CadastrarHorariosScreenState extends State<CadastrarHorariosScreen> {
  final _formKey = GlobalKey<FormState>();
  String _diaSemana = 'Segunda';
  String _inicio = '';
  String _fim = '';
  bool _salvando = false;

  final List<String> _diasSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  Future<void> _selecionarHorarioInicio() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _inicio = _formatarHora(hora);
      });
    }
  }

  Future<void> _selecionarHorarioFim() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _fim = _formatarHora(hora);
      });
    }
  }

  String _formatarHora(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _salvarHorario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _salvando = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('horarios')
          .add({'dia': _diaSemana, 'inicio': _inicio, 'fim': _fim});
    }

    setState(() {
      _salvando = false;
    });

    if (!mounted) return;
    Navigator.pop(context, 'sucesso');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Horário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _diaSemana,
                decoration: const InputDecoration(labelText: 'Dia da semana'),
                items:
                    _diasSemana.map((dia) {
                      return DropdownMenuItem(value: dia, child: Text(dia));
                    }).toList(),
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      _diaSemana = valor;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selecionarHorarioInicio,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Horário de início',
                  ),
                  child: Text(_inicio.isEmpty ? 'Selecionar' : _inicio),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selecionarHorarioFim,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Horário de término',
                  ),
                  child: Text(_fim.isEmpty ? 'Selecionar' : _fim),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvando ? null : _salvarHorario,
                child:
                    _salvando
                        ? const CircularProgressIndicator()
                        : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
