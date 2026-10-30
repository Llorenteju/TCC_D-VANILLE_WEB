import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';

class ApresentacaoSitePage extends StatelessWidget {
  const ApresentacaoSitePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final corDestaque = isDark ? DVanilleColors.darkRose : DVanilleColors.rose;
    final corTexto = isDark ? DVanilleColors.darkInk : DVanilleColors.ink;
    final corSecundaria =
        isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.darkTaupe;
    final corSuperficie = isDark ? DVanilleColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? DVanilleColors.darkCream : DVanilleColors.cream,

      // Botão de acessibilidade sem exibir o header do site.
      floatingActionButton: const BotaoAcessibilidade(),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: Column(
                  children: [
                    Text(
                      'Conheça a D’Vanille',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DancingScript',
                        fontWeight: FontWeight.bold,
                        fontSize: 52,
                        color: corDestaque,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Muito mais que uma cafeteria: uma experiência pensada '
                      'para unir sabor, tecnologia e inclusão alimentar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: DVanilleColors.darkTaupe,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _funcionalidade(
                      contexto: context,
                      icone: Icons.restaurant_menu_outlined,
                      titulo: 'Cardápio digital',
                      descricao:
                          'Explore nossos produtos, conheça os ingredientes '
                          'e consulte informações nutricionais para fazer '
                          'escolhas mais conscientes.',
                      corDestaque: corDestaque,
                      corTexto: corTexto,
                      corSecundaria: corSecundaria,
                      corSuperficie: corSuperficie,
                    ),
                    _funcionalidade(
                      contexto: context,
                      icone: Icons.health_and_safety_outlined,
                      titulo: 'Inclusão alimentar',
                      descricao:
                          'Encontre informações sobre opções relacionadas '
                          'a diferentes restrições e preferências alimentares, '
                          'como intolerâncias, alergias e outras necessidades.',
                      corDestaque: corDestaque,
                      corTexto: corTexto,
                      corSecundaria: corSecundaria,
                      corSuperficie: corSuperficie,
                    ),
                    _funcionalidade(
                      contexto: context,
                      icone: Icons.calendar_month_outlined,
                      titulo: 'Reservas',
                      descricao:
                          'Consulte as opções disponíveis e faça sua reserva '
                          'para aproveitar a experiência D’Vanille.',
                      corDestaque: corDestaque,
                      corTexto: corTexto,
                      corSecundaria: corSecundaria,
                      corSuperficie: corSuperficie,
                    ),
                    _funcionalidade(
                      contexto: context,
                      icone: Icons.card_giftcard_outlined,
                      titulo: 'Ofertas e vale-presentes',
                      descricao: 'Acompanhe ofertas especiais e conheça nossos '
                          'vales-presentes para compartilhar momentos especiais.',
                      corDestaque: corDestaque,
                      corTexto: corTexto,
                      corSecundaria: corSecundaria,
                      corSuperficie: corSuperficie,
                    ),
                    _funcionalidade(
                      contexto: context,
                      icone: Icons.person_outline,
                      titulo: 'Perfil do cliente',
                      descricao:
                          'Crie sua conta e tenha acesso às funcionalidades '
                          'que exigem identificação, além de acompanhar '
                          'suas informações e atividades.',
                      corDestaque: corDestaque,
                      corTexto: corTexto,
                      corSecundaria: corSecundaria,
                      corSuperficie: corSuperficie,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: corSuperficie,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? DVanilleColors.darkBorder
                              : DVanilleColors.line,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Venha conhecer!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DancingScript',
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: corDestaque,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Explore nosso site e descubra tudo o que '
                            'preparamos para você.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: corTexto,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  Routes.home,
                                  (route) => false,
                                );
                              },
                              icon: const Icon(Icons.language),
                              label: const Text('Conhecer nosso site'),
                              style: FilledButton.styleFrom(
                                backgroundColor: corDestaque,
                                foregroundColor: isDark
                                    ? DVanilleColors.darkCream
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 17,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Voltar para minha comanda',
                              style: TextStyle(color: corSecundaria),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _funcionalidade({
    required BuildContext contexto,
    required IconData icone,
    required String titulo,
    required String descricao,
    required Color corDestaque,
    required Color corTexto,
    required Color corSecundaria,
    required Color corSuperficie,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: corSuperficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(contexto).brightness == Brightness.dark
              ? DVanilleColors.darkBorder
              : DVanilleColors.line,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: corDestaque.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icone,
              color: corDestaque,
              size: 27,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  descricao,
                  style: TextStyle(
                    color: corSecundaria,
                    height: 1.5,
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
