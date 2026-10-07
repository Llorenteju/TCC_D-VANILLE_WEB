import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final state = AppState.instance;
  late final TextEditingController nome;
  late final TextEditingController email;
  late final TextEditingController telefone;
  late final TextEditingController endereco;
  final senha = TextEditingController();
  late Set<String> restricoes;
  String? mensagem;

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

    endereco = TextEditingController(
      text: u?.endereco ?? '',
    );

    restricoes = {...?u?.restricoes};
  }

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    telefone.dispose();
    endereco.dispose();
    senha.dispose();
    super.dispose();
  }

  void _salvar() {
    state.atualizarPerfil(
      nome: nome.text.trim(),
      email: email.text.trim(),
      telefone: telefone.text.trim(),
      endereco: endereco.text.trim(),
      novaSenha: senha.text.isEmpty ? null : senha.text,
      restricoes: restricoes.toList(),
    );

    senha.clear();

    setState(
      () => mensagem = 'Dados atualizados com sucesso!',
    );

    showToast(
      'Perfil atualizado!',
      '✓',
    );
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 720;

    return PageShell(
      child: Column(
        children: [
          const SizedBox(height: 56),

          // ==========================================================
          // CABEÇALHO
          // ==========================================================
          const ContentWidth(
            child: Column(
              children: [
                Text(
                  'Meu perfil',
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
                  'Minha conta',
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

          const SizedBox(height: 30),

          ContentWidth(
            maxWidth: 760,
            child: InfoBox(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mensagem != null)
                    CaixaAlerta(
                      mensagem!,
                      erro: false,
                    ),

                  _linha(
                    estreito,
                    [
                      _campo(
                        nome,
                        'Nome',
                      ),
                      _campo(
                        email,
                        'E-mail',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _linha(
                    estreito,
                    [
                      _campo(
                        telefone,
                        'Telefone',
                      ),
                      _campo(
                        endereco,
                        'Endereço',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: senha,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nova senha (opcional)',
                      hintText: 'Deixe em branco para manter a atual',
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Restrições alimentares',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: DVanilleColors.darkTaupe,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: restricoesLabels.entries.map((e) {
                      final ativo = restricoes.contains(e.key);

                      return FilterChip(
                        label: Text(e.value),
                        selected: ativo,
                        selectedColor: DVanilleColors.blush,
                        checkmarkColor: DVanilleColors.darkTaupe,
                        onSelected: (v) => setState(() {
                          if (v) {
                            restricoes.add(e.key);
                          } else {
                            restricoes.remove(e.key);
                          }
                        }),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // BOTÕES
                  // ==================================================
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: _salvar,
                        child: const Text(
                          'Salvar alterações',
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          Routes.meusPedidos,
                        ),
                        child: const Text(
                          'Meus pedidos',
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          Routes.minhasReservas,
                        ),
                        child: const Text(
                          'Minhas reservas',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          state.logout();

                          showToast(
                            'Você saiu da sua conta.',
                            '👋',
                          );

                          Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.home,
                            (r) => false,
                          );
                        },
                        child: const Text(
                          'Sair da conta',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(
    TextEditingController c,
    String label,
  ) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }

  Widget _linha(
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
