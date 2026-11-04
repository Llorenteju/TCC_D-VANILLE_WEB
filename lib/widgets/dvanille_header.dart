import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/app.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class DVanilleHeader extends StatelessWidget {
  final String? activeRoute;
  final bool mostrarCarrinho;

  const DVanilleHeader({
    super.key,
    this.activeRoute,
    this.mostrarCarrinho = true,
  });

  static const List<List<String>> _links = [
    ['HOME', Routes.home],
    ['CONHEÇA', Routes.conheca],
    ['CARDÁPIO', Routes.cardapio],
    ['CONTATO', Routes.contato],
    ['OFERTAS', Routes.ofertas],
    ['SHOPPING', Routes.shopping],
    ['RESERVAS', Routes.reservas],
  ];

  void _ir(BuildContext context, String rota) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      rota,
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final largura = MediaQuery.sizeOf(context).width;
    final compacto = largura < 1100;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: const Border(
              bottom: BorderSide(
                color: DVanilleColors.line,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              child: compacto
                  ? _headerCompacto(context, state)
                  : _headerDesktop(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _headerDesktop(
    BuildContext context,
    AppState state,
  ) {
    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _logo(context),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final link in _links) _navLink(context, link[0], link[1]),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: state.logado ? 'Meu perfil' : 'Entrar',
                  onPressed: () => _ir(
                    context,
                    state.logado ? Routes.perfil : Routes.login,
                  ),
                  icon: const Icon(
                    Icons.person_outline,
                    color: DVanilleColors.darkTaupe,
                    size: 28,
                  ),
                ),
                if (mostrarCarrinho) ...[
                  const SizedBox(width: 8),
                  _carrinho(context, state),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCompacto(
    BuildContext context,
    AppState state,
  ) {
    return SizedBox(
      height: 75,
      child: Row(
        children: [
          _logo(context),
          const Spacer(),
          IconButton(
            tooltip: state.logado ? 'Meu perfil' : 'Entrar',
            onPressed: () => _ir(
              context,
              state.logado ? Routes.perfil : Routes.login,
            ),
            icon: const Icon(
              Icons.person_outline,
              color: DVanilleColors.darkTaupe,
              size: 26,
            ),
          ),
          if (mostrarCarrinho) _carrinho(context, state),
          IconButton(
            tooltip: 'Menu',
            onPressed: () => _abrirMenu(context, state),
            icon: const Icon(
              Icons.menu,
              color: DVanilleColors.darkTaupe,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo(BuildContext context) {
    return InkWell(
      onTap: () => _ir(context, Routes.home),
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 130,
        height: 85,
        child: Transform.scale(
          scale: 1.45,
          child: SvgPicture.asset(
            'assets/images/logoreal.svg',
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _navLink(
    BuildContext context,
    String texto,
    String rota,
  ) {
    final ativo = activeRoute == rota;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextButton(
        onPressed: () => _ir(context, rota),
        style: TextButton.styleFrom(
          foregroundColor: DVanilleColors.darkTaupe,
          backgroundColor: ativo ? DVanilleColors.blush2 : Colors.transparent,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }

  Widget _carrinho(
    BuildContext context,
    AppState state,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: DVanilleColors.taupe,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            tooltip: 'Carrinho',
            onPressed: () => _ir(context, Routes.carrinho),
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
        if (state.totalItens > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: DVanilleColors.rose,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: Text(
                '${state.totalItens}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _abrirMenu(
    BuildContext context,
    AppState state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final link in _links)
              ListTile(
                title: Text(
                  link[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _ir(context, link[1]);
                },
              ),
            if (state.logado)
              ListTile(
                title: const Text(
                  'MEUS PEDIDOS',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _ir(context, Routes.meusPedidos);
                },
              ),
            if (state.isAdmin)
              ListTile(
                title: const Text(
                  'ÁREA ADMIN',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
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
