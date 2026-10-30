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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final corTexto = isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

    final corTextoSecundario =
        isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

    final corDestaque =
        isDark ? DVanilleColors.darkRose : DVanilleColors.darkTaupe;

    final corBorda = isDark ? DVanilleColors.darkBorder : DVanilleColors.line;

    final id = ModalRoute.of(context)?.settings.arguments;

    final pedido = AppState.instance.pedidoPorId(id is String ? id : null) ??
        (AppState.instance.pedidos.isEmpty
            ? null
            : AppState.instance.pedidos.last);

    if (pedido == null) {
      return const PageShell(
        child: EstadoVazio(
          emoji: '📦',
          titulo: 'Pedido não encontrado.',
        ),
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
                Text(
                  'Pedido enviado com sucesso!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'CreamCake',
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: corDestaque,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Acompanhe abaixo os detalhes do seu pedido.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: corTextoSecundario,
                  ),
                ),
                const SizedBox(height: 24),
                InfoBox(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _linha(
                        'Número do pedido',
                        pedido.id,
                        isDark: isDark,
                        corTexto: corTexto,
                        corBorda: corBorda,
                        negrito: true,
                      ),
                      _linha(
                        'Horário',
                        pedido.data,
                        isDark: isDark,
                        corTexto: corTexto,
                        corBorda: corBorda,
                      ),
                      ...pedido.itens.map(
                        (i) => _linha(
                          '${i.qtd}x ${i.nome}',
                          money(i.subtotal),
                          isDark: isDark,
                          corTexto: corTexto,
                          corBorda: corBorda,
                        ),
                      ),
                      _linha(
                        'Total',
                        money(pedido.total),
                        isDark: isDark,
                        corTexto: corTexto,
                        corBorda: corBorda,
                        negrito: true,
                        ultima: true,
                      ),
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
                      style: isDark
                          ? OutlinedButton.styleFrom(
                              foregroundColor: DVanilleColors.darkRose,
                              side: BorderSide(
                                color: DVanilleColors.darkRose,
                              ),
                            )
                          : null,
                      onPressed: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.cardapio,
                        (r) => false,
                      ),
                      child: const Text('Voltar ao cardápio'),
                    ),
                    FilledButton(
                      style: isDark
                          ? FilledButton.styleFrom(
                              backgroundColor: DVanilleColors.darkRose,
                              foregroundColor: DVanilleColors.darkCream,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                      onPressed: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.meusPedidos,
                        (r) => false,
                      ),
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

  Widget _linha(
    String titulo,
    String valor, {
    required bool isDark,
    required Color corTexto,
    required Color corBorda,
    bool negrito = false,
    bool ultima = false,
  }) {
    final estilo = TextStyle(
      fontSize: 14,
      fontWeight: negrito ? FontWeight.w800 : FontWeight.w500,
      color: corTexto,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      decoration: ultima
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: corBorda,
                  style: BorderStyle.solid,
                ),
              ),
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              titulo,
              style: estilo,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: estilo,
            ),
          ),
        ],
      ),
    );
  }
}
