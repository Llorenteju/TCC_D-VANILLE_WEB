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

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _corTexto => _isDark
      ? Theme.of(context).colorScheme.onSurface
      : DVanilleColors.darkTaupe;
  Color get _corSecundaria =>
      _isDark ? const Color(0xFFCEBFB1) : DVanilleColors.taupe;
  Color get _corBorda =>
      _isDark ? const Color(0xFF5A4D44) : DVanilleColors.line;

  void _verProduto(Produto produto) => Navigator.of(context).pushNamed(
        Routes.adminProdutoDetalhes,
        arguments: produto.id,
      );

  void _editarProduto(Produto produto) => Navigator.of(context).pushNamed(
        Routes.adminProdutoForm,
        arguments: produto.id,
      );

  Future<void> _excluirProduto(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Tem certeza que deseja excluir "${produto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmar == true) {
      AppState.instance.excluirProduto(produto.id);
      showToast('Produto excluído!', '🗑️');
    }
  }

  Widget _menuAcoes(Produto produto) {
    return PopupMenuButton<String>(
      tooltip: 'Ações de ${produto.nome}',
      icon: Icon(Icons.more_horiz_rounded, color: _corSecundaria),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (acao) {
        switch (acao) {
          case 'ver':
            _verProduto(produto);
            break;
          case 'editar':
            _editarProduto(produto);
            break;
          case 'excluir':
            _excluirProduto(produto);
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'ver',
          child: Row(children: [
            Icon(Icons.visibility_outlined),
            SizedBox(width: 12),
            Text('Visualizar'),
          ]),
        ),
        PopupMenuItem<String>(
          value: 'editar',
          child: Row(children: [
            Icon(Icons.edit_outlined),
            SizedBox(width: 12),
            Text('Editar'),
          ]),
        ),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'excluir',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFB5473F)),
            SizedBox(width: 12),
            Text('Excluir', style: TextStyle(color: Color(0xFFB5473F))),
          ]),
        ),
      ],
    );
  }

  Widget _etiquetaCategoria(String categoria) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: _isDark ? DVanilleColors.darkCream2 : DVanilleColors.blush2,
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

  Widget _preco(Produto produto) {
    final promocao = produto.oferta &&
        produto.precoAntigo != null &&
        produto.precoAntigo! > produto.preco;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          money(produto.preco),
          style: TextStyle(fontWeight: FontWeight.w700, color: _corTexto),
        ),
        if (promocao)
          Text(
            money(produto.precoAntigo!),
            style: TextStyle(
              fontSize: 11,
              color: _corSecundaria,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }

  Widget _status(Produto produto) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const StatusPill('ativo'),
          if (produto.oferta) ...[
            const SizedBox(height: 6),
            const Text(
              'Em oferta',
              style: TextStyle(color: DVanilleColors.rose, fontSize: 11),
            ),
          ],
        ],
      );

  Widget _foto(Produto produto, double tamanho) => SizedBox(
        width: tamanho,
        height: tamanho,
        child: ImagemProduto(
          url: produto.imagem,
          icone: produto.icon,
          altura: tamanho,
          radius: BorderRadius.circular(10),
        ),
      );

  Widget _campoBusca() => TextField(
        controller: _buscaController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Pesquisar produto...',
          prefixIcon:
              const Icon(Icons.search_rounded, color: DVanilleColors.rose),
          suffixIcon: _buscaController.text.isNotEmpty
              ? IconButton(
                  onPressed: () => setState(() {
                    _buscaController.clear();
                  }),
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _corBorda),
          ),
        ),
      );

  Widget _campoCategoria(List<String> categorias, String selecionada) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _corBorda),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selecionada,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          items: [
            const DropdownMenuItem(
              value: 'todas',
              child: Text('Todas as categorias'),
            ),
            ...categorias.map(
              (categoria) => DropdownMenuItem(
                value: categoria,
                child: Text(labelCategoria(categoria)),
              ),
            ),
          ],
          onChanged: (valor) {
            if (valor != null) setState(() => _categoriaSelecionada = valor);
          },
        ),
      ),
    );
  }

  Widget _tabela(List<Produto> produtos) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _corBorda),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < 900 ? 900 : constraints.maxWidth,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
                  color: _isDark
                      ? DVanilleColors.darkCream2
                      : DVanilleColors.cream2,
                  child: Row(
                    children: const [
                      Expanded(flex: 4, child: Text('PRODUTO')),
                      Expanded(flex: 3, child: Text('CATEGORIA')),
                      Expanded(flex: 2, child: Text('PREÇO')),
                      Expanded(flex: 2, child: Text('STATUS')),
                      SizedBox(width: 66, child: Text('AÇÕES')),
                    ],
                  ),
                ),
                for (final produto in produtos) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _verProduto(produto),
                      hoverColor: _isDark
                          ? const Color(0xFF42362E)
                          : const Color(0xFFFFF3F0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  _foto(produto, 54),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Text(
                                      produto.nome,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _corTexto,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _etiquetaCategoria(produto.categoria),
                              ),
                            ),
                            Expanded(flex: 2, child: _preco(produto)),
                            Expanded(flex: 2, child: _status(produto)),
                            SizedBox(width: 66, child: _menuAcoes(produto)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: _corBorda),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardMobile(Produto produto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _corBorda),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                  onTap: () => _verProduto(produto), child: _foto(produto, 68)),
              const SizedBox(width: 13),
              Expanded(
                child: InkWell(
                  onTap: () => _verProduto(produto),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto.nome,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _corTexto,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _etiquetaCategoria(produto.categoria),
                    ],
                  ),
                ),
              ),
              _menuAcoes(produto),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: _corBorda),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _preco(produto)),
              _status(produto),
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
        final categorias = state.produtos
            .map((produto) => produto.categoria)
            .toSet()
            .toList()
          ..sort((a, b) => labelCategoria(a).compareTo(labelCategoria(b)));
        final categoria = categorias.contains(_categoriaSelecionada)
            ? _categoriaSelecionada
            : 'todas';
        final termo = _buscaController.text.trim().toLowerCase();
        final produtos = state.produtos.where((produto) {
          return (termo.isEmpty ||
                  produto.nome.toLowerCase().contains(termo)) &&
              (categoria == 'todas' || produto.categoria == categoria);
        }).toList()
          ..sort((a, b) {
            final comparar =
                a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
            return _ordemCrescente ? comparar : -comparar;
          });

        return AdminShell(
          titulo: 'Produtos',
          rotaAtual: Routes.adminProdutos,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final largura = constraints.maxWidth;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Gerencie os produtos do cardápio da D’Vanille.',
                        style: TextStyle(color: _corSecundaria),
                      ),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(
                          Routes.adminProdutoForm,
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Novo produto'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (largura >= 680)
                    Row(
                      children: [
                        Expanded(flex: 3, child: _campoBusca()),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: _campoCategoria(categorias, categoria),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _campoBusca(),
                        const SizedBox(height: 12),
                        _campoCategoria(categorias, categoria),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${produtos.length} de ${state.produtos.length} produtos',
                          style: TextStyle(color: _corSecundaria),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => setState(
                          () => _ordemCrescente = !_ordemCrescente,
                        ),
                        icon: const Icon(Icons.sort_by_alpha_rounded),
                        label:
                            Text(_ordemCrescente ? 'Nome: A–Z' : 'Nome: Z–A'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (produtos.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                          child: Text('Nenhum produto encontrado.')),
                    )
                  else if (largura >= 700)
                    _tabela(produtos)
                  else
                    Column(children: produtos.map(_cardMobile).toList()),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
