import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../models/reserva.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import 'admin_shell.dart';

class AdminReservasPage extends StatefulWidget {
  const AdminReservasPage({super.key});

  @override
  State<AdminReservasPage> createState() => _AdminReservasPageState();
}

class _AdminReservasPageState extends State<AdminReservasPage> {
  static const List<String> _opcoes = [
    'solicitada',
    'confirmada',
    'cancelada',
    'finalizada',
  ];

  final TextEditingController _buscaController = TextEditingController();

  String _filtroStatus = 'todos';
  DateTime? _dataSelecionada;

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
    switch (status) {
      case 'solicitada':
        return const Color(0xFFAD762D);
      case 'confirmada':
        return const Color(0xFF43815A);
      case 'cancelada':
        return const Color(0xFFB5473F);
      case 'finalizada':
        return DVanilleColors.taupe;
      default:
        return DVanilleColors.rose;
    }
  }

  Color _fundoStatus(String status) {
    if (_isDark) {
      switch (status) {
        case 'solicitada':
          return const Color(0xFF4E3925);
        case 'confirmada':
          return const Color(0xFF294735);
        case 'cancelada':
          return const Color(0xFF502E2C);
        case 'finalizada':
          return const Color(0xFF494036);
        default:
          return DVanilleColors.darkCream2;
      }
    }

    switch (status) {
      case 'solicitada':
        return const Color(0xFFFFF1DA);
      case 'confirmada':
        return const Color(0xFFE4F2E7);
      case 'cancelada':
        return const Color(0xFFFBE7E5);
      case 'finalizada':
        return const Color(0xFFF0EBE5);
      default:
        return DVanilleColors.blush2;
    }
  }

  String _nomeStatus(String status) {
    switch (status) {
      case 'solicitada':
        return 'Solicitada';
      case 'confirmada':
        return 'Confirmada';
      case 'cancelada':
        return 'Cancelada';
      case 'finalizada':
        return 'Finalizada';
      default:
        return status;
    }
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  // ================= STATUS =================

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

  void _atualizarStatus(
    Reserva reserva,
    String novoStatus,
  ) {
    if (reserva.status == novoStatus) return;

    AppState.instance.atualizarStatusReserva(
      reserva.id,
      novoStatus,
    );

    showToast(
      'Status da reserva atualizado!',
      '📅',
    );
  }

  Widget _menuStatus(Reserva reserva) {
    return PopupMenuButton<String>(
      tooltip: 'Alterar status da reserva',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (status) {
        _atualizarStatus(reserva, status);
      },
      itemBuilder: (context) {
        return _opcoes.map((status) {
          return PopupMenuItem<String>(
            value: status,
            child: Row(
              children: [
                Icon(
                  reserva.status == status
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 19,
                  color: _corStatus(status),
                ),
                const SizedBox(width: 12),
                Text(_nomeStatus(status)),
              ],
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _etiquetaStatus(reserva.status),
          const SizedBox(width: 5),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _corSecundaria,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ================= ESTATÍSTICAS =================

  Widget _cardEstatistica({
    required String titulo,
    required int quantidade,
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
                        '$quantidade',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: _corTexto,
                        ),
                      ),
                    ),
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

  Widget _resumoReservas(
    double largura,
    List<Reserva> reservas,
  ) {
    final dados = [
      (
        'Total de reservas',
        reservas.length,
        Icons.calendar_month_outlined,
        DVanilleColors.rose,
      ),
      (
        'Solicitadas',
        reservas.where((r) => r.status == 'solicitada').length,
        Icons.schedule_outlined,
        const Color(0xFFC69A56),
      ),
      (
        'Confirmadas',
        reservas.where((r) => r.status == 'confirmada').length,
        Icons.event_available_outlined,
        const Color(0xFF74A381),
      ),
      (
        'Canceladas',
        reservas.where((r) => r.status == 'cancelada').length,
        Icons.event_busy_outlined,
        const Color(0xFFC9827B),
      ),
    ];

    final int colunas;

    if (largura >= 980) {
      colunas = 4;
    } else if (largura >= 480) {
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
            quantidade: item.$2,
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
        hintText: 'Pesquisar cliente, e-mail ou telefone...',
        hintStyle: TextStyle(color: _corSecundaria),
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

  // ================= FILTRO POR STATUS =================

  Widget _campoStatus() {
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
                value: _filtroStatus,
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
                  ..._opcoes.map(
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

  // ================= FILTRO POR DATA =================

  Future<void> _selecionarData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data da reserva',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (!mounted || selecionada == null) return;

    setState(() {
      _dataSelecionada = selecionada;
    });
  }

  Widget _campoData() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _corSuperficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _corBorda),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: _selecionarData,
              icon: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: DVanilleColors.rose,
              ),
              label: Text(
                _dataSelecionada == null
                    ? 'Todas as datas'
                    : _formatarData(_dataSelecionada!),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _corTexto,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          if (_dataSelecionada != null)
            IconButton(
              tooltip: 'Remover filtro de data',
              onPressed: () {
                setState(() {
                  _dataSelecionada = null;
                });
              },
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _barraFiltros(double largura) {
    if (largura < 850) {
      return Column(
        children: [
          _campoBusca(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _campoStatus()),
              const SizedBox(width: 10),
              Expanded(child: _campoData()),
            ],
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
          child: _campoStatus(),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: _campoData(),
        ),
      ],
    );
  }

  void _limparFiltros() {
    setState(() {
      _buscaController.clear();
      _filtroStatus = 'todos';
      _dataSelecionada = null;
    });
  }

  // ================= DETALHES DA RESERVA =================

  Widget _linhaInformacao(
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
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
          const SizedBox(height: 4),
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

  Future<void> _verDetalhes(Reserva reserva) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Detalhes da reserva',
            style: TextStyle(
              fontFamily: 'CreamCake',
              fontSize: 32,
              color: DVanilleColors.darkTaupe,
            ),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiquetaStatus(reserva.status),
                  const SizedBox(height: 20),
                  _linhaInformacao(
                    'Cliente',
                    reserva.nome,
                  ),
                  _linhaInformacao(
                    'E-mail',
                    reserva.email,
                  ),
                  _linhaInformacao(
                    'Telefone',
                    reserva.telefone,
                  ),
                  Divider(color: _corBorda),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _linhaInformacao(
                          'Data',
                          reserva.dataBr,
                        ),
                      ),
                      Expanded(
                        child: _linhaInformacao(
                          'Horário',
                          reserva.horario,
                        ),
                      ),
                    ],
                  ),
                  _linhaInformacao(
                    'Número de pessoas',
                    '${reserva.pessoas}',
                  ),
                  Divider(color: _corBorda),
                  const SizedBox(height: 12),
                  _linhaInformacao(
                    'Preferências',
                    reserva.preferencias,
                  ),
                  _linhaInformacao(
                    'Observações',
                    reserva.observacoes,
                  ),
                ],
              ),
            ),
          ),
          actions: [
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
          Expanded(
            flex: 3,
            child: _tituloColuna('CLIENTE'),
          ),
          Expanded(
            flex: 4,
            child: _tituloColuna('E-MAIL'),
          ),
          Expanded(
            flex: 3,
            child: _tituloColuna('TELEFONE'),
          ),
          SizedBox(
            width: 115,
            child: _tituloColuna('DATA'),
          ),
          SizedBox(
            width: 95,
            child: _tituloColuna('HORÁRIO'),
          ),
          SizedBox(
            width: 78,
            child: _tituloColuna('PESSOAS'),
          ),
          SizedBox(
            width: 185,
            child: _tituloColuna('STATUS'),
          ),
          SizedBox(
            width: 65,
            child: Center(
              child: _tituloColuna('VER'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaTabela(Reserva reserva) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _verDetalhes(reserva),
            hoverColor:
                _isDark ? const Color(0xFF42362E) : const Color(0xFFFFF3F0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 17,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        reserva.nome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _corTexto,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        reserva.email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _corTexto,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      reserva.telefone,
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 115,
                    child: Text(
                      reserva.dataBr,
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 95,
                    child: Text(
                      reserva.horario,
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 78,
                    child: Text(
                      '${reserva.pessoas}',
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 185,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _menuStatus(reserva),
                    ),
                  ),
                  SizedBox(
                    width: 65,
                    child: IconButton(
                      tooltip: 'Ver detalhes da reserva',
                      onPressed: () => _verDetalhes(reserva),
                      icon: const Icon(
                        Icons.visibility_outlined,
                        color: DVanilleColors.rose,
                        size: 21,
                      ),
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

  Widget _tabelaReservas(List<Reserva> reservas) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraTabela =
            constraints.maxWidth < 1120 ? 1120.0 : constraints.maxWidth;

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
                  for (final reserva in reservas) _linhaTabela(reserva),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= CARDS MOBILE =================

  Widget _cardReservaMobile(Reserva reserva) {
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
          Text(
            reserva.nome,
            style: TextStyle(
              color: _corTexto,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            reserva.email,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          _menuStatus(reserva),
          const SizedBox(height: 16),
          Divider(color: _corBorda),
          const SizedBox(height: 13),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _informacaoCompacta(
                Icons.calendar_today_outlined,
                reserva.dataBr,
              ),
              _informacaoCompacta(
                Icons.access_time_rounded,
                reserva.horario,
              ),
              _informacaoCompacta(
                Icons.people_outline_rounded,
                '${reserva.pessoas} pessoas',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _verDetalhes(reserva),
              icon: const Icon(
                Icons.visibility_outlined,
                size: 19,
              ),
              label: const Text('Ver detalhes'),
              style: TextButton.styleFrom(
                foregroundColor: DVanilleColors.rose,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _informacaoCompacta(
    IconData icone,
    String texto,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icone,
          size: 17,
          color: DVanilleColors.rose,
        ),
        const SizedBox(width: 7),
        Text(
          texto,
          style: TextStyle(
            color: _corTexto,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ================= LISTA VAZIA =================

  Widget _mensagemListaVazia(bool existemReservas) {
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
            Icons.event_busy_outlined,
            size: 44,
            color: DVanilleColors.rose,
          ),
          const SizedBox(height: 14),
          Text(
            existemReservas
                ? 'Nenhuma reserva encontrada'
                : 'Nenhuma reserva registrada',
            style: TextStyle(
              color: _corTexto,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            existemReservas
                ? 'Tente outra pesquisa ou altere os filtros.'
                : 'As reservas dos clientes aparecerão aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 13,
            ),
          ),
          if (existemReservas) ...[
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
        final todasReservas = state.reservas;

        final busca = _buscaController.text.trim().toLowerCase();

        final reservasFiltradas = todasReservas.reversed.where((reserva) {
          final correspondeBusca = busca.isEmpty ||
              reserva.nome.toLowerCase().contains(busca) ||
              reserva.email.toLowerCase().contains(busca) ||
              reserva.telefone.toLowerCase().contains(busca);

          final correspondeStatus =
              _filtroStatus == 'todos' || reserva.status == _filtroStatus;

          final correspondeData = _dataSelecionada == null ||
              reserva.dataBr == _formatarData(_dataSelecionada!);

          return correspondeBusca && correspondeStatus && correspondeData;
        }).toList();

        return AdminShell(
          titulo: 'Reservas',
          rotaAtual: Routes.adminReservas,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final largura = constraints.maxWidth;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SUBTÍTULO
                  Text(
                    'Acompanhe e organize as reservas da cafeteria.',
                    style: TextStyle(
                      color: _corSecundaria,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CARDS DE RESUMO
                  _resumoReservas(
                    largura,
                    todasReservas,
                  ),

                  const SizedBox(height: 27),

                  // PESQUISA E FILTROS
                  _barraFiltros(largura),

                  const SizedBox(height: 17),

                  // CONTADOR
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: _corSecundaria,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${reservasFiltradas.length} de '
                          '${todasReservas.length} reservas',
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

                  // LISTA RESPONSIVA
                  if (reservasFiltradas.isEmpty)
                    _mensagemListaVazia(
                      todasReservas.isNotEmpty,
                    )
                  else if (largura >= 700)
                    _tabelaReservas(reservasFiltradas)
                  else
                    Column(
                      children:
                          reservasFiltradas.map(_cardReservaMobile).toList(),
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
