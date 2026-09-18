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

    return PageShell(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final meus = state.meusPedidos;

          return Column(
            children: [
              const SizedBox(height: 56),
              const ContentWidth(
                child: SectionHead(
                    eyebrow: 'Histórico', titulo: 'Meus pedidos'),
              ),
              const SizedBox(height: 30),
              if (meus.isEmpty)
                EstadoVazio(
                  emoji: '📦',
                  titulo: 'Você ainda não fez nenhum pedido.',
                  acao: FilledButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                            Routes.cardapio, (r) => false),
                    child: const Text('Ver cardápio'),
                  ),
                )
              else
                ContentWidth(
                  child: Column(
                    children: meus
                        .map((p) => Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              child: InfoBox(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(p.id,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w800,
                                                fontSize: 16)),
                                        const SizedBox(width: 12),
                                        StatusPill(p.status),
                                        const Spacer(),
                                        Text(money(p.total),
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w800,
                                                color: DVanilleColors
                                                    .darkTaupe)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    DicaCampo(p.data),
                                    const SizedBox(height: 6),
                                    Text(p.resumoItens,
                                        style:
                                            const TextStyle(fontSize: 14)),
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: () => Navigator.pushNamed(
                                          context, Routes.acompanharPedido,
                                          arguments: p.id),
                                      child: const Text('Ver pedido'),
                                    ),
                                  ],
                                ),
                              ),
                            ))
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
