import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_kit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Imagens SVG das categorias.
  static const Map<String, String> _iconesCategorias = {
    'bolo': 'assets/images/bolo.svg',
    'salgados': 'assets/images/salgado.svg',
    'doces': 'assets/images/doce.svg',
    'sobremesas-geladas': 'assets/images/sobremesagelada.svg',
    'bebidas-quentes': 'assets/images/bebidaquente.svg',
    'bebidas-geladas': 'assets/images/bebidagelada.svg',
  };

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return PageShell(
      activeRoute: Routes.home,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final destaques = state.produtos
              .where(
                (p) => [1, 5, 11, 14].contains(p.id),
              )
              .toList();

          final ofertas = state.ofertas.take(3).toList();

          return Column(
            children: [
              _hero(context),

              const SizedBox(height: 56),

              ContentWidth(
                child: Column(
                  children: [
                    // TÍTULO ROSA
                    Text(
                      'Nossa proposta',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 42,
                        fontWeight: FontWeight.w400,
                        color: DVanilleColors.rose,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Sabor, acolhimento e inclusão em cada detalhe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: DVanilleColors.darkTaupe,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Cada produto da D'Vanille traz ingredientes, informações nutricionais e indicação de restrições alimentares de forma clara, para que você escolha com segurança e prazer.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: DVanilleColors.ink,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _categorias(context),
                  ],
                ),
              ),

              const SizedBox(height: 64),

              // PRODUTOS EM DESTAQUE
              Container(
                width: double.infinity,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 56,
                ),
                child: ContentWidth(
                  child: Column(
                    children: [
                      Text(
                        'Selecionados para você',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'CreamCake',
                          fontSize: 42,
                          fontWeight: FontWeight.w400,
                          color: DVanilleColors.rose,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Produtos em destaque',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: DVanilleColors.darkTaupe,
                        ),
                      ),
                      const SizedBox(height: 34),
                      GradeProdutos(
                        produtos: destaques,
                      ),
                      const SizedBox(height: 30),
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.cardapio,
                          (r) => false,
                        ),
                        child: const Text(
                          'Ver cardápio completo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 64),

              // OFERTAS
              ContentWidth(
                child: Column(
                  children: [
                    Text(
                      'Não perca',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 42,
                        fontWeight: FontWeight.w400,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ofertas da semana',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: DVanilleColors.darkTaupe,
                      ),
                    ),
                    const SizedBox(height: 34),
                    GradeProdutos(
                      produtos: ofertas,
                    ),
                    const SizedBox(height: 30),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: DVanilleColors.blush,
                        foregroundColor: DVanilleColors.darkTaupe,
                      ),
                      onPressed: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.ofertas,
                        (r) => false,
                      ),
                      child: const Text(
                        'Ver todas as ofertas',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 64),

              // LOCALIZAÇÃO E HORÁRIO
              Container(
                width: double.infinity,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 56,
                ),
                child: ContentWidth(
                  child: Wrap(
                    spacing: 22,
                    runSpacing: 22,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: 480,
                        child: InfoBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Localização',
                                style: AppTheme.display(
                                  size: 22,
                                  color: DVanilleColors.darkTaupe,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _linhaIcone(
                                Icons.place_outlined,
                                'Rua das Baunilhas, 245 — Jardim das Flores, São Paulo/SP',
                              ),
                              _linhaIcone(
                                Icons.phone_outlined,
                                '(11) 4002-8922',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 480,
                        child: InfoBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Horário de funcionamento',
                                style: AppTheme.display(
                                  size: 22,
                                  color: DVanilleColors.darkTaupe,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _linhaIcone(
                                Icons.schedule,
                                'Terça a Sexta — 09h às 20h',
                              ),
                              _linhaIcone(
                                Icons.schedule,
                                'Sábado e Domingo — 10h às 21h',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _hero(BuildContext context) {
    return ContentWidth(
      padding: const EdgeInsets.fromLTRB(
        24,
        56,
        24,
        0,
      ),
      child: Column(
        children: [
          Text(
            'Bem-vindo à',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'CreamCake',
              fontSize: 38,
              fontWeight: FontWeight.w400,
              color: DVanilleColors.rose,
              height: 0.95,
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -5),
            child: Text(
              "D'Vanille",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'CreamCake',
                fontSize: 68,
                fontWeight: FontWeight.w400,
                color: DVanilleColors.darkTaupe,
                height: 0.95,
              ),
            ),
          ),

          const SizedBox(height: 4),

          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: const Text(
              'Uma cafeteria pensada para acolher todas as pessoas, com sabor, tecnologia e informação nutricional clara para quem possui restrições alimentares.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.5,
                height: 1.6,
                color: DVanilleColors.darkTaupe,
              ),
            ),
          ),

          const SizedBox(height: 26),

          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.cardapio,
                  (r) => false,
                ),
                child: const Text(
                  'Conheça nosso cardápio',
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.cardapio,
                  (r) => false,
                ),
                child: const Text(
                  'Faça seu pedido',
                ),
              ),
            ],
          ),

          const SizedBox(height: 44),

          // IMAGEM DA CAFETERIA
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              'assets/images/cafeteriainterna.png',
              width: double.infinity,
              height: 340,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORIAS
  // ============================================================

  Widget _categorias(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double espacamento = 12;

        // No desktop, calcula automaticamente uma largura
        // para que as 6 categorias caibam na mesma linha.
        final double larguraCard =
            (constraints.maxWidth - (espacamento * 5)) / 6;

        // Evita que os cards fiquem grandes demais.
        final double larguraFinal = larguraCard.clamp(145.0, 190.0);

        // Em telas pequenas, usa Wrap para permitir
        // que os cards quebrem naturalmente.
        if (constraints.maxWidth < 950) {
          return Wrap(
            spacing: espacamento,
            runSpacing: espacamento,
            alignment: WrapAlignment.center,
            children: categorias
                .map(
                  (c) => _pilulaCategoria(
                    context,
                    c,
                    170,
                  ),
                )
                .toList(),
          );
        }

        // Desktop:
        // seis categorias ficam alinhadas na mesma linha.
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < categorias.length; i++) ...[
              SizedBox(
                width: larguraFinal,
                child: _pilulaCategoria(
                  context,
                  categorias[i],
                  larguraFinal,
                ),
              ),
              if (i < categorias.length - 1)
                const SizedBox(
                  width: espacamento,
                ),
            ],
          ],
        );
      },
    );
  }

  // ============================================================
  // CARD DE CATEGORIA
  // ============================================================

  Widget _pilulaCategoria(
    BuildContext context,
    Categoria c,
    double largura,
  ) {
    final caminhoImagem = _iconesCategorias[c.id];

    return InkWell(
      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.cardapio,
        (r) => false,
        arguments: c.id,
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: largura,
        height: 155,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: DVanilleColors.line,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (caminhoImagem != null)
              SvgPicture.asset(
                caminhoImagem,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 10),
            Text(
              c.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: DVanilleColors.darkTaupe,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LINHAS DE INFORMAÇÃO
  // ============================================================

  Widget _linhaIcone(
    IconData icone,
    String texto,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 18,
            color: DVanilleColors.rose,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
