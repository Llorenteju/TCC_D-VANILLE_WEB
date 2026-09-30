import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/app.dart';
import '../theme/app_theme.dart';

class DVanilleFooter extends StatelessWidget {
  const DVanilleFooter({
    super.key,
  });

  void _ir(BuildContext context, String rota) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      rota,
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ========================================================
        // ESPAÇO ENTRE O CONTEÚDO DA PÁGINA E O RODAPÉ
        // ========================================================

        const SizedBox(height: 60),

        // ========================================================
        // RODAPÉ
        // ========================================================

        Container(
          width: double.infinity,
          color: DVanilleColors.taupe,
          padding: const EdgeInsets.symmetric(
            horizontal: 45,
            vertical: 38,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1500,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 950) {
                    return _footerCompacto(context);
                  }

                  return _footerDesktop(context);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FOOTER DESKTOP
  // ============================================================

  Widget _footerDesktop(BuildContext context) {
    return Row(
      // IMPORTANTE:
      // Mantém todas as colunas alinhadas pelo topo.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // LOGO + DESCRIÇÃO
        // ========================================================

        Expanded(
          flex: 14,
          child: _sobre(),
        ),

        const SizedBox(width: 45),

        // ========================================================
        // NAVEGUE
        // ========================================================

        Expanded(
          flex: 7,
          child: _navegue(context),
        ),

        const SizedBox(width: 40),

        // ========================================================
        // CONTATO
        // ========================================================

        Expanded(
          flex: 8,
          child: _contato(),
        ),

        const SizedBox(width: 40),

        // ========================================================
        // FUNCIONAMENTO
        // ========================================================

        Expanded(
          flex: 8,
          child: _funcionamento(),
        ),
      ],
    );
  }

  // ============================================================
  // FOOTER MOBILE / TABLET
  // ============================================================

  Widget _footerCompacto(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sobre(),
        const SizedBox(height: 35),
        _navegue(context),
        const SizedBox(height: 30),
        _contato(),
        const SizedBox(height: 30),
        _funcionamento(),
      ],
    );
  }

  // ============================================================
  // LOGO + DESCRIÇÃO DA CAFETERIA
  // ============================================================

  Widget _sobre() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --------------------------------------------------------
        // LOGO
        // --------------------------------------------------------

        SizedBox(
          width: 135,
          height: 135,
          child: SvgPicture.asset(
            'assets/images/rodape.svg',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 25),

        // --------------------------------------------------------
        // DESCRIÇÃO
        // --------------------------------------------------------

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Sabor, acolhimento e inclusão em cada detalhe.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Uma cafeteria pensada para todas as pessoas, '
                'com informação nutricional clara e opções para '
                'diferentes restrições alimentares.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NAVEGUE
  // ============================================================

  Widget _navegue(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('Navegue'),
        const SizedBox(height: 17),
        _link(
          context,
          'Conheça a D’Vanille',
          Routes.conheca,
        ),
        _link(
          context,
          'Cardápio',
          Routes.cardapio,
        ),
        _link(
          context,
          'Ofertas',
          Routes.ofertas,
        ),
        _link(
          context,
          'Reservas',
          Routes.reservas,
        ),
        _texto(
          'Vale-presentes',
        ),
      ],
    );
  }

  // ============================================================
  // CONTATO
  // ============================================================

  Widget _contato() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('Contato'),
        const SizedBox(height: 17),
        const Text(
          'Rua das Baunilhas, 245 — Jardim\n'
          'das Flores, São Paulo/SP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          '(11) 4002-8922',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'contato@dvanille.com.br',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          '@dvanille.cafe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FUNCIONAMENTO
  // ============================================================

  Widget _funcionamento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('Funcionamento'),
        const SizedBox(height: 17),
        const Text(
          'Terça a Sexta — 09h às 20h',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Sábado e Domingo — 10h às 21h',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Segunda — Fechado',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TÍTULOS DAS COLUNAS
  // ============================================================

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
    );
  }

  // ============================================================
  // LINKS
  // ============================================================

  Widget _link(
    BuildContext context,
    String texto,
    String rota,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: InkWell(
        onTap: () => _ir(
          context,
          rota,
        ),
        child: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TEXTO SEM LINK
  // ============================================================

  Widget _texto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }
}
