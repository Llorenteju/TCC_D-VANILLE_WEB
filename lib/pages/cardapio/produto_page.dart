import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../models/produto.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class ProdutoPage extends StatefulWidget {
  const ProdutoPage({super.key});

  @override
  State<ProdutoPage> createState() => _ProdutoPageState();
}

class _ProdutoPageState extends State<ProdutoPage> {
  int quantidade = 1;

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;

    final Produto? produto =
        arg is Produto ? arg : AppState.instance.produtoPorId(arg);

    final estreito = MediaQuery.sizeOf(context).width < 900;

    if (produto == null) {
      return PageShell(
        activeRoute: Routes.cardapio,
        child: EstadoVazio(
          emoji: '🔍',
          titulo: 'Produto não encontrado',
          acao: FilledButton(
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.cardapio, (r) => false),
            child: const Text('Voltar ao cardápio'),
          ),
        ),
      );
    }

    final imagem = ImagemProduto(
      url: produto.imagem,
      icone: produto.icon,
      altura: estreito ? 260 : 420,
      radius: const BorderRadius.all(
        Radius.circular(18),
      ),
    );

    final detalhes = _detalhes(context, produto);

    return PageShell(
      activeRoute: Routes.cardapio,
      child: Column(
        children: [
          const SizedBox(height: 40),
          ContentWidth(
            child: estreito
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imagem,
                      const SizedBox(height: 28),
                      detalhes,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: imagem,
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: detalhes,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _detalhes(
    BuildContext context,
    Produto produto,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: produto.restricoes.map((r) => BadgeRestricao(r)).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          produto.nome,
          style: AppTheme.display(
            size: 34,
            color: DVanilleColors.darkTaupe,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          produto.descricao,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              money(produto.preco),
              style: AppTheme.display(
                size: 30,
                weight: FontWeight.w700,
                color: DVanilleColors.rose,
              ),
            ),
            if (produto.precoAntigo != null) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  money(produto.precoAntigo!),
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: DVanilleColors.taupe,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        _titulo('Ingredientes'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: produto.ingredientes.map((i) => TagSimples(i)).toList(),
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _titulo('Informações nutricionais'),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: DicaCampo('(por porção)'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: produto.nutricional.linhas
              .map(
                (linha) => Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: DVanilleColors.line,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(linha[0]),
                      ),
                      Text(
                        linha[1],
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: DVanilleColors.darkTaupe,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 22),
        _titulo('Alergênicos'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: produto.alergenicos.map((a) => TagSimples(a)).toList(),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 18,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SeletorQuantidade(
              valor: quantidade,
              onMenos: () => setState(
                () => quantidade = quantidade > 1 ? quantidade - 1 : 1,
              ),
              onMais: () => setState(
                () => quantidade++,
              ),
            ),
            FilledButton(
              onPressed: () {
                AppState.instance.adicionarProduto(
                  produto,
                  qtd: quantidade,
                );

                showToast(
                  'Produto adicionado ao carrinho!',
                  'carrinho.svg',
                );
              },
              child: const Text(
                'Adicionar ao carrinho',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: AppTheme.display(
        size: 20,
        color: DVanilleColors.darkTaupe,
      ),
    );
  }
}
