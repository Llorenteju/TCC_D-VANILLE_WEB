import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/app.dart';
import '../../models/item_carrinho.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class CarrinhoPage extends StatefulWidget {
  const CarrinhoPage({super.key});

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  final state = AppState.instance;
  final cupom = TextEditingController();

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get corTexto =>
      isDark ? DVanilleColors.darkInk : DVanilleColors.darkTaupe;

  Color get corTextoSecundario =>
      isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.taupe;

  Color get corBorda =>
      isDark ? DVanilleColors.darkBorder : DVanilleColors.line;

  @override
  void dispose() {
    cupom.dispose();
    super.dispose();
  }

  void _aplicarCupom() {
    if (cupom.text.trim().toUpperCase() == 'ANIVERSARIO') {
      showToast(
        'Este cupom é exclusivo para pedidos realizados pela comanda da mesa.',
        '⚠️',
      );
      return;
    }

    if (state.aplicarCupom(cupom.text)) {
      showToast(
        'Cupom aplicado com sucesso!',
        'cupom.svg',
      );
    } else {
      showToast(
        'Cupom inválido.',
        '⚠️',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 900;

    return PageShell(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          if (state.carrinho.isEmpty) {
            return const EstadoVazio(
              emoji: 'carrinho.svg',
              titulo: 'Seu carrinho está vazio',
            );
          }

          final itens = Column(
            children:
                state.carrinho.map((item) => _itemCarrinho(item)).toList(),
          );

          final resumo = _resumo(context);

          return Column(
            children: [
              const SizedBox(height: 56),
              ContentWidth(
                child: Column(
                  children: [
                    const Text(
                      'Carrinho',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Revise seus itens',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: corTextoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 65),
              ContentWidth(
                child: estreito
                    ? Column(
                        children: [
                          itens,
                          const SizedBox(height: 26),
                          resumo,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: itens,
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: resumo,
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

  Widget _itemCarrinho(ItemCarrinho item) {
    final ehValePresente = item.ehValePresente;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: corBorda),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: ehValePresente
                ? Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? DVanilleColors.darkSurface
                          : DVanilleColors.blush2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: corBorda),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: SvgPicture.asset(
                      'assets/images/presente.svg',
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        isDark ? DVanilleColors.darkRose : DVanilleColors.rose,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : ImagemProduto(
                    url: item.imagem,
                    icone: item.icon,
                    altura: 78,
                    radius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nome,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: corTexto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${money(item.preco)} · Subtotal: ${money(item.subtotal)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: corTextoSecundario,
                  ),
                ),
                if (ehValePresente && item.destinatario.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Para: ${item.destinatario}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: corTextoSecundario,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SeletorQuantidade(
            valor: item.qtd,
            onMenos: () {
              final ultimo = item.qtd <= 1;

              state.alterarQuantidade(item.id, -1);

              if (ultimo) {
                showToast(
                  'Item removido do carrinho.',
                  'lixeira.svg',
                );
              }
            },
            onMais: () => state.alterarQuantidade(item.id, 1),
          ),
          IconButton(
            tooltip: 'Remover',
            onPressed: () {
              state.removerItem(item.id);

              showToast(
                'Item removido do carrinho.',
                'lixeira.svg',
              );
            },
            icon: SvgPicture.asset(
              'assets/images/lixeira.svg',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                isDark ? DVanilleColors.darkRose : DVanilleColors.darkTaupe,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumo(BuildContext context) {
    final temProdutos = state.itensProdutos.isNotEmpty;
    final temValePresentes = state.itensValePresentes.isNotEmpty;

    return InfoBox(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo',
            style: AppTheme.display(
              size: 22,
              color: corTexto,
            ),
          ),
          const SizedBox(height: 10),
          _linhaResumo('Subtotal', money(state.subtotal)),
          if (state.cupomAplicado != null)
            _linhaResumo(
              'Desconto (${state.cupomAplicado})',
              '- ${money(state.desconto)}',
            ),
          Divider(color: corBorda),
          _linhaResumo(
            'Total',
            money(state.total),
            destaque: true,
          ),
          if (temProdutos && temValePresentes) ...[
            const SizedBox(height: 12),
            CaixaAlerta(
              'Os alimentos e os vale-presentes precisam ser finalizados separadamente. Remova um dos tipos de item para continuar.',
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Cupom de desconto',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: corTexto,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cupom,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(color: corTexto),
                  decoration: InputDecoration(
                    hintText: 'Ex: PRIMEIRACOMPRA',
                    hintStyle: TextStyle(
                      color: corTextoSecundario,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? DVanilleColors.darkCream
                        : DVanilleColors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: corBorda),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: DVanilleColors.rose,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _aplicarCupom,
                child: const Text('Aplicar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.cupomAplicado != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF304333) : const Color(0xFFE4EEE0),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF557A59)
                      : const Color(0xFFC6D9C0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/cupom.svg',
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? const Color(0xFFA7D4A1)
                          : const Color(0xFF3D6B3A),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '${state.cupomAplicado} aplicado',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFA7D4A1)
                          : const Color(0xFF3D6B3A),
                    ),
                  ),
                ],
              ),
            )
          else
            DicaCampo(
              'Experimente: PRIMEIRACOMPRA',
            ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: temProdutos && temValePresentes
                  ? null
                  : () => Navigator.pushNamed(
                        context,
                        Routes.checkout,
                      ),
              child: const Text('Finalizar pedido'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaResumo(
    String titulo,
    String valor, {
    bool destaque = false,
  }) {
    final estilo = TextStyle(
      fontSize: destaque ? 18 : 14.5,
      fontWeight: destaque ? FontWeight.w800 : FontWeight.w500,
      color: destaque ? corTexto : corTextoSecundario,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: estilo),
          Text(valor, style: estilo),
        ],
      ),
    );
  }
}
