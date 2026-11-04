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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final corDestaque = isDark ? DVanilleColors.darkRose : DVanilleColors.rose;

    final corTitulo =
        isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

    final corTexto = isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

    return PageShell(
      activeRoute: Routes.ofertas,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final lista = state.ofertas;

          return Column(
            children: [
              const SizedBox(height: 56),
              ContentWidth(
                child: Column(
                  children: [
                    Text(
                      'Ofertas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: corDestaque,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aproveite nossas ofertas especiais',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: corTitulo,
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
                        permitirAdicionar: false,
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
                            "Bem-vindo à D'Vanille",
                            textAlign: TextAlign.center,
                            style: AppTheme.display(
                              size: 38,
                              color: corTitulo,
                            ).copyWith(
                              fontFamily: 'CreamCake',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ganhe um desconto especial na sua primeira compra com o cupom PRIMEIRACOMPRA, também disponível no nosso aplicativo mobile.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: corTexto,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Presenteie-se no seu aniversário! Clientes cadastrados que estiverem na semana do aniversário podem aproveitar 15% de desconto com o cupom ANIVERSARIO. Para utilizar o benefício, é necessário acessar a comanda digital pelo QR Code disponível na mesa da cafeteria, estar conectado à conta e aplicar o cupom diretamente na comanda. Esse benefício é exclusivo para pedidos realizados pela comanda da mesa e não está disponível no carrinho do site ou no aplicativo mobile.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: corTexto,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 56),
            ],
          );
        },
      ),
    );
  }
}
