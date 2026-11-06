import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../models/usuario.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import 'admin_shell.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  final TextEditingController _buscaController = TextEditingController();

  String _filtroTipo = 'todos';

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

  Color get _corFundoRosa =>
      _isDark ? DVanilleColors.darkCream2 : DVanilleColors.blush2;

  // ================= TIPO DE USUÁRIO =================

  String _nomeTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'cliente':
        return 'Cliente';
      case 'admin':
        return 'Administrador';
      default:
        return tipo.isEmpty ? 'Não definido' : tipo;
    }
  }

  Widget _etiquetaTipo(String tipo) {
    final administrador = tipo.toLowerCase() == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: administrador
            ? _corFundoRosa
            : (_isDark ? DVanilleColors.darkCream2 : DVanilleColors.cream2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _nomeTipo(tipo),
        style: TextStyle(
          color: _isDark
              ? Colors.white
              : administrador
                  ? DVanilleColors.rose
                  : DVanilleColors.darkTaupe,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ================= RESTRIÇÕES ALIMENTARES =================

  String _nomeRestricao(String restricao) {
    return restricoesLabels[restricao] ?? restricao;
  }

  Widget _etiquetaRestricao(String restricao) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _corFundoRosa,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _nomeRestricao(restricao),
        style: TextStyle(
          color: _isDark ? Colors.white : DVanilleColors.darkTaupe,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _listaRestricoes(
    Usuario usuario, {
    bool compacta = false,
  }) {
    if (usuario.restricoes.isEmpty) {
      return Text(
        'Nenhuma informada',
        style: TextStyle(
          color: _corSecundaria,
          fontSize: 12,
        ),
      );
    }

    final restricoes =
        compacta ? usuario.restricoes.take(2).toList() : usuario.restricoes;

    final restantes = usuario.restricoes.length - restricoes.length;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final restricao in restricoes) _etiquetaRestricao(restricao),
        if (restantes > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color:
                  _isDark ? DVanilleColors.darkCream2 : DVanilleColors.cream2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+$restantes',
              style: TextStyle(
                color: _corSecundaria,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
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
                        color: _corFundoRosa,
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

  Widget _resumoUsuarios(
    double largura,
    List<Usuario> usuarios,
  ) {
    final clientes =
        usuarios.where((u) => u.tipo.toLowerCase() == 'cliente').length;

    final administradores =
        usuarios.where((u) => u.tipo.toLowerCase() == 'admin').length;

    final estatisticas = [
      (
        'Usuários cadastrados',
        usuarios.length,
        Icons.people_alt_outlined,
        DVanilleColors.rose,
      ),
      (
        'Clientes',
        clientes,
        Icons.person_outline_rounded,
        DVanilleColors.taupe,
      ),
      (
        'Administradores',
        administradores,
        Icons.admin_panel_settings_outlined,
        const Color(0xFFC69A56),
      ),
    ];

    final int colunas;

    if (largura >= 980) {
      colunas = 3;
    } else if (largura >= 560) {
      colunas = 2;
    } else {
      colunas = 1;
    }

    const espacamento = 16.0;

    final larguraCard = (largura - espacamento * (colunas - 1)) / colunas;

    return Wrap(
      spacing: espacamento,
      runSpacing: espacamento,
      children: estatisticas.map((item) {
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
        hintText: 'Pesquisar nome, e-mail ou telefone...',
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

  // ================= FILTRO DE TIPO =================

  Widget _campoTipo() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
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
                value: _filtroTipo,
                isExpanded: true,
                dropdownColor: _corSuperficie,
                style: TextStyle(
                  color: _corTexto,
                  fontSize: 14,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'todos',
                    child: Text('Todos os usuários'),
                  ),
                  DropdownMenuItem(
                    value: 'cliente',
                    child: Text('Clientes'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administradores'),
                  ),
                ],
                onChanged: (valor) {
                  if (valor == null) return;

                  setState(() {
                    _filtroTipo = valor;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraFiltros(double largura) {
    if (largura < 690) {
      return Column(
        children: [
          _campoBusca(),
          const SizedBox(height: 12),
          _campoTipo(),
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
          child: _campoTipo(),
        ),
      ],
    );
  }

  void _limparFiltros() {
    setState(() {
      _buscaController.clear();
      _filtroTipo = 'todos';
    });
  }

  // ================= DETALHES DO USUÁRIO =================

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
          SelectableText(
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

  Future<void> _verDetalhes(Usuario usuario) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Detalhes do usuário',
            style: TextStyle(
              fontFamily: 'CreamCake',
              fontSize: 34,
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
                  // ÍCONE DO PERFIL
                  Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: _corFundoRosa,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: DVanilleColors.rose,
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario.nome,
                              style: TextStyle(
                                color: _corTexto,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 7),
                            _etiquetaTipo(usuario.tipo),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Divider(color: _corBorda),

                  const SizedBox(height: 17),

                  _campoDetalhe(
                    'Nome completo',
                    usuario.nome,
                  ),

                  _campoDetalhe(
                    'E-mail',
                    usuario.email,
                  ),

                  _campoDetalhe(
                    'Telefone',
                    usuario.telefone,
                  ),

                  Divider(color: _corBorda),

                  const SizedBox(height: 17),

                  Text(
                    'Restrições alimentares',
                    style: TextStyle(
                      color: _corTexto,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _listaRestricoes(usuario),
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
            child: _tituloColuna('NOME'),
          ),
          Expanded(
            flex: 3,
            child: _tituloColuna('E-MAIL'),
          ),
          Expanded(
            flex: 2,
            child: _tituloColuna('TELEFONE'),
          ),
          Expanded(
            flex: 2,
            child: _tituloColuna('TIPO'),
          ),
          Expanded(
            flex: 3,
            child: _tituloColuna('RESTRIÇÕES'),
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

  Widget _linhaTabela(Usuario usuario) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _verDetalhes(usuario),
            hoverColor:
                _isDark ? const Color(0xFF42362E) : const Color(0xFFFFF3F0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  // NOME
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Text(
                        usuario.nome,
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

                  // E-MAIL
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Text(
                        usuario.email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _corTexto,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // TELEFONE
                  Expanded(
                    flex: 2,
                    child: Text(
                      usuario.telefone.isEmpty ? '—' : usuario.telefone,
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  // TIPO
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _etiquetaTipo(usuario.tipo),
                    ),
                  ),

                  // RESTRIÇÕES
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _listaRestricoes(
                        usuario,
                        compacta: true,
                      ),
                    ),
                  ),

                  // VISUALIZAR
                  SizedBox(
                    width: 65,
                    child: IconButton(
                      tooltip: 'Ver detalhes do usuário',
                      onPressed: () {
                        _verDetalhes(usuario);
                      },
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

  Widget _tabelaUsuarios(List<Usuario> usuarios) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraTabela =
            constraints.maxWidth < 1080 ? 1080.0 : constraints.maxWidth;

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
                  for (final usuario in usuarios) _linhaTabela(usuario),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= CARDS MOBILE =================

  Widget _cardUsuarioMobile(Usuario usuario) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: _corFundoRosa,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: DVanilleColors.rose,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nome,
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      usuario.email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _corSecundaria,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _etiquetaTipo(usuario.tipo),
          const SizedBox(height: 16),
          Divider(color: _corBorda),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                color: DVanilleColors.rose,
                size: 18,
              ),
              const SizedBox(width: 9),
              Text(
                usuario.telefone.isEmpty
                    ? 'Telefone não informado'
                    : usuario.telefone,
                style: TextStyle(
                  color: _corTexto,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Restrições alimentares',
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          _listaRestricoes(
            usuario,
            compacta: true,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                _verDetalhes(usuario);
              },
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

  // ================= LISTA VAZIA =================

  Widget _mensagemListaVazia(bool existemUsuarios) {
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
            Icons.person_search_outlined,
            size: 45,
            color: DVanilleColors.rose,
          ),
          const SizedBox(height: 14),
          Text(
            existemUsuarios
                ? 'Nenhum usuário encontrado'
                : 'Nenhum usuário cadastrado',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _corTexto,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            existemUsuarios
                ? 'Tente outra pesquisa ou altere o filtro.'
                : 'Os usuários cadastrados aparecerão aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 13,
            ),
          ),
          if (existemUsuarios) ...[
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
        final todosUsuarios = state.usuarios;

        final busca = _buscaController.text.trim().toLowerCase();

        final usuariosFiltrados = todosUsuarios.where((usuario) {
          final correspondeBusca = busca.isEmpty ||
              usuario.nome.toLowerCase().contains(busca) ||
              usuario.email.toLowerCase().contains(busca) ||
              usuario.telefone.toLowerCase().contains(busca);

          final correspondeTipo = _filtroTipo == 'todos' ||
              usuario.tipo.toLowerCase() == _filtroTipo;

          return correspondeBusca && correspondeTipo;
        }).toList();

        usuariosFiltrados.sort(
          (a, b) => a.nome.toLowerCase().compareTo(
                b.nome.toLowerCase(),
              ),
        );

        return AdminShell(
          titulo: 'Usuários',
          rotaAtual: Routes.adminUsuarios,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final largura = constraints.maxWidth;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SUBTÍTULO
                  Text(
                    'Consulte os usuários cadastrados na D’Vanille.',
                    style: TextStyle(
                      color: _corSecundaria,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ESTATÍSTICAS
                  _resumoUsuarios(
                    largura,
                    todosUsuarios,
                  ),

                  const SizedBox(height: 27),

                  // PESQUISA E FILTRO
                  _barraFiltros(largura),

                  const SizedBox(height: 17),

                  // CONTADOR
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        color: _corSecundaria,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${usuariosFiltrados.length} de '
                          '${todosUsuarios.length} usuários',
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
                  if (usuariosFiltrados.isEmpty)
                    _mensagemListaVazia(
                      todosUsuarios.isNotEmpty,
                    )
                  else if (largura >= 760)
                    _tabelaUsuarios(usuariosFiltrados)
                  else
                    Column(
                      children:
                          usuariosFiltrados.map(_cardUsuarioMobile).toList(),
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
