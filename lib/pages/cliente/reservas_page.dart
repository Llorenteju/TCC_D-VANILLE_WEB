import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';
import '../../theme/app_theme.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final state = AppState.instance;

  final formularioKey = GlobalKey<FormState>();

  late final TextEditingController nome;
  late final TextEditingController email;
  late final TextEditingController telefone;

  final pessoas = TextEditingController(text: '2');
  final preferencias = TextEditingController();
  final observacoes = TextEditingController();

  DateTime? data;
  String horario = horariosReserva.first;

  bool tentouEnviar = false;

  @override
  void initState() {
    super.initState();

    final u = state.usuarioLogado;

    nome = TextEditingController(
      text: u?.nome ?? '',
    );

    email = TextEditingController(
      text: u?.email ?? '',
    );

    telefone = TextEditingController(
      text: u?.telefone ?? '',
    );
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
      firstDate: DateTime(
        hoje.year,
        hoje.month,
        hoje.day,
      ),
      lastDate: DateTime(
        hoje.year + 2,
      ),
      helpText: 'Selecione a data da reserva',
    );

    if (escolhida != null) {
      setState(() {
        data = escolhida;
      });
    }
  }

  String? _validarObrigatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    final emailDigitado = valor.trim();

    final emailValido = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(emailDigitado);

    if (!emailValido) {
      return 'Informe um e-mail válido';
    }

    return null;
  }

  String? _validarTelefone(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    final numeros = valor.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (numeros.length != 11) {
      return 'Informe um telefone com 11 números';
    }

    if (numeros[2] != '9') {
      return 'Informe um celular válido';
    }

    return null;
  }

  String? _validarPessoas(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    final quantidade = int.tryParse(
      valor.trim(),
    );

    if (quantidade == null || quantidade < 1) {
      return 'Informe uma quantidade válida';
    }

    return null;
  }

  void _solicitar() {
    FocusScope.of(context).unfocus();

    setState(() {
      tentouEnviar = true;
    });

    final valido = formularioKey.currentState?.validate() ?? false;

    if (!valido) {
      return;
    }

    if (data == null) {
      return;
    }

    final hoje = DateTime.now();

    final hojeSemHorario = DateTime(
      hoje.year,
      hoje.month,
      hoje.day,
    );

    if (data!.isBefore(hojeSemHorario)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A data da reserva não pode ser no passado.',
          ),
        ),
      );

      return;
    }

    final quantidade = int.tryParse(
          pessoas.text.trim(),
        ) ??
        0;

    if (quantidade < 1) {
      return;
    }

    final reserva = state.criarReserva(
      nome: nome.text.trim(),
      email: email.text.trim(),
      telefone: telefone.text.trim(),
      data: _formatarData(data!),
      horario: horario,
      pessoas: quantidade,
      preferencias: preferencias.text.trim(),
      observacoes: observacoes.text.trim(),
    );

    showToast(
      'Reserva realizada com sucesso!',
      'agenda.svg',
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.reservaConfirmada,
      (rota) => false,
      arguments: reserva.id,
    );
  }

  String _formatarData(DateTime data) {
    return '${data.year}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 720;

    final erroData = tentouEnviar && data == null ? 'Campo obrigatório' : null;

    return PageShell(
      child: Column(
        children: [
          const SizedBox(height: 56),

          // ==========================================================
          // TÍTULO
          // ==========================================================

          const ContentWidth(
            child: Column(
              children: [
                Text(
                  'Fazer uma reserva',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'CreamCake',
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: DVanilleColors.rose,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Garanta seu lugar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: DVanilleColors.darkTaupe,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ==========================================================
          // BOTÃO MINHAS RESERVAS
          // ==========================================================

          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.minhasReservas,
              );
            },
            icon: const Icon(
              Icons.calendar_month_outlined,
              size: 20,
            ),
            label: const Text(
              'Minhas reservas',
            ),
          ),

          const SizedBox(height: 41),

          // ==========================================================
          // FORMULÁRIO
          // ==========================================================

          ContentWidth(
            maxWidth: 760,
            child: Form(
              key: formularioKey,
              child: InfoBox(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // NOME + E-MAIL
                    // ==================================================

                    _par(
                      estreito,
                      [
                        TextFormField(
                          controller: nome,
                          validator: _validarObrigatorio,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Nome *',
                          ),
                        ),
                        TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validarEmail,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'E-mail *',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // TELEFONE + QUANTIDADE
                    // ==================================================

                    _par(
                      estreito,
                      [
                        TextFormField(
                          controller: telefone,
                          keyboardType: TextInputType.phone,
                          validator: _validarTelefone,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Telefone *',
                            hintText: '(11) 98765-4321',
                          ),
                        ),
                        TextFormField(
                          controller: pessoas,
                          keyboardType: TextInputType.number,
                          validator: _validarPessoas,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade de pessoas *',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // DATA + HORÁRIO
                    // ==================================================

                    _par(
                      estreito,
                      [
                        InkWell(
                          onTap: _escolherData,
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Data *',
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                size: 18,
                              ),
                              errorText: erroData,
                            ),
                            child: Text(
                              data == null
                                  ? 'Selecione uma data'
                                  : '${data!.day.toString().padLeft(2, '0')}/'
                                      '${data!.month.toString().padLeft(2, '0')}/'
                                      '${data!.year}',
                              style: TextStyle(
                                color:
                                    data == null ? DVanilleColors.taupe : null,
                              ),
                            ),
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          initialValue: horario,
                          decoration: const InputDecoration(
                            labelText: 'Horário *',
                          ),
                          items: horariosReserva
                              .map(
                                (horario) => DropdownMenuItem<String>(
                                  value: horario,
                                  child: Text(horario),
                                ),
                              )
                              .toList(),
                          onChanged: (valor) {
                            if (valor == null) {
                              return;
                            }

                            setState(() {
                              horario = valor;
                            });
                          },
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Campo obrigatório';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // PREFERÊNCIAS — OPCIONAL
                    // ==================================================

                    TextFormField(
                      controller: preferencias,
                      decoration: const InputDecoration(
                        labelText: 'Preferências de produtos',
                        hintText:
                            'Ex: mesa perto da janela, produtos sem glúten...',
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // INFORMAÇÕES ADICIONAIS — OPCIONAL
                    // ==================================================

                    TextFormField(
                      controller: observacoes,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Informações adicionais',
                        hintText: 'Digite alguma informação importante...',
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // BOTÃO
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _solicitar,
                        child: const Text(
                          'Solicitar reserva',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _par(
    bool estreito,
    List<Widget> filhos,
  ) {
    if (estreito) {
      return Column(
        children: [
          filhos[0],
          const SizedBox(height: 14),
          filhos[1],
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: filhos[0],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: filhos[1],
        ),
      ],
    );
  }
}
