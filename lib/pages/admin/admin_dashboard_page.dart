import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_kit.dart';
import 'admin_shell.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final stats = [
          ['${state.produtos.length}', 'Produtos cadastrados'],
          ['${state.pedidos.length}', 'Pedidos realizados'],
          ['${state.reservas.length}', 'Reservas'],
          [
            '${state.usuarios.where((u) => u.tipo == 'cliente').length}',
            'Usuários'
          ],
        ];

        final recentesPedidos =
            state.pedidos.reversed.take(3).toList();
        final recentesReservas =
            state.reservas.reversed.take(3).toList();

        return AdminShell(
          titulo: 'Dashboard',
          rotaAtual: Routes.admin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: stats
                    .map((s) => SizedBox(
                          width: 210,
                          child: InfoBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s[0],
                                    style: AppTheme.display(
                                        size: 34,
                                        weight: FontWeight.w700,
                                        color: DVanilleColors.darkTaupe)),
                                Text(s[1],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: DVanilleColors.darkTaupe)),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 22,
                runSpacing: 22,
                children: [
                  SizedBox(
                    width: 420,
                    child: InfoBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pedidos recentes',
                              style: AppTheme.display(
                                  size: 22,
                                  color: DVanilleColors.darkTaupe)),
                          const SizedBox(height: 8),
                          if (recentesPedidos.isEmpty)
                            const DicaCampo('Nenhum pedido ainda.'),
                          ...recentesPedidos.map((p) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            '${p.id} — ${p.clienteEmail}',
                                            style: const TextStyle(
                                                fontSize: 13.5))),
                                    Text(money(p.total),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 420,
                    child: InfoBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reservas recentes',
                              style: AppTheme.display(
                                  size: 22,
                                  color: DVanilleColors.darkTaupe)),
                          const SizedBox(height: 8),
                          if (recentesReservas.isEmpty)
                            const DicaCampo('Nenhuma reserva ainda.'),
                          ...recentesReservas.map((r) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            '${r.nome} — ${r.dataBr}',
                                            style: const TextStyle(
                                                fontSize: 13.5))),
                                    StatusPill(r.status),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
