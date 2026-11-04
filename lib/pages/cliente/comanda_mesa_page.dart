import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../models/comanda_mesa.dart';
import '../../services/comanda_mesa_state.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';

class ComandaMesaPage extends StatefulWidget {
  const ComandaMesaPage({super.key});

  @override
  State<ComandaMesaPage> createState() => _ComandaMesaPageState();
}

class _ComandaMesaPageState extends State<ComandaMesaPage> {
  final ComandaMesaState _comandas = ComandaMesaState.instance;
  final GlobalKey _itensComandaKey = GlobalKey();
  final TextEditingController _cupomController = TextEditingController();

  String? _mesa;
  bool _inicializada = false;
  bool _finalizando = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _corTexto => _isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

  Color get _corTextoSecundario =>
      _isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

  Color get _corDestaque =>
      _isDark ? DVanilleColors.darkRose : DVanilleColors.rose;

  Color get _corBorda =>
      _isDark ? DVanilleColors.darkBorder : DVanilleColors.line;

  @override
  void dispose() {
    _cupomController.dispose();
    super.dispose();
  }

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
        SnackBar(
          content: Text(mensagem),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // Aplica o cupom de aniversário à comanda da mesa.
  void _aplicarCupomAniversario() {
    final codigo = _cupomController.text
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[\s\u200B-\u200D\uFEFF]'), '');

    if (codigo.isEmpty) {
      _mostrarMensagem('Digite o código do cupom.');
      return;
    }

    if (!AppState.instance.logado) {
      _mostrarMensagem(
        'Entre na sua conta para utilizar o cupom.',
      );

      Navigator.pushNamed(
        context,
        Routes.login,
        arguments: RedirecionamentoLogin(
          Routes.comandaMesa,
          {'mesa': _mesa},
        ),
      );
      return;
    }

    final codigoNormalizado = codigo.replaceAll('Á', 'A');

    if (codigoNormalizado != 'ANIVERSARIO') {
      _mostrarMensagem('Código de cupom inválido.');
      return;
    }

    final mesa = _mesa;

    if (mesa == null || mesa.isEmpty) {
      _mostrarMensagem('Não foi possível identificar a mesa.');
      return;
    }

    final sucesso = _comandas.aplicarCupomAniversario(mesa);

    if (sucesso) {
      _cupomController.clear();
      _mostrarMensagem(
        'Cupom de aniversário aplicado com sucesso! Você ganhou 15% de desconto.',
      );
    } else {
      _mostrarMensagem(
        'Não foi possível aplicar o cupom. Verifique se você está na semana do seu aniversário, se há itens pendentes e se ainda não existe outro cupom aplicado.',
      );
    }
  }

  // Remove o cupom da comanda.
  void _removerCupom(String mesa) {
    _comandas.removerCupom(mesa);
    _mostrarMensagem('Cupom removido da comanda.');
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

    if (!AppState.instance.logado) {
      Navigator.pushNamed(
        context,
        Routes.login,
        arguments: RedirecionamentoLogin(
          Routes.comandaMesa,
          {'mesa': mesa},
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              _isDark ? DVanilleColors.darkSurface : DVanilleColors.cream,
          title: Text(
            'Finalizar pedido?',
            style: TextStyle(
              color: _corTexto,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confira os itens antes de enviar o pedido da mesa $mesa.',
                    style: TextStyle(color: _corTextoSecundario),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: _corBorda),
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _corTexto,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${item.quantidade} × ${money(item.preco)}',
                                  style: TextStyle(
                                    color: _corTextoSecundario,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            money(item.subtotal),
                            style: TextStyle(color: _corTexto),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: _corBorda),
                  if (comanda.temCupom) ...[
                    _linhaTotal(
                      'Subtotal',
                      money(comanda.subtotal),
                    ),
                    const SizedBox(height: 8),
                    _linhaTotal(
                      'Desconto (${(comanda.percentualDesconto * 100).toStringAsFixed(0)}%)',
                      '- ${money(comanda.desconto)}',
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total do pedido',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _corTexto,
                          ),
                        ),
                      ),
                      Text(
                        money(comanda.total),
                        style: Theme.of(dialogContext)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _corDestaque,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: _isDark
                  ? TextButton.styleFrom(
                      foregroundColor: DVanilleColors.darkRose,
                    )
                  : null,
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Voltar e editar'),
            ),
            FilledButton.icon(
              style: _isDark
                  ? FilledButton.styleFrom(
                      backgroundColor: DVanilleColors.darkRose,
                      foregroundColor: DVanilleColors.darkCream,
                    )
                  : null,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirmar pedido'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    if (!AppState.instance.logado) {
      Navigator.pushNamed(
        context,
        Routes.login,
        arguments: RedirecionamentoLogin(
          Routes.comandaMesa,
          {'mesa': mesa},
        ),
      );
      return;
    }

    setState(() => _finalizando = true);

    try {
      final sucesso = _comandas.enviarPedidoAoCaixa(mesa);

      if (!mounted) return;

      if (sucesso) {
        _mostrarMensagem(
          'Pedido da mesa $mesa enviado ao caixa com sucesso!',
        );
      } else {
        _mostrarMensagem(
          'Não foi possível enviar. Confira o status da comanda.',
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
      return PageShell(
        activeRoute: null,
        mostrarCabecalho: false,
        mostrarRodape: false,
        mostrarAcessibilidade: true,
        mostrarCarrinho: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Não foi possível identificar a mesa. '
              'Acesse a comanda pelo QR Code disponibilizado '
              'pela cafeteria.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _corTexto),
            ),
          ),
        ),
      );
    }

    return PageShell(
      activeRoute: null,
      mostrarCabecalho: false,
      mostrarRodape: false,
      mostrarAcessibilidade: true,
      mostrarCarrinho: false,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          _comandas,
          AppState.instance,
        ]),
        builder: (context, _) {
          final atual = _comandas.comandaDaMesa(mesa);

          if (atual == null) {
            return Center(
              child: Text(
                'Comanda não encontrada.',
                style: TextStyle(color: _corTexto),
              ),
            );
          }

          final encerrada = atual.status == 'encerrada';

          final historicoPedidos = AppState.instance.pedidos
              .where((pedido) => pedido.mesa == mesa)
              .toList()
            ..sort((a, b) => b.data.compareTo(a.data));

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 36),
                    Column(
                      children: [
                        Text(
                          'Minha Comanda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'CreamCake',
                            fontSize: 48,
                            fontWeight: FontWeight.w400,
                            color: _corDestaque,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Acompanhe seu pedido à mesa',
                          textAlign: TextAlign.center,
                          style: AppTheme.display(
                            size: 24,
                            weight: FontWeight.w600,
                            color: _corTextoSecundario,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Mesa $mesa',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.titleMedium?.copyWith(
                        color: _corTexto,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _resumoComanda(atual, tema),
                    const SizedBox(height: 24),
                    Text(
                      'Histórico de pedidos',
                      style: tema.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _corTexto,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (historicoPedidos.isEmpty)
                      _cardMensagem(
                        'Você ainda não enviou nenhum pedido. '
                        'Seus pedidos aparecerão aqui após a confirmação.',
                      )
                    else
                      ...historicoPedidos.map(
                        (pedido) => Card(
                          clipBehavior: Clip.antiAlias,
                          child: ExpansionTile(
                            leading: Icon(
                              Icons.receipt_long_outlined,
                              color: _corDestaque,
                            ),
                            title: Text(
                              'Pedido ${pedido.id}',
                              style: TextStyle(color: _corTexto),
                            ),
                            subtitle: Text(
                              '${pedido.data} • ${pedido.status}',
                              style: TextStyle(color: _corTextoSecundario),
                            ),
                            trailing: Text(
                              money(pedido.total),
                              style: tema.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _corTexto,
                              ),
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            children: [
                              Divider(color: _corBorda),
                              _linhaDoTempoPedido(pedido.status, tema),
                              const SizedBox(height: 16),
                              Divider(color: _corBorda),
                              ...pedido.itens.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.qtd}x ${item.nome}',
                                          style: TextStyle(color: _corTexto),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        money(item.subtotal),
                                        style: TextStyle(color: _corTexto),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(color: _corBorda),
                              if (pedido.desconto > 0) ...[
                                _linhaTotal(
                                  'Desconto do cupom',
                                  '- ${money(pedido.desconto)}',
                                ),
                                const SizedBox(height: 8),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Total do pedido',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _corTexto,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    money(pedido.total),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _corTexto,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'O que você deseja fazer?',
                      style: tema.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _corTexto,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: encerrada ? null : () => _fazerPedido(mesa),
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text('Fazer novo pedido'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              _isDark ? DVanilleColors.darkRose : null,
                          foregroundColor:
                              _isDark ? DVanilleColors.darkCream : null,
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
                          'Ver itens pendentes (${atual.quantidadeItens})',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor:
                              _isDark ? DVanilleColors.darkRose : null,
                          side: _isDark
                              ? BorderSide(color: DVanilleColors.darkRose)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: encerrada
                            ? null
                            : () {
                                _comandas.solicitarAtendimento(mesa);
                                _mostrarMensagem(
                                  'Garçom solicitado para a mesa $mesa!',
                                );
                              },
                        icon: const Icon(Icons.room_service_outlined),
                        label: const Text('Chamar garçom'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor:
                              _isDark ? DVanilleColors.darkRose : null,
                          side: _isDark
                              ? BorderSide(color: DVanilleColors.darkRose)
                              : null,
                        ),
                      ),
                    ),

                    // Botão para acessar a apresentação do site.
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.apresentacaoSite,
                          );
                        },
                        icon: const Icon(Icons.language),
                        label: const Text('Conheça o site D’Vanille'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor:
                              _isDark ? DVanilleColors.darkRose : null,
                          side: _isDark
                              ? BorderSide(color: DVanilleColors.darkRose)
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    Container(
                      key: _itensComandaKey,
                      child: Text(
                        'Itens pendentes da comanda',
                        style: tema.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _corTexto,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (atual.itens.isEmpty)
                      _cardMensagem(
                        'Não há itens pendentes. '
                        'Você pode fazer um novo pedido quando desejar.',
                      )
                    else
                      ...atual.itens.map(
                        (item) => Card(
                          child: ListTile(
                            title: Text(
                              item.nome,
                              style: TextStyle(color: _corTexto),
                            ),
                            subtitle: Text(
                              '${item.quantidade} × ${money(item.preco)}'
                              '\nSubtotal: ${money(item.subtotal)}',
                              style: TextStyle(color: _corTextoSecundario),
                            ),
                            isThreeLine: true,
                            trailing: encerrada
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
                                        color: _corDestaque,
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
                                        color: _corDestaque,
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
                                        color: _corDestaque,
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

                    // Área de aplicação do cupom de aniversário.
                    if (!encerrada && atual.itens.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.card_giftcard_outlined,
                                    color: _corDestaque,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Cupom de aniversário',
                                      style:
                                          tema.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _corTexto,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aproveite 15% de desconto durante a semana do seu aniversário!',
                                style: TextStyle(
                                  color: _corTextoSecundario,
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (atual.temCupom) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _corDestaque.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _corDestaque,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: _corDestaque,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              atual.cupomAplicado!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: _corTexto,
                                              ),
                                            ),
                                            Text(
                                              'Desconto de ${(atual.percentualDesconto * 100).toStringAsFixed(0)}% aplicado',
                                              style: TextStyle(
                                                color: _corTextoSecundario,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Remover cupom',
                                        onPressed: () => _removerCupom(mesa),
                                        icon: const Icon(Icons.close),
                                        color: _corDestaque,
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                TextField(
                                  controller: _cupomController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: InputDecoration(
                                    labelText: 'Código do cupom',
                                    hintText: 'Ex.: ANIVERSARIO',
                                    prefixIcon: const Icon(
                                      Icons.confirmation_number_outlined,
                                    ),
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _corBorda,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _corDestaque,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (_) =>
                                      _aplicarCupomAniversario(),
                                ),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: _aplicarCupomAniversario,
                                  icon: const Icon(Icons.local_offer_outlined),
                                  label: const Text('Aplicar cupom'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _isDark
                                        ? DVanilleColors.darkRose
                                        : null,
                                    foregroundColor: _isDark
                                        ? DVanilleColors.darkCream
                                        : null,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _linhaTotal(
                              'Quantidade de itens pendentes',
                              '${atual.quantidadeItens}',
                            ),
                            const SizedBox(height: 12),
                            _linhaTotal(
                              'Subtotal',
                              money(atual.subtotal),
                            ),
                            if (atual.desconto > 0) ...[
                              const SizedBox(height: 8),
                              _linhaTotal(
                                'Desconto (${(atual.percentualDesconto * 100).toStringAsFixed(0)}%)',
                                '- ${money(atual.desconto)}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cupom: ${atual.cupomAplicado}',
                                style: TextStyle(
                                  color: _corDestaque,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const Divider(height: 24),
                            _linhaTotal(
                              'Total dos itens pendentes',
                              money(atual.total),
                              destaque: true,
                            ),
                            const SizedBox(height: 20),
                            if (encerrada)
                              Text(
                                'Esta comanda foi encerrada.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _corTextoSecundario,
                                ),
                              )
                            else
                              FilledButton.icon(
                                onPressed: atual.itens.isEmpty || _finalizando
                                    ? null
                                    : () => _confirmarFinalizacao(mesa, atual),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      _isDark ? DVanilleColors.darkRose : null,
                                  foregroundColor:
                                      _isDark ? DVanilleColors.darkCream : null,
                                ),
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
                                      ? 'Enviando...'
                                      : 'Enviar novo pedido',
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
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: _corTextoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cardMensagem(String mensagem) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          mensagem,
          style: TextStyle(color: _corTextoSecundario),
        ),
      ),
    );
  }

  Widget _linhaDoTempoPedido(String status, ThemeData tema) {
    final etapas = [
      {
        'status': 'recebido',
        'titulo': 'Pedido recebido',
        'descricao': 'Seu pedido foi enviado com sucesso.',
        'icone': Icons.receipt_long_outlined,
      },
      {
        'status': 'em preparação',
        'titulo': 'Em preparação',
        'descricao': 'Estamos preparando seu pedido com carinho.',
        'icone': Icons.soup_kitchen_outlined,
      },
      {
        'status': 'pronto',
        'titulo': 'Pedido pronto',
        'descricao': 'Seu pedido está pronto!',
        'icone': Icons.room_service_outlined,
      },
      {
        'status': 'finalizado',
        'titulo': 'Pedido finalizado',
        'descricao': 'O atendimento deste pedido foi concluído.',
        'icone': Icons.check_circle_outline,
      },
    ];

    final statusAtual = status.trim().toLowerCase();

    final indiceAtual = etapas.indexWhere(
      (etapa) => etapa['status'] == statusAtual,
    );

    final indiceAtivo = indiceAtual < 0 ? 0 : indiceAtual;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tema.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _corBorda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acompanhe seu pedido',
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _corTexto,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'O andamento é atualizado conforme o status do pedido.',
            style: tema.textTheme.bodySmall?.copyWith(
              color: _corTextoSecundario,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(etapas.length, (indice) {
            final etapa = etapas[indice];
            final concluida = indice < indiceAtivo;
            final atual = indice == indiceAtivo;
            final icone = etapa['icone'] as IconData;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 36,
                    child: Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: concluida || atual
                                ? _corDestaque
                                : (_isDark
                                    ? DVanilleColors.darkSurface
                                    : tema.colorScheme.surfaceContainerHighest),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  concluida || atual ? _corDestaque : _corBorda,
                            ),
                          ),
                          child: Icon(
                            concluida ? Icons.check : icone,
                            size: 17,
                            color: concluida || atual
                                ? (_isDark
                                    ? DVanilleColors.darkCream
                                    : Colors.white)
                                : _corTextoSecundario,
                          ),
                        ),
                        if (indice < etapas.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              color: concluida ? _corDestaque : _corBorda,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: indice < etapas.length - 1 ? 20 : 0,
                        top: 3,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            etapa['titulo'] as String,
                            style: tema.textTheme.bodyLarge?.copyWith(
                              fontWeight: atual || concluida
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: atual ? _corDestaque : _corTexto,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            etapa['descricao'] as String,
                            style: tema.textTheme.bodySmall?.copyWith(
                              color: _corTextoSecundario,
                            ),
                          ),
                          if (atual) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _corDestaque.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Etapa atual',
                                style: tema.textTheme.labelSmall?.copyWith(
                                  color: _corDestaque,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
            Icon(
              Icons.receipt_long_outlined,
              size: 32,
              color: _corDestaque,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comanda ${comanda.id}',
                    style: tema.textTheme.titleMedium?.copyWith(
                      color: _corTexto,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: $status',
                    style: TextStyle(color: _corTextoSecundario),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mesa ${comanda.mesa}',
                    style: TextStyle(color: _corTextoSecundario),
                  ),
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
              color: _corDestaque,
            )
        : Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _corTexto,
            );

    return Row(
      children: [
        Expanded(child: Text(titulo, style: estilo)),
        const SizedBox(width: 12),
        Text(valor, style: estilo),
      ],
    );
  }
}
