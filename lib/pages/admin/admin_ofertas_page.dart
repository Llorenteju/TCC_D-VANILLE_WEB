import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import 'admin_shell.dart';

class AdminOfertasPage extends StatefulWidget {
  const AdminOfertasPage({super.key});

  @override
  State<AdminOfertasPage> createState() => _AdminOfertasPageState();
}

class _AdminOfertasPageState extends State<AdminOfertasPage> {
  String _filtro = 'todas';

  String _data(DateTime? data) {
    if (data == null) return 'Sem data definida';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  void _mensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _abrirFormulario({OfertaConfigurada? editando}) async {
    final state = AppState.instance;
    final disponiveis = state.produtos.where((produto) {
      return editando != null
          ? produto.id == editando.produtoId
          : state.ofertaPorProduto(produto.id) == null;
    }).toList();

    if (disponiveis.isEmpty) {
      _mensagem('Não há produtos disponíveis para uma nova oferta.');
      return;
    }

    var produtoId = editando?.produtoId ?? disponiveis.first.id;
    DateTime? inicio = editando?.inicio;
    DateTime? fim = editando?.fim;
    final percentualController = TextEditingController(
      text: editando == null
          ? '15'
          : editando.percentual.toStringAsFixed(1).replaceAll('.', ','),
    );
    final chaveFormulario = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, atualizarDialogo) {
            final precoOriginal = state.precoOriginalProduto(produtoId);
            final percentual = double.tryParse(
              percentualController.text.trim().replaceAll(',', '.'),
            );
            final precoPromocional = percentual == null ||
                    percentual <= 0 ||
                    percentual >= 100
                ? null
                : (precoOriginal * (1 - percentual / 100) * 100).round() /
                    100;

            Future<void> escolherData({required bool inicial}) async {
              final hoje = DateTime.now();
              final atual = inicial ? inicio : fim;
              final escolhida = await showDatePicker(
                context: dialogContext,
                initialDate: atual ?? hoje,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                locale: const Locale('pt', 'BR'),
              );
              if (escolhida != null && dialogContext.mounted) {
                atualizarDialogo(() {
                  if (inicial) {
                    inicio = escolhida;
                  } else {
                    fim = escolhida;
                  }
                });
              }
            }

            return AlertDialog(
              title: Text(
                editando == null ? 'Nova oferta' : 'Editar oferta',
                style: const TextStyle(
                  fontFamily: 'CreamCake',
                  fontSize: 34,
                  color: DVanilleColors.darkTaupe,
                ),
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Form(
                    key: chaveFormulario,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: produtoId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Produto',
                            border: OutlineInputBorder(),
                          ),
                          items: disponiveis.map((produto) {
                            return DropdownMenuItem<int>(
                              value: produto.id,
                              child: Text(
                                produto.nome,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: editando != null
                              ? null
                              : (valor) {
                                  if (valor != null) {
                                    atualizarDialogo(() => produtoId = valor);
                                  }
                                },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: percentualController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Desconto (%)',
                            hintText: 'Ex.: 15',
                            border: OutlineInputBorder(),
                            suffixText: '%',
                          ),
                          onChanged: (_) => atualizarDialogo(() {}),
                          validator: (valor) {
                            final numero = double.tryParse(
                              (valor ?? '').trim().replaceAll(',', '.'),
                            );
                            if (numero == null ||
                                !numero.isFinite ||
                                numero <= 0 ||
                                numero >= 100) {
                              return 'Informe um percentual entre 0 e 100.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(dialogContext)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Preço original: ${money(precoOriginal)}'),
                              const SizedBox(height: 5),
                              Text(
                                'Preço com desconto: '
                                '${precoPromocional == null ? '—' : money(precoPromocional)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: DVanilleColors.rose,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Validade da promoção (opcional)',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _campoData(
                          rotulo: 'Início',
                          valor: _data(inicio),
                          aoEscolher: () => escolherData(inicial: true),
                          aoLimpar: inicio == null
                              ? null
                              : () => atualizarDialogo(() => inicio = null),
                        ),
                        const SizedBox(height: 8),
                        _campoData(
                          rotulo: 'Término',
                          valor: _data(fim),
                          aoEscolher: () => escolherData(inicial: false),
                          aoLimpar: fim == null
                              ? null
                              : () => atualizarDialogo(() => fim = null),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sem datas, a oferta permanece ativa até ser encerrada.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(dialogContext)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!chaveFormulario.currentState!.validate()) return;
                    final percentual = double.parse(
                      percentualController.text.trim().replaceAll(',', '.'),
                    );
                    final erro = state.salvarOferta(
                      produtoId: produtoId,
                      percentual: percentual,
                      inicio: inicio,
                      fim: fim,
                    );
                    if (erro != null) {
                      _mensagem(erro);
                      return;
                    }
                    Navigator.pop(dialogContext);
                    _mensagem('Oferta salva com sucesso!');
                  },
                  child: const Text('Salvar oferta'),
                ),
              ],
            );
          },
        );
      },
    );
    percentualController.dispose();
  }

  Widget _campoData({
    required String rotulo,
    required String valor,
    required VoidCallback aoEscolher,
    VoidCallback? aoLimpar,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            rotulo,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: aoEscolher,
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: Text(valor),
          ),
        ),
        if (aoLimpar != null)
          IconButton(
            tooltip: 'Limpar data',
            onPressed: aoLimpar,
            icon: const Icon(Icons.close, size: 18),
          ),
      ],
    );
  }

  Future<void> _encerrarOferta(OfertaConfigurada oferta) async {
    final produto = AppState.instance.produtoPorId(oferta.produtoId);
    if (produto == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Encerrar oferta'),
        content: Text(
          'Deseja remover a promoção de "${produto.nome}"? '
          'O produto voltará ao preço original.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      AppState.instance.encerrarOferta(oferta.produtoId);
      _mensagem('Oferta encerrada.');
    }
  }

  Widget _resumo(String valor, String texto, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DVanilleColors.line),
      ),
      child: Row(
        children: [
          Icon(icone, color: DVanilleColors.rose, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: DVanilleColors.rose,
                ),
              ),
              Text(texto, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cartaoOferta(OfertaConfigurada oferta) {
    final state = AppState.instance;
    final produto = state.produtoPorId(oferta.produtoId);
    if (produto == null) return const SizedBox.shrink();

    final status = oferta.status;
    final ativa = status == 'ativa';
    final corStatus = ativa
        ? const Color(0xFF388567)
        : status == 'agendada'
            ? const Color(0xFF5477A0)
            : DVanilleColors.taupe;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DVanilleColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: DVanilleColors.blush2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: DVanilleColors.rose,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  produto.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: corStatus.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status == 'ativa'
                      ? 'Ativa'
                      : status == 'agendada'
                          ? 'Agendada'
                          : 'Encerrada',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: corStatus,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              Text(
                'Original: ${money(oferta.precoOriginal)}',
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                'Oferta: ${money(oferta.precoPromocional)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: DVanilleColors.rose,
                ),
              ),
              Text(
                '${oferta.percentual.toStringAsFixed(1).replaceAll('.', ',')}% OFF',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Início: ${_data(oferta.inicio)}  •  Término: ${_data(oferta.fim)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: DVanilleColors.line),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => _abrirFormulario(editando: oferta),
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Editar'),
              ),
              TextButton.icon(
                onPressed: () => _encerrarOferta(oferta),
                icon: const Icon(Icons.close_rounded, size: 17),
                label: const Text('Encerrar oferta'),
                style: TextButton.styleFrom(
                  foregroundColor: DVanilleColors.rose,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final configuradas = state.ofertasGerenciadas;
        final ativas = configuradas.where((o) => o.status == 'ativa').length;
        final agendadas =
            configuradas.where((o) => o.status == 'agendada').length;
        final encerradas =
            configuradas.where((o) => o.status == 'encerrada').length;
        final filtradas = configuradas.where((o) {
          return _filtro == 'todas' || o.status == _filtro;
        }).toList();

        return AdminShell(
          titulo: 'Ofertas',
          rotaAtual: Routes.adminOfertas,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  const Text(
                    'Gerencie as promoções dos produtos cadastrados.',
                    style: TextStyle(fontSize: 14),
                  ),
                  FilledButton.icon(
                    onPressed: () => _abrirFormulario(),
                    icon: const Icon(Icons.add),
                    label: const Text('Nova oferta'),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _resumo('$ativas', 'Ofertas ativas', Icons.sell_outlined),
                  _resumo(
                    '$agendadas',
                    'Agendadas',
                    Icons.event_available_outlined,
                  ),
                  _resumo(
                    '$encerradas',
                    'Encerradas',
                    Icons.history_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filtro in [
                      ('todas', 'Todas'),
                      ('ativa', 'Ativas'),
                      ('agendada', 'Agendadas'),
                      ('encerrada', 'Encerradas'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filtro.$2),
                          selected: _filtro == filtro.$1,
                          onSelected: (_) =>
                              setState(() => _filtro = filtro.$1),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (filtradas.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DVanilleColors.line),
                  ),
                  child: const Text(
                    'Nenhuma oferta encontrada. Use "Nova oferta" para cadastrar uma promoção.',
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final largura = constraints.maxWidth;
                    final larguraCard =
                        largura >= 900 ? (largura - 18) / 2 : largura;
                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: filtradas.map((oferta) {
                        return SizedBox(
                          width: larguraCard,
                          child: _cartaoOferta(oferta),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
