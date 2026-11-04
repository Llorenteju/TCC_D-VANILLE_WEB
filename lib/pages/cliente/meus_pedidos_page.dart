import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class MeusPedidosPage extends StatelessWidget {
  const MeusPedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final corDestaque = isDark ? DVanilleColors.darkRose : DVanilleColors.rose;

    final corTextoSecundario =
        isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

    final corTexto = isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

    final estiloBotao = isDark
        ? FilledButton.styleFrom(
            backgroundColor: DVanilleColors.darkRose,
            foregroundColor: DVanilleColors.darkCream,
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 14,
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          )
        : null;

    return PageShell(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final meus = state.meusPedidos;

          return Column(
            children: [
              const SizedBox(height: 56),
              ContentWidth(
                child: Column(
                  children: [
                    Text(
                      'Meus pedidos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: corDestaque,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Acompanhe seus pedidos',
                      textAlign: TextAlign.center,
                      style: AppTheme.display(
                        size: 24,
                        color: corTextoSecundario,
                      ).copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (meus.isEmpty)
                EstadoVazio(
                  emoji: '📦',
                  titulo: 'Você ainda não fez nenhum pedido.',
                  acao: FilledButton(
                    style: estiloBotao,
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.cardapio,
                      (r) => false,
                    ),
                    child: const Text('Ver cardápio'),
                  ),
                )
              else
                ContentWidth(
                  child: Column(
                    children: meus
                        .map(
                          (p) => Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: InfoBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.id,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: corTexto,
                                          ),
                                        ),
                                      ),
                                      StatusPill(p.status),
                                      const SizedBox(width: 12),
                                      Text(
                                        money(p.total),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: corTextoSecundario,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  DicaCampo(p.data),
                                  const SizedBox(height: 6),
                                  Text(
                                    p.resumoItens,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: corTexto,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      Routes.acompanharPedido,
                                      arguments: p.id,
                                    ),
                                    style: isDark
                                        ? OutlinedButton.styleFrom(
                                            foregroundColor:
                                                DVanilleColors.darkRose,
                                            side: BorderSide(
                                              color: DVanilleColors.darkRose,
                                            ),
                                          )
                                        : null,
                                    child: const Text('Ver pedido'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
