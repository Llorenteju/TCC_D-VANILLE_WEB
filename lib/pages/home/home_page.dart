import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_kit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Imagens SVG das categorias.
  static const Map<String, String> _iconesCategorias = {
    'bolo': 'assets/images/bolo.svg',
    'salgados': 'assets/images/salgado.svg',
    'doces': 'assets/images/doce.svg',
    'sobremesas-geladas': 'assets/images/sobremesagelada.svg',
    'bebidas-quentes': 'assets/images/bebidaquente.svg',
    'bebidas-geladas': 'assets/images/bebidagelada.svg',
  };

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return PageShell(
      activeRoute: Routes.home,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final destaques = state.produtos
              .where(
                (p) => [1, 5, 11, 14].contains(p.id),
              )
              .toList();

          final ofertas = state.ofertas.take(3).toList();

          return Column(
            children: [
              _hero(context),

              const SizedBox(height: 56),

              ContentWidth(
                child: Column(
                  children: [
                    Text(
                      'Nossa proposta',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 42,
                        fontWeight: FontWeight.w400,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sabor, acolhimento e inclusão em cada detalhe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: DVanilleColors.darkTaupe,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Cada produto da D'Vanille traz ingredientes, informações nutricionais e indicação de restrições alimentares de forma clara, para que você escolha com segurança e prazer.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: DVanilleColors.ink,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _categorias(context),
                  ],
                ),
              ),

              const SizedBox(height: 64),

              Container(
                width: double.infinity,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 56,
                ),
                child: ContentWidth(
                  child: Column(
                    children: [
                      Text(
                        'Selecionados para você',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'CreamCake',
                          fontSize: 42,
                          fontWeight: FontWeight.w400,
                          color: DVanilleColors.rose,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Produtos em destaque',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: DVanilleColors.darkTaupe,
                        ),
                      ),
                      const SizedBox(height: 34),
                      GradeProdutos(
                        produtos: destaques,
                      ),
                      const SizedBox(height: 30),
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.cardapio,
                          (r) => false,
                        ),
                        child: const Text(
                          'Ver cardápio completo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 64),

              ContentWidth(
                child: Column(
                  children: [
                    Text(
                      'Não perca',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 42,
                        fontWeight: FontWeight.w400,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ofertas da semana',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: DVanilleColors.darkTaupe,
                      ),
                    ),
                    const SizedBox(height: 34),
                    GradeProdutos(
                      produtos: ofertas,
                    ),
                    const SizedBox(height: 30),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: DVanilleColors.blush,
                        foregroundColor: DVanilleColors.darkTaupe,
                      ),
                      onPressed: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.ofertas,
                        (r) => false,
                      ),
                      child: const Text(
                        'Ver todas as ofertas',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 64),

              // ============================================================
              // APP D'VANILLE
              // ============================================================

              _secaoAplicativo(context),

              const SizedBox(height: 64),

              // ============================================================
              // LOCALIZAÇÃO E HORÁRIO
              // ============================================================

              Container(
                width: double.infinity,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 56,
                ),
                child: ContentWidth(
                  child: Wrap(
                    spacing: 22,
                    runSpacing: 22,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: 480,
                        child: InfoBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Localização',
                                style: AppTheme.display(
                                  size: 22,
                                  color: DVanilleColors.darkTaupe,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _linhaIcone(
                                Icons.place_outlined,
                                'Rua das Baunilhas, 245 — Jardim das Flores, São Paulo/SP',
                              ),
                              _linhaIcone(
                                Icons.phone_outlined,
                                '(11) 4002-8922',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 480,
                        child: InfoBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Horário de funcionamento',
                                style: AppTheme.display(
                                  size: 22,
                                  color: DVanilleColors.darkTaupe,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _linhaIcone(
                                Icons.schedule,
                                'Terça a Sexta — 09h às 20h',
                              ),
                              _linhaIcone(
                                Icons.schedule,
                                'Sábado e Domingo — 10h às 21h',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 64),
            ],
          );
        },
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return ContentWidth(
      padding: const EdgeInsets.fromLTRB(
        24,
        56,
        24,
        0,
      ),
      child: Column(
        children: [
          Text(
            'Bem-vindo à',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'CreamCake',
              fontSize: 38,
              fontWeight: FontWeight.w400,
              color: DVanilleColors.rose,
              height: 0.95,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -5),
            child: Text(
              "D'Vanille",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'CreamCake',
                fontSize: 68,
                fontWeight: FontWeight.w400,
                color: DVanilleColors.darkTaupe,
                height: 0.95,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: const Text(
              'Uma cafeteria pensada para acolher todas as pessoas, com sabor, tecnologia e informação nutricional clara para quem possui restrições alimentares.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.5,
                height: 1.6,
                color: DVanilleColors.darkTaupe,
              ),
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.cardapio,
                  (r) => false,
                ),
                child: const Text(
                  'Conheça nosso cardápio',
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.cardapio,
                  (r) => false,
                ),
                child: const Text(
                  'Faça seu pedido',
                ),
              ),
            ],
          ),
          const SizedBox(height: 44),
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              'assets/images/cafeteriainterna.png',
              width: double.infinity,
              height: 340,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _secaoAplicativo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 56,
      ),
      decoration: BoxDecoration(
        color: DVanilleColors.blush2,
        borderRadius: BorderRadius.circular(32),
      ),
      child: ContentWidth(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final estreito = constraints.maxWidth < 800;

            final texto = Column(
              crossAxisAlignment: estreito
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sua comida favorita na palma da sua mão',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'CreamCake',
                    fontSize: 42,
                    fontWeight: FontWeight.w400,
                    color: DVanilleColors.rose,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Deu vontade? A D’Vanille vai até você.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: DVanilleColors.darkTaupe,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Peça suas delícias favoritas pelo nosso app e receba no conforto de casa.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: DVanilleColors.ink,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment:
                      estreito ? WrapAlignment.center : WrapAlignment.start,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: DVanilleColors.darkTaupe,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'App D’Vanille',
                              ),
                              content: const Text(
                                'Em breve você poderá baixar o aplicativo D’Vanille e fazer seus pedidos por delivery.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Fechar',
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        'Pedir pelo app',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 18,
                  runSpacing: 12,
                  alignment:
                      estreito ? WrapAlignment.center : WrapAlignment.start,
                  children: const [
                    _BeneficioApp(
                      icone: Icons.delivery_dining_outlined,
                      texto: 'Delivery sem complicação',
                    ),
                    _BeneficioApp(
                      icone: Icons.favorite_border,
                      texto: 'Escolha seus favoritos',
                    ),
                    _BeneficioApp(
                      icone: Icons.home_outlined,
                      texto: 'Receba onde estiver',
                    ),
                  ],
                ),
              ],
            );

            // ============================================================
            // MOCKUP DO CELULAR
            // Tela inicial de um smartphone.
            // ============================================================

            final celular = Container(
              width: estreito ? 220 : 250,
              height: estreito ? 420 : 470,
              decoration: BoxDecoration(
                color: DVanilleColors.ink,
                borderRadius: BorderRadius.circular(38),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 25,
                    offset: Offset(0, 12),
                    color: Color(0x30000000),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(9),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),

                  // FUNDO MAIS ESCURO PARA DAR CONTRASTE AO ÍCONE
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF9C8A73),
                      Color(0xFF7C6C58),
                      Color(0xFF9C8A73),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Fundo decorativo da tela inicial.
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CustomPaint(
                          painter: _CelularWallpaperPainter(),
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        const SizedBox(height: 10),

                        // NOTCH / CÂMERA
                        Container(
                          width: 78,
                          height: 22,
                          decoration: BoxDecoration(
                            color: DVanilleColors.ink,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: DVanilleColors.darkTaupe,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // BARRA DE STATUS
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '09:41',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: DVanilleColors.cream,
                                ),
                              ),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.signal_cellular_alt,
                                    size: 12,
                                    color: DVanilleColors.cream,
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.wifi,
                                    size: 12,
                                    color: DVanilleColors.cream,
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.battery_full,
                                    size: 14,
                                    color: DVanilleColors.cream,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // DATA
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Quarta-feira',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: DVanilleColors.cream,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ÍCONES DA TELA INICIAL
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _iconeAplicativo(
                                Icons.photo_library_outlined,
                                'Fotos',
                              ),
                              _iconeAplicativo(
                                Icons.calendar_month_outlined,
                                'Agenda',
                              ),
                              _iconeAplicativo(
                                Icons.music_note_outlined,
                                'Música',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _iconeAplicativo(
                                Icons.camera_alt_outlined,
                                'Câmera',
                              ),

                              _iconeAplicativo(
                                Icons.chat_bubble_outline,
                                'Mensagens',
                              ),

                              // APP D'VANILLE
                              // O SVG aparece inteiro e sem fundo branco.
                              GestureDetector(
                                onTap: () {},
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: SvgPicture.asset(
                                        'assets/images/app.svg',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'D’Vanille',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        color: DVanilleColors.cream,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // TEXTO DE CHAMADA
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 25,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.22,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.18,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Toque no app D’Vanille para pedir',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: DVanilleColors.cream,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // DOCK INFERIOR
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          height: 58,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.25,
                            ),
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.18,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _iconeDock(
                                Icons.phone_outlined,
                              ),
                              _iconeDock(
                                Icons.camera_alt_outlined,
                              ),
                              _iconeDock(
                                Icons.chat_bubble_outline,
                              ),
                              _iconeDock(
                                Icons.music_note_outlined,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // BARRA INFERIOR DO CELULAR
                        Container(
                          width: 76,
                          height: 4,
                          margin: const EdgeInsets.only(
                            bottom: 8,
                          ),
                          decoration: BoxDecoration(
                            color: DVanilleColors.cream,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );

            if (estreito) {
              return Column(
                children: [
                  texto,
                  const SizedBox(height: 42),
                  celular,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: texto,
                ),
                const SizedBox(width: 70),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: celular,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _iconeAplicativo(
    IconData icone,
    String nome,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.72,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icone,
            size: 24,
            color: DVanilleColors.darkTaupe,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          nome,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            color: DVanilleColors.cream,
          ),
        ),
      ],
    );
  }

  Widget _iconeDock(IconData icone) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: DVanilleColors.cream,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(
        icone,
        size: 20,
        color: DVanilleColors.darkTaupe,
      ),
    );
  }

  Widget _categorias(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double espacamento = 12;

        final double larguraCard =
            (constraints.maxWidth - (espacamento * 5)) / 6;

        final double larguraFinal = larguraCard.clamp(145.0, 190.0);

        if (constraints.maxWidth < 950) {
          return Wrap(
            spacing: espacamento,
            runSpacing: espacamento,
            alignment: WrapAlignment.center,
            children: categorias
                .map(
                  (c) => _pilulaCategoria(
                    context,
                    c,
                    170,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < categorias.length; i++) ...[
              SizedBox(
                width: larguraFinal,
                child: _pilulaCategoria(
                  context,
                  categorias[i],
                  larguraFinal,
                ),
              ),
              if (i < categorias.length - 1)
                const SizedBox(
                  width: espacamento,
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _pilulaCategoria(
    BuildContext context,
    Categoria c,
    double largura,
  ) {
    final caminhoImagem = _iconesCategorias[c.id];

    return InkWell(
      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.cardapio,
        (r) => false,
        arguments: c.id,
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: largura,
        height: 155,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: DVanilleColors.line,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (caminhoImagem != null)
              SvgPicture.asset(
                caminhoImagem,
                width: 62,
                height: 62,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 10),
            Text(
              c.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: DVanilleColors.darkTaupe,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaIcone(
    IconData icone,
    String texto,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 18,
            color: DVanilleColors.rose,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeneficioApp extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _BeneficioApp({
    required this.icone,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icone,
          size: 20,
          color: DVanilleColors.rose,
        ),
        const SizedBox(width: 7),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: DVanilleColors.darkTaupe,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PAPEL DE PAREDE DO CELULAR
// ============================================================

class _CelularWallpaperPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Rosa suave para criar contraste sobre o taupe.
    paint.color = const Color(0xFFEFCDCC).withValues(
      alpha: 0.28,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.15,
        size.height * 0.20,
      ),
      70,
      paint,
    );

    // Creme suave.
    paint.color = const Color(0xFFFFEEDD).withValues(
      alpha: 0.22,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.90,
        size.height * 0.42,
      ),
      90,
      paint,
    );

    // Rosa novamente na parte inferior.
    paint.color = const Color(0xFFEFCDCC).withValues(
      alpha: 0.18,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.30,
        size.height * 0.82,
      ),
      100,
      paint,
    );

    // Linhas decorativas claras.
    final linePaint = Paint()
      ..color = const Color(0xFFFFF4E8).withValues(
        alpha: 0.14,
      )
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(
      0,
      size.height * 0.32,
    );

    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.23,
      size.width,
      size.height * 0.34,
    );

    canvas.drawPath(
      path,
      linePaint,
    );

    final path2 = Path();

    path2.moveTo(
      0,
      size.height * 0.67,
    );

    path2.quadraticBezierTo(
      size.width * 0.50,
      size.height * 0.76,
      size.width,
      size.height * 0.60,
    );

    canvas.drawPath(
      path2,
      linePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
