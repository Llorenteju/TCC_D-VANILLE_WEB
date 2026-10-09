import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  Future<void> _confirmar(
    BuildContext context,
    String modo,
  ) async {
    final state = AppState.instance;

    if (state.carrinho.isEmpty) {
      showToast(
        'Seu carrinho está vazio.',
        '⚠️',
      );
      return;
    }

    final temProdutos = state.itensProdutos.isNotEmpty;
    final temVales = state.itensValePresentes.isNotEmpty;

    // Não permite finalizar compras de tipos diferentes juntas.
    if (temProdutos && temVales) {
      showToast(
        'Finalize os alimentos e os vale-presentes separadamente.',
        '⚠️',
      );
      return;
    }

    final ehCompraVale = temVales;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            ehCompraVale
                ? 'Confirmar compra dos vale-presentes'
                : 'Confirmar pedido',
          ),
          content: Text(
            ehCompraVale
                ? 'Deseja confirmar a compra de '
                    '${state.itensValePresentes.length} '
                    'item(ns) de vale-presente, no total de '
                    '${money(state.subtotalValePresentes)}? '
                    'Após confirmar, os vales serão emitidos.'
                : 'Deseja confirmar seu pedido no valor de '
                    '${money(state.subtotalProdutos)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Confirmar compra'),
            ),
          ],
        );
      },
    );

    if (confirmado != true || !context.mounted) {
      return;
    }

    // Verifica novamente o carrinho após o diálogo.
    if (state.carrinho.isEmpty) {
      showToast(
        'Seu carrinho está vazio.',
        '⚠️',
      );
      return;
    }

    if (ehCompraVale) {
      final vales = state.confirmarCompraValePresentes();

      if (vales.isEmpty) {
        showToast(
          'Não foi possível confirmar a compra dos vales.',
          '⚠️',
        );
        return;
      }

      showToast(
        'Compra confirmada! Seus vale-presentes foram emitidos.',
        'confete.svg',
      );

      // Nesta etapa, usamos a tela de confirmação existente
      // apenas para evitar criar uma rota ainda não cadastrada.
      // A próxima etapa poderá apresentar os códigos emitidos.
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.shopping,
        (route) => false,
      );

      return;
    }

    if (state.itensProdutos.isEmpty) {
      showToast(
        'Não existem produtos para criar o pedido.',
        '⚠️',
      );
      return;
    }

    final pedido = state.criarPedido(modo);

    showToast(
      'Pedido realizado com sucesso!',
      'confete.svg',
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.pedidoConfirmado,
      (route) => false,
      arguments: pedido.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final estreito = MediaQuery.sizeOf(context).width < 900;

    return PageShell(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final usuario = state.usuarioLogado;
          final temProdutos = state.itensProdutos.isNotEmpty;
          final temVales = state.itensValePresentes.isNotEmpty;
          final compraMista = temProdutos && temVales;

          final titulo = temVales && !temProdutos
              ? 'Finalizar compra'
              : 'Finalizar pedido';

          final subtitulo = temVales && !temProdutos
              ? 'Confira os dados dos seus vale-presentes'
              : 'Confirme os dados do seu pedido';

          final dados = InfoBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dados do cliente',
                  style: AppTheme.display(
                    size: 22,
                    color: DVanilleColors.darkTaupe,
                  ),
                ),
                const SizedBox(height: 8),
                Text(usuario?.nome ?? ''),
                Text(usuario?.email ?? ''),
                Text(usuario?.telefone ?? ''),
                const SizedBox(height: 22),
                Text(
                  temVales && !temProdutos
                      ? 'Vale-presentes'
                      : 'Itens do pedido',
                  style: AppTheme.display(
                    size: 22,
                    color: DVanilleColors.darkTaupe,
                  ),
                ),
                const SizedBox(height: 8),
                ...state.carrinho.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.qtd}x ${item.nome}',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(money(item.subtotal)),
                          ],
                        ),
                        if (item.ehValePresente) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Destinatário: ${item.destinatario}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (item.mensagem.trim().isNotEmpty)
                            Text(
                              'Mensagem: ${item.mensagem}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Divider(
                  color: DVanilleColors.line,
                ),
                _linha(
                  'Subtotal',
                  money(state.subtotal),
                ),
                if (state.cupomAplicado != null)
                  _linha(
                    'Desconto',
                    '- ${money(state.desconto)}',
                  ),
                _linha(
                  'Total',
                  money(state.total),
                  destaque: true,
                ),
                if (compraMista) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Seu carrinho contém alimentos e vale-presentes. '
                    'Remova um dos tipos para concluir cada compra '
                    'separadamente.',
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ],
            ),
          );

          final acoes = InfoBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temVales && !temProdutos
                      ? 'Confirmar compra'
                      : 'Como deseja prosseguir?',
                  style: AppTheme.display(
                    size: 22,
                    color: DVanilleColors.darkTaupe,
                  ),
                ),
                const SizedBox(height: 6),
                DicaCampo(
                  temVales && !temProdutos
                      ? 'Esta é uma confirmação simulada. '
                          'Nenhum pagamento real será processado.'
                      : 'Válido para atendimento presencial.',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: compraMista
                        ? null
                        : () => _confirmar(
                              context,
                              'caixa',
                            ),
                    child: Text(
                      temVales && !temProdutos
                          ? 'Confirmar compra dos vales'
                          : 'Enviar pedido ao caixa',
                    ),
                  ),
                ),
                if (!temVales || temProdutos) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: compraMista
                          ? null
                          : () => _confirmar(
                                context,
                                'retirar',
                              ),
                      child: const Text(
                        'Retirar na cafeteria',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );

          return Column(
            children: [
              const SizedBox(height: 56),
              ContentWidth(
                child: Column(
                  children: [
                    Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                child: estreito
                    ? Column(
                        children: [
                          dados,
                          const SizedBox(height: 22),
                          acoes,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 13,
                            child: dados,
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            flex: 10,
                            child: acoes,
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

  Widget _linha(
    String titulo,
    String valor, {
    bool destaque = false,
  }) {
    final estilo = TextStyle(
      fontSize: destaque ? 18 : 14.5,
      fontWeight: destaque ? FontWeight.w800 : FontWeight.w500,
      color: destaque ? DVanilleColors.darkTaupe : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: estilo,
          ),
          Text(
            valor,
            style: estilo,
          ),
        ],
      ),
    );
  }
}
