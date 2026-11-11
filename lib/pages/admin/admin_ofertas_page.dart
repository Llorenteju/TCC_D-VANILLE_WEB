import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../models/produto.dart';
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _abrirFormulario({OfertaConfigurada? editando}) async {
    final state = AppState.instance;
    // Busca diretamente no AppState, incluindo produtos novos criados no Admin.
    // Os que já têm oferta permanecem VISÍVEIS no seletor, mas não podem
    // receber outra oferta pelo botão "Nova oferta".
    final produtosCadastrados = List<Produto>.from(state.produtos)
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    if (editando != null &&
        !produtosCadastrados.any((p) => p.id == editando.produtoId)) {
      _mensagem('O produto desta oferta não foi encontrado.');
      return;
    }

    if (produtosCadastrados.isEmpty) {
      _mensagem('Nenhum produto cadastrado. Cadastre um produto primeiro.');
      return;
    }

    if (editando == null &&
        !produtosCadastrados.any(
          (produto) => state.ofertaPorProduto(produto.id) == null,
        )) {
      _mensagem(
        'Todos os produtos já possuem uma oferta. Edite ou encerre uma oferta existente.',
      );
      return;
    }

    // O diálogo devolve somente os dados. A alteração no AppState
    // é feita após o fechamento, evitando reconstruir a página
    // administrativa enquanto o formulário ainda está aberto.
    final resultado = await showDialog<_DadosOferta>(
      context: context,
      builder: (dialogContext) => _FormularioOfertaDialog(
        produtos: produtosCadastrados,
        editando: editando,
        precoOriginal: state.precoOriginalProduto,
        possuiOferta: (produtoId) => state.ofertaPorProduto(produtoId) != null,
      ),
    );

    if (!mounted || resultado == null) return;

    final erro = state.salvarOferta(
      produtoId: resultado.produtoId,
      percentual: resultado.percentual,
      inicio: resultado.inicio,
      fim: resultado.fim,
    );

    if (erro != null) {
      _mensagem(erro);
      return;
    }

    _mensagem('Oferta salva com sucesso!');
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

    if (!mounted || confirmar != true) return;
    AppState.instance.encerrarOferta(oferta.produtoId);
    _mensagem('Oferta encerrada.');
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
        mainAxisSize: MainAxisSize.min,
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
            runSpacing: 8,
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

// Resultado temporário do formulário. Não altera a oferta até o
// diálogo terminar, evitando notificações no meio da navegação.
class _DadosOferta {
  final int produtoId;
  final double percentual;
  final DateTime? inicio;
  final DateTime? fim;

  const _DadosOferta({
    required this.produtoId,
    required this.percentual,
    required this.inicio,
    required this.fim,
  });
}

class _FormularioOfertaDialog extends StatefulWidget {
  final List<Produto> produtos;
  final OfertaConfigurada? editando;
  final double Function(int) precoOriginal;
  final bool Function(int) possuiOferta;

  const _FormularioOfertaDialog({
    required this.produtos,
    required this.editando,
    required this.precoOriginal,
    required this.possuiOferta,
  });

  @override
  State<_FormularioOfertaDialog> createState() =>
      _FormularioOfertaDialogState();
}

class _FormularioOfertaDialogState extends State<_FormularioOfertaDialog> {
  final _chaveFormulario = GlobalKey<FormState>();
  late final TextEditingController _percentualController;
  late int _produtoId;
  DateTime? _inicio;
  DateTime? _fim;
  String? _erroDatas;

  @override
  void initState() {
    super.initState();
    _produtoId = widget.editando?.produtoId ??
        widget.produtos
            .firstWhere(
              (produto) => !widget.possuiOferta(produto.id),
              orElse: () => widget.produtos.first,
            )
            .id;
    _inicio = widget.editando?.inicio;
    _fim = widget.editando?.fim;
    _percentualController = TextEditingController(
      text: widget.editando == null
          ? '15'
          : widget.editando!.percentual.toStringAsFixed(1).replaceAll('.', ','),
    );
  }

  @override
  void dispose() {
    _percentualController.dispose();
    super.dispose();
  }

  String _data(DateTime? data) {
    if (data == null) return 'Sem data definida';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Future<void> _escolherData({required bool inicial}) async {
    final hoje = DateTime.now();
    final atual = inicial ? _inicio : _fim;
    final dataInicial = atual != null && atual.year >= 2020 ? atual : hoje;

    final escolhida = await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (!mounted || escolhida == null) return;
    setState(() {
      if (inicial) {
        _inicio = escolhida;
      } else {
        _fim = escolhida;
      }
      _erroDatas = null;
    });
  }

  Widget _campoData({
    required String rotulo,
    required DateTime? valor,
    required bool inicial,
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
            onPressed: () => _escolherData(inicial: inicial),
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: Text(_data(valor)),
          ),
        ),
        if (valor != null)
          IconButton(
            tooltip: 'Limpar data',
            onPressed: () => setState(() {
              if (inicial) {
                _inicio = null;
              } else {
                _fim = null;
              }
              _erroDatas = null;
            }),
            icon: const Icon(Icons.close, size: 18),
          ),
      ],
    );
  }

  void _confirmar() {
    if (!(_chaveFormulario.currentState?.validate() ?? false)) return;

    // Evita substituir uma promoção existente sem passar pelo botão "Editar".
    if (widget.editando == null && widget.possuiOferta(_produtoId)) {
      setState(() {
        _erroDatas =
            'Este produto já possui uma oferta. Use o botão Editar na oferta existente.';
      });
      return;
    }

    final percentual = double.parse(
      _percentualController.text.trim().replaceAll(',', '.'),
    );

    if (_inicio != null && _fim != null && _fim!.isBefore(_inicio!)) {
      setState(() {
        _erroDatas = 'A data final não pode ser anterior à inicial.';
      });
      return;
    }

    if (_fim != null) {
      final agora = DateTime.now();
      final hoje = DateTime(agora.year, agora.month, agora.day);
      final termino = DateTime(_fim!.year, _fim!.month, _fim!.day);
      if (termino.isBefore(hoje)) {
        setState(() {
          _erroDatas = 'A data final não pode estar no passado.';
        });
        return;
      }
    }

    if (widget.precoOriginal(_produtoId) <= 0) {
      setState(() {
        _erroDatas = 'O preço original precisa ser positivo.';
      });
      return;
    }

    Navigator.of(context).pop(
      _DadosOferta(
        produtoId: _produtoId,
        percentual: percentual,
        inicio: _inicio,
        fim: _fim,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final precoOriginal = widget.precoOriginal(_produtoId);
    final percentual = double.tryParse(
      _percentualController.text.trim().replaceAll(',', '.'),
    );
    final precoPromocional =
        percentual == null || percentual <= 0 || percentual >= 100
            ? null
            : (precoOriginal * (1 - percentual / 100) * 100).round() / 100;

    return AlertDialog(
      title: Text(
        widget.editando == null ? 'Nova oferta' : 'Editar oferta',
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
            key: _chaveFormulario,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.produtos.length} produtos cadastrados no sistema',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: _produtoId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Produto',
                    helperText:
                        'Lista atualizada dos produtos cadastrados no Admin',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.produtos.map((produto) {
                    final jaTemOferta = widget.possuiOferta(produto.id);
                    return DropdownMenuItem<int>(
                      value: produto.id,
                      enabled: widget.editando != null || !jaTemOferta,
                      child: Text(
                        jaTemOferta && widget.editando == null
                            ? '${produto.nome} (já possui oferta)'
                            : produto.nome,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: widget.editando != null
                      ? null
                      : (valor) {
                          if (valor == null) return;
                          setState(() => _produtoId = valor);
                        },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _percentualController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Desconto (%)',
                    hintText: 'Ex.: 15',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  onChanged: (_) => setState(() {}),
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
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
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
                _campoData(rotulo: 'Início', valor: _inicio, inicial: true),
                const SizedBox(height: 8),
                _campoData(rotulo: 'Término', valor: _fim, inicial: false),
                if (_erroDatas != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _erroDatas!,
                    style: const TextStyle(
                      color: Color(0xFFB5473F),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Sem datas, a oferta permanece ativa até ser encerrada.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Salvar oferta'),
        ),
      ],
    );
  }
}
