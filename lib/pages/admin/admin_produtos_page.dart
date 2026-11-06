import 'package:flutter/material.dart';

import 'package:dvanille/app/app.dart';
import 'package:dvanille/data/mock_data.dart';
import 'package:dvanille/models/produto.dart';
import 'package:dvanille/services/app_state.dart';
import 'package:dvanille/services/navigation.dart';
import 'package:dvanille/theme/app_theme.dart';
import 'package:dvanille/widgets/ui_kit.dart';

import 'admin_shell.dart';

class AdminProdutosPage extends StatefulWidget {
  const AdminProdutosPage({super.key});

  @override
  State<AdminProdutosPage> createState() => _AdminProdutosPageState();
}

class _AdminProdutosPageState extends State<AdminProdutosPage> {
  final TextEditingController _buscaController = TextEditingController();

  String _categoriaSelecionada = 'todas';
  bool _ordemCrescente = true;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _corTexto => _isDark
      ? Theme.of(context).colorScheme.onSurface
      : DVanilleColors.darkTaupe;

  Color get _corSecundaria =>
      _isDark ? const Color(0xFFCEBFB1) : DVanilleColors.taupe;

  Color get _corBorda =>
      _isDark ? const Color(0xFF5A4D44) : DVanilleColors.line;

  Color get _corRosaFundo =>
      _isDark ? DVanilleColors.darkCream2 : DVanilleColors.blush2;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // ================= NAVEGAÇÃO =================

  void _novoProduto() {
    Navigator.pushNamed(
      context,
      Routes.adminProdutoForm,
    );
  }

  void _visualizarProduto(Produto produto) {
    Navigator.pushNamed(
      context,
      Routes.produto,
      arguments: produto.id,
    );
  }

  void _editarProduto(Produto produto) {
    Navigator.pushNamed(
      context,
      Routes.adminProdutoForm,
      arguments: produto.id,
    );
  }

  Future<void> _excluirProduto(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir produto'),
          content: Text(
            'Tem certeza que deseja excluir '
            '"${produto.nome}"?',
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
      AppState.instance.excluirProduto(produto.id);
      showToast('Produto excluído!', '🗑️');
    }
  }

  // ================= AÇÕES =================

  Widget _menuAcoes(Produto produto) {
    return PopupMenuButton<String>(
      tooltip: 'Ações de ${produto.nome}',
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
          case 'ver':
            _visualizarProduto(produto);
            break;

          case 'editar':
            _editarProduto(produto);
            break;

          case 'excluir':
            _excluirProduto(produto);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'ver',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 20),
              SizedBox(width: 12),
              Text('Visualizar'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'editar',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 12),
              Text('Editar'),
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

  // ================= FILTROS =================

  void _limparFiltros() {
    setState(() {
      _buscaController.clear();
      _categoriaSelecionada = 'todas';
    });
  }

  Widget _campoBusca() {
    return TextField(
      controller: _buscaController,
      onChanged: (_) {
        setState(() {});
      },
      style: TextStyle(
        color: _corTexto,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Pesquisar produto...',
        hintStyle: TextStyle(
          color: _corSecundaria,
        ),
        prefixIcon: Icon(
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
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _corBorda,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _corBorda,
          ),
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

  Widget _campoCategoria(
    List<String> categorias,
    String categoriaAtual,
  ) {
    return Container(
      height: 53,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _corBorda,
        ),
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
                value: categoriaAtual,
                isExpanded: true,
                dropdownColor: Theme.of(context).cardColor,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _corSecundaria,
                ),
                style: TextStyle(
                  color: _corTexto,
                  fontSize: 14,
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'todas',
                    child: Text('Todas as categorias'),
                  ),
                  ...categorias.map(
                    (categoria) => DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(
                        labelCategoria(categoria),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (valor) {
                  if (valor == null) return;

                  setState(() {
                    _categoriaSelecionada = valor;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ELEMENTOS VISUAIS =================

  Widget _etiquetaCategoria(String categoria) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: _corRosaFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labelCategoria(categoria),
        style: const TextStyle(
          color: DVanilleColors.rose,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _etiquetaOferta() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _corRosaFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Em oferta',
        style: TextStyle(
          color: DVanilleColors.rose,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _precoProduto(Produto produto) {
    final mostrarPrecoAntigo = produto.oferta &&
        produto.precoAntigo != null &&
        produto.precoAntigo! > produto.preco;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          money(produto.preco),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _corTexto,
          ),
        ),
        if (mostrarPrecoAntigo) ...[
          const SizedBox(height: 3),
          Text(
            money(produto.precoAntigo!),
            style: TextStyle(
              fontSize: 11,
              color: _corSecundaria,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusProduto(Produto produto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const StatusPill('ativo'),
        if (produto.oferta) ...[
          const SizedBox(height: 6),
          _etiquetaOferta(),
        ],
      ],
    );
  }

  // ================= CABEÇALHO =================

  Widget _cabecalhoPagina(double largura) {
    final descricao = Text(
      'Gerencie os produtos do cardápio da D’Vanille.',
      style: TextStyle(
        fontSize: 14,
        color: _corSecundaria,
      ),
    );

    final botao = FilledButton.icon(
      onPressed: _novoProduto,
      icon: const Icon(
        Icons.add_rounded,
        size: 20,
      ),
      label: const Text('Novo produto'),
      style: FilledButton.styleFrom(
        backgroundColor: DVanilleColors.taupe,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 17,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );

    if (largura < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          descricao,
          const SizedBox(height: 14),
          botao,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: descricao),
        const SizedBox(width: 16),
        botao,
      ],
    );
  }

  Widget _barraFiltros(
    double largura,
    List<String> categorias,
    String categoriaAtual,
  ) {
    if (largura < 680) {
      return Column(
        children: [
          _campoBusca(),
          const SizedBox(height: 12),
          _campoCategoria(categorias, categoriaAtual),
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
          child: _campoCategoria(
            categorias,
            categoriaAtual,
          ),
        ),
      ],
    );
  }

  // ================= TABELA DESKTOP =================

  Widget _textoCabecalho(String texto) {
    return Text(
      texto,
      style: TextStyle(
        color: _corSecundaria,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _cabecalhoTabela() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      color: _isDark ? DVanilleColors.darkCream2 : DVanilleColors.cream2,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: _textoCabecalho('PRODUTO'),
          ),
          Expanded(
            flex: 3,
            child: _textoCabecalho('CATEGORIA'),
          ),
          Expanded(
            flex: 2,
            child: _textoCabecalho('PREÇO'),
          ),
          Expanded(
            flex: 2,
            child: _textoCabecalho('STATUS'),
          ),
          SizedBox(
            width: 58,
            child: Center(
              child: _textoCabecalho('AÇÕES'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaTabela(Produto produto) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _visualizarProduto(produto),
            hoverColor:
                _isDark ? const Color(0xFF42362E) : const Color(0xFFFFF3F0),
            splashColor: DVanilleColors.blush2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // FOTO + NOME
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 54,
                            height: 54,
                            child: ImagemProduto(
                              url: produto.imagem,
                              icone: produto.icon,
                              altura: 54,
                              radius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            produto.nome,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _corTexto,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),

                  // CATEGORIA
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _etiquetaCategoria(
                        produto.categoria,
                      ),
                    ),
                  ),

                  // PREÇO
                  Expanded(
                    flex: 2,
                    child: _precoProduto(produto),
                  ),

                  // STATUS
                  Expanded(
                    flex: 2,
                    child: _statusProduto(produto),
                  ),

                  // AÇÕES
                  SizedBox(
                    width: 58,
                    child: Center(
                      child: _menuAcoes(produto),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: _corBorda,
        ),
      ],
    );
  }

  Widget _tabelaProdutos(List<Produto> produtos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraTabela =
            constraints.maxWidth < 900 ? 900.0 : constraints.maxWidth;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                  for (final produto in produtos) _linhaTabela(produto),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= CARDS MOBILE =================

  Widget _cardProdutoMobile(Produto produto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 67,
                  height: 67,
                  child: ImagemProduto(
                    url: produto.imagem,
                    icone: produto.icon,
                    altura: 67,
                    radius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _corTexto,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _etiquetaCategoria(
                      produto.categoria,
                    ),
                  ],
                ),
              ),
              _menuAcoes(produto),
            ],
          ),
          const SizedBox(height: 15),
          Divider(
            color: _corBorda,
            height: 1,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _precoProduto(produto),
              ),
              _statusProduto(produto),
            ],
          ),
        ],
      ),
    );
  }

  // ================= LISTA VAZIA =================

  Widget _mensagemListaVazia(bool temProdutos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 46,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _corBorda),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 45,
            color: DVanilleColors.rose,
          ),
          const SizedBox(height: 13),
          Text(
            temProdutos
                ? 'Nenhum produto encontrado'
                : 'Nenhum produto cadastrado',
            style: TextStyle(
              color: _corTexto,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            temProdutos
                ? 'Tente pesquisar outro nome ou categoria.'
                : 'Cadastre um produto para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          if (temProdutos)
            OutlinedButton.icon(
              onPressed: _limparFiltros,
              icon: const Icon(
                Icons.filter_alt_off_outlined,
                size: 18,
              ),
              label: const Text('Limpar filtros'),
            )
          else
            FilledButton.icon(
              onPressed: _novoProduto,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo produto'),
            ),
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
        // Categorias existentes no cadastro.
        final categorias =
            state.produtos.map((produto) => produto.categoria).toSet().toList();

        categorias.sort(
          (a, b) => labelCategoria(a).compareTo(
            labelCategoria(b),
          ),
        );

        // Mantém o filtro válido mesmo após exclusões.
        final categoriaAtual = categorias.contains(_categoriaSelecionada)
            ? _categoriaSelecionada
            : 'todas';

        final busca = _buscaController.text.trim().toLowerCase();

        // Filtragem e ordenação dos produtos.
        final produtosFiltrados = state.produtos.where(
          (produto) {
            final correspondeBusca =
                busca.isEmpty || produto.nome.toLowerCase().contains(busca);

            final correspondeCategoria = categoriaAtual == 'todas' ||
                produto.categoria == categoriaAtual;

            return correspondeBusca && correspondeCategoria;
          },
        ).toList();

        produtosFiltrados.sort((a, b) {
          final comparacao =
              a.nome.toLowerCase().compareTo(b.nome.toLowerCase());

          return _ordemCrescente ? comparacao : -comparacao;
        });

        final total = state.produtos.length;
        final encontrados = produtosFiltrados.length;

        final textoContador = encontrados == total
            ? '$total produtos cadastrados'
            : '$encontrados de $total produtos';

        return AdminShell(
          titulo: 'Produtos',
          rotaAtual: Routes.adminProdutos,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final largura = constraints.maxWidth;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CABEÇALHO
                  _cabecalhoPagina(largura),

                  const SizedBox(height: 26),

                  // PESQUISA E CATEGORIAS
                  _barraFiltros(
                    largura,
                    categorias,
                    categoriaAtual,
                  ),

                  const SizedBox(height: 17),

                  // CONTADOR + ORDENAÇÃO
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: _corSecundaria,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            textoContador,
                            style: TextStyle(
                              color: _corSecundaria,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _ordemCrescente = !_ordemCrescente;
                          });
                        },
                        icon: const Icon(
                          Icons.sort_by_alpha_rounded,
                          size: 19,
                        ),
                        label: Text(
                          _ordemCrescente ? 'Nome: A–Z' : 'Nome: Z–A',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: DVanilleColors.rose,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // LISTAGEM RESPONSIVA
                  if (produtosFiltrados.isEmpty)
                    _mensagemListaVazia(
                      state.produtos.isNotEmpty,
                    )
                  else if (largura >= 700)
                    _tabelaProdutos(
                      produtosFiltrados,
                    )
                  else
                    Column(
                      children:
                          produtosFiltrados.map(_cardProdutoMobile).toList(),
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
