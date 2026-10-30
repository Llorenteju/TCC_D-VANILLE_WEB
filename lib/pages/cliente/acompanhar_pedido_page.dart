import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class AcompanharPedidoPage extends StatelessWidget {
  const AcompanharPedidoPage({super.key});

  /// Mesmas etapas do tracker do HTML.
  static const etapas = [
    ['recebido', 'Pedido recebido'],
    ['pagamento', 'Pagamento confirmado'],
    ['em preparação', 'Em preparação'],
    ['pronto', 'Pronto'],
    ['finalizado', 'Finalizado'],
  ];

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments;
    final state = AppState.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PageShell(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final pedido = state.pedidoPorId(id is String ? id : null);

          if (pedido == null) {
            return const EstadoVazio(
              emoji: '📦',
              titulo: 'Pedido não encontrado.',
            );
          }

          // "recebido" já considera o pagamento confirmado,
          // como no protótipo.
          final indiceAtual = pedido.status == 'recebido'
              ? 1
              : etapas.indexWhere((e) => e[0] == pedido.status);

          return Column(
            children: [
              const SizedBox(height: 56),
              ContentWidth(
                child: SectionHead(
                  eyebrow: 'Pedido ${pedido.id}',
                  titulo: 'Acompanhar pedido',
                ),
              ),
              const SizedBox(height: 34),
              ContentWidth(
                maxWidth: 440,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < etapas.length; i++)
                      _etapa(
                        etapas[i][1],
                        i <= indiceAtual,
                        i == etapas.length - 1,
                        isDark,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              OutlinedButton(
                style: isDark
                    ? OutlinedButton.styleFrom(
                        foregroundColor: DVanilleColors.darkRose,
                        side: BorderSide(
                          color: DVanilleColors.darkRose,
                        ),
                      )
                    : null,
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.meusPedidos,
                  (r) => false,
                ),
                child: const Text('Voltar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _etapa(
    String titulo,
    bool concluida,
    bool ultima,
    bool isDark,
  ) {
    final corConcluida =
        isDark ? DVanilleColors.darkRose : DVanilleColors.taupe;

    final corPendente =
        isDark ? DVanilleColors.darkSurface : DVanilleColors.cream2;

    final corBorda = isDark ? DVanilleColors.darkBorder : DVanilleColors.line;

    final corTexto = isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: concluida ? corConcluida : corPendente,
                  border: Border.all(
                    color: concluida ? corConcluida : corBorda,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  concluida ? '✓' : '○',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: concluida
                        ? (isDark ? DVanilleColors.darkCream : Colors.white)
                        : (isDark
                            ? DVanilleColors.darkTextSecondary
                            : DVanilleColors.taupe),
                  ),
                ),
              ),
              if (!ultima)
                Container(
                  width: 2,
                  height: 34,
                  color: concluida ? corConcluida : corBorda,
                ),
            ],
          ),
          const SizedBox(width: 14),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: corTexto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
