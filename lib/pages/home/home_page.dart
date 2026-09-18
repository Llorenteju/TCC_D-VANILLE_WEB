import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_kit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return PageShell(
      activeRoute: Routes.home,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final destaques = state.produtos
              .where((p) => [1, 5, 11, 14].contains(p.id))
              .toList();
          final ofertas = state.ofertas.take(3).toList();

          return Column(
            children: [
              _hero(context),
              const SizedBox(height: 56),
              ContentWidth(
                child: Column(
                  children: [
                    const SectionHead(
                      eyebrow: 'Nossa proposta',
                      titulo:
                          'Sabor, acolhimento e inclusão em cada detalhe.',
                      subtitulo:
                          "Cada produto da D'Vanille traz ingredientes, informações nutricionais e indicação de restrições alimentares de forma clara — para que você escolha com segurança e prazer.",
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.center,
                      children: categorias
                          .map((c) => _pilulaCategoria(context, c))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              Container(
                width: double.infinity,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(vertical: 56),
                child: ContentWidth(
                  child: Column(
                    children: [
                      const SectionHead(
                        eyebrow: 'Selecionados para você',
                        titulo: 'Produtos em destaque',
                      ),
                      const SizedBox(height: 34),
                      GradeProdutos(produtos: destaques),
                      const SizedBox(height: 30),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamedAndRemoveUntil(
                                Routes.cardapio, (r) => false),
                        child: const Text('Ver cardápio completo'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 64),
              ContentWidth(
                child: Column(
                  children: [
                    const SectionHead(
                      eyebrow: 'Não perca',
                      titulo: 'Ofertas da semana',
                    ),
                    const SizedBox(height: 34),
                    GradeProdutos(produtos: ofertas),
                    const SizedBox(height: 30),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: DVanilleColors.blush,
                        foregroundColor: DVanilleColors.darkTaupe,
                      ),
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                              Routes.ofertas, (r) => false),
                      child: const Text('Ver todas as ofertas'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              Container(
                width: double.infinity,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(vertical: 56),
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
                              Text('Localização',
                                  style: AppTheme.display(
                                      size: 22,
                                      color: DVanilleColors.darkTaupe)),
                              const SizedBox(height: 10),
                              _linhaIcone(Icons.place_outlined,
                                  'Rua das Baunilhas, 245 — Jardim das Flores, São Paulo/SP'),
                              _linhaIcone(
                                  Icons.phone_outlined, '(11) 4002-8922'),
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
                              Text('Horário de funcionamento',
                                  style: AppTheme.display(
                                      size: 22,
                                      color: DVanilleColors.darkTaupe)),
                              const SizedBox(height: 10),
                              _linhaIcone(Icons.schedule,
                                  'Terça a Sexta — 09h às 20h'),
                              _linhaIcone(Icons.schedule,
                                  'Sábado e Domingo — 10h às 21h'),
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

  Widget _hero(BuildContext context) {
    return ContentWidth(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
      child: Column(
        children: [
          Text('Bem-vindo à',
              style: AppTheme.display(size: 20, weight: FontWeight.w500)
                  .copyWith(
                      fontStyle: FontStyle.italic,
                      color: DVanilleColors.rose)),
          const SizedBox(height: 4),
          Text("D'Vanille",
              textAlign: TextAlign.center,
              style: AppTheme.display(
                  size: 48, color: DVanilleColors.darkTaupe)),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Text(
              'Uma cafeteria pensada para acolher todas as pessoas — com sabor, tecnologia e informação nutricional clara para quem possui restrições alimentares.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.5,
                  height: 1.6,
                  color: DVanilleColors.darkTaupe),
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.cardapio, (r) => false),
                child: const Text('Conheça nosso cardápio'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.cardapio, (r) => false),
                child: const Text('Faça seu pedido'),
              ),
            ],
          ),
          const SizedBox(height: 44),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: const ImagemProduto(
              url: Img.hero,
              icone: '☕',
              altura: 340,
              radius: BorderRadius.all(Radius.circular(28)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pilulaCategoria(BuildContext context, Categoria c) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.cardapio,
        (r) => false,
        arguments: c.id,
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: DVanilleColors.line),
        ),
        child: Column(
          children: [
            Text(c.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 10),
            Text(c.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: DVanilleColors.darkTaupe)),
          ],
        ),
      ),
    );
  }

  Widget _linhaIcone(IconData icone, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: DVanilleColors.rose),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 14.5))),
        ],
      ),
    );
  }
}
