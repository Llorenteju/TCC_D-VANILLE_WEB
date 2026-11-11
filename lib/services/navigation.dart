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

    // ================= ÍCONE DA NOTIFICAÇÃO =================

    // Mantém o ícone especial de alteração de senha.
    final iconeNotificacao = mensagemMinuscula.contains('senha alterada')
        ? 'trocarsenha.svg'
        : icone;

    // Converte os emojis e nomes especiais
    // utilizados anteriormente para seus respectivos SVGs.
    const Map<String, String> iconesEspeciais = {
      '🔒': 'cadeado.svg',
      '🎁': 'presente.svg',
      '👋': 'tchau.svg',
      'vales_finalizados': 'presente.svg',
      'comanda_mesa': 'comanda_mesa.svg',
    };

    final nomeIcone = iconesEspeciais[iconeNotificacao] ?? iconeNotificacao;

    late final Widget iconeWidget;

    // Reconhece automaticamente qualquer arquivo SVG.
    if (nomeIcone.toLowerCase().endsWith('.svg')) {
      iconeWidget = SvgPicture.asset(
        'assets/images/$nomeIcone',
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          corTexto,
          BlendMode.srcIn,
        ),
      );
    } else {
      // Mantém o suporte a emojis e símbolos.
      iconeWidget = Text(
        iconeNotificacao,
        style: const TextStyle(
          fontSize: 18,
          color: corTexto,
        ),
      );
    }

    // ================= AÇÕES DA NOTIFICAÇÃO =================

    final mostrarMeusVales = iconeNotificacao == 'vales_finalizados';

    final mostrarIrAoCarrinho = iconeNotificacao == 'carrinho.svg';

    final mostrarVerComanda = (iconeNotificacao == 'comanda_mesa.svg' ||
            iconeNotificacao == 'comanda_mesa') &&
        mesa != null &&
        mesa.trim().isNotEmpty;

    // ================= EXIBIR NOTIFICAÇÃO =================

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

          // ================= BOTÕES OPCIONAIS =================

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

          // ================= ESTILO =================

          duration: const Duration(
            milliseconds: 1000,
          ),

          behavior: SnackBarBehavior.floating,

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
