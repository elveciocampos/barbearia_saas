import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  AppointmentScreenState createState() => AppointmentScreenState();
}

class AppointmentScreenState extends State<AppointmentScreen> {
  final _dateController = TextEditingController();
  final _barberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Captura as informações do agendamento
        final appointmentData = {
          'uid_cliente': 'clienteId', // Pegue o UID do cliente (usuário logado)
          'uid_barbeiro': 'barbeiroId', // Pegue o UID do barbeiro escolhido
          'data_hora': _dateController.text,
          'status': 'pendente',
        };

        // Envia para o Firestore
        await FirebaseFirestore.instance
            .collection('agendamentos')
            .add(appointmentData);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento realizado com sucesso!')),
        );

        // Redireciona para a tela inicial ou uma tela de confirmação
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao agendar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo para escolher o barbeiro
              TextFormField(
                controller: _barberController,
                decoration: const InputDecoration(labelText: 'Barbeiro'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Escolha um barbeiro';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Campo para escolher a data e hora
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Data e Hora (dd/MM/yyyy HH:mm)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Data e Hora obrigatórios';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _bookAppointment,
                child: const Text('Agendar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
