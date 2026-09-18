import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dvanille_header.dart';
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
    ['📊', 'Dashboard', Routes.admin],
    ['🧁', 'Produtos', Routes.adminProdutos],
    ['📦', 'Pedidos', Routes.adminPedidos],
    ['📅', 'Reservas', Routes.adminReservas],
    ['🎁', 'Vale-presentes', Routes.adminValePresentes],
    ['👤', 'Usuários', Routes.adminUsuarios],
  ];

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 980;

    final conteudo = SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: AppTheme.display(
                  size: 32, color: DVanilleColors.darkTaupe)),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );

    return Scaffold(
      floatingActionButton: const BotaoAcessibilidade(),
      body: Column(
        children: [
          const DVanilleHeader(),
          Expanded(
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
        ],
      ),
    );
  }

  Widget _menuLateral(BuildContext context) {
    return Container(
      width: 230,
      color: Theme.of(context).cardColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: itens.map((item) {
          final ativo = item[2] == rotaAtual;
          return InkWell(
            onTap: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(item[2], (r) => false),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 13),
              decoration: BoxDecoration(
                color: ativo ? DVanilleColors.blush2 : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color:
                        ativo ? DVanilleColors.rose : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(item[0]),
                  const SizedBox(width: 10),
                  Text(item[1],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: ativo
                            ? DVanilleColors.rose
                            : DVanilleColors.darkTaupe,
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _menuHorizontal(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: itens.map((item) {
            final ativo = item[2] == rotaAtual;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(item[2], (r) => false),
                style: TextButton.styleFrom(
                  backgroundColor:
                      ativo ? DVanilleColors.blush2 : Colors.transparent,
                  foregroundColor: ativo
                      ? DVanilleColors.rose
                      : DVanilleColors.darkTaupe,
                  shape: const StadiumBorder(),
                ),
                child: Text('${item[0]} ${item[1]}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Tabela rolável no eixo horizontal, como as .data-table do HTML.
class TabelaAdmin extends StatelessWidget {
  final List<String> colunas;
  final List<DataRow> linhas;

  const TabelaAdmin({super.key, required this.colunas, required this.linhas});

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
