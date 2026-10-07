import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/app.dart';
import '../../models/reserva.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class MinhasReservasPage extends StatelessWidget {
  const MinhasReservasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return PageShell(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final reservas = state.minhasReservas;

          return Column(
            children: [
              const SizedBox(height: 56),
              const ContentWidth(
                child: Column(
                  children: [
                    Text(
                      'Minhas reservas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Acompanhe suas reservas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: DVanilleColors.darkTaupe,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              ContentWidth(
                maxWidth: 850,
                child: reservas.isEmpty
                    ? _vazio(context)
                    : Column(
                        children: [
                          for (final reserva in reservas)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _cartaoReserva(
                                context,
                                reserva,
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _vazio(BuildContext context) {
    return InfoBox(
      padding: const EdgeInsets.all(35),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/agenda.svg',
            width: 85,
            height: 85,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 22),
          Text(
            'Você ainda não possui reservas.',
            textAlign: TextAlign.center,
            style: AppTheme.display(
              size: 24,
              color: DVanilleColors.darkTaupe,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Faça uma reserva para garantir seu lugar na D’Vanille.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: DVanilleColors.darkTaupe,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.reservas,
              );
            },
            icon: SvgPicture.asset(
              'assets/images/agenda.svg',
              width: 19,
              height: 19,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            label: const Text(
              'Fazer uma reserva',
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoReserva(
    BuildContext context,
    Reserva reserva,
  ) {
    final podeCancelar = reserva.status.toLowerCase() != 'cancelada' &&
        reserva.status.toLowerCase() != 'concluida' &&
        reserva.status.toLowerCase() != 'concluída';

    return InfoBox(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: DVanilleColors.blush2,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SvgPicture.asset(
                  'assets/images/agenda.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reserva ${reserva.id}',
                      style: AppTheme.display(
                        size: 23,
                        color: DVanilleColors.darkTaupe,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _statusTexto(reserva.status),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _statusCor(reserva.status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Divider(
            color: DVanilleColors.line,
          ),
          const SizedBox(height: 16),
          _linha(
            'Data',
            _formatarData(reserva.data),
            Icons.calendar_today_outlined,
          ),
          _linha(
            'Horário',
            reserva.horario,
            Icons.access_time_outlined,
          ),
          _linha(
            'Pessoas',
            '${reserva.pessoas}',
            Icons.people_outline,
          ),
          _linha(
            'Nome',
            reserva.nome,
            Icons.person_outline,
          ),
          _linha(
            'E-mail',
            reserva.email,
            Icons.email_outlined,
          ),
          _linha(
            'Telefone',
            reserva.telefone,
            Icons.phone_outlined,
          ),
          if (reserva.preferencias.trim().isNotEmpty)
            _linha(
              'Preferências',
              reserva.preferencias,
              Icons.restaurant_menu_outlined,
            ),
          if (reserva.observacoes.trim().isNotEmpty)
            _linha(
              'Informações adicionais',
              reserva.observacoes,
              Icons.notes_outlined,
            ),
          if (podeCancelar) ...[
            const SizedBox(height: 10),
            const Divider(
              color: DVanilleColors.line,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _confirmarCancelamento(
                    context,
                    reserva,
                  );
                },
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 19,
                ),
                label: const Text(
                  'Cancelar reserva',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9B5555),
                  side: const BorderSide(
                    color: Color(0xFF9B5555),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmarCancelamento(
    BuildContext context,
    Reserva reserva,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cancelar reserva?',
          ),
          content: Text(
            'Tem certeza que deseja cancelar a reserva ${reserva.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Voltar',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF9B5555),
              ),
              child: const Text(
                'Cancelar reserva',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    AppState.instance.atualizarStatusReserva(
      reserva.id,
      'cancelada',
    );

    showToast(
      'Reserva cancelada com sucesso.',
      'agenda.svg',
    );
  }

  Widget _linha(
    String titulo,
    String valor,
    IconData icone,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 20,
            color: DVanilleColors.taupe,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 145,
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DVanilleColors.darkTaupe,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(String data) {
    final partes = data.split('-');

    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }

    return data;
  }

  String _statusTexto(String status) {
    switch (status.toLowerCase()) {
      case 'solicitada':
        return 'Reserva solicitada';

      case 'confirmada':
        return 'Reserva confirmada';

      case 'cancelada':
        return 'Reserva cancelada';

      case 'concluida':
      case 'concluída':
        return 'Reserva concluída';

      default:
        return status;
    }
  }

  Color _statusCor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada':
        return const Color(0xFF4D7650);

      case 'cancelada':
        return const Color(0xFF9B5555);

      case 'concluida':
      case 'concluída':
        return DVanilleColors.taupe;

      case 'solicitada':
      default:
        return DVanilleColors.rose;
    }
  }
}
