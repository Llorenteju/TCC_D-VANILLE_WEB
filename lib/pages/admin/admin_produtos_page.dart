import 'package:flutter/material.dart';

import 'package:dvanille/app/app.dart';
import 'package:dvanille/data/mock_data.dart';
import 'package:dvanille/services/app_state.dart';
import 'package:dvanille/services/navigation.dart';
import 'package:dvanille/widgets/ui_kit.dart';
import 'admin_shell.dart';

class AdminProdutosPage extends StatelessWidget {
  const AdminProdutosPage({super.key});

  Future<void> _excluir(BuildContext context, int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir produto'),
        content: const Text('Tem certeza que deseja excluir este produto?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar == true) {
      AppState.instance.excluirProduto(id);
      showToast('Produto excluído!', '🗑️');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return AdminShell(
          titulo: 'Produtos',
          rotaAtual: Routes.adminProdutos,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DicaCampo('${state.produtos.length} produtos cadastrados'),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.adminProdutoForm),
                    child: const Text('+ Novo produto'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TabelaAdmin(
                colunas: const [
                  '',
                  'NOME',
                  'CATEGORIA',
                  'PREÇO',
                  'STATUS',
                  'AÇÕES'
                ],
                linhas: state.produtos
                    .map((p) => DataRow(cells: [
                          DataCell(SizedBox(
                            width: 44,
                            height: 44,
                            child: ImagemProduto(
                              url: p.imagem,
                              icone: p.icon,
                              altura: 44,
                              radius:
                                  const BorderRadius.all(Radius.circular(8)),
                            ),
                          )),
                          DataCell(Text(p.nome)),
                          DataCell(Text(labelCategoria(p.categoria))),
                          DataCell(Text(money(p.preco))),
                          const DataCell(StatusPill('ativo')),
                          DataCell(Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, Routes.produto,
                                    arguments: p.id),
                                child: const Text('Ver'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, Routes.adminProdutoForm,
                                    arguments: p.id),
                                child: const Text('Editar'),
                              ),
                              TextButton(
                                onPressed: () => _excluir(context, p.id),
                                style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFB5473F)),
                                child: const Text('Excluir'),
                              ),
                            ],
                          )),
                        ]))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
