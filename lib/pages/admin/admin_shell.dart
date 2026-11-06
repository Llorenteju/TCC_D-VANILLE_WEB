import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';

class AdminShell extends StatelessWidget {
  final String titulo;
  final String rotaAtual;
  final Widget child;

  const AdminShell({
    super.key,
    required this.titulo,
    required this.rotaAtual,
    required this.child,
  });

  static const List<List<String>> itens = [
    ['dashboard.svg', 'Dashboard', Routes.admin],
    ['produtos.svg', 'Produtos', Routes.adminProdutos],
    ['ofertas.svg', 'Ofertas', Routes.adminOfertas],
    ['pedidos.svg', 'Pedidos', Routes.adminPedidos],
    ['agenda.svg', 'Reservas', Routes.adminReservas],
    ['presente.svg', 'Vale-presentes', Routes.adminValePresentes],
    ['perfil.svg', 'Usuários', Routes.adminUsuarios],
  ];

  TextStyle _estiloTitulo() {
    return const TextStyle(
      fontFamily: 'CreamCake',
      fontSize: 46,
      fontWeight: FontWeight.w400,
      color: DVanilleColors.darkTaupe,
    );
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 980;

    final conteudo = SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: _estiloTitulo()),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );

    return Scaffold(
      floatingActionButton: const BotaoAcessibilidade(),
      body: SafeArea(
        child: estreito
            ? Column(
                children: [
                  _menuHorizontal(context),
                  Expanded(child: conteudo),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _menuLateral(context),
                  Expanded(child: conteudo),
                ],
              ),
      ),
    );
  }

  // Usa os ícones SVG cadastrados, incluindo ofertas.svg.
  Widget _icone(String arquivo) {
    return SvgPicture.asset(
      'assets/images/$arquivo',
      width: 23,
      height: 23,
      fit: BoxFit.contain,
    );
  }

  void _navegar(BuildContext context, String rota) {
    if (rota == rotaAtual) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      rota,
      (route) => false,
    );
  }

  Widget _itemMenuLateral(BuildContext context, List<String> item) {
    final ativo = item[2] == rotaAtual;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navegar(context, item[2]),
          borderRadius: BorderRadius.circular(14),
          hoverColor: const Color(0x55F6DEDC),
          splashColor: const Color(0x44EFCDCC),
          child: Ink(
            decoration: BoxDecoration(
              color: ativo ? DVanilleColors.blush2 : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ativo ? const Color(0x44C98F8C) : Colors.transparent,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 25,
                    decoration: BoxDecoration(
                      color: ativo ? DVanilleColors.rose : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _icone(item[0]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item[1],
                      style: TextStyle(
                        fontWeight: ativo ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 14,
                        color: ativo
                            ? DVanilleColors.rose
                            : DVanilleColors.darkTaupe,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuLateral(BuildContext context) {
    return Container(
      width: 240,
      color: Theme.of(context).cardColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 22),
        children: itens.map((item) {
          return _itemMenuLateral(context, item);
        }).toList(),
      ),
    );
  }

  Widget _menuHorizontal(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: itens.map((item) {
            final ativo = item[2] == rotaAtual;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                onPressed: () => _navegar(context, item[2]),
                style: TextButton.styleFrom(
                  backgroundColor:
                      ativo ? DVanilleColors.blush2 : Colors.transparent,
                  foregroundColor:
                      ativo ? DVanilleColors.rose : DVanilleColors.darkTaupe,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _icone(item[0]),
                    const SizedBox(width: 9),
                    Text(
                      item[1],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Tabela rolável no eixo horizontal.
class TabelaAdmin extends StatelessWidget {
  final List<String> colunas;
  final List<DataRow> linhas;

  const TabelaAdmin({
    super.key,
    required this.colunas,
    required this.linhas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DVanilleColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
            color: DVanilleColors.darkTaupe,
          ),
          dataTextStyle: const TextStyle(fontSize: 13.5),
          columns: colunas.map((c) => DataColumn(label: Text(c))).toList(),
          rows: linhas,
        ),
      ),
    );
  }
}
