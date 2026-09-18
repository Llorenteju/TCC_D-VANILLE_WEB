import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final state = AppState.instance;
  late final TextEditingController nome;
  late final TextEditingController email;
  late final TextEditingController telefone;
  final pessoas = TextEditingController(text: '2');
  final preferencias = TextEditingController();
  final observacoes = TextEditingController();

  DateTime? data;
  String horario = horariosReserva.first;
  String? erro;

  @override
  void initState() {
    super.initState();
    final u = state.usuarioLogado;
    nome = TextEditingController(text: u?.nome ?? '');
    email = TextEditingController(text: u?.email ?? '');
    telefone = TextEditingController(text: u?.telefone ?? '');
  }

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    telefone.dispose();
    pessoas.dispose();
    preferencias.dispose();
    observacoes.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: data ?? hoje,
      firstDate: DateTime(hoje.year, hoje.month, hoje.day),
      lastDate: DateTime(hoje.year + 2),
      helpText: 'Selecione a data da reserva',
    );
    if (escolhida != null) setState(() => data = escolhida);
  }

  void _solicitar() {
    final qtd = int.tryParse(pessoas.text) ?? 0;
    if (data == null) {
      setState(() => erro = 'Selecione uma data.');
      return;
    }
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    if (data!.isBefore(inicioHoje)) {
      setState(() => erro = 'A data da reserva não pode ser no passado.');
      return;
    }
    if (qtd < 1) {
      setState(
          () => erro = 'Informe uma quantidade válida de pessoas.');
      return;
    }

    final reserva = state.criarReserva(
      nome: nome.text.trim(),
      email: email.text.trim(),
      telefone: telefone.text.trim(),
      data: _formatarIso(data!),
      horario: horario,
      pessoas: qtd,
      preferencias: preferencias.text.trim(),
      observacoes: observacoes.text.trim(),
    );
    showToast('Reserva realizada com sucesso!', '📅');
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.reservaConfirmada,
      (r) => false,
      arguments: reserva.id,
    );
  }

  static String _formatarIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 720;

    return PageShell(
      child: Column(
        children: [
          const SizedBox(height: 56),
          const ContentWidth(
            child: SectionHead(
                eyebrow: 'Garanta seu lugar', titulo: 'Fazer uma reserva'),
          ),
          const SizedBox(height: 30),
          ContentWidth(
            maxWidth: 760,
            child: InfoBox(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (erro != null) CaixaAlerta(erro!),
                  _par(estreito, [
                    TextField(
                        controller: nome,
                        decoration:
                            const InputDecoration(labelText: 'Nome')),
                    TextField(
                        controller: email,
                        decoration:
                            const InputDecoration(labelText: 'E-mail')),
                  ]),
                  const SizedBox(height: 14),
                  _par(estreito, [
                    TextField(
                        controller: telefone,
                        keyboardType: TextInputType.phone,
                        decoration:
                            const InputDecoration(labelText: 'Telefone')),
                    TextField(
                      controller: pessoas,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Quantidade de pessoas'),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _par(estreito, [
                    InkWell(
                      onTap: _escolherData,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data',
                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(
                          data == null
                              ? 'Selecione uma data'
                              : '${data!.day.toString().padLeft(2, '0')}/${data!.month.toString().padLeft(2, '0')}/${data!.year}',
                          style: TextStyle(
                            color: data == null
                                ? DVanilleColors.taupe
                                : null,
                          ),
                        ),
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: horario,
                      decoration:
                          const InputDecoration(labelText: 'Horário'),
                      items: horariosReserva
                          .map((h) =>
                              DropdownMenuItem(value: h, child: Text(h)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => horario = v ?? horario),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  TextField(
                    controller: preferencias,
                    decoration: const InputDecoration(
                      labelText: 'Preferências de produtos',
                      hintText:
                          'Ex: mesa perto da janela, produtos sem glúten...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: observacoes,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Informações adicionais'),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        onPressed: _solicitar,
                        child: const Text('Solicitar reserva')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _par(bool estreito, List<Widget> filhos) {
    if (estreito) {
      return Column(
        children: [filhos[0], const SizedBox(height: 14), filhos[1]],
      );
    }
    return Row(
      children: [
        Expanded(child: filhos[0]),
        const SizedBox(width: 14),
        Expanded(child: filhos[1]),
      ],
    );
  }
}
