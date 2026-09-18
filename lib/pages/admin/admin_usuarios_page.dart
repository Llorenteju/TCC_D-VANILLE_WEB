import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import 'admin_shell.dart';

class AdminUsuariosPage extends StatelessWidget {
  const AdminUsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return AdminShell(
          titulo: 'Usuários',
          rotaAtual: Routes.adminUsuarios,
          child: TabelaAdmin(
            colunas: const [
              'NOME',
              'EMAIL',
              'TELEFONE',
              'TIPO',
              'RESTRIÇÕES'
            ],
            linhas: state.usuarios
                .map((u) => DataRow(cells: [
                      DataCell(Text(u.nome)),
                      DataCell(Text(u.email)),
                      DataCell(
                          Text(u.telefone.isEmpty ? '—' : u.telefone)),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: DVanilleColors.blush2,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(u.tipo,
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: DVanilleColors.darkTaupe)),
                      )),
                      DataCell(Text(u.restricoes.isEmpty
                          ? '—'
                          : u.restricoes
                              .map((r) => restricoesLabels[r] ?? r)
                              .join(', '))),
                    ]))
                .toList(),
          ),
        );
      },
    );
  }
}
