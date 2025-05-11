import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> criarAgendamento({
  required String barbeariaId,
  required String barbeiroId,
  required String servico,
  required DateTime dataHora,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('Usuário não autenticado');
  }

  final agendamento = {
    'clienteId': user.uid,
    'barbeariaId': barbeariaId,
    'barbeiroId': barbeiroId,
    'servico': servico,
    'dataHora': Timestamp.fromDate(dataHora),
    'confirmado': false,
    'cancelado': false,
    'criadoEm': FieldValue.serverTimestamp(),
  };

  await FirebaseFirestore.instance.collection('agendamentos').add(agendamento);
}
