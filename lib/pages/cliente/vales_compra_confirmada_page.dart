import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../models/vale_presente.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class ValesCompraConfirmadaPage extends StatelessWidget {
  const ValesCompraConfirmadaPage({super.key});

  String _formatarDinheiro(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final corDestaque = isDark ? DVanilleColors.darkRose : DVanilleColors.rose;

    final corTexto = isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

    final corTextoSecundario =
        isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

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
              Icon(
                Icons.check_circle_outline,
                size: 76,
                color: corDestaque,
              ),
              const SizedBox(height: 18),
              Text(
                'Compra confirmada!',
                textAlign: TextAlign.center,
                style: AppTheme.display(
                  size: 38,
                  weight: FontWeight.w700,
                  color: corTextoSecundario,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Confira os dados dos seus vale-presentes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: corTexto),
              ),
              const SizedBox(height: 28),
              if (vales.isEmpty)
                InfoBox(
                  child: Text(
                    'Não encontramos os códigos desta compra. '
                    'Consulte seus vale-presentes na área correspondente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: corTexto),
                  ),
                )
              else ...[
                ...vales.map((vale) => _cartaoVale(vale, isDark)),
                const SizedBox(height: 18),
                InfoBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total da compra',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: corTexto,
                        ),
                      ),
                      Text(
                        _formatarDinheiro(total),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: corTextoSecundario,
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
                  style: isDark
                      ? FilledButton.styleFrom(
                          backgroundColor: DVanilleColors.darkRose,
                          foregroundColor: DVanilleColors.darkCream,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
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
                  style: isDark
                      ? OutlinedButton.styleFrom(
                          foregroundColor: DVanilleColors.darkRose,
                          side: BorderSide(
                            color: DVanilleColors.darkRose,
                          ),
                        )
                      : null,
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
              Text(
                'Guarde os códigos para consultar os vales posteriormente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: corTextoSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartaoVale(ValePresente vale, bool isDark) {
    final corDestaque = isDark ? DVanilleColors.darkRose : DVanilleColors.rose;

    final corTexto = isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

    final corTextoSecundario =
        isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InfoBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 30,
                  color: corDestaque,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Vale-presente D'Vanille",
                    style: AppTheme.display(
                      size: 23,
                      weight: FontWeight.w700,
                      color: corTextoSecundario,
                    ),
                  ),
                ),
                Text(
                  _formatarDinheiro(vale.valor),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: corTexto,
                  ),
                ),
              ],
            ),
            Divider(
              height: 28,
              color: isDark ? DVanilleColors.darkBorder : DVanilleColors.line,
            ),
            Text(
              'Código do vale',
              style: TextStyle(
                fontSize: 13,
                color: corTextoSecundario,
              ),
            ),
            const SizedBox(height: 5),
            SelectableText(
              vale.codigo,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: corDestaque,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Destinatário: ${vale.destinatario}',
              style: TextStyle(color: corTexto),
            ),
            if (vale.mensagem.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Mensagem: ${vale.mensagem}',
                style: TextStyle(color: corTexto),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Status: ${vale.status}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: corTextoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
