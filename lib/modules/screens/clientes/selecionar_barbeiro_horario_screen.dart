import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelecionarBarbeiroHorarioScreen extends StatefulWidget {
  final String barbeariaId;

  const SelecionarBarbeiroHorarioScreen({super.key, required this.barbeariaId});

  @override
  SelecionarBarbeiroHorarioScreenState createState() =>
      SelecionarBarbeiroHorarioScreenState();
}

class SelecionarBarbeiroHorarioScreenState
    extends State<SelecionarBarbeiroHorarioScreen> {
  String? _barbeiroSelecionado;
  DateTime? _horarioSelecionado;

  Future<List<DocumentSnapshot>> _getBarbeiros() async {
    final barbeariaDoc =
        await FirebaseFirestore.instance
            .collection('barbearias')
            .doc(widget.barbeariaId)
            .get();

    final donoUid = barbeariaDoc.data()?['donoUid'];
    if (donoUid == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('barbeariaId', isEqualTo: donoUid)
            .where('userType', isEqualTo: 'barbeiro')
            .get();

    return snapshot.docs;
  }

  Future<List<String>> _getHorariosDisponiveis(String barbeiroId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('barbearias')
            .doc(widget.barbeariaId)
            .collection('horarios')
            .where('barbeiroId', isEqualTo: barbeiroId)
            .get();

    return snapshot.docs
        .map((doc) => doc['horario']?.toString() ?? '')
        .where((horario) => horario.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolher Barbeiro e Horário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<List<DocumentSnapshot>>(
              future: _getBarbeiros(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Nenhum barbeiro encontrado.'),
                  );
                }

                final barbeiros = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecione um barbeiro:',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Escolha um barbeiro'),
                      value: _barbeiroSelecionado,
                      onChanged: (value) {
                        setState(() {
                          _barbeiroSelecionado = value;
                          _horarioSelecionado = null;
                        });
                      },
                      items:
                          barbeiros.map((barbeiro) {
                            final data =
                                barbeiro.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: barbeiro.id,
                              child: Text(
                                data['nome'] ?? 'Sem nome',
                              ), // corrigido aqui
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (_barbeiroSelecionado != null)
                      FutureBuilder<List<String>>(
                        future: _getHorariosDisponiveis(_barbeiroSelecionado!),
                        builder: (context, horariosSnapshot) {
                          if (horariosSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!horariosSnapshot.hasData ||
                              horariosSnapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('Nenhum horário disponível.'),
                            );
                          }

                          final horarios = horariosSnapshot.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Escolha um horário:',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton<DateTime>(
                                isExpanded: true,
                                hint: const Text('Escolha um horário'),
                                value: _horarioSelecionado,
                                onChanged: (value) {
                                  setState(() {
                                    _horarioSelecionado = value;
                                  });
                                },
                                items:
                                    horarios.map((horario) {
                                      try {
                                        final horarioDate = DateTime.parse(
                                          horario,
                                        );
                                        return DropdownMenuItem<DateTime>(
                                          value: horarioDate,
                                          child: Text(
                                            '${horarioDate.hour.toString().padLeft(2, '0')}:${horarioDate.minute.toString().padLeft(2, '0')}',
                                          ),
                                        );
                                      } catch (_) {
                                        return const DropdownMenuItem<DateTime>(
                                          value: null,
                                          child: Text('Formato inválido'),
                                        );
                                      }
                                    }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _barbeiroSelecionado != null && _horarioSelecionado != null
                      ? () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Agendamento Confirmado'),
                                content: Text(
                                  'Você agendou com sucesso para o barbeiro $_barbeiroSelecionado no horário ${_horarioSelecionado!.hour}:${_horarioSelecionado!.minute.toString().padLeft(2, '0')}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      }
                      : null,
              child: const Text('Confirmar Agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}
