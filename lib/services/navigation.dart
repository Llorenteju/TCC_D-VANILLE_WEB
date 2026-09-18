import 'package:flutter/material.dart';

/// Chaves globais — permitem navegar e mostrar toasts de qualquer lugar,
/// como as funções navigate() e showToast() do protótipo HTML.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Mensagem flutuante equivalente ao #toast do HTML.
void showToast(String mensagem, [String icone = '✓']) {
  // Agendado para o fim do frame: o toast também é disparado durante a
  // troca de rotas, quando o ScaffoldMessenger ainda está sendo construído.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('$icone  $mensagem'),
          duration: const Duration(milliseconds: 2600),
          shape: const StadiumBorder(),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        ),
      );
  });
}
