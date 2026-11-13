import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  int etapa = 1;
  String? erro;

  final nome = TextEditingController();
  final email = TextEditingController();
  final telefone = TextEditingController();
  final dataNascimento = TextEditingController();
  final senha = TextEditingController();
  final senha2 = TextEditingController();

  // Cada campo tem seu próprio controle de visualização.
  bool mostrarSenha = false;
  bool mostrarConfirmacaoSenha = false;

  DateTime? dataNascimentoSelecionada;
  final Set<String> restricoes = {};
  bool notificacoes = true;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get corTexto => isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

  Color get corTextoSecundario =>
      isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

  Color get corBorda =>
      isDark ? DVanilleColors.darkBorder : DVanilleColors.line;

  Color get corDestaque =>
      isDark ? DVanilleColors.darkRose : DVanilleColors.rose;

  // Identifica se o cadastro foi aberto a partir da comanda.
  RedirecionamentoLogin? get redirecionamento {
    final argumento = ModalRoute.of(context)?.settings.arguments;

    if (argumento is RedirecionamentoLogin &&
        argumento.rota == Routes.comandaMesa) {
      return argumento;
    }

    return null;
  }

  bool get veioDaComanda => redirecionamento != null;

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    telefone.dispose();
    dataNascimento.dispose();
    senha.dispose();
    senha2.dispose();
    super.dispose();
  }

  String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

  String _formatarData(DateTime data) {
    return '${_doisDigitos(data.day)}/'
        '${_doisDigitos(data.month)}/'
        '${data.year}';
  }

  Future<void> _selecionarDataNascimento() async {
    final hoje = DateTime.now();
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataNascimentoSelecionada ?? hoje,
      firstDate: DateTime(1900),
      lastDate: hoje,
      helpText: 'Selecione sua data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      fieldLabelText: 'Data de nascimento',
      errorFormatText: 'Informe uma data válida.',
      errorInvalidText: 'Selecione uma data válida.',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: corDestaque,
                  onPrimary:
                      isDark ? DVanilleColors.darkCream : DVanilleColors.white,
                  surface: isDark
                      ? DVanilleColors.darkSurface
                      : DVanilleColors.cream,
                  onSurface: corTexto,
                ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada == null || !mounted) return;

    setState(() {
      dataNascimentoSelecionada = dataSelecionada;
      dataNascimento.text = _formatarData(dataSelecionada);
      erro = null;
    });
  }

  void _continuar() {
    final state = AppState.instance;

    if (nome.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        telefone.text.trim().isEmpty ||
        dataNascimentoSelecionada == null ||
        senha.text.isEmpty ||
        senha2.text.isEmpty) {
      setState(() => erro = 'Preencha todos os campos obrigatórios.');
      return;
    }

    if (state.emailJaCadastrado(email.text.trim())) {
      setState(() => erro = 'Este e-mail já está cadastrado.');
      return;
    }

    if (!AppState.senhaValida(senha.text)) {
      setState(() {
        erro = 'A senha deve ter no mínimo 6 caracteres, '
            '1 letra maiúscula e 1 caractere especial.';
      });
      return;
    }

    if (senha.text != senha2.text) {
      setState(() => erro = 'As senhas não coincidem.');
      return;
    }

    setState(() {
      erro = null;
      etapa = 2;
    });
  }

  void _alternarRestricao(String id) {
    setState(() {
      if (id == 'nenhuma') {
        if (restricoes.contains('nenhuma')) {
          restricoes.remove('nenhuma');
        } else {
          restricoes
            ..clear()
            ..add('nenhuma');
        }
        return;
      }

      if (restricoes.contains(id)) {
        restricoes.remove(id);
      } else {
        restricoes
          ..remove('nenhuma')
          ..add(id);
      }

      erro = null;
    });
  }

  void _concluir() {
    if (restricoes.isEmpty) {
      setState(() {
        erro = 'Selecione uma opção ou escolha "Nenhuma".';
      });
      return;
    }

    final nascimento = dataNascimentoSelecionada;
    if (nascimento == null) {
      setState(() {
        etapa = 1;
        erro = 'Informe sua data de nascimento completa.';
      });
      return;
    }

    AppState.instance.cadastrar(
      nome: nome.text.trim(),
      email: email.text.trim(),
      telefone: telefone.text.trim(),
      senha: senha.text,
      dataNascimento: nascimento,
      restricoes: restricoes.where((r) => r != 'nenhuma').toList(),
      notificacoes: notificacoes,
    );

    showToast('Cadastro realizado com sucesso!', '🎉');

    final destino = redirecionamento;
    Navigator.of(context).pushNamedAndRemoveUntil(
      destino?.rota ?? Routes.home,
      (r) => false,
      arguments: destino?.argumentos,
    );
  }

  // Ícone de olho com a mesma paleta do restante do formulário.
  Widget _botaoVisibilidadeSenha({
    required bool visivel,
    required VoidCallback alternar,
    required String campo,
  }) {
    return IconButton(
      tooltip: visivel ? 'Ocultar $campo' : 'Mostrar $campo',
      onPressed: alternar,
      icon: Icon(
        visivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: corTextoSecundario,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      mostrarCabecalho: !veioDaComanda,
      mostrarRodape: !veioDaComanda,
      child: Column(
        children: [
          const SizedBox(height: 56),
          ContentWidth(
            maxWidth: 520,
            child: InfoBox(
              padding: const EdgeInsets.all(32),
              child: etapa == 1 ? _etapa1() : _etapa2(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etapa1() {
    return Column(
      children: [
        Text(
          'Criar conta',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'CreamCake',
            fontSize: 42,
            fontWeight: FontWeight.w400,
            color: corDestaque,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Junte-se a nós',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: corTextoSecundario,
          ),
        ),
        const SizedBox(height: 24),
        if (erro != null) CaixaAlerta(erro!),
        TextField(
          controller: nome,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: corTexto),
          decoration: const InputDecoration(labelText: 'Nome completo *'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: corTexto),
          decoration: const InputDecoration(labelText: 'E-mail *'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: telefone,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: corTexto),
          decoration: const InputDecoration(
            labelText: 'Telefone *',
            hintText: '(11) 90000-0000',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: dataNascimento,
          readOnly: true,
          onTap: _selecionarDataNascimento,
          style: TextStyle(color: corTexto),
          decoration: const InputDecoration(
            labelText: 'Data de nascimento *',
            hintText: 'dd/mm/aaaa',
            suffixIcon: Icon(Icons.calendar_month),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: senha,
          obscureText: !mostrarSenha,
          autocorrect: false,
          enableSuggestions: false,
          style: TextStyle(color: corTexto),
          decoration: InputDecoration(
            labelText: 'Senha *',
            suffixIcon: _botaoVisibilidadeSenha(
              visivel: mostrarSenha,
              campo: 'senha',
              alternar: () => setState(() {
                mostrarSenha = !mostrarSenha;
              }),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: DicaCampo(
            'Mínimo 6 caracteres, com 1 letra maiúscula e 1 caractere especial.',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: senha2,
          obscureText: !mostrarConfirmacaoSenha,
          autocorrect: false,
          enableSuggestions: false,
          style: TextStyle(color: corTexto),
          decoration: InputDecoration(
            labelText: 'Confirmar senha *',
            suffixIcon: _botaoVisibilidadeSenha(
              visivel: mostrarConfirmacaoSenha,
              campo: 'confirmação de senha',
              alternar: () => setState(() {
                mostrarConfirmacaoSenha = !mostrarConfirmacaoSenha;
              }),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _continuar,
            child: const Text('Continuar'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Já tem conta?', style: TextStyle(color: corTexto)),
            TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                Routes.login,
                arguments: redirecionamento,
              ),
              child: const Text('Entrar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _etapa2() {
    return Column(
      children: [
        Text(
          'Você possui alguma restrição alimentar?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'CreamCake',
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: corDestaque,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Quase lá',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: corTextoSecundario,
          ),
        ),
        const SizedBox(height: 22),
        if (erro != null) CaixaAlerta(erro!),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: opcoesRestricaoCadastro.map((o) {
            final selecionado = restricoes.contains(o[0]);
            return SizedBox(
              width: 210,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _alternarRestricao(o[0]),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selecionado
                        ? (isDark
                            ? DVanilleColors.darkCream
                            : DVanilleColors.blush2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selecionado ? corDestaque : corBorda,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selecionado,
                        activeColor: corDestaque,
                        checkColor: isDark
                            ? DVanilleColors.darkCream
                            : DVanilleColors.white,
                        onChanged: (_) => _alternarRestricao(o[0]),
                      ),
                      Expanded(
                        child: Text(
                          o[1],
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: corTexto,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        CheckboxListTile(
          value: notificacoes,
          onChanged: (v) => setState(
            () => notificacoes = v ?? false,
          ),
          activeColor: corDestaque,
          checkColor: isDark ? DVanilleColors.darkCream : DVanilleColors.white,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Desejo receber notificações de ofertas e novidades',
            style: TextStyle(
              fontSize: 14,
              color: corTexto,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _concluir,
            child: const Text('Concluir cadastro'),
          ),
        ),
      ],
    );
  }
}
