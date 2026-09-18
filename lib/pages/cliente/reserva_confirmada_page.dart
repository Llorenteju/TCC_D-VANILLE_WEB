import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';
import '../auth/recuperar_senha_page.dart' show IconeSucesso;

class ReservaConfirmadaPage extends StatelessWidget {
  const ReservaConfirmadaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments;
    final state = AppState.instance;
    final reserva = state.reservaPorId(id is String ? id : null) ??
        (state.reservas.isEmpty ? null : state.reservas.last);

    if (reserva == null) {
      return const PageShell(
        child: EstadoVazio(emoji: '📅', titulo: 'Reserva não encontrada.'),
      );
    }

    return PageShell(
      child: Column(
        children: [
          const SizedBox(height: 48),
          ContentWidth(
            maxWidth: 520,
            child: Column(
              children: [
                const IconeSucesso(),
                const SizedBox(height: 18),
                Text('Reserva solicitada com sucesso!',
                    textAlign: TextAlign.center,
                    style: AppTheme.display(
                        size: 30, color: DVanilleColors.darkTaupe)),
                const SizedBox(height: 22),
                InfoBox(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _linha('Número', reserva.id, negrito: true),
                      _linha('Nome', reserva.nome),
                      _linha('Data', reserva.dataBr),
                      _linha('Horário', reserva.horario),
                      _linha('Pessoas', '${reserva.pessoas}', ultima: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StatusPill(reserva.status),
                const SizedBox(height: 26),
                FilledButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.home, (r) => false),
                  child: const Text('Voltar para Home'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linha(String titulo, String valor,
      {bool negrito = false, bool ultima = false}) {
    final estilo = TextStyle(
        fontSize: 14,
        fontWeight: negrito ? FontWeight.w800 : FontWeight.w500);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: ultima
          ? null
          : const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: DVanilleColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(titulo, style: estilo), Text(valor, style: estilo)],
      ),
    );
  }
}
