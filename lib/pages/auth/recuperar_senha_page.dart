
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

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get corDestaque =>
      isDark ? DVanilleColors.darkRose : DVanilleColors.rose;

  Color get corTexto => isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

  Color get corTextoSecundario =>
      isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

  RedirecionamentoLogin? get redirecionamento {
    final argumento = ModalRoute.of(context)?.settings.arguments;

    if (argumento is RedirecionamentoLogin &&
        argumento.rota == Routes.comandaMesa) {
      return argumento;
    }

    return null;
  }

  bool get veioDaComanda => redirecionamento != null;

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

  void _voltarLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.login,
      (r) => false,
      arguments: redirecionamento,
    );
  }

  ButtonStyle get estiloBotao {
    return FilledButton.styleFrom(
      backgroundColor: isDark ? DVanilleColors.darkRose : DVanilleColors.rose,
      foregroundColor: isDark ? DVanilleColors.darkCream : DVanilleColors.white,
      minimumSize: const Size(190, 52),
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 14,
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      mostrarCabecalho: !veioDaComanda,
      mostrarRodape: !veioDaComanda,
      centralizarConteudo: veioDaComanda,
      child: ContentWidth(
        maxWidth: 480,
        child: enviado ? _sucesso() : _formulario(),
      ),
    );
  }

  Widget _formulario() {
    return InfoBox(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recuperar senha',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CreamCake',
              fontSize: 42,
              fontWeight: FontWeight.w400,
              color: corDestaque,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informe seu e-mail cadastrado para receber '
            'as instruções de recuperação.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: corTexto,
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            style: TextStyle(color: corTexto),
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
              style: estiloBotao,
              child: const Text('Enviar'),
            ),
          ),
          TextButton(
            onPressed: _voltarLogin,
            child: const Text('Voltar ao login'),
          ),
        ],
      ),
    );
  }

  Widget _sucesso() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const IconeSucesso(),
        const SizedBox(height: 20),
        Text(
          'Solicitação realizada!',
          textAlign: TextAlign.center,
          style: AppTheme.display(
            size: 30,
            color: corTextoSecundario,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Se o e-mail informado estiver cadastrado, você receberá '
          'as instruções para recuperar sua senha.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: corTexto,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 220,
          height: 52,
          child: FilledButton(
            onPressed: _voltarLogin,
            style: estiloBotao,
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Voltar ao login'),
            ),
          ),
        ),
        const SizedBox(height: 6),
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

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }
}

class IconeSucesso extends StatelessWidget {
  const IconeSucesso({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: isDark ? DVanilleColors.darkSurface : const Color(0xFFE4EEE0),
        shape: BoxShape.circle,
        border: isDark ? Border.all(color: DVanilleColors.darkBorder) : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check,
        size: 40,
        color: isDark ? DVanilleColors.darkRose : const Color(0xFF3D6B3A),
      ),
    );
  }
}
