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

              // Título principal da página
              const ContentWidth(
                child: Column(
                  children: [
                    Text(
                      'Ofertas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Aproveite nossas ofertas especiais',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: DVanilleColors.darkTaupe,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              ContentWidth(
                child: Column(
                  children: [
                    if (lista.isEmpty)
                      const EstadoVazio(
                        emoji: '🏷️',
                        titulo: 'Nenhuma oferta disponível no momento.',
                      )
                    else
                      GradeProdutos(
                        produtos: lista,
                        mostrarPercentual: true,
                        acaoUnica: true,
                      ),
                    const SizedBox(height: 16),
                    const DicaCampo(
                      'Cupom: PRIMEIRACOMPRA · Válido para a primeira compra',
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    InfoBox(
                      child: Column(
                        children: [
                          Text(
                            "Bem Vindo à D'Vanille",
                            textAlign: TextAlign.center,
                            style: AppTheme.display(
                              size: 38,
                              color: DVanilleColors.darkTaupe,
                            ).copyWith(
                              fontFamily: 'CreamCake',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ganhe um desconto especial na sua primeira compra com o cupom PRIMEIRACOMPRA, também disponível no nosso aplicativo mobile.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Cupom de aniversário: disponível mediante verificação da data de nascimento cadastrada no perfil. O benefício é liberado durante o período do aniversário.',
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
