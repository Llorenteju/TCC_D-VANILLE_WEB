import 'package:flutter/material.dart';

import '../app/app.dart';
import '../data/mock_data.dart';
import '../models/produto.dart';
import '../services/app_state.dart';
import '../services/navigation.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

class ProductCard extends StatelessWidget {
  final Produto produto;

  /// Mostra "-30%" em vez de "OFERTA" (usado na página de Ofertas).
  final bool mostrarPercentual;

  /// Na página de ofertas o card exibe apenas um botão largo.
  final bool acaoUnica;

  const ProductCard({
    super.key,
    required this.produto,
    this.mostrarPercentual = false,
    this.acaoUnica = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 272,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DVanilleColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ImagemProduto(
                  url: produto.imagem, icone: produto.icon, altura: 170),
              if (produto.oferta)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: DVanilleColors.rose,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      mostrarPercentual
                          ? '-${produto.descontoPercentual}%'
                          : 'OFERTA',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(produto.nome,
                    style: const TextStyle(
                        fontSize: 16.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(labelCategoriaDoProduto(produto),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: DVanilleColors.taupe)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 54,
                  child: Text(
                    produto.descricao,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: DVanilleColors.darkTaupe),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: produto.restricoes
                      .take(3)
                      .map((r) => BadgeRestricao(r))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(money(produto.preco),
                        style: AppTheme.display(
                            size: 22,
                            weight: FontWeight.w700,
                            color: DVanilleColors.rose)),
                    if (produto.precoAntigo != null) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          money(produto.precoAntigo!),
                          style: const TextStyle(
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                            color: DVanilleColors.taupe,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: acaoUnica
                ? SizedBox(
                    width: double.infinity,
                    child: _botaoAdicionar(context, largo: true),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w800),
                          ),
                          onPressed: () => Navigator.pushNamed(
                              context, Routes.produto,
                              arguments: produto.id),
                          child: const Text('Ver produto'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _botaoAdicionar(context),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _botaoAdicionar(BuildContext context, {bool largo = false}) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: DVanilleColors.blush,
        foregroundColor: DVanilleColors.darkTaupe,
        padding: EdgeInsets.symmetric(horizontal: largo ? 20 : 14, vertical: 10),
        textStyle:
            const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
      ),
      onPressed: () {
        AppState.instance.adicionarProduto(produto);
        showToast('Produto adicionado ao carrinho!', 'carrinho.svg');
      },
      child: Text(largo ? 'Adicionar ao carrinho' : '+ Carrinho'),
    );
  }
}

String labelCategoriaDoProduto(Produto p) {
  return labelCategoria(p.categoria);
}

/// Grade responsiva de cards (equivale aos .grid-3 / .grid-4 do CSS).
class GradeProdutos extends StatelessWidget {
  final List<Produto> produtos;
  final bool mostrarPercentual;
  final bool acaoUnica;

  const GradeProdutos({
    super.key,
    required this.produtos,
    this.mostrarPercentual = false,
    this.acaoUnica = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 22,
      runSpacing: 22,
      alignment: WrapAlignment.center,
      children: produtos
          .map((p) => ProductCard(
                produto: p,
                mostrarPercentual: mostrarPercentual,
                acaoUnica: acaoUnica,
              ))
          .toList(),
    );
  }
}
