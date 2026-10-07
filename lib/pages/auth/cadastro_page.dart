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
  final anoAniversario = TextEditingController();
  final senha = TextEditingController();
  final senha2 = TextEditingController();

  final Set<String> restricoes = {};
  bool notificacoes = true;

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    telefone.dispose();
    anoAniversario.dispose();
    senha.dispose();
    senha2.dispose();
    super.dispose();
  }

  void _continuar() {
    final state = AppState.instance;

    // Todos os campos da primeira etapa são obrigatórios.
    if (nome.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        telefone.text.trim().isEmpty ||
        anoAniversario.text.trim().isEmpty ||
        senha.text.isEmpty ||
        senha2.text.isEmpty) {
      setState(() {
        erro = 'Preencha todos os campos obrigatórios.';
      });
      return;
    }

    // Validação do ano de aniversário.
    final ano = int.tryParse(anoAniversario.text.trim());

    if (ano == null ||
        anoAniversario.text.trim().length != 4 ||
        ano < 1900 ||
        ano > DateTime.now().year) {
      setState(() {
        erro = 'Informe um ano de aniversário válido.';
      });
      return;
    }

    if (state.emailJaCadastrado(email.text)) {
      setState(() {
        erro = 'Este e-mail já está cadastrado.';
      });
      return;
    }

    if (!AppState.senhaValida(senha.text)) {
      setState(() {
        erro =
            'A senha deve ter no mínimo 6 caracteres, 1 letra maiúscula e 1 caractere especial.';
      });
      return;
    }

    if (senha.text != senha2.text) {
      setState(() {
        erro = 'As senhas não coincidem.';
      });
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
    });
  }

  void _concluir() {
    if (restricoes.isEmpty) {
      setState(() {
        erro = 'Selecione uma opção ou escolha "Nenhuma".';
      });
      return;
    }

    final ano = int.tryParse(anoAniversario.text.trim());

    if (ano == null) {
      setState(() {
        erro = 'Informe um ano de aniversário válido.';
      });
      return;
    }

    AppState.instance.cadastrar(
      nome: nome.text.trim(),
      email: email.text.trim(),
      telefone: telefone.text.trim(),
      senha: senha.text,
      anoAniversario: ano,
      restricoes: restricoes.where((r) => r != 'nenhuma').toList(),
      notificacoes: notificacoes,
    );

    showToast(
      'Cadastro realizado com sucesso!',
      '🎉',
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.home,
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
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
        const Text(
          'Criar conta',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'CreamCake',
            fontSize: 42,
            fontWeight: FontWeight.w400,
            color: DVanilleColors.rose,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Junte-se a nós',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: DVanilleColors.darkTaupe,
          ),
        ),
        const SizedBox(height: 24),
        if (erro != null) CaixaAlerta(erro!),
        TextField(
          controller: nome,
          decoration: const InputDecoration(
            labelText: 'Nome completo *',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'E-mail *',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: telefone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefone *',
            hintText: '(11) 90000-0000',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: anoAniversario,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: 'Ano de aniversário *',
            hintText: 'Ex.: 2008',
            counterText: '',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: senha,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Senha *',
          ),
        ),
        const SizedBox(height: 6),
        const Align(
          alignment: Alignment.centerLeft,
          child: DicaCampo(
            'Mínimo 6 caracteres, com 1 letra maiúscula e 1 caractere especial.',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: senha2,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirmar senha *',
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _continuar,
            child: const Text(
              'Continuar',
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Já tem conta?',
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                Routes.login,
              ),
              child: const Text(
                'Entrar',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _etapa2() {
    return Column(
      children: [
        const Text(
          'Você possui alguma restrição alimentar?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'CreamCake',
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: DVanilleColors.rose,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Quase lá',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: DVanilleColors.darkTaupe,
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
                onTap: () => _alternarRestricao(o[0]),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DVanilleColors.line,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selecionado,
                        onChanged: (_) => _alternarRestricao(o[0]),
                      ),
                      Expanded(
                        child: Text(
                          o[1],
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
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
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Desejo receber notificações de ofertas e novidades',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _concluir,
            child: const Text(
              'Concluir cadastro',
            ),
          ),
        ),
      ],
    );
  }
}
