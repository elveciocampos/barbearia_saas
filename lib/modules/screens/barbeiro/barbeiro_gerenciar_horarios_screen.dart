import 'package:flutter/material.dart';

class GerenciarHorariosAppBar extends StatefulWidget {
  GerenciarHorariosAppBar({Key? key}) : super(key: key);

  @override
  _GerenciarHorariosAppBarState createState() =>
      _GerenciarHorariosAppBarState();
}

class _GerenciarHorariosAppBarState extends State<GerenciarHorariosAppBar> {
  bool switchValue1 = false;

  final List<Map<String, String>> horarios = [
    {'dia': 'Segunda-feira', 'horario': '08:00 - 18:00'},
    {'dia': 'Terça-feira', 'horario': '08:00 - 18:00'},
    {'dia': 'Quarta-feira', 'horario': '08:00 - 18:00'},
    {'dia': 'Quinta-feira', 'horario': '08:00 - 18:00'},
    {'dia': 'Sexta-feira', 'horario': '08:00 - 18:00'},
    {'dia': 'Sábado', 'horario': '09:00 - 14:00'},
    {'dia': 'Domingo', 'horario': 'Fechado'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Theme.of(context).colorScheme.onBackground,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Gerenciar Horários',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: const Icon(Icons.save_rounded),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                print('Salvar pressionado');
              },
            ),
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bloco superior
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Color(0x1A000000),
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Horário Semanal',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          Switch(
                            value: switchValue1,
                            onChanged: (newValue) {
                              setState(() {
                                switchValue1 = newValue;
                              });
                            },
                            activeColor: Colors.green,
                            inactiveTrackColor: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Configure seus horários de funcionamento para cada dia da semana',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Lista de horários
              ListView.builder(
                itemCount: horarios.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = horarios[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['dia']!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['horario']!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              tooltip: 'Editar horário',
                              onPressed: () {
                                // Ação de editar horário
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
