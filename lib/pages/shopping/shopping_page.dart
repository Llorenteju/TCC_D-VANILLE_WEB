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
  bool _aceitouCondicoes = false;

  static const valores = <double>[
    30.0,
    50.0,
    100.0,
    150.0,
  ];

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get corTitulo =>
      isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

  Color get corTexto => isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

  Color get corDestaque =>
      isDark ? DVanilleColors.darkRose : DVanilleColors.rose;

  Color get corSecundaria =>
      isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.taupe;

  Color get corBorda =>
      isDark ? DVanilleColors.darkBorder : DVanilleColors.line;

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
    if (AppState.instance.isAdmin) {
      _mostrarMensagem(AppState.avisoContaAdministrativa);
      return;
    }
    final destinatario = nome.text.trim();
    final textoMensagem = mensagem.text.trim();

    if (destinatario.isEmpty) {
      setState(() {
        erro = 'Informe o nome de quem receberá o vale-presente.';
      });
      _mostrarMensagem(erro!);
      return;
    }

    if (!_aceitouCondicoes) {
      setState(() {
        erro = 'Leia e confirme as condições de utilização do vale-presente.';
      });
      _mostrarMensagem(erro!);
      return;
    }

    final state = AppState.instance;

    state.adicionarItem(
      ItemCarrinho(
        id: 'gift-${DateTime.now().microsecondsSinceEpoch}',
        nome: "Vale-presente D'Vanille (${money(valor)})",
        preco: valor,
        icon: '🎁',
        tipo: TipoItemCarrinho.valePresente,
        destinatario: destinatario,
        mensagem: textoMensagem,
      ),
    );

    _mostrarMensagem('Vale-presente adicionado ao carrinho!');

    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.carrinho,
      (route) => false,
    );
  }

  Widget _itemCondicao(IconData icone, String titulo, String descricao) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  isDark ? DVanilleColors.darkSurface : DVanilleColors.blush2,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icone, color: corDestaque, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: corTexto,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: TextStyle(
                    color: corSecundaria,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _condicoesDeUso() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: corBorda),
        color: isDark ? DVanilleColors.darkSurface : DVanilleColors.cream,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como utilizar seu vale-presente',
            style: TextStyle(
              fontFamily: 'CreamCake',
              fontSize: 30,
              color: corTitulo,
            ),
          ),
          const SizedBox(height: 16),
          _itemCondicao(
            Icons.storefront_outlined,
            'Uso somente na cafeteria física',
            'Apresente o código ao funcionário da D’Vanille no momento da compra. '
                'Não é válido para pagar pedidos no site ou aplicativo.',
          ),
          _itemCondicao(
            Icons.looks_one_outlined,
            'Uma única utilização',
            'O vale é resgatado uma só vez. Após a confirmação pela equipe, '
                'seu status muda para Utilizado e o código não pode ser reutilizado.',
          ),
          _itemCondicao(
            Icons.payments_outlined,
            'Diferença de valor',
            'Se a compra for menor que o valor do vale, a diferença deve ser '
                'restituída conforme a legislação de defesa do consumidor. '
                'Se for maior, o cliente pode pagar a diferença no caixa.',
          ),
          _itemCondicao(
            Icons.event_outlined,
            'Validade do vale',
            'Todo vale novo tem validade automática de 30 dias úteis, contados '
                'a partir do dia seguinte à compra. Não são contados '
                'sábados, domingos e feriados nacionais aplicáveis. A data exata '
                'aparece em Meus vales-presente e no PDF.',
          ),
          const SizedBox(height: 2),
          Text(
            'Após a compra confirmada, o código ficará disponível na página '
            'Meus vales-presente, com as informações necessárias para apresentá-lo.',
            style: TextStyle(
              color: corSecundaria,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
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
                const SizedBox(height: 12),
                Text(
                  'Um presente especial para ser aproveitado presencialmente '
                  'na D’Vanille.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: corSecundaria,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
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
                const SizedBox(height: 40),
                _condicoesDeUso(),
                const SizedBox(height: 36),
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
                      if (erro != null) ...[
                        CaixaAlerta(erro!),
                        const SizedBox(height: 12),
                      ],
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
                      const SizedBox(height: 20),
                      CheckboxListTile(
                        value: _aceitouCondicoes,
                        onChanged: (valor) {
                          setState(() {
                            _aceitouCondicoes = valor ?? false;
                            erro = null;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: corDestaque,
                        title: Text(
                          'Li e estou ciente das condições: uso presencial, '
                          'uma única utilização e validade de 30 dias úteis.',
                          style: TextStyle(
                            color: corTexto,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (AppState.instance.isAdmin) ...[
                        Text(
                          AppState.avisoContaAdministrativa,
                          style: TextStyle(color: corSecundaria, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              AppState.instance.isAdmin ? null : _adicionar,
                          child: const Text('Adicionar ao carrinho'),
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
            stops: const [0.0, 0.35, 0.55, 0.75, 1.0],
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
