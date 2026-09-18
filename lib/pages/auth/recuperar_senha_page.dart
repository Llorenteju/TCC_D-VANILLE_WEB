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
  final email = TextEditingController();
  bool enviado = false;

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
          Text('Recuperar senha',
              style:
                  AppTheme.display(size: 30, color: DVanilleColors.darkTaupe)),
          const SizedBox(height: 8),
          const Text(
            'Informe seu e-mail cadastrado para receber o link de recuperação.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => setState(() => enviado = true),
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
        Text('Email enviado com sucesso!',
            textAlign: TextAlign.center,
            style: AppTheme.display(size: 30, color: DVanilleColors.darkTaupe)),
        const SizedBox(height: 10),
        const Text(
          'Enviamos um link de recuperação para o e-mail informado.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.login, (r) => false),
          child: const Text('Voltar ao login'),
        ),
      ],
    );
  }
}

/// Círculo verde com o "check" usado nas telas de sucesso.
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
      child: const Icon(Icons.check, size: 40, color: Color(0xFF3D6B3A)),
    );
  }
}
