import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../models/produto.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_kit.dart';
import 'admin_shell.dart';

class AdminProdutoDetalhesPage extends StatelessWidget {
  const AdminProdutoDetalhesPage({super.key});

  void _voltar(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.adminProdutos,
      (route) => false,
    );
  }

  Widget _secao({required String titulo, required Widget conteudo, required Color cor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: AppTheme.display(size: 21, color: cor)),
        const SizedBox(height: 10),
        conteudo,
      ],
    );
  }

  Widget _etiquetas(List<String> valores, {bool restricao = false}) {
    if (valores.isEmpty) {
      return const Text('Nenhuma informação cadastrada.');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: valores.map((valor) {
        return restricao
            ? BadgeRestricao(valor)
            : TagSimples(valor);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final Produto? produto = arg is Produto
        ? AppState.instance.produtoPorId(arg.id)
        : AppState.instance.produtoPorId(arg);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corTexto = isDark
        ? Theme.of(context).colorScheme.onSurface
        : DVanilleColors.darkTaupe;
    final corSecundaria = isDark
        ? const Color(0xFFCEBFB1)
        : DVanilleColors.taupe;
    final corBorda = isDark ? const Color(0xFF5A4D44) : DVanilleColors.line;

    if (produto == null) {
      return AdminShell(
        titulo: 'Detalhes do produto',
        rotaAtual: Routes.adminProdutos,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Produto não encontrado ou removido.'),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => _voltar(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Voltar para Produtos'),
            ),
          ],
        ),
      );
    }

    final antigoValido = produto.oferta &&
        produto.precoAntigo != null &&
        produto.precoAntigo! > produto.preco;

    return AdminShell(
      titulo: 'Detalhes do produto',
      rotaAtual: Routes.adminProdutos,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final estreito = constraints.maxWidth < 850;
          final imagem = ImagemProduto(
            url: produto.imagem,
            icone: produto.icon,
            altura: estreito ? 250 : 390,
            radius: const BorderRadius.all(Radius.circular(18)),
          );

          final detalhes = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                produto.nome,
                style: AppTheme.display(size: 34, color: corTexto),
              ),
              const SizedBox(height: 8),
              Text(
                labelCategoria(produto.categoria),
                style: TextStyle(color: corSecundaria, fontSize: 14),
              ),
              const SizedBox(height: 14),
              _etiquetas(produto.restricoes, restricao: true),
              const SizedBox(height: 18),
              Text(
                produto.descricao.isEmpty
                    ? 'Sem descrição cadastrada.'
                    : produto.descricao,
                style: TextStyle(color: corTexto, fontSize: 15, height: 1.55),
              ),
              const SizedBox(height: 17),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    money(produto.preco),
                    style: AppTheme.display(
                      size: 30,
                      weight: FontWeight.w700,
                      color: DVanilleColors.rose,
                    ),
                  ),
                  if (antigoValido)
                    Text(
                      money(produto.precoAntigo!),
                      style: TextStyle(
                        color: corSecundaria,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (antigoValido)
                    Chip(label: Text('${produto.descontoPercentual}% OFF')),
                ],
              ),
              const SizedBox(height: 22),
              _secao(
                titulo: 'Ingredientes',
                cor: corTexto,
                conteudo: _etiquetas(produto.ingredientes),
              ),
              const SizedBox(height: 24),
              _secao(
                titulo: 'Informações nutricionais (por porção)',
                cor: corTexto,
                conteudo: Column(
                  children: produto.nutricional.linhas.map((linha) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(linha[0], style: TextStyle(color: corTexto))),
                              Text(
                                linha[1],
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: corTexto,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(height: 1, color: corBorda),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              _secao(
                titulo: 'Alergênicos',
                cor: corTexto,
                conteudo: _etiquetas(produto.alergenicos),
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _voltar(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Voltar para Produtos'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      Routes.adminProdutoForm,
                      arguments: produto.id,
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar produto'),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(estreito ? 16 : 25),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: corBorda),
                ),
                child: estreito
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          imagem,
                          const SizedBox(height: 25),
                          detalhes,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: imagem),
                          const SizedBox(width: 34),
                          Expanded(flex: 6, child: detalhes),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
