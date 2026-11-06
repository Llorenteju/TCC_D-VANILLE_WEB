import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app.dart';
import '../../models/vale_presente.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import 'admin_shell.dart';

class AdminValePresentesPage extends StatefulWidget {
  const AdminValePresentesPage({super.key});

  @override
  State<AdminValePresentesPage> createState() => _AdminValePresentesPageState();
}

class _AdminValePresentesPageState extends State<AdminValePresentesPage> {
  final TextEditingController _buscaController = TextEditingController();

  String _filtroStatus = 'todos';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // ================= CORES =================

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _corTexto => _isDark
      ? Theme.of(context).colorScheme.onSurface
      : DVanilleColors.darkTaupe;

  Color get _corSecundaria =>
      _isDark ? const Color(0xFFCEBFB1) : DVanilleColors.taupe;

  Color get _corBorda =>
      _isDark ? const Color(0xFF5A4D44) : DVanilleColors.line;

  Color get _corSuperficie => Theme.of(context).cardColor;

  Color _corStatus(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
        return const Color(0xFF43815A);
      case 'utilizado':
        return const Color(0xFF467A96);
      case 'expirado':
        return const Color(0xFFAD762D);
      case 'cancelado':
        return const Color(0xFFB5473F);
      default:
        return DVanilleColors.rose;
    }
  }

  Color _fundoStatus(String status) {
    if (_isDark) {
      switch (status.toLowerCase()) {
        case 'ativo':
          return const Color(0xFF294735);
        case 'utilizado':
          return const Color(0xFF253F50);
        case 'expirado':
          return const Color(0xFF4E3925);
        case 'cancelado':
          return const Color(0xFF502E2C);
        default:
          return DVanilleColors.darkCream2;
      }
    }

    switch (status.toLowerCase()) {
      case 'ativo':
        return const Color(0xFFE4F2E7);
      case 'utilizado':
        return const Color(0xFFE7F1F7);
      case 'expirado':
        return const Color(0xFFFFF1DA);
      case 'cancelado':
        return const Color(0xFFFBE7E5);
      default:
        return DVanilleColors.blush2;
    }
  }

  String _nomeStatus(String status) {
    if (status.isEmpty) return 'Não informado';

    return '${status[0].toUpperCase()}${status.substring(1)}';
  }

  String _formatarData(String data) {
    final convertida = DateTime.tryParse(data);

    if (convertida == null) return data;

    final dia = convertida.day.toString().padLeft(2, '0');
    final mes = convertida.month.toString().padLeft(2, '0');

    return '$dia/$mes/${convertida.year}';
  }

  // ================= ETIQUETA DE STATUS =================

  Widget _etiquetaStatus(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _fundoStatus(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _nomeStatus(status),
        style: TextStyle(
          color: _isDark ? Colors.white : _corStatus(status),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ================= ESTATÍSTICAS =================

  Widget _cardEstatistica({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _corSuperficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _corBorda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            color: cor,
          ),
          Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        valor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: _corTexto,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isDark
                            ? DVanilleColors.darkCream2
                            : DVanilleColors.blush2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icone,
                        color: cor,
                        size: 23,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  style: TextStyle(
                    color: _corTexto,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumoVales(
    double largura,
    List<ValePresente> vales,
  ) {
    final ativos =
        vales.where((vale) => vale.status.toLowerCase() == 'ativo').length;

    final valorTotal = vales.fold<double>(
      0,
      (total, vale) => total + vale.valor,
    );

    final dados = [
      (
        'Vales emitidos',
        '${vales.length}',
        Icons.card_giftcard_outlined,
        DVanilleColors.rose,
      ),
      (
        'Vales ativos',
        '$ativos',
        Icons.check_circle_outline_rounded,
        const Color(0xFF74A381),
      ),
      (
        'Valor total emitido',
        money(valorTotal),
        Icons.account_balance_wallet_outlined,
        DVanilleColors.taupe,
      ),
    ];

    final int colunas;

    if (largura >= 980) {
      colunas = 3;
    } else if (largura >= 600) {
      colunas = 2;
    } else {
      colunas = 1;
    }

    const espacamento = 16.0;

    final larguraCard = (largura - espacamento * (colunas - 1)) / colunas;

    return Wrap(
      spacing: espacamento,
      runSpacing: espacamento,
      children: dados.map((item) {
        return SizedBox(
          width: larguraCard,
          child: _cardEstatistica(
            titulo: item.$1,
            valor: item.$2,
            icone: item.$3,
            cor: item.$4,
          ),
        );
      }).toList(),
    );
  }

  // ================= PESQUISA =================

  Widget _campoBusca() {
    return TextField(
      controller: _buscaController,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        color: _corTexto,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Pesquisar código ou destinatário...',
        hintStyle: TextStyle(
          color: _corSecundaria,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: DVanilleColors.rose,
        ),
        suffixIcon: _buscaController.text.isNotEmpty
            ? IconButton(
                tooltip: 'Limpar pesquisa',
                onPressed: () {
                  setState(() {
                    _buscaController.clear();
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                ),
              )
            : null,
        filled: true,
        fillColor: _corSuperficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _corBorda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: DVanilleColors.rose,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ================= FILTRO DE STATUS =================

  Widget _campoStatus(
    List<String> statusDisponiveis,
    String statusSelecionado,
  ) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _corSuperficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _corBorda),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_list_rounded,
            color: DVanilleColors.rose,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: statusSelecionado,
                isExpanded: true,
                dropdownColor: _corSuperficie,
                style: TextStyle(
                  color: _corTexto,
                  fontSize: 14,
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'todos',
                    child: Text('Todos os status'),
                  ),
                  ...statusDisponiveis.map(
                    (status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(_nomeStatus(status)),
                    ),
                  ),
                ],
                onChanged: (valor) {
                  if (valor == null) return;

                  setState(() {
                    _filtroStatus = valor;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraFiltros(
    double largura,
    List<String> statusDisponiveis,
    String statusSelecionado,
  ) {
    if (largura < 690) {
      return Column(
        children: [
          _campoBusca(),
          const SizedBox(height: 12),
          _campoStatus(
            statusDisponiveis,
            statusSelecionado,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _campoBusca(),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: _campoStatus(
            statusDisponiveis,
            statusSelecionado,
          ),
        ),
      ],
    );
  }

  void _limparFiltros() {
    setState(() {
      _buscaController.clear();
      _filtroStatus = 'todos';
    });
  }

  // ================= COPIAR CÓDIGO =================

  Future<void> _copiarCodigo(ValePresente vale) async {
    await Clipboard.setData(
      ClipboardData(text: vale.codigo),
    );

    if (!mounted) return;

    showToast(
      'Código copiado!',
      '📋',
    );
  }

  // ================= EXCLUIR VALE =================

  Future<void> _excluirVale(ValePresente vale) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Excluir vale-presente'),
          content: Text(
            'Tem certeza que deseja excluir o vale '
            '"${vale.codigo}"?\n\n'
            'Essa ação não poderá ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB5473F),
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirmar == true) {
      AppState.instance.excluirValePresente(vale.id);

      showToast(
        'Vale-presente excluído!',
        '🗑️',
      );
    }
  }

  // ================= DETALHES =================

  Widget _campoDetalhe(
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            valor.trim().isEmpty ? 'Não informado' : valor,
            style: TextStyle(
              color: _corTexto,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verDetalhes(ValePresente vale) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Vale-presente',
            style: TextStyle(
              fontFamily: 'CreamCake',
              fontSize: 36,
              color: _corTexto,
            ),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiquetaStatus(vale.status),
                  const SizedBox(height: 20),
                  _campoDetalhe(
                    'Código',
                    vale.codigo,
                  ),
                  Divider(color: _corBorda),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _campoDetalhe(
                          'Valor',
                          money(vale.valor),
                        ),
                      ),
                      Expanded(
                        child: _campoDetalhe(
                          'Emitido em',
                          _formatarData(vale.criadoEm),
                        ),
                      ),
                    ],
                  ),
                  _campoDetalhe(
                    'Destinatário',
                    vale.destinatario,
                  ),
                  _campoDetalhe(
                    'Comprador',
                    vale.compradorEmail,
                  ),
                  Divider(color: _corBorda),
                  const SizedBox(height: 15),
                  _campoDetalhe(
                    'Mensagem personalizada',
                    vale.mensagem,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _copiarCodigo(vale),
              icon: const Icon(
                Icons.copy_rounded,
                size: 18,
              ),
              label: const Text('Copiar código'),
              style: TextButton.styleFrom(
                foregroundColor: DVanilleColors.rose,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // ================= MENU DE AÇÕES =================

  Widget _menuAcoes(ValePresente vale) {
    return PopupMenuButton<String>(
      tooltip: 'Ações do vale-presente',
      icon: Icon(
        Icons.more_horiz_rounded,
        color: _corSecundaria,
        size: 25,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (acao) {
        switch (acao) {
          case 'detalhes':
            _verDetalhes(vale);
            break;
          case 'copiar':
            _copiarCodigo(vale);
            break;
          case 'excluir':
            _excluirVale(vale);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'detalhes',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 20),
              SizedBox(width: 12),
              Text('Ver detalhes'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'copiar',
          child: Row(
            children: [
              Icon(Icons.copy_outlined, size: 20),
              SizedBox(width: 12),
              Text('Copiar código'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'excluir',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: Color(0xFFB5473F),
              ),
              SizedBox(width: 12),
              Text(
                'Excluir',
                style: TextStyle(
                  color: Color(0xFFB5473F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= TABELA DESKTOP =================

  Widget _tituloColuna(String titulo) {
    return Text(
      titulo,
      style: TextStyle(
        color: _corSecundaria,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _cabecalhoTabela() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      color: _isDark ? DVanilleColors.darkCream2 : DVanilleColors.cream2,
      child: Row(
        children: [
          SizedBox(
            width: 190,
            child: _tituloColuna('CÓDIGO'),
          ),
          SizedBox(
            width: 120,
            child: _tituloColuna('VALOR'),
          ),
          Expanded(
            child: _tituloColuna('DESTINATÁRIO'),
          ),
          SizedBox(
            width: 135,
            child: _tituloColuna('CRIADO EM'),
          ),
          SizedBox(
            width: 145,
            child: _tituloColuna('STATUS'),
          ),
          SizedBox(
            width: 70,
            child: Center(
              child: _tituloColuna('AÇÕES'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaTabela(ValePresente vale) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _verDetalhes(vale),
            hoverColor:
                _isDark ? const Color(0xFF42362E) : const Color(0xFFFFF3F0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 190,
                    child: Text(
                      vale.codigo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      money(vale.valor),
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      vale.destinatario.isEmpty
                          ? 'Não informado'
                          : vale.destinatario,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 135,
                    child: Text(
                      _formatarData(vale.criadoEm),
                      style: TextStyle(
                        color: _corSecundaria,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 145,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _etiquetaStatus(vale.status),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Center(
                      child: _menuAcoes(vale),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          color: _corBorda,
        ),
      ],
    );
  }

  Widget _tabelaVales(List<ValePresente> vales) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraTabela =
            constraints.maxWidth < 960 ? 960.0 : constraints.maxWidth;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _corSuperficie,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _corBorda),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: larguraTabela,
              child: Column(
                children: [
                  _cabecalhoTabela(),
                  for (final vale in vales) _linhaTabela(vale),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= CARDS MOBILE =================

  Widget _cardValeMobile(ValePresente vale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _corSuperficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _corBorda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vale.codigo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _corTexto,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _menuAcoes(vale),
            ],
          ),
          const SizedBox(height: 8),
          _etiquetaStatus(vale.status),
          const SizedBox(height: 16),
          Divider(color: _corBorda),
          const SizedBox(height: 13),
          Text(
            vale.destinatario.isEmpty
                ? 'Destinatário não informado'
                : vale.destinatario,
            style: TextStyle(
              color: _corTexto,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Emitido em ${_formatarData(vale.criadoEm)}',
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: Text(
                  money(vale.valor),
                  style: TextStyle(
                    color: _corTexto,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _verDetalhes(vale),
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                ),
                label: const Text('Ver detalhes'),
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

  // ================= LISTA VAZIA =================

  Widget _mensagemListaVazia(bool existemVales) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 44,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: _corSuperficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _corBorda),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.card_giftcard_outlined,
            size: 45,
            color: DVanilleColors.rose,
          ),
          const SizedBox(height: 14),
          Text(
            existemVales
                ? 'Nenhum vale-presente encontrado'
                : 'Nenhum vale-presente emitido',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _corTexto,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            existemVales
                ? 'Tente outra pesquisa ou altere o filtro.'
                : 'Os vales-presente aparecerão aqui após a compra.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 13,
            ),
          ),
          if (existemVales) ...[
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _limparFiltros,
              icon: const Icon(
                Icons.filter_alt_off_outlined,
              ),
              label: const Text('Limpar filtros'),
            ),
          ],
        ],
      ),
    );
  }

  // ================= TELA PRINCIPAL =================

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final todosVales = state.valePresentes;

        final statusDisponiveis = todosVales
            .map((vale) => vale.status.trim().toLowerCase())
            .where((status) => status.isNotEmpty && status != 'todos')
            .toSet()
            .toList()
          ..sort();

        final statusAtual = _filtroStatus == 'todos' ||
                statusDisponiveis.contains(_filtroStatus)
            ? _filtroStatus
            : 'todos';

        final busca = _buscaController.text.trim().toLowerCase();

        final valesFiltrados = todosVales.reversed.where((vale) {
          final correspondeBusca = busca.isEmpty ||
              vale.codigo.toLowerCase().contains(busca) ||
              vale.destinatario.toLowerCase().contains(busca);

          final correspondeStatus = statusAtual == 'todos' ||
              vale.status.trim().toLowerCase() == statusAtual;

          return correspondeBusca && correspondeStatus;
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
                    'Acompanhe os vales-presente emitidos pela cafeteria.',
                    style: TextStyle(
                      color: _corSecundaria,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // INDICADORES
                  _resumoVales(
                    largura,
                    todosVales,
                  ),

                  const SizedBox(height: 27),

                  // PESQUISA E FILTROS
                  _barraFiltros(
                    largura,
                    statusDisponiveis,
                    statusAtual,
                  ),

                  const SizedBox(height: 17),

                  // CONTADOR
                  Row(
                    children: [
                      Icon(
                        Icons.card_giftcard_outlined,
                        color: _corSecundaria,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${valesFiltrados.length} de '
                          '${todosVales.length} vales-presente',
                          style: TextStyle(
                            color: _corSecundaria,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // LISTAGEM RESPONSIVA
                  if (valesFiltrados.isEmpty)
                    _mensagemListaVazia(
                      todosVales.isNotEmpty,
                    )
                  else if (largura >= 720)
                    _tabelaVales(valesFiltrados)
                  else
                    Column(
                      children: valesFiltrados.map(_cardValeMobile).toList(),
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
