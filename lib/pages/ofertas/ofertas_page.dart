import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_kit.dart';

class OfertasPage extends StatelessWidget {
  const OfertasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return PageShell(
      activeRoute: Routes.ofertas,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final lista = state.ofertas;
          return Column(
            children: [
              const SizedBox(height: 56),
              const ContentWidth(
                child: SectionHead(eyebrow: 'Aproveite', titulo: 'Ofertas'),
              ),
              const SizedBox(height: 34),
              ContentWidth(
                child: Column(
                  children: [
                    if (lista.isEmpty)
                      const EstadoVazio(
                          emoji: '🏷️',
                          titulo: 'Nenhuma oferta disponível no momento.')
                    else
                      GradeProdutos(
                        produtos: lista,
                        mostrarPercentual: true,
                        acaoUnica: true,
                      ),
                    const SizedBox(height: 16),
                    const DicaCampo(
                      'Cupom: PRIMEIRACOMPRA · Válido até o fim do mês',
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    InfoBox(
                      child: Column(
                        children: [
                          Text("Bem-vindo(a) à D'Vanille",
                              textAlign: TextAlign.center,
                              style: AppTheme.display(
                                  size: 24,
                                  color: DVanilleColors.darkTaupe)),
                          const SizedBox(height: 8),
                          const Text(
                            'Ganhe um desconto especial na sua primeira compra com o cupom PRIMEIRACOMPRA, também disponível no nosso aplicativo mobile.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
