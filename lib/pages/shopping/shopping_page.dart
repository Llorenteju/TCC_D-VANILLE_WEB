
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../models/item_carrinho.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  double valor = 50;

  final nome = TextEditingController();
  final mensagem = TextEditingController();

  String? erro;

  static const valores = [
    30.0,
    50.0,
    100.0,
    150.0,
  ];

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get corTitulo =>
      isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

  Color get corTexto =>
      isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

  Color get corDestaque =>
      isDark ? DVanilleColors.darkRose : DVanilleColors.rose;

  @override
  void dispose() {
    nome.dispose();
    mensagem.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _adicionar() {
    final destinatario = nome.text.trim();
    final textoMensagem = mensagem.text.trim();

    if (destinatario.isEmpty) {
      _mostrarMensagem(
        'Informe o nome de quem receberá o vale-presente.',
      );
      return;
    }

    final state = AppState.instance;

    state.adicionarItem(
      ItemCarrinho(
        id: 'gift-${DateTime.now().millisecondsSinceEpoch}',
        nome: "Vale-presente D'Vanille (${money(valor)})",
        preco: valor,
        icon: '🎁',
        tipo: TipoItemCarrinho.valePresente,
        destinatario: destinatario,
        mensagem: textoMensagem,
      ),
    );

    _mostrarMensagem(
      'Vale-presente adicionado ao carrinho!',
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.carrinho,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      activeRoute: Routes.shopping,
      child: Column(
        children: [
          const SizedBox(height: 56),
          ContentWidth(
            child: Column(
              children: [
                Text(
                  'Shopping — Vale-presente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'CreamCake',
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: corDestaque,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Presenteie com carinho',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: corTitulo,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 65),
          ContentWidth(
            maxWidth: 820,
            child: Column(
              children: [
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  alignment: WrapAlignment.center,
                  children: valores.map(_cartao).toList(),
                ),
                const SizedBox(height: 70),
                InfoBox(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalize seu presente',
                        style: TextStyle(
                          fontFamily: 'CreamCake',
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          color: corTitulo,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (erro != null) CaixaAlerta(erro!),
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Valor selecionado',
                        ),
                        child: Text(
                          money(valor),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: corTitulo,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: nome,
                        style: TextStyle(color: corTexto),
                        decoration: const InputDecoration(
                          labelText: 'Nome do presenteado',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: mensagem,
                        maxLines: 3,
                        style: TextStyle(color: corTexto),
                        decoration: const InputDecoration(
                          labelText: 'Mensagem',
                          hintText: 'Escreva uma mensagem especial...',
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _adicionar,
                          child: const Text(
                            'Adicionar ao carrinho',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 56),
        ],
      ),
    );
  }

  Widget _cartao(double v) {
    final selecionado = v == valor;

    final coresGradiente = isDark
        ? const [
            Color(0xFF57403F),
            Color(0xFF624747),
            Color(0xFF503B3B),
            Color(0xFF684B4B),
            Color(0xFF57403F),
          ]
        : const [
            Color(0xFFF2D1D2),
            Color(0xFFEFC9CA),
            Color(0xFFF5DCDD),
            Color(0xFFEBC3C5),
            Color(0xFFEFCACB),
          ];

    final corCartaoTexto =
        isDark ? DVanilleColors.darkInk : DVanilleColors.taupe;

    return InkWell(
      onTap: () {
        setState(() {
          valor = v;
          erro = null;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 190,
        height: 185,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [
              0.0,
              0.35,
              0.55,
              0.75,
              1.0,
            ],
            colors: coresGradiente,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selecionado
                ? corDestaque
                : isDark
                    ? DVanilleColors.darkBorder
                    : Colors.transparent,
            width: selecionado ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: corDestaque.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "VALE-PRESENTE D'VANILLE",
              style: TextStyle(
                color: corCartaoTexto,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: .6,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  money(v),
                  maxLines: 1,
                  softWrap: false,
                  style: AppTheme.display(
                    size: 25,
                    weight: FontWeight.w700,
                    color: corCartaoTexto,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
