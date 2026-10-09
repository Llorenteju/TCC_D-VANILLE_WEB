
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final TextEditingController email = TextEditingController();

  bool enviado = false;
  String? erroEmail;

  bool _emailValido(String valor) {
    final emailNormalizado = valor.trim();

    final regex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    return regex.hasMatch(emailNormalizado);
  }

  void _enviar() {
    final emailInformado = email.text.trim();

    if (emailInformado.isEmpty) {
      setState(() {
        erroEmail = 'Informe seu e-mail.';
        enviado = false;
      });
      return;
    }

    if (!_emailValido(emailInformado)) {
      setState(() {
        erroEmail = 'Digite um e-mail válido. Ex.: nome@email.com';
        enviado = false;
      });
      return;
    }

    setState(() {
      erroEmail = null;
      enviado = true;
    });
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: Column(
        children: [
          const SizedBox(height: 56),
          ContentWidth(
            maxWidth: 480,
            child: enviado ? _sucesso() : _formulario(),
          ),
        ],
      ),
    );
  }

  Widget _formulario() {
    return InfoBox(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            'Recuperar senha',
            style: TextStyle(
              fontFamily: 'CreamCake',
              fontSize: 42,
              fontWeight: FontWeight.w400,
              color: DVanilleColors.rose,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Informe seu e-mail cadastrado para receber '
            'as instruções de recuperação.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            onChanged: (_) {
              if (erroEmail != null) {
                setState(() {
                  erroEmail = null;
                });
              }
            },
            onSubmitted: (_) => _enviar(),
            decoration: InputDecoration(
              labelText: 'E-mail',
              hintText: 'nome@email.com',
              errorText: erroEmail,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _enviar,
              child: const Text('Enviar'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.login, (r) => false),
            child: const Text('Voltar ao login'),
          ),
        ],
      ),
    );
  }

  Widget _sucesso() {
    return Column(
      children: [
        const IconeSucesso(),
        const SizedBox(height: 20),
        Text(
          'Solicitação realizada!',
          textAlign: TextAlign.center,
          style: AppTheme.display(
            size: 30,
            color: DVanilleColors.darkTaupe,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Se o e-mail informado estiver cadastrado, você receberá '
          'as instruções para recuperar sua senha.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.login, (r) => false),
          child: const Text('Voltar ao login'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              enviado = false;
              erroEmail = null;
            });
          },
          child: const Text('Tentar outro e-mail'),
        ),
      ],
    );
  }
}

/// Ícone compartilhado pelas telas de confirmação.
class IconeSucesso extends StatelessWidget {
  const IconeSucesso({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: const BoxDecoration(
        color: Color(0xFFE4EEE0),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.check,
        size: 40,
        color: Color(0xFF3D6B3A),
      ),
    );
  }
}
