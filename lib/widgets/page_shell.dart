import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'dvanille_footer.dart';
import 'dvanille_header.dart';

class PageShell extends StatelessWidget {
  final Widget child;
  final String? activeRoute;
  final bool mostrarRodape;
  final bool mostrarCabecalho;
  final bool mostrarAcessibilidade;
  final bool mostrarCarrinho;

  const PageShell({
    super.key,
    required this.child,
    this.activeRoute,
    this.mostrarRodape = true,
    this.mostrarCabecalho = true,
    this.mostrarAcessibilidade = true,
    this.mostrarCarrinho = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          mostrarAcessibilidade ? const BotaoAcessibilidade() : null,
      body: Column(
        children: [
          if (mostrarCabecalho)
            DVanilleHeader(
              activeRoute: activeRoute,
              mostrarCarrinho: mostrarCarrinho,
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  child,
                  if (mostrarRodape) const DVanilleFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de acessibilidade — tamanho da fonte e modo escuro.
class BotaoAcessibilidade extends StatelessWidget {
  const BotaoAcessibilidade({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: DVanilleColors.taupe,
      foregroundColor: Colors.white,
      tooltip: 'Configurações de acessibilidade',
      onPressed: () => _abrirPainel(context),
      child: const Icon(Icons.accessibility_new),
    );
  }

  void _abrirPainel(BuildContext context) {
    final state = AppState.instance;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'ACESSIBILIDADE',
          style: AppTheme.display(
            size: 18,
            color: DVanilleColors.darkTaupe,
          ),
        ),
        content: ListenableBuilder(
          listenable: state,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tamanho da fonte',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: state.diminuirFonte,
                        child: const Text('A-'),
                      ),
                      const SizedBox(width: 6),
                      OutlinedButton(
                        onPressed: state.aumentarFonte,
                        child: const Text('A+'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Modo escuro',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Switch(
                    value: state.dark,
                    activeThumbColor: DVanilleColors.taupe,
                    onChanged: (_) => state.alternarDark(),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
