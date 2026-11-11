import 'dart:async';

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
  static const _statusDisponiveis = [
    'solicitada',
    'confirmada',
    'cancelada',
    'finalizada',
  ];

  final _buscaController = TextEditingController();
  String _filtroStatus = 'todos';
  String _filtroData = 'todas';
  bool _mostrarHistorico = false;

  // Calculado sob demanda: nunca depende de uma inicialização tardia.
  // Evita LateInitializationError, inclusive após Hot Reload.
  DateTime get _hoje => DateUtils.dateOnly(DateTime.now());

  Timer? _relogio;
  DateTime? _ultimoDiaExibido;

  @override
  void initState() {
    super.initState();
    _ultimoDiaExibido = _hoje;

    // Confere a virada do dia mesmo com a página aberta.
    // A reserva de ontem passa a aparecer no histórico automaticamente.
    _relogio = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final hoje = _hoje;
      if (_ultimoDiaExibido != hoje) {
        _ultimoDiaExibido = hoje;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _relogio?.cancel();
    _buscaController.dispose();
    super.dispose();
  }

  bool get _escuro => Theme.of(context).brightness == Brightness.dark;
  Color get _texto => _escuro
      ? Theme.of(context).colorScheme.onSurface
      : DVanilleColors.darkTaupe;
  Color get _secundaria =>
      _escuro ? const Color(0xFFCEBFB1) : DVanilleColors.taupe;
  Color get _borda => _escuro ? const Color(0xFF5A4D44) : DVanilleColors.line;
  Color get _superficie => Theme.of(context).cardColor;
  Color get _fundoSuave =>
      _escuro ? DVanilleColors.darkCream2 : DVanilleColors.cream2;

  // O modelo apresenta a data para o usuário por meio de dataBr.
  // Aceita tanto dd/MM/yyyy quanto yyyy-MM-dd.
  DateTime? _dataReserva(Reserva reserva) {
    final texto = reserva.dataBr.trim();
    final iso = DateTime.tryParse(texto);
    if (iso != null) return DateUtils.dateOnly(iso);

    final partes = texto.split(RegExp(r'[/\-.]'));
    if (partes.length != 3) return null;

    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);
    if (dia == null || mes == null || ano == null) return null;

    final data = DateTime(ano, mes, dia);
    if (data.year != ano || data.month != mes || data.day != dia) {
      return null;
    }
    return data;
  }

  bool _passou(Reserva reserva) {
    final data = _dataReserva(reserva);
    return data != null && data.isBefore(_hoje);
  }

  String _nomeStatus(String status) {
    switch (status.toLowerCase()) {
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

  Color _corStatus(String status) {
    switch (status.toLowerCase()) {
      case 'solicitada':
        return const Color(0xFFB08035);
      case 'confirmada':
        return const Color(0xFF4A8A65);
      case 'cancelada':
        return const Color(0xFFB65755);
      case 'finalizada':
        return DVanilleColors.taupe;
      default:
        return DVanilleColors.rose;
    }
  }

  Widget _etiquetaStatus(String status) {
    final cor = _corStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _escuro ? _fundoSuave : cor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _nomeStatus(status),
        style: TextStyle(
          color: _escuro ? Colors.white : cor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _atualizarStatus(Reserva reserva, String novoStatus) {
    if (reserva.status == novoStatus) return;
    AppState.instance.atualizarStatusReserva(reserva.id, novoStatus);
    showToast('Status da reserva atualizado!', 'agenda.svg');
  }

  Widget _menuStatus(Reserva reserva) {
    return PopupMenuButton<String>(
      tooltip: 'Alterar status da reserva',
      onSelected: (novoStatus) => _atualizarStatus(reserva, novoStatus),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      itemBuilder: (_) => _statusDisponiveis.map((status) {
        return PopupMenuItem<String>(
          value: status,
          child: Row(
            children: [
              Icon(
                reserva.status == status
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 18,
                color: _corStatus(status),
              ),
              const SizedBox(width: 10),
              Text(_nomeStatus(status)),
            ],
          ),
        );
      }).toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _etiquetaStatus(reserva.status),
          const SizedBox(width: 3),
          Icon(Icons.keyboard_arrow_down_rounded, color: _secundaria, size: 20),
        ],
      ),
    );
  }

  Widget _cardResumo(String titulo, int numero, IconData icone, Color cor) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borda),
        boxShadow: const [
          BoxShadow(
              color: Color(0x10000000), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: cor),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('$numero',
                          style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: _texto)),
                    ),
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: _fundoSuave,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icone, color: cor, size: 23),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(titulo,
                    style: TextStyle(
                        color: _texto,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumo(double largura, List<Reserva> lista) {
    final dados = [
      ('Total', lista.length, Icons.event_note_outlined, DVanilleColors.rose),
      (
        'Solicitadas',
        lista.where((r) => r.status == 'solicitada').length,
        Icons.pending_actions_outlined,
        const Color(0xFFC69A56)
      ),
      (
        'Confirmadas',
        lista.where((r) => r.status == 'confirmada').length,
        Icons.event_available_outlined,
        const Color(0xFF65A07B)
      ),
      (
        'Canceladas',
        lista.where((r) => r.status == 'cancelada').length,
        Icons.event_busy_outlined,
        const Color(0xFFC47777)
      ),
    ];
    final colunas = largura >= 960 ? 4 : (largura >= 500 ? 2 : 1);
    const espaco = 14.0;
    final larguraCard = (largura - espaco * (colunas - 1)) / colunas;
    return Wrap(
      spacing: espaco,
      runSpacing: espaco,
      children: dados
          .map((item) => SizedBox(
                width: larguraCard,
                child: _cardResumo(item.$1, item.$2, item.$3, item.$4),
              ))
          .toList(),
    );
  }

  Widget _abas(int atuais, int historico) {
    Widget aba(
        String texto, IconData icone, bool selecionada, VoidCallback aoClicar) {
      return OutlinedButton.icon(
        onPressed: aoClicar,
        icon: Icon(icone, size: 19),
        label: Text(texto),
        style: OutlinedButton.styleFrom(
          foregroundColor: selecionada
              ? (_escuro ? Colors.white : DVanilleColors.darkTaupe)
              : _secundaria,
          backgroundColor: selecionada ? _fundoSuave : _superficie,
          side: BorderSide(color: selecionada ? DVanilleColors.rose : _borda),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        aba('Reservas atuais ($atuais)', Icons.event_available_outlined,
            !_mostrarHistorico, () {
          setState(() {
            _mostrarHistorico = false;
            _filtroData = 'todas';
          });
        }),
        aba('Histórico de reservas ($historico)', Icons.history_rounded,
            _mostrarHistorico, () {
          setState(() {
            _mostrarHistorico = true;
            _filtroData = 'todas';
          });
        }),
      ],
    );
  }

  Widget _busca() {
    return TextField(
      controller: _buscaController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Pesquisar nome, e-mail ou telefone...',
        prefixIcon:
            const Icon(Icons.search_rounded, color: DVanilleColors.rose),
        suffixIcon: _buscaController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Limpar pesquisa',
                onPressed: () => setState(_buscaController.clear),
              ),
        filled: true,
        fillColor: _superficie,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: _borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: DVanilleColors.rose),
        ),
      ),
    );
  }

  Widget _seletor(String valor, List<(String, String)> opcoes,
      ValueChanged<String> aoMudar) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: _superficie,
        border: Border.all(color: _borda),
        borderRadius: BorderRadius.circular(13),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valor,
          isExpanded: true,
          dropdownColor: _superficie,
          items: opcoes
              .map((item) => DropdownMenuItem<String>(
                    value: item.$1,
                    child: Text(item.$2, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (novo) {
            if (novo != null) aoMudar(novo);
          },
        ),
      ),
    );
  }

  Widget _filtros(double largura) {
    final status = <(String, String)>[
      ('todos', 'Todos os status'),
      for (final s in _statusDisponiveis) (s, _nomeStatus(s)),
    ];
    final datas = _mostrarHistorico
        ? <(String, String)>[
            ('todas', 'Todas as datas'),
            ('30dias', 'Últimos 30 dias'),
            ('90dias', 'Últimos 90 dias'),
          ]
        : <(String, String)>[
            ('todas', 'Todas as datas'),
            ('hoje', 'Hoje'),
            ('7dias', 'Próximos 7 dias'),
            ('mes', 'Este mês'),
          ];
    final campos = [
      _busca(),
      _seletor(_filtroStatus, status,
          (novo) => setState(() => _filtroStatus = novo)),
      _seletor(
          _filtroData, datas, (novo) => setState(() => _filtroData = novo)),
    ];

    if (largura < 780) {
      return Column(children: [
        campos[0],
        const SizedBox(height: 12),
        campos[1],
        const SizedBox(height: 12),
        campos[2],
      ]);
    }
    return Row(children: [
      Expanded(flex: 3, child: campos[0]),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: campos[1]),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: campos[2]),
    ]);
  }

  bool _passaFiltroData(Reserva reserva) {
    if (_filtroData == 'todas') return true;
    final dia = _dataReserva(reserva);
    if (dia == null) return false;

    if (_mostrarHistorico) {
      final dias = _filtroData == '30dias' ? 30 : 90;
      return !dia.isBefore(_hoje.subtract(Duration(days: dias)));
    }
    switch (_filtroData) {
      case 'hoje':
        return dia == _hoje;
      case '7dias':
        return !dia.isBefore(_hoje) &&
            dia.isBefore(_hoje.add(const Duration(days: 7)));
      case 'mes':
        return dia.year == _hoje.year && dia.month == _hoje.month;
      default:
        return true;
    }
  }

  void _limparFiltros() {
    setState(() {
      _buscaController.clear();
      _filtroStatus = 'todos';
      _filtroData = 'todas';
    });
  }

  List<Reserva> _filtrar(List<Reserva> origem) {
    final pesquisa = _buscaController.text.trim().toLowerCase();
    final resultado = origem.where((reserva) {
      final correspondePesquisa = pesquisa.isEmpty ||
          reserva.nome.toLowerCase().contains(pesquisa) ||
          reserva.email.toLowerCase().contains(pesquisa) ||
          reserva.telefone.toLowerCase().contains(pesquisa);
      final correspondeStatus =
          _filtroStatus == 'todos' || reserva.status == _filtroStatus;
      return correspondePesquisa &&
          correspondeStatus &&
          _passaFiltroData(reserva);
    }).toList();

    resultado.sort((a, b) {
      final diaA = _dataReserva(a);
      final diaB = _dataReserva(b);
      if (diaA == null && diaB == null) return a.id.compareTo(b.id);
      if (diaA == null) return 1;
      if (diaB == null) return -1;
      final ordem = diaA.compareTo(diaB);
      if (ordem != 0) return _mostrarHistorico ? -ordem : ordem;
      return a.horario.compareTo(b.horario);
    });
    return resultado;
  }

  Widget _linhaDetalhe(String titulo, String conteudo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(titulo,
                style: TextStyle(color: _secundaria, fontSize: 13)),
          ),
          Expanded(
            child: SelectableText(
              conteudo.trim().isEmpty ? 'Não informado' : conteudo,
              style: TextStyle(
                  color: _texto, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verDetalhes(Reserva reserva) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Detalhes da reserva',
            style: TextStyle(
              fontFamily: 'CreamCake',
              fontSize: 34,
              color: _texto,
            )),
        content: SizedBox(
          width: 510,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _linhaDetalhe('Reserva', reserva.id),
                _linhaDetalhe('Nome', reserva.nome),
                _linhaDetalhe('E-mail', reserva.email),
                _linhaDetalhe('Telefone', reserva.telefone),
                _linhaDetalhe('Data', reserva.dataBr),
                _linhaDetalhe('Horário', reserva.horario),
                _linhaDetalhe('Pessoas', '${reserva.pessoas}'),
                Divider(color: _borda),
                const SizedBox(height: 10),
                _linhaDetalhe('Preferências', reserva.preferencias),
                _linhaDetalhe('Observações', reserva.observacoes),
                const SizedBox(height: 8),
                _etiquetaStatus(reserva.status),
                if (_passou(reserva)) ...[
                  const SizedBox(height: 12),
                  Text(
                      'Esta reserva está no histórico porque a data já passou.',
                      style: TextStyle(color: _secundaria, fontSize: 12)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho(String texto) => Text(texto,
      style: TextStyle(
        color: _secundaria,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ));

  Widget _linhaTabela(Reserva reserva) {
    return Column(children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor:
              _escuro ? const Color(0xFF42362E) : const Color(0xFFFFF3F0),
          onTap: () => _verDetalhes(reserva),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(children: [
              Expanded(
                  flex: 3,
                  child: Text(reserva.nome,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _texto,
                      ))),
              Expanded(
                  flex: 3,
                  child: Text(reserva.email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _texto, fontSize: 13))),
              Expanded(
                  flex: 2,
                  child: Text(reserva.dataBr,
                      style: TextStyle(color: _texto, fontSize: 13))),
              Expanded(
                  flex: 1,
                  child: Text(reserva.horario,
                      style: TextStyle(color: _texto, fontSize: 13))),
              Expanded(
                  flex: 1,
                  child: Text('${reserva.pessoas}',
                      style: TextStyle(color: _texto, fontSize: 13))),
              SizedBox(width: 192, child: _menuStatus(reserva)),
              SizedBox(
                  width: 55,
                  child: IconButton(
                    tooltip: 'Ver detalhes',
                    icon: const Icon(Icons.visibility_outlined,
                        color: DVanilleColors.rose),
                    onPressed: () => _verDetalhes(reserva),
                  )),
            ]),
          ),
        ),
      ),
      Divider(height: 1, color: _borda),
    ]);
  }

  Widget _tabela(List<Reserva> reservas) {
    return LayoutBuilder(builder: (context, constraints) {
      final largura =
          constraints.maxWidth < 1050 ? 1050.0 : constraints.maxWidth;
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _superficie,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borda),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: largura,
            child: Column(children: [
              Container(
                color: _fundoSuave,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
                child: Row(children: [
                  Expanded(flex: 3, child: _cabecalho('NOME')),
                  Expanded(flex: 3, child: _cabecalho('E-MAIL')),
                  Expanded(flex: 2, child: _cabecalho('DATA')),
                  Expanded(flex: 1, child: _cabecalho('HORA')),
                  Expanded(flex: 1, child: _cabecalho('PESSOAS')),
                  SizedBox(width: 192, child: _cabecalho('STATUS')),
                  SizedBox(width: 55, child: _cabecalho('VER')),
                ]),
              ),
              for (final reserva in reservas) _linhaTabela(reserva),
            ]),
          ),
        ),
      );
    });
  }

  Widget _cardMobile(Reserva reserva) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borda),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(reserva.nome,
                  style: TextStyle(
                    color: _texto,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ))),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Ver detalhes',
            icon: const Icon(Icons.visibility_outlined,
                color: DVanilleColors.rose),
            onPressed: () => _verDetalhes(reserva),
          ),
        ]),
        const SizedBox(height: 5),
        Text(reserva.email, style: TextStyle(color: _secundaria, fontSize: 13)),
        const SizedBox(height: 14),
        Divider(color: _borda),
        const SizedBox(height: 11),
        Wrap(spacing: 18, runSpacing: 10, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.event_outlined,
                color: DVanilleColors.rose, size: 18),
            const SizedBox(width: 7),
            Text('${reserva.dataBr} · ${reserva.horario}',
                style: TextStyle(color: _texto)),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.people_outline,
                color: DVanilleColors.rose, size: 18),
            const SizedBox(width: 7),
            Text('${reserva.pessoas} pessoas', style: TextStyle(color: _texto)),
          ]),
        ]),
        const SizedBox(height: 15),
        _menuStatus(reserva),
        const SizedBox(height: 7),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.visibility_outlined, size: 19),
              label: const Text('Ver detalhes'),
              onPressed: () => _verDetalhes(reserva),
              style: TextButton.styleFrom(foregroundColor: DVanilleColors.rose),
            )),
      ]),
    );
  }

  Widget _vazio(bool existemReservas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borda),
      ),
      child: Column(children: [
        const Icon(Icons.event_busy_outlined,
            color: DVanilleColors.rose, size: 45),
        const SizedBox(height: 13),
        Text(
          existemReservas
              ? 'Nenhuma reserva corresponde aos filtros'
              : (_mostrarHistorico
                  ? 'O histórico de reservas está vazio'
                  : 'Nenhuma reserva atual'),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _texto, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 9),
        Text(
          existemReservas
              ? 'Experimente alterar a pesquisa ou os filtros.'
              : (_mostrarHistorico
                  ? 'As reservas aparecem aqui a partir do dia seguinte à data marcada.'
                  : 'As reservas de hoje e as futuras aparecerão aqui.'),
          textAlign: TextAlign.center,
          style: TextStyle(color: _secundaria, fontSize: 13),
        ),
        if (existemReservas) ...[
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: _limparFiltros,
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: const Text('Limpar filtros'),
          ),
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final atuais = state.reservas.where((r) => !_passou(r)).toList();
        final historico = state.reservas.where(_passou).toList();
        final todasDaAba = _mostrarHistorico ? historico : atuais;
        final filtradas = _filtrar(todasDaAba);

        return AdminShell(
          titulo: 'Reservas',
          rotaAtual: Routes.adminReservas,
          child: LayoutBuilder(builder: (context, constraints) {
            final largura = constraints.maxWidth;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Acompanhe as reservas da cafeteria e consulte as anteriores.',
                    style: TextStyle(color: _secundaria, fontSize: 14)),
                const SizedBox(height: 23),
                _resumo(largura, atuais),
                const SizedBox(height: 25),
                _abas(atuais.length, historico.length),
                const SizedBox(height: 23),
                Text(
                  _mostrarHistorico
                      ? 'Reservas de datas anteriores a hoje'
                      : 'Reservas de hoje e dos próximos dias',
                  style: AppTheme.display(size: 23, color: _texto),
                ),
                const SizedBox(height: 16),
                _filtros(largura),
                const SizedBox(height: 15),
                Row(children: [
                  Icon(
                      _mostrarHistorico
                          ? Icons.history_rounded
                          : Icons.event_note_outlined,
                      size: 19,
                      color: _secundaria),
                  const SizedBox(width: 8),
                  Text('${filtradas.length} de ${todasDaAba.length} reservas',
                      style: TextStyle(
                          color: _secundaria,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 15),
                if (filtradas.isEmpty)
                  _vazio(todasDaAba.isNotEmpty)
                else if (largura >= 760)
                  _tabela(filtradas)
                else
                  for (final reserva in filtradas) _cardMobile(reserva),
              ],
            );
          }),
        );
      },
    );
  }
}
