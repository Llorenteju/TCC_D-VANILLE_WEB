import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';

/// Largura máxima do conteúdo (equivale ao .container do CSS).
const double kMaxContentWidth = 1180;

class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = kMaxContentWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Cabeçalho de seção: sobrancelha em itálico + título display + subtítulo.
class SectionHead extends StatelessWidget {
  final String eyebrow;
  final String titulo;
  final String? subtitulo;
  final CrossAxisAlignment alinhamento;

  const SectionHead({
    super.key,
    required this.eyebrow,
    required this.titulo,
    this.subtitulo,
    this.alinhamento = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final centralizado = alinhamento == CrossAxisAlignment.center;
    return Column(
      crossAxisAlignment: alinhamento,
      children: [
        Text(
          eyebrow,
          textAlign: centralizado ? TextAlign.center : TextAlign.start,
          style: AppTheme.display(size: 18, weight: FontWeight.w500)
              .copyWith(
                  fontStyle: FontStyle.italic, color: DVanilleColors.rose),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          textAlign: centralizado ? TextAlign.center : TextAlign.start,
          style: AppTheme.display(size: 32, color: DVanilleColors.darkTaupe),
        ),
        if (subtitulo != null) ...[
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              subtitulo!,
              textAlign: centralizado ? TextAlign.center : TextAlign.start,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
        ],
      ],
    );
  }
}

/// Caixa branca com borda suave (.info-box / .form-card do CSS).
class InfoBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const InfoBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DVanilleColors.line),
      ),
      child: child,
    );
  }
}

/// Selo de restrição alimentar, com a cor correspondente do CSS.
class BadgeRestricao extends StatelessWidget {
  final String chave;
  const BadgeRestricao(this.chave, {super.key});

  static const Map<String, Color> _cores = {
    'semGluten': DVanilleColors.badgeGluten,
    'semLactose': DVanilleColors.badgeLactose,
    'vegano': DVanilleColors.badgeVegan,
    'vegetariano': DVanilleColors.badgeVeg,
    'menosAcucar': DVanilleColors.badgeSugar,
  };

  @override
  Widget build(BuildContext context) {
    final label = restricoesLabels[chave];
    if (label == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _cores[chave] ?? DVanilleColors.blush2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DVanilleColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: DVanilleColors.darkTaupe,
        ),
      ),
    );
  }
}

/// Selo de status de pedido/reserva/vale-presente.
class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: StatusColors.fundo(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: StatusColors.texto(status),
        ),
      ),
    );
  }
}

/// Etiqueta simples usada para ingredientes e alergênicos (.ing-tag).
class TagSimples extends StatelessWidget {
  final String texto;
  const TagSimples(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DVanilleColors.cream2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DVanilleColors.line),
      ),
      child: Text(texto,
          style: const TextStyle(
              fontSize: 13, color: DVanilleColors.darkTaupe)),
    );
  }
}

/// Imagem de rede com fallback em emoji — equivale ao imgOrFallback() do HTML.
class ImagemProduto extends StatelessWidget {
  final String url;
  final String icone;
  final double? altura;
  final BorderRadius? radius;

  const ImagemProduto({
    super.key,
    required this.url,
    this.icone = '🍽️',
    this.altura,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: altura,
      width: double.infinity,
      color: DVanilleColors.blush2,
      alignment: Alignment.center,
      child: Text(icone, style: const TextStyle(fontSize: 38)),
    );

    final conteudo = url.isEmpty
        ? fallback
        : Image.network(
            url,
            height: altura,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : fallback,
          );

    if (radius == null) return conteudo;
    return ClipRRect(borderRadius: radius!, child: conteudo);
  }
}

/// Linha de "chips" de filtro/categoria.
class ChipSelecao extends StatelessWidget {
  final String label;
  final bool ativo;
  final VoidCallback onTap;

  const ChipSelecao({
    super.key,
    required this.label,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: ativo ? DVanilleColors.taupe : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: ativo ? DVanilleColors.taupe : DVanilleColors.line,
              width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: ativo ? Colors.white : DVanilleColors.darkTaupe,
          ),
        ),
      ),
    );
  }
}

/// Estado vazio com emoji, título e texto (.empty-state).
class EstadoVazio extends StatelessWidget {
  final String emoji;
  final String titulo;
  final String? texto;
  final Widget? acao;

  const EstadoVazio({
    super.key,
    required this.emoji,
    required this.titulo,
    this.texto,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 42)),
          const SizedBox(height: 10),
          Text(titulo,
              textAlign: TextAlign.center,
              style: AppTheme.display(
                  size: 22, color: DVanilleColors.darkTaupe)),
          if (texto != null) ...[
            const SizedBox(height: 8),
            Text(texto!, textAlign: TextAlign.center),
          ],
          if (acao != null) ...[const SizedBox(height: 22), acao!],
        ],
      ),
    );
  }
}

/// Seletor de quantidade (.qty-stepper).
class SeletorQuantidade extends StatelessWidget {
  final int valor;
  final VoidCallback onMenos;
  final VoidCallback onMais;

  const SeletorQuantidade({
    super.key,
    required this.valor,
    required this.onMenos,
    required this.onMais,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DVanilleColors.line, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _botao(context, '–', onMenos, true),
          SizedBox(
            width: 44,
            child: Text('$valor',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          _botao(context, '+', onMais, false),
        ],
      ),
    );
  }

  Widget _botao(
      BuildContext context, String texto, VoidCallback onTap, bool esquerda) {
    final radius = esquerda
        ? const BorderRadius.horizontal(left: Radius.circular(999))
        : const BorderRadius.horizontal(right: Radius.circular(999));
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: DVanilleColors.cream2, borderRadius: radius),
        child: Text(texto,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DVanilleColors.darkTaupe)),
      ),
    );
  }
}

/// Caixa de alerta (.alert-error / .alert-success).
class CaixaAlerta extends StatelessWidget {
  final String mensagem;
  final bool erro;

  const CaixaAlerta(this.mensagem, {super.key, this.erro = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: erro ? const Color(0xFFFBE4E1) : const Color(0xFFE4EEE0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        mensagem,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: erro ? const Color(0xFFA3403A) : const Color(0xFF3D6B3A),
        ),
      ),
    );
  }
}

/// Texto de apoio abaixo dos campos (.field-hint).
class DicaCampo extends StatelessWidget {
  final String texto;
  final TextAlign align;
  const DicaCampo(this.texto, {super.key, this.align = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: align,
      style: const TextStyle(fontSize: 12.5, color: DVanilleColors.darkTaupe),
    );
  }
}
