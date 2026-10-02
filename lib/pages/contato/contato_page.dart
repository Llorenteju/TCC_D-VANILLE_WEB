import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  bool erroFormulario = false;

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    assunto.dispose();
    mensagem.dispose();
    super.dispose();
  }

  bool _emailValido(String valor) {
    final email = valor.trim();

    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  void _enviar() {
    final nomeVazio = nome.text.trim().isEmpty;
    final emailVazio = email.text.trim().isEmpty;
    final assuntoVazio = assunto.text.trim().isEmpty;
    final mensagemVazia = mensagem.text.trim().isEmpty;

    final emailValido = emailVazio ? false : _emailValido(email.text);

    if (nomeVazio ||
        emailVazio ||
        !emailValido ||
        assuntoVazio ||
        mensagemVazia) {
      setState(() {
        erroFormulario = true;

        if (emailVazio || !emailValido) {
          enviado = 'Verifique os campos obrigatórios e o e-mail informado.';
        } else {
          enviado = 'Preencha todos os campos para enviar sua mensagem.';
        }
      });

      return;
    }

    // FRONT-END:
    // Futuramente, aqui será feita a integração
    // com o backend e o banco de dados.

    nome.clear();
    email.clear();
    assunto.clear();
    mensagem.clear();

    setState(() {
      erroFormulario = false;
      enviado = 'Mensagem enviada com sucesso! Em breve entraremos em contato.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 900;

    final informacoes = InfoBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações',
            style: AppTheme.display(
              size: 22,
              color: DVanilleColors.darkTaupe,
            ),
          ),
          const SizedBox(height: 12),
          _linha(
            Icons.place_outlined,
            'Rua das Baunilhas, 245 — São Paulo/SP',
          ),
          _linha(
            Icons.schedule,
            'Terça a Domingo',
          ),
          _linha(
            Icons.phone_outlined,
            '(11) 4002-8922 · WhatsApp',
          ),
          _linha(
            Icons.mail_outline,
            'contato@dvanille.com.br',
          ),
          _linhaInstagram(
            '@dvanille.cafe',
          ),
          const SizedBox(height: 14),
          const DicaCampo(
            "Equipe D'Vanille: Ana Clara, Julia, Karina e Viviane.",
          ),
        ],
      ),
    );

    final formulario = InfoBox(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          if (enviado != null)
            CaixaAlerta(
              enviado!,
              erro: erroFormulario,
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nome,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    errorText: erroFormulario && nome.text.trim().isEmpty
                        ? 'Preencha seu nome'
                        : null,
                  ),
                  onChanged: (_) {
                    if (erroFormulario) {
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'exemplo@email.com',
                    errorText: erroFormulario
                        ? email.text.trim().isEmpty
                            ? 'Preencha seu e-mail'
                            : !_emailValido(email.text)
                                ? 'Digite um e-mail válido'
                                : null
                        : null,
                  ),
                  onChanged: (_) {
                    if (erroFormulario) {
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: assunto,
            decoration: InputDecoration(
              labelText: 'Assunto',
              errorText: erroFormulario && assunto.text.trim().isEmpty
                  ? 'Preencha o assunto'
                  : null,
            ),
            onChanged: (_) {
              if (erroFormulario) {
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: mensagem,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Mensagem',
              alignLabelWithHint: true,
              errorText: erroFormulario && mensagem.text.trim().isEmpty
                  ? 'Digite sua mensagem'
                  : null,
            ),
            onChanged: (_) {
              if (erroFormulario) {
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _enviar,
              child: const Text(
                'Enviar mensagem',
              ),
            ),
          ),
        ],
      ),
    );

    return PageShell(
      activeRoute: Routes.contato,
      child: Column(
        children: [
          const SizedBox(height: 56),
          ContentWidth(
            child: Column(
              children: [
                Text(
                  'Fale conosco',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'CreamCake',
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: DVanilleColors.rose,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Entre em contato com a D'Vanille",
                  textAlign: TextAlign.center,
                  style: AppTheme.display(
                    size: 24,
                    weight: FontWeight.w600,
                    color: DVanilleColors.darkTaupe,
                  ).copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ContentWidth(
            child: estreito
                ? Column(
                    children: [
                      informacoes,
                      const SizedBox(height: 22),
                      formulario,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 10,
                        child: informacoes,
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        flex: 12,
                        child: formulario,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _linha(
    IconData icone,
    String texto,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 18,
            color: DVanilleColors.rose,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaInstagram(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/instalogo.svg',
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
