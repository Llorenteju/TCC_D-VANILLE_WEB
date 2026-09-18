import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import 'admin_shell.dart';

class AdminPedidosPage extends StatelessWidget {
  const AdminPedidosPage({super.key});

  static const opcoes = ['recebido', 'em preparação', 'pronto', 'finalizado'];

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return AdminShell(
          titulo: 'Pedidos',
          rotaAtual: Routes.adminPedidos,
          child: TabelaAdmin(
            colunas: const [
              'NÚMERO',
              'CLIENTE',
              'PRODUTOS',
              'TOTAL',
              'HORÁRIO',
              'STATUS'
            ],
            linhas: state.pedidos.reversed
                .map((p) => DataRow(cells: [
                      DataCell(Text(p.id)),
                      DataCell(Text(p.clienteEmail)),
                      DataCell(ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Text(p.resumoItens,
                            overflow: TextOverflow.ellipsis),
                      )),
                      DataCell(Text(money(p.total))),
                      DataCell(Text(p.data)),
                      DataCell(DropdownButton<String>(
                        value: opcoes.contains(p.status)
                            ? p.status
                            : opcoes.first,
                        underline: const SizedBox.shrink(),
                        items: opcoes
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          state.atualizarStatusPedido(p.id, v);
                          showToast('Status do pedido atualizado!', '📦');
                        },
                      )),
                    ]))
                .toList(),
          ),
        );
      },
    );
  }
}
