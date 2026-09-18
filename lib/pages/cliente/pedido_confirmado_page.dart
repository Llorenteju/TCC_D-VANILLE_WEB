import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';
import '../auth/recuperar_senha_page.dart' show IconeSucesso;

class PedidoConfirmadoPage extends StatelessWidget {
  const PedidoConfirmadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments;
    final pedido = AppState.instance.pedidoPorId(id is String ? id : null) ??
        (AppState.instance.pedidos.isEmpty
            ? null
            : AppState.instance.pedidos.last);

    if (pedido == null) {
      return const PageShell(
        child: EstadoVazio(emoji: '📦', titulo: 'Pedido não encontrado.'),
      );
    }

    return PageShell(
      child: Column(
        children: [
          const SizedBox(height: 48),
          ContentWidth(
            maxWidth: 560,
            child: Column(
              children: [
                const IconeSucesso(),
                const SizedBox(height: 18),
                Text('Pedido enviado com sucesso!',
                    textAlign: TextAlign.center,
                    style: AppTheme.display(
                        size: 30, color: DVanilleColors.darkTaupe)),
                const SizedBox(height: 8),
                const Text('Acompanhe abaixo os detalhes do seu pedido.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                InfoBox(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _linha('Número do pedido', pedido.id, negrito: true),
                      _linha('Horário', pedido.data),
                      ...pedido.itens.map((i) =>
                          _linha('${i.qtd}x ${i.nome}', money(i.subtotal))),
                      _linha('Total', money(pedido.total),
                          negrito: true, ultima: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                StatusPill(pedido.status),
                const SizedBox(height: 26),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                              Routes.cardapio, (r) => false),
                      child: const Text('Voltar ao cardápio'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                              Routes.meusPedidos, (r) => false),
                      child: const Text('Ver meus pedidos'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linha(String titulo, String valor,
      {bool negrito = false, bool ultima = false}) {
    final estilo = TextStyle(
      fontSize: 14,
      fontWeight: negrito ? FontWeight.w800 : FontWeight.w500,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: ultima
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: DVanilleColors.line, style: BorderStyle.solid),
              ),
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(titulo, style: estilo)),
          Text(valor, style: estilo),
        ],
      ),
    );
  }
}
