import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import 'admin_shell.dart';

class AdminReservasPage extends StatelessWidget {
  const AdminReservasPage({super.key});

  static const opcoes = [
    'solicitada',
    'confirmada',
    'cancelada',
    'finalizada'
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return AdminShell(
          titulo: 'Reservas',
          rotaAtual: Routes.adminReservas,
          child: TabelaAdmin(
            colunas: const [
              'CLIENTE',
              'EMAIL',
              'TELEFONE',
              'DATA',
              'HORÁRIO',
              'PESSOAS',
              'STATUS'
            ],
            linhas: state.reservas.reversed
                .map((r) => DataRow(cells: [
                      DataCell(Text(r.nome)),
                      DataCell(Text(r.email)),
                      DataCell(Text(r.telefone)),
                      DataCell(Text(r.dataBr)),
                      DataCell(Text(r.horario)),
                      DataCell(Text('${r.pessoas}')),
                      DataCell(DropdownButton<String>(
                        value: opcoes.contains(r.status)
                            ? r.status
                            : opcoes.first,
                        underline: const SizedBox.shrink(),
                        items: opcoes
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          state.atualizarStatusReserva(r.id, v);
                          showToast('Status da reserva atualizado!', '📅');
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
