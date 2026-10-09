import 'package:flutter/material.dart';

import '../app/app.dart';
import '../data/mock_data.dart';
import '../models/produto.dart';
import '../services/app_state.dart';
import '../services/comanda_mesa_state.dart';
import '../services/navigation.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

class ProductCard extends StatelessWidget {
  final Produto produto;

  /// Mostra o percentual de desconto nas ofertas.
  final bool mostrarPercentual;

  /// Exibe somente o botão principal.
  final bool acaoUnica;

  /// Define se o card permite adicionar produtos.
  /// Mantém o comportamento atual por padrão.
  final bool permitirAdicionar;

  /// Número da mesa quando o cardápio é acessado pelo QR Code.
  final String? mesa;

  const ProductCard({
    super.key,
    required this.produto,
    this.mostrarPercentual = false,
    this.acaoUnica = false,
    this.permitirAdicionar = true,
    this.mesa,
  });

  bool get _modoMesa => mesa != null && mesa!.trim().isNotEmpty;

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
                url: produto.imagem,
                icone: produto.icon,
                altura: 170,
              ),
              if (produto.oferta)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                        fontWeight: FontWeight.w800,
                      ),
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
                Text(
                  produto.nome,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  labelCategoriaDoProduto(produto),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DVanilleColors.taupe,
                  ),
                ),
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
                      color: DVanilleColors.darkTaupe,
                    ),
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
                    Text(
                      money(produto.preco),
                      style: AppTheme.display(
                        size: 22,
                        weight: FontWeight.w700,
                        color: DVanilleColors.rose,
                      ),
                    ),
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
                    child: permitirAdicionar
                        ? _botaoAdicionar(context, largo: true)
                        : _botaoVerProduto(context, largo: true),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _botaoVerProduto(context),
                      ),
                      if (permitirAdicionar) ...[
                        const SizedBox(width: 8),
                        _botaoAdicionar(context),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _botaoVerProduto(
    BuildContext context, {
    bool largo = false,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        textStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(
          context,
          Routes.produto,
          arguments: produto.id,
        );
      },
      child: const Text('Ver produto'),
    );
  }

  Widget _botaoAdicionar(
    BuildContext context, {
    bool largo = false,
  }) {
    final texto = _modoMesa
        ? (largo ? 'Adicionar à comanda' : '+ Comanda')
        : (largo ? 'Adicionar ao carrinho' : '+ Carrinho');

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: DVanilleColors.blush,
        foregroundColor: DVanilleColors.darkTaupe,
        padding: EdgeInsets.symmetric(
          horizontal: largo ? 20 : 14,
          vertical: 10,
        ),
        textStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
      onPressed: () {
        if (_modoMesa) {
          ComandaMesaState.instance.adicionarProduto(
            mesa: mesa!.trim(),
            produto: produto,
          );

          showToast(
            'Produto adicionado à comanda da mesa ${mesa!.trim()}!',
            '✓',
          );
          return;
        }

        AppState.instance.adicionarProduto(produto);

        showToast(
          'Produto adicionado ao carrinho!',
          'carrinho.svg',
        );
      },
      child: Text(texto),
    );
  }
}

String labelCategoriaDoProduto(Produto p) {
  final categoria = categorias.where(
    (c) => c.id == p.categoria,
  );

  if (categoria.isNotEmpty) {
    return categoria.first.label;
  }

  return p.categoria;
}

/// Grade responsiva de cards.
class GradeProdutos extends StatelessWidget {
  final List<Produto> produtos;
  final bool mostrarPercentual;
  final bool acaoUnica;
  final bool permitirAdicionar;
  final String? mesa;

  const GradeProdutos({
    super.key,
    required this.produtos,
    this.mostrarPercentual = false,
    this.acaoUnica = false,
    this.permitirAdicionar = true,
    this.mesa,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 22,
      runSpacing: 22,
      alignment: WrapAlignment.center,
      children: produtos
          .map(
            (p) => ProductCard(
              produto: p,
              mostrarPercentual: mostrarPercentual,
              acaoUnica: acaoUnica,
              permitirAdicionar: permitirAdicionar,
              mesa: mesa,
            ),
          )
          .toList(),
    );
  }
}
