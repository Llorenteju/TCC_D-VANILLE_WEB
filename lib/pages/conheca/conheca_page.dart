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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final corDestaque = isDark ? DVanilleColors.darkRose : DVanilleColors.rose;

    final corTitulo =
        isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;

    final corTexto = isDark ? DVanilleColors.darkInk : DVanilleColors.ink;

    return PageShell(
      activeRoute: Routes.conheca,
      child: Column(
        children: [
          const SizedBox(height: 56),

          ContentWidth(
            child: Column(
              children: [
                Text(
                  'Nossa história',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'CreamCake',
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: corDestaque,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Conheça a D'Vanille",
                  textAlign: TextAlign.center,
                  style: AppTheme.display(
                    size: 24,
                    weight: FontWeight.w600,
                    color: corTitulo,
                  ).copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 55),
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
                      _TextoProposito(
                        corDestaque: corDestaque,
                        corTitulo: corTitulo,
                        corTexto: corTexto,
                      ),
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
                      Expanded(
                        child: _TextoProposito(
                          corDestaque: corDestaque,
                          corTitulo: corTitulo,
                          corTexto: corTexto,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // PILARES

          Container(
            width: double.infinity,
            color: isDark ? DVanilleColors.darkCream2 : DVanilleColors.cream2,
            padding: const EdgeInsets.symmetric(vertical: 56),
            child: ContentWidth(
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _Pilar(
                    titulo: 'Inclusão alimentar',
                    texto:
                        'Cardápio pensado para diabetes, intolerância à lactose, doença celíaca, alergias, dietas vegetarianas e veganas.',
                    corTitulo: corTitulo,
                    corTexto: corTexto,
                  ),
                  _Pilar(
                    titulo: 'Tecnologia',
                    texto:
                        'Plataforma digital com cardápio interativo, filtros por restrição e informações nutricionais detalhadas.',
                    corTitulo: corTitulo,
                    corTexto: corTexto,
                  ),
                  _Pilar(
                    titulo: 'Experiência',
                    texto:
                        'Ambiente delicado e acolhedor, com atendimento atento às necessidades de cada cliente.',
                    corTitulo: corTitulo,
                    corTexto: corTexto,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 56),

          // ENDEREÇO E HORÁRIO

          ContentWidth(
            child: Wrap(
              spacing: 22,
              runSpacing: 22,
              alignment: WrapAlignment.center,
              children: [
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
                            color: corTitulo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rua das Baunilhas, 245 — Jardim das Flores, São Paulo/SP',
                          style: TextStyle(
                            color: corTexto,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                            color: corTitulo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Terça a Sexta, 09h–20h · Sábado e Domingo, 10h–21h · Segunda, fechado',
                          style: TextStyle(
                            color: corTexto,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 56),
        ],
      ),
    );
  }
}

// ================================================================
// TEXTO DO PROPÓSITO
// ================================================================

class _TextoProposito extends StatelessWidget {
  final Color corDestaque;
  final Color corTitulo;
  final Color corTexto;

  const _TextoProposito({
    required this.corDestaque,
    required this.corTitulo,
    required this.corTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nosso propósito',
          style: TextStyle(
            fontFamily: 'CreamCake',
            fontSize: 48,
            fontWeight: FontWeight.w400,
            color: corDestaque,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Uma experiência mais segura, acessível e acolhedora!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: corTitulo,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "A D'Vanille nasceu do desejo de unir gastronomia, tecnologia e bem-estar. Buscamos tornar a experiência de se alimentar fora de casa mais segura e acolhedora para pessoas com restrições alimentares, sem abrir mão do sabor e da beleza de cada receita.",
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 15,
            height: 1.7,
            color: corTexto,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Acreditamos que todo mundo merece sentar à mesa, ler um cardápio com clareza e escolher com confiança. Por isso, cada produto traz ingredientes, informações nutricionais e indicação de restrições de forma visual e simples.',
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 15,
            height: 1.7,
            color: corTexto,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// PILAR
// ================================================================

class _Pilar extends StatelessWidget {
  final String titulo;
  final String texto;
  final Color corTitulo;
  final Color corTexto;

  const _Pilar({
    required this.titulo,
    required this.texto,
    required this.corTitulo,
    required this.corTexto,
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
                color: corTitulo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              style: TextStyle(
                height: 1.6,
                color: corTexto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
