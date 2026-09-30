import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../models/produto.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_kit.dart';

class CardapioPage extends StatefulWidget {
  const CardapioPage({super.key});

  @override
  State<CardapioPage> createState() => _CardapioPageState();
}

class _CardapioPageState extends State<CardapioPage> {
  final state = AppState.instance;
  final buscaController = TextEditingController();

  String categoria = 'todas';
  String busca = '';
  final Set<String> filtros = {};
  bool _argumentoLido = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argumentoLido) return;

    _argumentoLido = true;

    final arg = ModalRoute.of(context)?.settings.arguments;

    if (arg is String && arg.isNotEmpty) {
      categoria = arg;
    }
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 760;

    return PageShell(
      activeRoute: Routes.cardapio,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final lista = state.filtrarProdutos(
            categoria: categoria,
            busca: busca,
            restricoes: filtros,
          );

          final recomendados = state.recomendados;

          return Column(
            children: [
              const SizedBox(height: 56),

              // ==========================================================
              // CABEÇALHO DO CARDÁPIO
              // ==========================================================
              ContentWidth(
                child: Column(
                  children: [
                    Text(
                      'Nosso Cardápio',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // SUBTÍTULO
                    Text(
                      'Escolha com clareza e sabor',
                      textAlign: TextAlign.center,
                      style: AppTheme.display(
                        size: 24,
                        weight: FontWeight.w600,
                        color: DVanilleColors.darkTaupe,
                      ).copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // DESCRIÇÃO
                    const Text(
                      'Pesquise, filtre por restrições alimentares e veja tudo sobre ingredientes e valores nutricionais.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: DVanilleColors.ink,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ==========================================================
              // CONTEÚDO
              // ==========================================================
              ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======================================================
                    // RECOMENDADOS
                    // ======================================================
                    if (recomendados.isNotEmpty) ...[
                      Text(
                        'Recomendado para você',
                        style: AppTheme.display(
                          size: 24,
                          color: DVanilleColors.darkTaupe,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const DicaCampo(
                        'Sugestões com base nas restrições alimentares do seu perfil. Isso não substitui orientação médica ou nutricional.',
                      ),
                      const SizedBox(height: 16),
                      GradeProdutos(
                        produtos: recomendados,
                      ),
                      const SizedBox(height: 44),
                    ],

                    // ======================================================
                    // CATEGORIAS
                    // ======================================================
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 23,
                        runSpacing: 8,
                        children: [
                          ChipSelecao(
                            label: 'Todas',
                            ativo: categoria == 'todas',
                            onTap: () {
                              setState(() {
                                categoria = 'todas';
                              });
                            },
                          ),
                          for (final c in categorias)
                            ChipSelecao(
                              label: c.label,
                              ativo: categoria == c.id,
                              onTap: () {
                                setState(() {
                                  categoria = c.id;
                                });
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ======================================================
                    // LAYOUT RESPONSIVO
                    // ======================================================
                    if (estreito) ...[
                      _painelFiltros(context),
                      const SizedBox(height: 20),
                      _campoBusca(),
                      const SizedBox(height: 24),
                      _resultado(lista),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 250,
                            child: _painelFiltros(context),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: Column(
                              children: [
                                _campoBusca(),
                                const SizedBox(height: 24),
                                _resultado(lista),
                              ],
                            ),
                          ),
                        ],
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

  // =========================================================================
  // CAMPO DE BUSCA
  // =========================================================================

  Widget _campoBusca() {
    return TextField(
      controller: buscaController,
      onChanged: (v) {
        setState(() {
          busca = v;
        });
      },
      decoration: const InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: DVanilleColors.taupe,
        ),
        hintText: 'Pesquisar produtos, ex: café, cupcake, sem glúten...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(999),
          ),
          borderSide: BorderSide(
            color: DVanilleColors.line,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(999),
          ),
          borderSide: BorderSide(
            color: DVanilleColors.line,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(999),
          ),
          borderSide: BorderSide(
            color: DVanilleColors.rose,
            width: 2,
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // PAINEL DE FILTROS
  // =========================================================================

  Widget _painelFiltros(BuildContext context) {
    return InfoBox(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por restrição',
            style: AppTheme.display(
              size: 19,
              color: DVanilleColors.darkTaupe,
            ),
          ),
          const SizedBox(height: 6),
          for (final entrada in restricoesLabels.entries)
            InkWell(
              onTap: () {
                setState(() {
                  if (filtros.contains(entrada.key)) {
                    filtros.remove(entrada.key);
                  } else {
                    filtros.add(entrada.key);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 2,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: filtros.contains(entrada.key),
                      activeColor: DVanilleColors.taupe,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            filtros.add(entrada.key);
                          } else {
                            filtros.remove(entrada.key);
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        entrada.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // RESULTADOS
  // =========================================================================

  Widget _resultado(List<Produto> lista) {
    if (lista.isEmpty) {
      return const EstadoVazio(
        emoji: '🔍',
        titulo: 'Nenhum produto encontrado',
        texto:
            'Não encontramos produtos para essa busca. Tente outro termo ou remova alguns filtros.',
      );
    }

    return GradeProdutos(
      produtos: lista,
    );
  }
}
