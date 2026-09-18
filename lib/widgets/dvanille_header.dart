import 'package:flutter/material.dart';

import '../app/app.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class DVanilleHeader extends StatelessWidget {
  final String? activeRoute;

  const DVanilleHeader({super.key, this.activeRoute});

  static const List<List<String>> _links = [
    ['HOME', Routes.home],
    ['CONHEÇA', Routes.conheca],
    ['CARDÁPIO', Routes.cardapio],
    ['CONTATO', Routes.contato],
    ['OFERTAS', Routes.ofertas],
    ['SHOPPING', Routes.shopping],
  ];

  void _ir(BuildContext context, String rota) {
    Navigator.of(context).pushNamedAndRemoveUntil(rota, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final largura = MediaQuery.sizeOf(context).width;
    final compacto = largura < 900;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: const Border(
                bottom: BorderSide(color: DVanilleColors.line)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _logo(context),
                  const Spacer(),
                  if (!compacto)
                    for (final link in _links)
                      _navLink(context, link[0], link[1]),
                  if (!compacto) const SizedBox(width: 6),
                  IconButton(
                    tooltip: state.logado ? 'Meu perfil' : 'Entrar',
                    onPressed: () => _ir(context,
                        state.logado ? Routes.perfil : Routes.login),
                    icon: const Icon(Icons.person_outline,
                        color: DVanilleColors.darkTaupe),
                  ),
                  _carrinho(context, state),
                  if (compacto)
                    IconButton(
                      tooltip: 'Menu',
                      onPressed: () => _abrirMenu(context, state),
                      icon: const Icon(Icons.menu,
                          color: DVanilleColors.darkTaupe),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _logo(BuildContext context) {
    return InkWell(
      onTap: () => _ir(context, Routes.home),
      borderRadius: BorderRadius.circular(30),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: DVanilleColors.blush, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('🌸', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Text("D'Vanille",
              style: AppTheme.display(
                  size: 24,
                  weight: FontWeight.w700,
                  color: DVanilleColors.darkTaupe)),
        ],
      ),
    );
  }

  Widget _navLink(BuildContext context, String texto, String rota) {
    final ativo = activeRoute == rota;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: () => _ir(context, rota),
        style: TextButton.styleFrom(
          foregroundColor: DVanilleColors.darkTaupe,
          backgroundColor:
              ativo ? DVanilleColors.blush2 : Colors.transparent,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: Text(texto,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: .7)),
      ),
    );
  }

  Widget _carrinho(BuildContext context, AppState state) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
              color: DVanilleColors.taupe, shape: BoxShape.circle),
          child: IconButton(
            tooltip: 'Carrinho',
            onPressed: () => _ir(context, Routes.carrinho),
            icon: const Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 20),
          ),
        ),
        if (state.totalItens > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: DVanilleColors.rose,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2),
              ),
              child: Text('${state.totalItens}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
          ),
      ],
    );
  }

  void _abrirMenu(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final link in _links)
              ListTile(
                title: Text(link[0],
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(context);
                  _ir(context, link[1]);
                },
              ),
            ListTile(
              title: const Text('RESERVAS',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(context);
                _ir(context, Routes.reservas);
              },
            ),
            if (state.logado)
              ListTile(
                title: const Text('MEUS PEDIDOS',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(context);
                  _ir(context, Routes.meusPedidos);
                },
              ),
            if (state.isAdmin)
              ListTile(
                title: const Text('ÁREA ADMIN',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(context);
                  _ir(context, Routes.admin);
                },
              ),
          ],
        ),
      ),
    );
  }
}
