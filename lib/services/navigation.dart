import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showToast(
  String mensagem, [
  String icone = '✓',
]) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final messenger = messengerKey.currentState;

    if (messenger == null) return;

    const corTexto = Colors.white;

    Widget iconeWidget;

    if (icone == '🔒' || icone == 'cadeado.svg') {
      iconeWidget = SvgPicture.asset(
        'assets/images/cadeado.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else if (icone == '🎁' || icone == 'presente.svg') {
      iconeWidget = SvgPicture.asset(
        'assets/images/presente.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else if (icone == 'palmas.svg') {
      iconeWidget = SvgPicture.asset(
        'assets/images/palmas.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else if (icone == 'lixeira.svg') {
      iconeWidget = SvgPicture.asset(
        'assets/images/lixeira.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else if (icone == 'carrinho.svg') {
      iconeWidget = SvgPicture.asset(
        'assets/images/carrinho.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else if (icone == 'cupom.svg') {
      iconeWidget = SvgPicture.asset(
        'assets/images/cupom.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else if (icone == 'agenda.svg') {
      iconeWidget = SvgPicture.asset(
        'assets/images/agenda.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else if (icone == 'confete.svg') {
      iconeWidget = SvgPicture.asset(
        'assets/images/confete.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else {
      iconeWidget = Text(
        icone,
        style: const TextStyle(
          fontSize: 18,
          color: corTexto,
        ),
      );
    }

    final mostrarIrAoCarrinho = icone == 'carrinho.svg';

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              iconeWidget,
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mensagem,
                  style: const TextStyle(
                    color: corTexto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          action: mostrarIrAoCarrinho
              ? SnackBarAction(
                  label: 'Ir ao carrinho',
                  textColor: Colors.white,
                  onPressed: () {
                    navigatorKey.currentState?.pushNamed(
                      '/carrinho',
                    );
                  },
                )
              : null,
          duration: const Duration(
            milliseconds: 4000,
          ),
          shape: const StadiumBorder(),
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            20,
          ),
        ),
      );
  });
}
