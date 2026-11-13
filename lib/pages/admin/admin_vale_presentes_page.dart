import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app.dart';
import '../../models/vale_presente.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import 'admin_shell.dart';

/// Gestão e validação presencial dos vales-presente da D'Vanille.
/// O código é resgatado uma única vez e vence automaticamente em 30 dias úteis.
class AdminValePresentesPage extends StatefulWidget {
  const AdminValePresentesPage({super.key});

  @override
  State<AdminValePresentesPage> createState() => _AdminValePresentesPageState();
}

class _AdminValePresentesPageState extends State<AdminValePresentesPage> {
  final _buscaController = TextEditingController();
  final _codigoController = TextEditingController();

  String _aba = 'ativos';
  String _filtroStatus = 'todos';

  static const _statusDisponiveis = <String>[
    'todos',
    'ativo',
    'utilizado',
    'expirado',
    'cancelado',
  ];

  @override
  void dispose() {
    _buscaController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  bool get _escuro => Theme.of(context).brightness == Brightness.dark;
  Color get _texto => _escuro
      ? Theme.of(context).colorScheme.onSurface
      : DVanilleColors.darkTaupe;
  Color get _subtexto =>
      _escuro ? const Color(0xFFCEBFB1) : DVanilleColors.taupe;
  Color get _borda => _escuro ? const Color(0xFF5A4D44) : DVanilleColors.line;
  Color get _superficie => Theme.of(context).cardColor;

  String _nomeStatus(String status) {
    switch (status) {
      case 'ativo':
        return 'Ativo';
      case 'utilizado':
        return 'Utilizado';
      case 'expirado':
        return 'Expirado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Todos os status';
    }
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'ativo':
        return const Color(0xFF43815A);
      case 'utilizado':
        return const Color(0xFF467A96);
      case 'expirado':
        return const Color(0xFFAA762F);
      case 'cancelado':
        return const Color(0xFFAA514C);
      default:
        return DVanilleColors.rose;
    }
  }

  Color _fundoStatus(String status) {
    if (_escuro) return const Color(0xFF42382F);
    switch (status) {
      case 'ativo':
        return const Color(0xFFE4F2E7);
      case 'utilizado':
        return const Color(0xFFE7F1F7);
      case 'expirado':
        return const Color(0xFFFFF1DA);
      case 'cancelado':
        return const Color(0xFFFBE4E1);
      default:
        return DVanilleColors.blush2;
    }
  }

  Widget _etiquetaStatus(String status) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _fundoStatus(status),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          _nomeStatus(status),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _escuro ? Colors.white : _corStatus(status),
          ),
        ),
      );

  String _data(DateTime? data) {
    if (data == null) return 'Sem validade definida';
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year}';
  }

  Widget _cardResumo(
    String titulo,
    String valor,
    IconData icone,
    Color cor,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _superficie,
        border: Border.all(color: _borda),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: cor),
          Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        valor,
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                          color: _texto,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        titulo,
                        style: TextStyle(fontSize: 13, color: _subtexto),
                      ),
                    ],
                  ),
                ),
                Icon(icone, color: cor, size: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumo(List<ValePresente> vales, double largura) {
    final itens = [
      (
        'Emitidos',
        vales.length.toString(),
        Icons.card_giftcard,
        DVanilleColors.rose
      ),
      (
        'Ativos',
        vales.where((v) => v.status == 'ativo').length.toString(),
        Icons.check_circle_outline,
        const Color(0xFF43815A)
      ),
      (
        'Utilizados',
        vales.where((v) => v.status == 'utilizado').length.toString(),
        Icons.redeem_outlined,
        const Color(0xFF467A96)
      ),
      (
        'Expirados',
        vales.where((v) => v.status == 'expirado').length.toString(),
        Icons.schedule_outlined,
        const Color(0xFFAA762F)
      ),
      (
        'Cancelados',
        vales.where((v) => v.status == 'cancelado').length.toString(),
        Icons.block_outlined,
        const Color(0xFFAA514C)
      ),
    ];
    final colunas = largura >= 1040
        ? 5
        : largura >= 550
            ? 2
            : 1;
    const espaco = 12.0;
    final larguraCard = (largura - (colunas - 1) * espaco) / colunas;
    return Wrap(
      spacing: espaco,
      runSpacing: espaco,
      children: [
        for (final item in itens)
          SizedBox(
            width: larguraCard,
            child: _cardResumo(item.$1, item.$2, item.$3, item.$4),
          ),
      ],
    );
  }

  void _avisar(String mensagem, {bool sucesso = false}) {
    showToast(mensagem, sucesso ? '✓' : '⚠️');
  }

  Future<void> _copiarCodigo(ValePresente vale) async {
    await Clipboard.setData(ClipboardData(text: vale.codigo));
    if (!mounted) return;
    showToast('Código copiado!', 'copiar.svg');
  }

  Widget _informacao(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: 12, color: _subtexto)),
          const SizedBox(height: 4),
          SelectableText(
            valor.trim().isEmpty ? 'Não informado' : valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _texto,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _detalhes(ValePresente vale) async {
    final state = AppState.instance;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Detalhes do vale-presente',
          style: TextStyle(fontFamily: 'CreamCake', fontSize: 30),
        ),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _etiquetaStatus(vale.status),
                const SizedBox(height: 18),
                _informacao('Código', vale.codigo),
                _informacao('Valor', money(vale.valor)),
                _informacao('Destinatário', vale.destinatario),
                _informacao('Comprador', vale.compradorEmail),
                _informacao('Emissão', vale.criadoEm),
                _informacao(
                    'Validade', _data(state.validadeValePresente(vale.id))),
                if (state.dataResgateValePresente(vale.id) != null)
                  _informacao('Resgatado em',
                      _data(state.dataResgateValePresente(vale.id))),
                if (vale.mensagem.trim().isNotEmpty)
                  _informacao('Mensagem', vale.mensagem),
                const Divider(),
                Text(
                  'Uso presencial, com vencimento automático de 30 dias úteis após a emissão.',
                  style: TextStyle(fontSize: 12, color: _subtexto),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _copiarCodigo(vale);
            },
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copiar código'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarResgate(ValePresente vale) async {
    final state = AppState.instance;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Confirmar resgate presencial?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${vale.codigo}'),
            const SizedBox(height: 6),
            Text('Valor: ${money(vale.valor)}'),
            const SizedBox(height: 6),
            Text(
                'Destinatário: ${vale.destinatario.isEmpty ? 'Não informado' : vale.destinatario}'),
            const SizedBox(height: 14),
            const Text(
              'Confirme somente depois de receber o código na cafeteria. '
              'Após a confirmação, este código não poderá ser resgatado novamente.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar utilização'),
          ),
        ],
      ),
    );
    if (!mounted || confirmado != true) return;
    final problema = state.resgatarValePresente(vale.codigo);
    if (problema != null) {
      _avisar(problema);
    } else {
      _codigoController.clear();
      showToast('Vale-presente utilizado com sucesso!', 'presente.svg');
      setState(() => _aba = 'historico');
    }
  }

  void _buscarCodigoParaResgate() {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      _avisar('Informe o código apresentado pelo cliente.');
      return;
    }
    final vale = AppState.instance.valePorCodigo(codigo);
    if (vale == null) {
      _avisar('Código não encontrado.');
      return;
    }
    if (vale.status != 'ativo') {
      _avisar(
          'Este vale está ${_nomeStatus(vale.status).toLowerCase()} e não pode ser resgatado.');
      return;
    }
    _confirmarResgate(vale);
  }

  Future<void> _cancelarVale(ValePresente vale) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar vale-presente?'),
        content: Text('O código ${vale.codigo} não poderá mais ser utilizado.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Voltar')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cancelar vale')),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    final problema = AppState.instance.cancelarValePresente(vale.id);
    if (problema == null) {
      showToast('Vale-presente cancelado!', 'presente.svg');
      setState(() => _aba = 'historico');
    } else {
      _avisar(problema);
    }
  }

  Future<void> _excluirVale(ValePresente vale) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir registro permanentemente?'),
        content: const Text(
          'Esta ação apaga o vale também do armazenamento local e do histórico. '
          'Para impedir o uso de um vale, prefira a opção Cancelar.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Voltar')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Excluir registro')),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    AppState.instance.excluirValePresente(vale.id);
    showToast('Registro excluído!', 'lixeira.svg');
  }

  Widget _acoes(ValePresente vale) {
    final ativo = vale.status == 'ativo';
    return PopupMenuButton<String>(
      tooltip: 'Ações do vale-presente',
      icon: Icon(Icons.more_horiz_rounded, color: _texto),
      onSelected: (acao) {
        switch (acao) {
          case 'detalhes':
            _detalhes(vale);
            break;
          case 'copiar':
            _copiarCodigo(vale);
            break;
          case 'resgatar':
            _confirmarResgate(vale);
            break;
          case 'cancelar':
            _cancelarVale(vale);
            break;
          case 'excluir':
            _excluirVale(vale);
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'detalhes', child: Text('Ver detalhes')),
        const PopupMenuItem(value: 'copiar', child: Text('Copiar código')),
        if (ativo) ...[
          const PopupMenuItem(
              value: 'resgatar', child: Text('Confirmar resgate')),
          const PopupMenuItem(value: 'cancelar', child: Text('Cancelar vale')),
        ],
        const PopupMenuItem(value: 'excluir', child: Text('Excluir registro')),
      ],
    );
  }

  Widget _campoBusca() {
    return TextField(
      controller: _buscaController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: 'Pesquisar código, destinatário ou comprador',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _buscaController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar pesquisa',
                onPressed: () => setState(_buscaController.clear),
                icon: const Icon(Icons.close),
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }

  Widget _painelResgate(double largura) {
    final estreito = largura < 750;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _superficie,
        border: Border.all(color: _borda),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Validar código na cafeteria',
              style: TextStyle(
                  color: _texto, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
              'Digite o código apresentado presencialmente. Confira os dados antes de confirmar a utilização única.',
              style: TextStyle(color: _subtexto, fontSize: 13)),
          const SizedBox(height: 15),
          if (estreito) ...[
            TextField(
              controller: _codigoController,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _buscarCodigoParaResgate(),
              decoration: const InputDecoration(
                  labelText: 'Código do vale-presente',
                  prefixIcon: Icon(Icons.qr_code_2_outlined)),
            ),
            const SizedBox(height: 12),
            SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                    onPressed: _buscarCodigoParaResgate,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Validar código'))),
          ] else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codigoController,
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _buscarCodigoParaResgate(),
                    decoration: const InputDecoration(
                        labelText: 'Código do vale-presente',
                        prefixIcon: Icon(Icons.qr_code_2_outlined)),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                    onPressed: _buscarCodigoParaResgate,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Validar código')),
              ],
            ),
        ],
      ),
    );
  }

  Widget _filtros(double largura) {
    final filtro = DropdownButtonFormField<String>(
      key: ValueKey(_filtroStatus),
      initialValue: _filtroStatus,
      isExpanded: true,
      decoration: const InputDecoration(
          labelText: 'Status', prefixIcon: Icon(Icons.filter_list_rounded)),
      items: [
        for (final status in _statusDisponiveis)
          DropdownMenuItem(value: status, child: Text(_nomeStatus(status))),
      ],
      onChanged: (status) => setState(() => _filtroStatus = status ?? 'todos'),
    );
    if (largura < 720) {
      return Column(
          children: [_campoBusca(), const SizedBox(height: 12), filtro]);
    }
    return Row(children: [
      Expanded(flex: 3, child: _campoBusca()),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: filtro)
    ]);
  }

  Widget _abas(int ativos, int historico) {
    Widget botao(String id, String titulo, int total) {
      final selecionado = _aba == id;
      final textoSelecionado =
          _escuro ? DVanilleColors.darkCream : DVanilleColors.ink;

      return ChoiceChip(
        label: Text('$titulo ($total)'),
        selected: selecionado,
        // No tema escuro, rosa mais intenso com texto marrom bem escuro.
        // Evita texto claro sobre o fundo rosa do chip selecionado.
        selectedColor:
            _escuro ? DVanilleColors.darkRose : DVanilleColors.blush2,
        backgroundColor:
            _escuro ? DVanilleColors.darkSurface : DVanilleColors.white,
        labelStyle: TextStyle(
          color: selecionado ? textoSelecionado : _texto,
          fontSize: 14,
          fontWeight: selecionado ? FontWeight.w800 : FontWeight.w600,
        ),
        checkmarkColor: textoSelecionado,
        side: BorderSide(
          color: selecionado
              ? (_escuro ? DVanilleColors.darkRose : DVanilleColors.rose)
              : _borda,
        ),
        onSelected: (_) => setState(() => _aba = id),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 7,
      children: [
        botao('ativos', 'Vales ativos', ativos),
        botao('historico', 'Histórico', historico),
        botao('todos', 'Todos', ativos + historico),
      ],
    );
  }

  Widget _tabela(List<ValePresente> vales) {
    return LayoutBuilder(
      builder: (_, tamanho) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: _superficie,
            border: Border.all(color: _borda),
            borderRadius: BorderRadius.circular(18)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tamanho.maxWidth < 1100 ? 1100 : tamanho.maxWidth,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                  _escuro ? DVanilleColors.darkCream2 : DVanilleColors.cream2),
              horizontalMargin: 22,
              columnSpacing: 22,
              columns: const [
                DataColumn(label: Text('CÓDIGO')),
                DataColumn(label: Text('VALOR')),
                DataColumn(label: Text('DESTINATÁRIO')),
                DataColumn(label: Text('CRIADO EM')),
                DataColumn(label: Text('VALIDADE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('AÇÕES')),
              ],
              rows: [
                for (final vale in vales)
                  DataRow(
                    cells: [
                      DataCell(SelectableText(vale.codigo,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: _texto))),
                      DataCell(Text(money(vale.valor))),
                      DataCell(Text(
                          vale.destinatario.isEmpty ? '—' : vale.destinatario)),
                      DataCell(Text(vale.criadoEm)),
                      DataCell(Text(_data(
                          AppState.instance.validadeValePresente(vale.id)))),
                      DataCell(_etiquetaStatus(vale.status)),
                      DataCell(_acoes(vale)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardsMobile(List<ValePresente> vales) {
    return Column(
      children: [
        for (final vale in vales)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                  color: _superficie,
                  border: Border.all(color: _borda),
                  borderRadius: BorderRadius.circular(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(vale.codigo,
                            style: TextStyle(
                                fontWeight: FontWeight.w700, color: _texto))),
                    _acoes(vale)
                  ]),
                  const SizedBox(height: 8),
                  Text(money(vale.valor),
                      style: TextStyle(
                          color: _texto,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                      'Destinatário: ${vale.destinatario.isEmpty ? 'Não informado' : vale.destinatario}',
                      style: TextStyle(color: _subtexto)),
                  const SizedBox(height: 7),
                  Text(
                      'Validade: ${_data(AppState.instance.validadeValePresente(vale.id))}',
                      style: TextStyle(color: _subtexto)),
                  const SizedBox(height: 12),
                  _etiquetaStatus(vale.status),
                  const SizedBox(height: 10),
                  TextButton.icon(
                      onPressed: () => _detalhes(vale),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Ver detalhes')),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final todos = state.valePresentes.toList();
        final ativos = todos.where((v) => v.status == 'ativo').length;
        final historico = todos.length - ativos;
        final termo = _buscaController.text.trim().toLowerCase();
        final filtrados = todos.reversed.where((vale) {
          final buscaOk = termo.isEmpty ||
              vale.codigo.toLowerCase().contains(termo) ||
              vale.destinatario.toLowerCase().contains(termo) ||
              vale.compradorEmail.toLowerCase().contains(termo);
          final abaOk = _aba == 'todos' ||
              (_aba == 'ativos'
                  ? vale.status == 'ativo'
                  : vale.status != 'ativo');
          final statusOk =
              _filtroStatus == 'todos' || vale.status == _filtroStatus;
          return buscaOk && abaOk && statusOk;
        }).toList();

        return AdminShell(
          titulo: 'Vale-presentes',
          rotaAtual: Routes.adminValePresentes,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final largura = constraints.maxWidth;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Gerencie códigos de uso presencial com validade automática de 30 dias úteis.',
                      style: TextStyle(color: _subtexto, fontSize: 14)),
                  const SizedBox(height: 22),
                  _resumo(todos, largura),
                  const SizedBox(height: 24),
                  _painelResgate(largura),
                  const SizedBox(height: 24),
                  _abas(ativos, historico),
                  const SizedBox(height: 15),
                  _filtros(largura),
                  const SizedBox(height: 16),
                  Text('${filtrados.length} vale(s) exibido(s)',
                      style: TextStyle(color: _subtexto, fontSize: 13)),
                  const SizedBox(height: 12),
                  if (filtrados.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(35),
                      decoration: BoxDecoration(
                          color: _superficie,
                          border: Border.all(color: _borda),
                          borderRadius: BorderRadius.circular(18)),
                      child: Column(children: [
                        const Icon(Icons.card_giftcard,
                            size: 36, color: DVanilleColors.rose),
                        const SizedBox(height: 9),
                        Text('Nenhum vale-presente encontrado',
                            style: TextStyle(
                                color: _texto, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 5),
                        Text('Confira a aba, o status e a pesquisa.',
                            style: TextStyle(color: _subtexto))
                      ]),
                    )
                  else if (largura >= 730)
                    _tabela(filtrados)
                  else
                    _cardsMobile(filtrados),
                  const SizedBox(height: 20),
                  Text(
                    'Um vale utilizado não pode ser resgatado novamente. Se a compra for menor, a diferença de valor deve ser restituída ao consumidor. Sem backend, os dados são locais a este navegador.',
                    style: TextStyle(color: _subtexto, fontSize: 12),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
