import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showToast(
  String mensagem, [
  String icone = '✓',
  String? mesa,
]) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final messenger = messengerKey.currentState;

    if (messenger == null) return;

    const corTexto = Colors.white;
    final mensagemMinuscula = mensagem.toLowerCase();

    // Define o ícone da notificação.
    final iconeNotificacao = mensagemMinuscula.contains('senha alterada')
        ? 'trocarsenha.svg'
        : icone;

    late final Widget iconeWidget;

    if (iconeNotificacao == '🔒' || iconeNotificacao == 'cadeado.svg') {
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
    } else if (iconeNotificacao == '🎁' ||
        iconeNotificacao == 'presente.svg' ||
        iconeNotificacao == 'vales_finalizados') {
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
    } else if (iconeNotificacao == 'palmas.svg') {
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
    } else if (iconeNotificacao == 'tchau.svg' || iconeNotificacao == '👋') {
      iconeWidget = SvgPicture.asset(
        'assets/images/tchau.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else if (iconeNotificacao == 'trocarsenha.svg') {
      iconeWidget = SvgPicture.asset(
        'assets/images/trocarsenha.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else if (iconeNotificacao == 'lixeira.svg') {
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
    } else if (iconeNotificacao == 'carrinho.svg') {
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
    } else if (iconeNotificacao == 'comanda_mesa.svg' ||
        iconeNotificacao == 'comanda_mesa') {
      iconeWidget = SvgPicture.asset(
        'assets/images/comanda_mesa.svg',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else if (iconeNotificacao == 'cupom.svg') {
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
    } else if (iconeNotificacao == 'agenda.svg') {
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
    } else if (iconeNotificacao == 'confete.svg') {
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
        iconeNotificacao,
        style: const TextStyle(
          fontSize: 18,
          color: corTexto,
        ),
      );
    }

    // Ações disponíveis nas notificações.
    final mostrarMeusVales = iconeNotificacao == 'vales_finalizados';

    final mostrarIrAoCarrinho = iconeNotificacao == 'carrinho.svg';

    final mostrarVerComanda = (iconeNotificacao == 'comanda_mesa.svg' ||
            iconeNotificacao == 'comanda_mesa') &&
        mesa != null &&
        mesa.trim().isNotEmpty;

    messenger
      ..clearSnackBars()
      ..hideCurrentSnackBar()
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
          action: mostrarMeusVales
              ? SnackBarAction(
                  label: 'Meus vales-presente',
                  textColor: Colors.white,
                  onPressed: () {
                    navigatorKey.currentState?.pushNamed(
                      '/meus-vales-presente',
                    );
                  },
                )
              : mostrarIrAoCarrinho
                  ? SnackBarAction(
                      label: 'Ir ao carrinho',
                      textColor: Colors.white,
                      onPressed: () {
                        navigatorKey.currentState?.pushNamed(
                          '/carrinho',
                        );
                      },
                    )
                  : mostrarVerComanda
                      ? SnackBarAction(
                          label: 'Ver comanda',
                          textColor: Colors.white,
                          onPressed: () {
                            navigatorKey.currentState?.pushNamed(
                              '/comanda-mesa',
                              arguments: {
                                'mesa': mesa.trim(),
                              },
                            );
                          },
                        )
                      : null,

          // Tempo de exibição da notificação.
          duration: const Duration(milliseconds: 1000),

          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        ),
      );
  });
}
