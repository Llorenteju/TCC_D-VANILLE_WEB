import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';

/// Estrutura compartilhada das páginas do painel administrativo.
/// O painel não usa cabeçalho nem rodapé do site público.
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

  TextStyle _estiloTitulo(BuildContext context, bool estreito) {
    return TextStyle(
      fontFamily: 'CreamCake',
      fontSize: estreito ? 39 : 46,
      fontWeight: FontWeight.w400,
      color: AdminColors.titulo(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 980;

    final conteudo = SingleChildScrollView(
      padding: EdgeInsets.all(estreito ? 20 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo.trim().isNotEmpty) ...[
            Text(titulo, style: _estiloTitulo(context, estreito)),
            const SizedBox(height: 22),
          ],
          child,
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AdminColors.fundo(context),
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

  Widget _icone(BuildContext context, String arquivo, {bool ativo = false}) {
    return SvgPicture.asset(
      'assets/images/$arquivo',
      width: 23,
      height: 23,
      fit: BoxFit.contain,
      // Os SVGs originais são preservados; o filtro garante contraste
      // nos dois temas sem adicionar fundo branco aos ícones.
      colorFilter: ColorFilter.mode(
        ativo
            ? AdminColors.destaque(context)
            : AdminColors.textoSecundario(context),
        BlendMode.srcIn,
      ),
    );
  }

  void _navegar(BuildContext context, String rota) {
    if (rota == rotaAtual) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      rota,
      (route) => false,
    );
  }

  void _voltarAoSite(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.home,
      (route) => false,
    );
  }

  Future<void> _confirmarSaida(BuildContext context) async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AdminColors.card(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Sair da conta?',
            style: TextStyle(color: AdminColors.texto(dialogContext)),
          ),
          content: Text(
            'Você será desconectado da conta de administrador '
            'e voltará para a página inicial do site público.',
            style: TextStyle(
              color: AdminColors.textoSecundario(dialogContext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sair da conta'),
            ),
          ],
        );
      },
    );

    if (sair != true || !context.mounted) return;

    AppState.instance.logout();
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.home,
      (route) => false,
    );
  }

  Widget _botaoVoltarAoSite(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _voltarAoSite(context),
      icon: const Icon(Icons.arrow_back_rounded, size: 19),
      label: const Text('Voltar ao site público'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AdminColors.texto(context),
        backgroundColor: AdminColors.card(context),
        side: BorderSide(color: AdminColors.borda(context)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _botaoSair(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _confirmarSaida(context),
      icon: const Icon(Icons.logout_rounded, size: 19),
      label: const Text('Sair da conta'),
      style: TextButton.styleFrom(
        foregroundColor: AdminColors.sair(context),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _itemMenuLateral(BuildContext context, List<String> item) {
    final ativo = item[2] == rotaAtual;
    final corTexto = ativo
        ? AdminColors.destaque(context)
        : AdminColors.texto(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navegar(context, item[2]),
          borderRadius: BorderRadius.circular(14),
          hoverColor: AdminColors.destaque(context).withValues(alpha: 0.10),
          splashColor: AdminColors.destaque(context).withValues(alpha: 0.15),
          child: Ink(
            decoration: BoxDecoration(
              color: ativo
                  ? AdminColors.fundoSelecionado(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ativo
                    ? AdminColors.destaque(context).withValues(alpha: 0.35)
                    : Colors.transparent,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 25,
                    decoration: BoxDecoration(
                      color: ativo
                          ? AdminColors.destaque(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _icone(context, item[0], ativo: ativo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item[1],
                      style: TextStyle(
                        fontWeight: ativo ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 14,
                        color: corTexto,
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
      width: 254,
      decoration: BoxDecoration(
        color: AdminColors.menu(context),
        border: Border(
          right: BorderSide(color: AdminColors.borda(context)),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 22),
              children: itens.map((item) {
                return _itemMenuLateral(context, item);
              }).toList(),
            ),
          ),
          Divider(height: 1, color: AdminColors.borda(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _botaoVoltarAoSite(context),
                const SizedBox(height: 5),
                _botaoSair(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuHorizontal(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AdminColors.menu(context),
        border: Border(
          bottom: BorderSide(color: AdminColors.borda(context)),
        ),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
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
                      backgroundColor: ativo
                          ? AdminColors.fundoSelecionado(context)
                          : Colors.transparent,
                      foregroundColor: ativo
                          ? AdminColors.destaque(context)
                          : AdminColors.texto(context),
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
                        _icone(context, item[0], ativo: ativo),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _botaoVoltarAoSite(context),
                  _botaoSair(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabela reutilizável do Admin com contraste adaptado ao tema.
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
        color: AdminColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminColors.borda(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(AdminColors.menu(context)),
          headingTextStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AdminColors.texto(context),
          ),
          dataTextStyle: TextStyle(
            fontSize: 13.5,
            color: AdminColors.texto(context),
          ),
          columns: colunas.map((coluna) {
            return DataColumn(label: Text(coluna));
          }).toList(),
          rows: linhas,
        ),
      ),
    );
  }
}
