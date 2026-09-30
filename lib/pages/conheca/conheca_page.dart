import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class ConhecaPage extends StatelessWidget {
  const ConhecaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 980;

    return PageShell(
      activeRoute: Routes.conheca,
      child: Column(
        children: [
          const SizedBox(height: 56),

          ContentWidth(
            child: Column(
              children: [
                // =====================================================
                // NOSSA HISTÓRIA
                // =====================================================

                Text(
                  'Nossa história',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'CreamCake',
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: DVanilleColors.rose,
                  ),
                ),

                const SizedBox(height: 4),

                // =====================================================
                // CONHEÇA A D'VANILLE
                // =====================================================

                Text(
                  "Conheça a D'Vanille",
                  textAlign: TextAlign.center,
                  style: AppTheme.display(
                    size: 24,
                    weight: FontWeight.w600,
                    color: DVanilleColors.darkTaupe,
                  ).copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 55),

                // =====================================================
                // FOTO DA FACHADA + NOSSO PROPÓSITO
                // =====================================================

                if (estreito)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/fachada_DVanille.png',
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _TextoProposito(),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/fachada_DVanille.png',
                            width: double.infinity,
                            height: 330,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      const Expanded(
                        child: _TextoProposito(),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // ===========================================================
          // PILARES
          // ===========================================================

          Container(
            width: double.infinity,
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(
              vertical: 56,
            ),
            child: ContentWidth(
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: const [
                  _Pilar(
                    titulo: 'Inclusão alimentar',
                    texto:
                        'Cardápio pensado para diabetes, intolerância à lactose, doença celíaca, alergias, dietas vegetarianas e veganas.',
                  ),
                  _Pilar(
                    titulo: 'Tecnologia',
                    texto:
                        'Plataforma digital com cardápio interativo, filtros por restrição e informações nutricionais detalhadas.',
                  ),
                  _Pilar(
                    titulo: 'Experiência',
                    texto:
                        'Ambiente delicado e acolhedor, com atendimento atento às necessidades de cada cliente.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 56),

          // ===========================================================
          // ENDEREÇO E HORÁRIO
          // ===========================================================

          ContentWidth(
            child: Wrap(
              spacing: 22,
              runSpacing: 22,
              alignment: WrapAlignment.center,
              children: [
                // -------------------------------------------------------
                // ENDEREÇO
                // -------------------------------------------------------

                SizedBox(
                  width: 480,
                  height: 155,
                  child: InfoBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Endereço',
                          style: AppTheme.display(
                            size: 22,
                            color: DVanilleColors.darkTaupe,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Rua das Baunilhas, 245 — Jardim das Flores, São Paulo/SP',
                        ),
                      ],
                    ),
                  ),
                ),

                // -------------------------------------------------------
                // HORÁRIO
                // -------------------------------------------------------

                SizedBox(
                  width: 480,
                  height: 155,
                  child: InfoBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horário',
                          style: AppTheme.display(
                            size: 22,
                            color: DVanilleColors.darkTaupe,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Terça a Sexta, 09h–20h · Sábado e Domingo, 10h–21h · Segunda, fechado',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// TEXTO DO PROPÓSITO
// =====================================================================

class _TextoProposito extends StatelessWidget {
  const _TextoProposito();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nosso propósito',
          style: TextStyle(
            fontFamily: 'CreamCake',
            fontSize: 48,
            fontWeight: FontWeight.w400,
            color: DVanilleColors.rose,
            height: 1.1,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Uma experiência mais segura, acessível e acolhedora!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: DVanilleColors.darkTaupe,
            height: 1.25,
          ),
        ),
        SizedBox(height: 16),
        Text(
          "A D'Vanille nasceu do desejo de unir gastronomia, tecnologia e bem-estar. Buscamos tornar a experiência de se alimentar fora de casa mais segura e acolhedora para pessoas com restrições alimentares — sem abrir mão do sabor e da beleza de cada receita.",
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 15,
            height: 1.7,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Acreditamos que todo mundo merece sentar à mesa, ler um cardápio com clareza e escolher com confiança. Por isso, cada produto traz ingredientes, informações nutricionais e indicação de restrições de forma visual e simples.',
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 15,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// PILAR
// =====================================================================

class _Pilar extends StatelessWidget {
  final String titulo;
  final String texto;

  const _Pilar({
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: InfoBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: AppTheme.display(
                size: 22,
                color: DVanilleColors.darkTaupe,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              style: const TextStyle(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
