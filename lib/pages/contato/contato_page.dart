import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key});

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final nome = TextEditingController();
  final email = TextEditingController();
  final assunto = TextEditingController();
  final mensagem = TextEditingController();
  String? enviado;

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    assunto.dispose();
    mensagem.dispose();
    super.dispose();
  }

  void _enviar() {
    if (nome.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        assunto.text.trim().isEmpty ||
        mensagem.text.trim().isEmpty) {
      setState(() => enviado = null);
      return;
    }
    nome.clear();
    email.clear();
    assunto.clear();
    mensagem.clear();
    setState(() => enviado =
        'Mensagem enviada com sucesso! Em breve entraremos em contato.');
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 900;

    final informacoes = InfoBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informações',
              style:
                  AppTheme.display(size: 22, color: DVanilleColors.darkTaupe)),
          const SizedBox(height: 12),
          _linha(Icons.place_outlined,
              'Rua das Baunilhas, 245 — São Paulo/SP'),
          _linha(Icons.schedule, 'Terça a Domingo'),
          _linha(Icons.phone_outlined, '(11) 4002-8922 · WhatsApp'),
          _linha(Icons.mail_outline, 'contato@dvanille.com.br'),
          _linha(Icons.camera_alt_outlined, '@dvanille.cafe'),
          const SizedBox(height: 14),
          const DicaCampo(
              "Equipe D'Vanille: Ana Clara, Julia, Karina e Viviane."),
        ],
      ),
    );

    final formulario = InfoBox(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          if (enviado != null) CaixaAlerta(enviado!, erro: false),
          Row(
            children: [
              Expanded(
                child: TextField(
                    controller: nome,
                    decoration: const InputDecoration(labelText: 'Nome')),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'E-mail')),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
              controller: assunto,
              decoration: const InputDecoration(labelText: 'Assunto')),
          const SizedBox(height: 14),
          TextField(
            controller: mensagem,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Mensagem'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: _enviar,
                child: const Text('Enviar mensagem')),
          ),
        ],
      ),
    );

    return PageShell(
      activeRoute: Routes.contato,
      child: Column(
        children: [
          const SizedBox(height: 56),
          const ContentWidth(
            child: SectionHead(eyebrow: 'Fale conosco', titulo: 'Contato'),
          ),
          const SizedBox(height: 32),
          ContentWidth(
            child: estreito
                ? Column(children: [
                    informacoes,
                    const SizedBox(height: 22),
                    formulario,
                  ])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 10, child: informacoes),
                      const SizedBox(width: 28),
                      Expanded(flex: 12, child: formulario),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _linha(IconData icone, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: DVanilleColors.rose),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 14.5))),
        ],
      ),
    );
  }
}
