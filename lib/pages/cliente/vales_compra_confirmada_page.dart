import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../models/vale_presente.dart';

import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class ValesCompraConfirmadaPage extends StatelessWidget {
  const ValesCompraConfirmadaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Os vales recém-emitidos são enviados pela navegação.
    final argumentos = ModalRoute.of(context)?.settings.arguments;
    final vales =
        argumentos is List<ValePresente> ? argumentos : <ValePresente>[];

    final total = vales.fold<double>(
      0,
      (soma, vale) => soma + vale.valor,
    );

    return PageShell(
      child: ContentWidth(
        maxWidth: 760,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 55,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 76,
                color: DVanilleColors.rose,
              ),
              const SizedBox(height: 18),
              Text(
                'Compra confirmada!',
                textAlign: TextAlign.center,
                style: AppTheme.display(
                  size: 38,
                  weight: FontWeight.w700,
                  color: DVanilleColors.darkTaupe,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Confira os dados dos seus vale-presentes.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (vales.isEmpty)
                const InfoBox(
                  child: Text(
                    'Não encontramos os códigos desta compra. '
                    'Consulte seus vale-presentes na área correspondente.',
                    textAlign: TextAlign.center,
                  ),
                )
              else ...[
                ...vales.map(_cartaoVale),
                const SizedBox(height: 18),
                InfoBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total da compra',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        money(total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: DVanilleColors.darkTaupe,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.shopping,
                      (route) => false,
                    );
                  },
                  child: const Text('Voltar ao Shopping'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.home,
                      (route) => false,
                    );
                  },
                  child: const Text('Voltar ao início'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Guarde os códigos para consultar os vales posteriormente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartaoVale(ValePresente vale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InfoBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.card_giftcard,
                  size: 30,
                  color: DVanilleColors.rose,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Vale-presente D'Vanille",
                    style: AppTheme.display(
                      size: 23,
                      weight: FontWeight.w700,
                      color: DVanilleColors.darkTaupe,
                    ),
                  ),
                ),
                Text(
                  money(vale.valor),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            const Text(
              'Código do vale',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 5),
            SelectableText(
              vale.codigo,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 14),
            Text('Destinatário: ${vale.destinatario}'),
            if (vale.mensagem.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Mensagem: ${vale.mensagem}'),
            ],
            const SizedBox(height: 10),
            Text(
              'Status: ${vale.status}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
