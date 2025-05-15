import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  String? _categoriaSelecionada;
  String? _servicoSelecionado;
  DateTime? _horarioSelecionado;

  List<DocumentSnapshot> _barbeiros = [];
  List<DocumentSnapshot> _categorias = [];
  List<String> _servicos = [];
  List<String> _horarios = [];

  @override
  void initState() {
    super.initState();
    _carregarBarbeirosECategorias();
  }

  Future<void> _carregarBarbeirosECategorias() async {
    final barbeariaDoc =
        await FirebaseFirestore.instance
            .collection('barbearias')
            .doc(widget.barbeariaId)
            .get();

    final donoUid = barbeariaDoc.data()?['donoUid'];
    if (donoUid == null) return;

    final barbeirosSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('barbeariaId', isEqualTo: donoUid)
            .where('userType', isEqualTo: 'barbeiro')
            .get();

    final categoriasSnapshot =
        await FirebaseFirestore.instance.collection('categorias').get();

    if (!mounted) return;

    setState(() {
      _barbeiros = barbeirosSnapshot.docs;
      _categorias = categoriasSnapshot.docs;
    });
  }

  Future<void> _carregarServicosPorCategoria(String categoriaId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('categorias')
            .doc(categoriaId)
            .collection('servicos')
            .get();

    if (!mounted) return;

    setState(() {
      _servicos =
          snapshot.docs
              .map((doc) => doc['nome']?.toString() ?? '')
              .where((nome) => nome.isNotEmpty)
              .toList();
      _servicoSelecionado = null;
    });
  }

  Future<void> _carregarHorariosDisponiveis(String barbeiroId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('barbearias')
            .doc(widget.barbeariaId)
            .collection('horarios')
            .where('barbeiroId', isEqualTo: barbeiroId)
            .get();

    if (!mounted) return;

    setState(() {
      _horarios =
          snapshot.docs
              .map((doc) => doc['horario']?.toString() ?? '')
              .where((horario) => horario.isNotEmpty)
              .toList();
      _horarioSelecionado = null;
    });
  }

  void _confirmarAgendamento() {
    if (_barbeiroSelecionado == null ||
        _categoriaSelecionada == null ||
        _servicoSelecionado == null ||
        _horarioSelecionado == null) {
      return;
    }

    final barbeiro = _barbeiros.firstWhere((b) => b.id == _barbeiroSelecionado);
    final barbeiroNome = barbeiro['nome'] ?? 'Barbeiro';

    final categoria = _categorias.firstWhere(
      (c) => c.id == _categoriaSelecionada,
    );
    final categoriaNome = categoria['nome'] ?? 'Categoria';

    final horarioFormatado =
        '${_horarioSelecionado!.hour.toString().padLeft(2, '0')}:${_horarioSelecionado!.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Resumo do Agendamento',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🧔 Barbeiro: $barbeiroNome',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  '📂 Categoria: $categoriaNome',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  '✂️ Serviço: $_servicoSelecionado',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  '🕒 Horário: $horarioFormatado',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                ),
                label: const Text('Enviar pelo WhatsApp'),
                onPressed: () {
                  final mensagem = Uri.encodeComponent(
                    'Olá! Gostaria de confirmar meu agendamento:\n\n'
                    '🧔 Barbeiro: $barbeiroNome\n'
                    '📂 Categoria: $categoriaNome\n'
                    '✂️ Serviço: $_servicoSelecionado\n'
                    '🕒 Horário: $horarioFormatado',
                  );
                  final url = 'https://wa.me/?text=$mensagem';
                  launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text(
          'Agendar Horário',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              '1. Selecione o barbeiro:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            DropdownButton<String>(
              dropdownColor: const Color(0xFF1F1F1F),
              isExpanded: true,
              value: _barbeiroSelecionado,
              hint: const Text(
                'Escolha um barbeiro',
                style: TextStyle(color: Colors.white70),
              ),
              items:
                  _barbeiros.map((barbeiro) {
                    return DropdownMenuItem(
                      value: barbeiro.id,
                      child: Text(
                        barbeiro['nome'] ?? 'Sem nome',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _barbeiroSelecionado = value;
                  _carregarHorariosDisponiveis(value!);
                });
              },
            ),
            const SizedBox(height: 20),

            const Text(
              '2. Selecione a categoria:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            DropdownButton<String>(
              dropdownColor: const Color(0xFF1F1F1F),
              isExpanded: true,
              value: _categoriaSelecionada,
              hint: const Text(
                'Escolha uma categoria',
                style: TextStyle(color: Colors.white70),
              ),
              items:
                  _categorias.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(
                        cat['nome'] ?? 'Sem nome',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _categoriaSelecionada = value;
                  _carregarServicosPorCategoria(value!);
                });
              },
            ),
            const SizedBox(height: 20),

            const Text(
              '3. Escolha o serviço:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            DropdownButton<String>(
              dropdownColor: const Color(0xFF1F1F1F),
              isExpanded: true,
              value: _servicoSelecionado,
              hint: const Text(
                'Selecione um serviço',
                style: TextStyle(color: Colors.white70),
              ),
              items:
                  _servicos.map((servico) {
                    return DropdownMenuItem(
                      value: servico,
                      child: Text(
                        servico,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() => _servicoSelecionado = value);
              },
            ),
            const SizedBox(height: 20),

            const Text(
              '4. Escolha o horário:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            DropdownButton<DateTime?>(
              dropdownColor: const Color(0xFF1F1F1F),
              isExpanded: true,
              value: _horarioSelecionado,
              hint: const Text(
                'Selecione o horário',
                style: TextStyle(color: Colors.white70),
              ),
              items:
                  _horarios.map((horario) {
                    try {
                      final dt = DateTime.parse(horario);
                      return DropdownMenuItem<DateTime?>(
                        value: dt,
                        child: Text(
                          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } catch (_) {
                      return const DropdownMenuItem<DateTime?>(
                        value: null,
                        child: Text(
                          'Inválido',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                  }).toList(),
              onChanged: (value) {
                setState(() => _horarioSelecionado = value);
              },
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed:
                  (_barbeiroSelecionado != null &&
                          _categoriaSelecionada != null &&
                          _servicoSelecionado != null &&
                          _horarioSelecionado != null)
                      ? _confirmarAgendamento
                      : null,
              child: const Text('Confirmar Agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}
