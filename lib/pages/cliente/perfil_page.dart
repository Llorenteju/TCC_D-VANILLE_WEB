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
  late final TextEditingController dataNascimento;

  final senhaAtual = TextEditingController();
  final novaSenha = TextEditingController();
  final confirmarSenha = TextEditingController();

  late Set<String> restricoes;

  DateTime? dataNascimentoSelecionada;
  late bool notificacoes;

  bool mostrarSenhaAtual = false;
  bool mostrarNovaSenha = false;
  bool mostrarConfirmacao = false;

  String? mensagem;

  @override
  void initState() {
    super.initState();

    final u = state.usuarioLogado;

    nome = TextEditingController(text: u?.nome ?? '');
    email = TextEditingController(text: u?.email ?? '');
    telefone = TextEditingController(text: u?.telefone ?? '');
    endereco = TextEditingController(text: u?.endereco ?? '');

    dataNascimentoSelecionada = u?.dataNascimento;

    dataNascimento = TextEditingController(
      text: u?.dataNascimento == null ? '' : _formatarData(u!.dataNascimento!),
    );

    restricoes = {...?u?.restricoes};
    notificacoes = u?.notificacoes ?? true;
  }

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    telefone.dispose();
    endereco.dispose();
    dataNascimento.dispose();
    senhaAtual.dispose();
    novaSenha.dispose();
    confirmarSenha.dispose();
    super.dispose();
  }

  String _doisDigitos(int valor) {
    return valor.toString().padLeft(2, '0');
  }

  String _formatarData(DateTime data) {
    return '${_doisDigitos(data.day)}/'
        '${_doisDigitos(data.month)}/'
        '${data.year}';
  }

  void _mostrarMensagem(String texto) {
    setState(() {
      mensagem = texto;
    });
  }

  Future<void> _selecionarDataNascimento() async {
    final hoje = DateTime.now();

    final selecionada = await showDatePicker(
      context: context,
      initialDate: dataNascimentoSelecionada ?? hoje,
      firstDate: DateTime(1900),
      lastDate: hoje,
      helpText: 'Selecione sua data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (selecionada == null || !mounted) {
      return;
    }

    setState(() {
      dataNascimentoSelecionada = selecionada;
      dataNascimento.text = _formatarData(selecionada);
      mensagem = null;
    });
  }

  void _salvar() {
    final usuario = state.usuarioLogado;

    if (usuario == null) {
      _mostrarMensagem('Entre na sua conta para editar o perfil.');
      return;
    }

    if (nome.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        telefone.text.trim().isEmpty) {
      _mostrarMensagem('Preencha nome, e-mail e telefone.');
      return;
    }

    if (!RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email.text.trim())) {
      _mostrarMensagem('Informe um endereço de e-mail válido.');
      return;
    }

    if (dataNascimentoSelecionada == null) {
      _mostrarMensagem('Selecione sua data de nascimento completa.');
      return;
    }

    if (state.emailJaCadastrado(email.text) &&
        email.text.trim().toLowerCase() != usuario.email.trim().toLowerCase()) {
      _mostrarMensagem('Este e-mail já está cadastrado.');
      return;
    }

    // Verifica se a pessoa iniciou uma troca de senha.
    final solicitouTrocaSenha = senhaAtual.text.isNotEmpty ||
        novaSenha.text.isNotEmpty ||
        confirmarSenha.text.isNotEmpty;

    if (solicitouTrocaSenha) {
      // Todos os campos são obrigatórios para trocar a senha.
      if (senhaAtual.text.isEmpty ||
          novaSenha.text.isEmpty ||
          confirmarSenha.text.isEmpty) {
        _mostrarMensagem(
          'Para trocar a senha, preencha a senha atual, '
          'a nova senha e a confirmação.',
        );
        return;
      }

      // Confere a senha atual antes de salvar qualquer alteração.
      if (senhaAtual.text != usuario.senha) {
        _mostrarMensagem(
          'A senha atual está incorreta. Confira e tente novamente.',
        );
        return;
      }

      // A confirmação precisa ser igual à nova senha.
      if (novaSenha.text != confirmarSenha.text) {
        _mostrarMensagem(
          'A confirmação não coincide com a nova senha.',
        );
        return;
      }

      // Aplica as regras de senha que já existem no projeto.
      if (!AppState.senhaValida(novaSenha.text)) {
        _mostrarMensagem(
          'A nova senha deve ter no mínimo 6 caracteres, '
          '1 letra maiúscula e 1 caractere especial.',
        );
        return;
      }

      if (novaSenha.text == usuario.senha) {
        _mostrarMensagem(
          'A nova senha deve ser diferente da senha atual.',
        );
        return;
      }
    }

    // Só atualiza os dados depois que todas as validações passam.
    state.atualizarPerfil(
      nome: nome.text.trim(),
      email: email.text.trim(),
      telefone: telefone.text.trim(),
      endereco: endereco.text.trim(),
      dataNascimento: dataNascimentoSelecionada,
      notificacoes: notificacoes,
      novaSenha: solicitouTrocaSenha ? novaSenha.text : null,
      restricoes: restricoes.toList(),
    );

    senhaAtual.clear();
    novaSenha.clear();
    confirmarSenha.clear();

    setState(() {
      mensagem = 'Dados atualizados com sucesso!';
    });

    showToast(
      'Perfil atualizado!',
      '✓',
    );

    if (solicitouTrocaSenha) {
      showToast(
        'Senha alterada! Se não foi você, proteja sua conta.',
        '🔐',
      );
    }
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      onChanged: (_) {
        if (mensagem != null) {
          setState(() {
            mensagem = null;
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }

  Widget _campoSenha({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool mostrar,
    required VoidCallback alternarVisibilidade,
  }) {
    return TextField(
      controller: controller,
      obscureText: !mostrar,
      autofillHints: const [AutofillHints.password],
      onChanged: (_) {
        if (mensagem != null) {
          setState(() {
            mensagem = null;
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: IconButton(
          tooltip: mostrar ? 'Ocultar senha' : 'Mostrar senha',
          onPressed: alternarVisibilidade,
          icon: Icon(
            mostrar ? Icons.visibility_off : Icons.visibility,
          ),
        ),
      ),
    );
  }

  Widget _informacao(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: DVanilleColors.darkTaupe,
              ),
            ),
          ),
          Expanded(
            child: Text(valor),
          ),
        ],
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
        Expanded(child: filhos[0]),
        const SizedBox(width: 14),
        Expanded(child: filhos[1]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 720;
    final usuario = state.usuarioLogado;

    final labelsRestricoes = <String, String>{
      ...restricoesLabels,
    };

    for (final opcao in opcoesRestricaoCadastro) {
      labelsRestricoes[opcao[0]] = opcao[1];
    }

    return PageShell(
      child: Column(
        children: [
          const SizedBox(height: 56),
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
                  if (mensagem != null) ...[
                    CaixaAlerta(
                      mensagem!,
                      erro: mensagem != 'Dados atualizados com sucesso!',
                    ),
                    const SizedBox(height: 14),
                  ],
                  const Text(
                    'Dados pessoais',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DVanilleColors.darkTaupe,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _linha(
                    estreito,
                    [
                      _campo(nome, 'Nome completo *'),
                      _campo(
                        email,
                        'E-mail *',
                        tipo: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _linha(
                    estreito,
                    [
                      _campo(
                        telefone,
                        'Telefone *',
                        tipo: TextInputType.phone,
                      ),
                      TextField(
                        controller: dataNascimento,
                        readOnly: true,
                        onTap: _selecionarDataNascimento,
                        decoration: const InputDecoration(
                          labelText: 'Data de nascimento *',
                          hintText: 'dd/mm/aaaa',
                          suffixIcon: Icon(Icons.calendar_month),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: endereco,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                      hintText: 'Informe seu endereço',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Segurança da conta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DVanilleColors.darkTaupe,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Para trocar sua senha, confirme a senha atual '
                    'e informe a nova senha duas vezes.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  _campoSenha(
                    controller: senhaAtual,
                    label: 'Senha atual',
                    hint: 'Obrigatória para trocar a senha',
                    mostrar: mostrarSenhaAtual,
                    alternarVisibilidade: () {
                      setState(() {
                        mostrarSenhaAtual = !mostrarSenhaAtual;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _campoSenha(
                    controller: novaSenha,
                    label: 'Nova senha (opcional)',
                    hint: 'Deixe em branco para manter a atual',
                    mostrar: mostrarNovaSenha,
                    alternarVisibilidade: () {
                      setState(() {
                        mostrarNovaSenha = !mostrarNovaSenha;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _campoSenha(
                    controller: confirmarSenha,
                    label: 'Confirmar nova senha',
                    hint: 'Digite novamente a nova senha',
                    mostrar: mostrarConfirmacao,
                    alternarVisibilidade: () {
                      setState(() {
                        mostrarConfirmacao = !mostrarConfirmacao;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  const DicaCampo(
                    'A senha deve ter no mínimo 6 caracteres, '
                    '1 letra maiúscula e 1 caractere especial. '
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Restrições alimentares',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DVanilleColors.darkTaupe,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecione todas as opções que se aplicam a você.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: labelsRestricoes.entries.map((e) {
                      final ativo = restricoes.contains(e.key);

                      return FilterChip(
                        label: Text(e.value),
                        selected: ativo,
                        selectedColor: DVanilleColors.blush,
                        checkmarkColor: DVanilleColors.darkTaupe,
                        onSelected: (valor) {
                          setState(() {
                            if (valor) {
                              if (e.key == 'nenhuma') {
                                restricoes
                                  ..clear()
                                  ..add('nenhuma');
                              } else {
                                restricoes
                                  ..remove('nenhuma')
                                  ..add(e.key);
                              }
                            } else {
                              restricoes.remove(e.key);
                            }

                            mensagem = null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Preferências',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DVanilleColors.darkTaupe,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: notificacoes,
                    onChanged: (valor) {
                      setState(() {
                        notificacoes = valor ?? false;
                        mensagem = null;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Desejo receber notificações de ofertas e novidades',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Informações da conta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: DVanilleColors.darkTaupe,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _informacao(
                    'Tipo de conta',
                    usuario?.tipo == 'admin' ? 'Administrador' : 'Cliente',
                  ),
                  _informacao(
                    'Data de nascimento',
                    dataNascimento.text.isEmpty
                        ? 'Não informada'
                        : dataNascimento.text,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: _salvar,
                        child: const Text('Salvar alterações'),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          Routes.meusPedidos,
                        ),
                        child: const Text('Meus pedidos'),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          Routes.minhasReservas,
                        ),
                        child: const Text('Minhas reservas'),
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
                        child: const Text('Sair da conta'),
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
}
