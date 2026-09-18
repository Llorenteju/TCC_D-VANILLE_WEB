import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../widgets/ui_kit.dart';
import 'admin_shell.dart';

class AdminValePresentesPage extends StatelessWidget {
  const AdminValePresentesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return AdminShell(
          titulo: 'Vale-presentes',
          rotaAtual: Routes.adminValePresentes,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DicaCampo(
                  '${state.valePresentes.length} vale-presentes emitidos'),
              const SizedBox(height: 18),
              TabelaAdmin(
                colunas: const [
                  'CÓDIGO',
                  'VALOR',
                  'DESTINATÁRIO',
                  'CRIADO EM',
                  'STATUS',
                  'AÇÕES'
                ],
                linhas: state.valePresentes.reversed
                    .map((g) => DataRow(cells: [
                          DataCell(Text(g.codigo)),
                          DataCell(Text(money(g.valor))),
                          DataCell(Text(g.destinatario.isEmpty
                              ? '—'
                              : g.destinatario)),
                          DataCell(Text(g.criadoEm)),
                          DataCell(StatusPill(g.status)),
                          DataCell(TextButton(
                            onPressed: () {
                              state.excluirValePresente(g.id);
                              showToast('Vale-presente excluído!', '🗑️');
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFB5473F)),
                            child: const Text('Excluir'),
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
