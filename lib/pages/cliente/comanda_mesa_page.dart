import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../models/comanda_mesa.dart';
import '../../services/comanda_mesa_state.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_kit.dart';

class ComandaMesaPage extends StatefulWidget {
  const ComandaMesaPage({super.key});

  @override
  State<ComandaMesaPage> createState() => _ComandaMesaPageState();
}

class _ComandaMesaPageState extends State<ComandaMesaPage> {
  final ComandaMesaState _comandas = ComandaMesaState.instance;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _itensComandaKey = GlobalKey();

  String? _mesa;
  bool _inicializada = false;
  bool _finalizando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_inicializada) return;
    _inicializada = true;

    final argumentos = ModalRoute.of(context)?.settings.arguments;

    if (argumentos is Map) {
      _mesa = argumentos['mesa']?.toString();
    } else if (argumentos is String) {
      _mesa = argumentos;
    }

    // Permite ler a mesa em URLs com hash routing.
    final fragmento = Uri.base.fragment;
    final rotaFragmento = Uri.tryParse(fragmento);

    _mesa ??= rotaFragmento?.queryParameters['mesa'];
    _mesa ??= Uri.base.queryParameters['mesa'];

    final numeroMesa = _mesa?.trim();

    if (numeroMesa != null && numeroMesa.isNotEmpty) {
      _mesa = numeroMesa;
      _comandas.abrirComanda(numeroMesa);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fazerPedido(String mesa) {
    Navigator.pushNamed(
      context,
      Routes.cardapio,
      arguments: {
        'modo': 'mesa',
        'mesa': mesa,
      },
    );
  }

  void _verComanda() {
    final contexto = _itensComandaKey.currentContext;

    if (contexto != null) {
      Scrollable.ensureVisible(
        contexto,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
  }

  Future<void> _confirmarFinalizacao(
    String mesa,
    ComandaMesa comanda,
  ) async {
    if (_finalizando) return;

    if (comanda.itens.isEmpty) {
      _mostrarMensagem('Adicione pelo menos um produto ao pedido.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar pedido?'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confira os itens antes de enviar o pedido da mesa $mesa.',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  ...comanda.itens.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${item.quantidade} × ${money(item.preco)}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(money(item.subtotal)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total do pedido',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        money(comanda.total),
                        style: Theme.of(dialogContext)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Após confirmar, os itens deste pedido não poderão '
                    'ser alterados nesta demonstração.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Voltar e editar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirmar pedido'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    setState(() => _finalizando = true);

    try {
      // O estado valida novamente se a comanda ainda pode ser enviada.
      final sucesso = _comandas.enviarPedidoAoCaixa(mesa);

      if (!mounted) return;

      if (sucesso) {
        _mostrarMensagem(
          'Pedido da mesa $mesa finalizado com sucesso!',
        );
      } else {
        _mostrarMensagem(
          'Não foi possível finalizar. Confira o status da comanda.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _finalizando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final mesa = _mesa;

    if (mesa == null || mesa.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("D'Vanille"),
          centerTitle: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Não foi possível identificar a mesa. '
              'Acesse a comanda pelo QR Code disponibilizado '
              'pela cafeteria.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("D'Vanille"),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _comandas,
        builder: (context, _) {
          final atual = _comandas.comandaDaMesa(mesa);

          if (atual == null) {
            return const Center(
              child: Text('Comanda não encontrada.'),
            );
          }

          final enviado = atual.status == 'enviado ao caixa';
          final encerrada = atual.status == 'encerrada';
          final bloqueada = enviado || encerrada;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 36),

                  // Cabeçalho seguindo o padrão da página Contato.
                  Column(
                    children: [
                      const Text(
                        'Minha Comanda',
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
                        'Acompanhe seu pedido à mesa',
                        textAlign: TextAlign.center,
                        style: AppTheme.display(
                          size: 24,
                          weight: FontWeight.w600,
                          color: DVanilleColors.darkTaupe,
                        ).copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Mesa $mesa',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleMedium,
                  ),

                  const SizedBox(height: 20),

                  _resumoComanda(atual, tema),

                  const SizedBox(height: 24),

                  Text(
                    'O que você deseja fazer?',
                    style: tema.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: bloqueada ? null : () => _fazerPedido(mesa),
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Fazer pedido'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _verComanda,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        'Ver comanda e carrinho da mesa'
                        ' (${atual.quantidadeItens} itens)',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: atual.atendimentoSolicitado || bloqueada
                          ? null
                          : () {
                              _comandas.solicitarAtendimento(mesa);
                              _mostrarMensagem(
                                'Solicitação de atendimento registrada '
                                'para a mesa $mesa nesta demonstração.',
                              );
                            },
                      icon: const Icon(Icons.room_service_outlined),
                      label: Text(
                        atual.atendimentoSolicitado
                            ? 'Garçom solicitado'
                            : 'Chamar garçom',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  if (atual.atendimentoSolicitado) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'A solicitação foi registrada no protótipo. '
                      'Uma notificação real à equipe depende do backend.',
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 32),

                  Container(
                    key: _itensComandaKey,
                    child: Text(
                      'Comanda da mesa',
                      style: tema.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (atual.itens.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(
                          'Sua comanda está vazia. '
                          'Toque em "Fazer pedido" para escolher '
                          'produtos no cardápio.',
                        ),
                      ),
                    )
                  else
                    ...atual.itens.map(
                      (item) => Card(
                        child: ListTile(
                          title: Text(item.nome),
                          subtitle: Text(
                            '${item.quantidade} × ${money(item.preco)}'
                            '\nSubtotal: ${money(item.subtotal)}',
                          ),
                          isThreeLine: true,
                          trailing: bloqueada
                              ? null
                              : Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      tooltip: 'Diminuir quantidade',
                                      onPressed: () {
                                        _comandas.alterarQuantidade(
                                          mesa: mesa,
                                          produtoId: item.produtoId,
                                          variacao: -1,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Aumentar quantidade',
                                      onPressed: () {
                                        _comandas.alterarQuantidade(
                                          mesa: mesa,
                                          produtoId: item.produtoId,
                                          variacao: 1,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Remover produto',
                                      onPressed: () {
                                        _comandas.removerProduto(
                                          mesa: mesa,
                                          produtoId: item.produtoId,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _linhaTotal(
                            'Quantidade de itens',
                            '${atual.quantidadeItens}',
                          ),
                          const SizedBox(height: 8),
                          _linhaTotal(
                            'Total do pedido',
                            money(atual.total),
                            destaque: true,
                          ),
                          const SizedBox(height: 20),
                          if (encerrada)
                            const Text(
                              'Esta comanda foi encerrada.',
                              textAlign: TextAlign.center,
                            )
                          else if (enviado)
                            const Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 42,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Pedido finalizado!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'O pedido foi marcado como enviado ao '
                                  'caixa nesta demonstração. O envio real '
                                  'depende da integração com o backend.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          else
                            FilledButton.icon(
                              onPressed: atual.itens.isEmpty || _finalizando
                                  ? null
                                  : () => _confirmarFinalizacao(mesa, atual),
                              icon: _finalizando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check_circle_outline),
                              label: Text(
                                _finalizando
                                    ? 'Finalizando...'
                                    : 'Finalizar pedido',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'D’Vanille — uma experiência de café feita para você.',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _resumoComanda(ComandaMesa comanda, ThemeData tema) {
    final status = switch (comanda.status) {
      'encerrada' => 'Encerrada',
      'enviado ao caixa' => 'Enviada ao caixa',
      _ => comanda.atendimentoSolicitado ? 'Atendimento solicitado' : 'Aberta',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_outlined, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comanda ${comanda.id}',
                    style: tema.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('Status: $status'),
                  const SizedBox(height: 4),
                  Text('Mesa ${comanda.mesa}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaTotal(
    String titulo,
    String valor, {
    bool destaque = false,
  }) {
    final estilo = destaque
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      children: [
        Expanded(child: Text(titulo, style: estilo)),
        Text(valor, style: estilo),
      ],
    );
  }
}
