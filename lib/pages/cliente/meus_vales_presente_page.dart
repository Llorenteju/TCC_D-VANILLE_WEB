import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../app/app.dart';
import '../../models/vale_presente.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class MeusValesPresentePage extends StatelessWidget {
  const MeusValesPresentePage({super.key});

  String _statusEfetivo(ValePresente vale, AppState state) {
    final status = vale.status.trim().toLowerCase();
    if (status == 'usado') return 'utilizado';

    // Mostra a data vencida imediatamente, mesmo antes da rotina
    // periódica de expiração atualizar o AppState.
    if (status == 'ativo') {
      final validade = state.validadeValePresente(vale.id);
      if (validade != null) {
        final hoje = DateTime.now();
        final somenteHoje = DateTime(hoje.year, hoje.month, hoje.day);
        final somenteValidade =
            DateTime(validade.year, validade.month, validade.day);
        if (somenteValidade.isBefore(somenteHoje)) return 'expirado';
      }
    }
    return status;
  }

  String _nomeStatus(String status) {
    switch (status) {
      case 'ativo':
        return 'Ativo';
      case 'utilizado':
        return 'Utilizado';
      case 'expirado':
        return 'Expirado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Indisponível';
    }
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'ativo':
        return const Color(0xFF467D56);
      case 'utilizado':
        return const Color(0xFF5D759A);
      case 'expirado':
        return const Color(0xFFB17835);
      case 'cancelado':
        return const Color(0xFFB5473F);
      default:
        return DVanilleColors.taupe;
    }
  }

  String _formatarData(DateTime data) {
    String dois(int numero) => numero.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year}';
  }

  String _formatarDataHora(DateTime data) {
    String dois(int numero) => numero.toString().padLeft(2, '0');
    return '${_formatarData(data)} às ${dois(data.hour)}:${dois(data.minute)}';
  }

  String _formatarDataCompra(String data) {
    final valor = DateTime.tryParse(data.trim());
    return valor == null ? data : _formatarData(valor);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return PageShell(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final corTexto =
              isDark ? DVanilleColors.darkInk : DVanilleColors.darkTaupe;
          final corTextoSecundario =
              isDark ? DVanilleColors.darkTextSecondary : DVanilleColors.taupe;

          final usuario = state.usuarioLogado;
          final email = usuario?.email.trim().toLowerCase() ?? '';
          final vales = email.isEmpty
              ? <ValePresente>[]
              : state.valePresentes.where((vale) {
                  return vale.compradorEmail.trim().toLowerCase() == email;
                }).toList();

          vales.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));

          return Column(
            children: [
              const SizedBox(height: 48),
              ContentWidth(
                child: Column(
                  children: [
                    const Text(
                      'Meus vales-presente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 46,
                        fontWeight: FontWeight.w400,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Consulte o código, a validade e a situação de seus presentes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: corTextoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ContentWidth(
                maxWidth: 850,
                child: vales.isEmpty
                    ? _estadoVazio(context, isDark, corTexto)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            vales.length == 1
                                ? 'Você tem 1 vale-presente'
                                : 'Você tem ${vales.length} vales-presente',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: corTexto,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Os vales são aceitos apenas presencialmente na '
                            'cafeteria, em uma única compra e com restituição de eventual diferença de valor.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: corTextoSecundario,
                            ),
                          ),
                          const SizedBox(height: 18),
                          for (final vale in vales) ...[
                            _cartaoVale(
                              context,
                              vale,
                              state,
                              isDark,
                              corTexto,
                              corTextoSecundario,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 36),
            ],
          );
        },
      ),
    );
  }

  Widget _estadoVazio(
    BuildContext context,
    bool isDark,
    Color corTexto,
  ) {
    return InfoBox(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Icon(
            Icons.card_giftcard_outlined,
            size: 54,
            color: DVanilleColors.rose,
          ),
          const SizedBox(height: 16),
          Text(
            'Você ainda não tem vales-presente',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: corTexto,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Quando você comprar um vale-presente, ele aparecerá aqui '
            'com seu código, status e validade.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? DVanilleColors.darkTextSecondary
                  : DVanilleColors.taupe,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.shopping);
            },
            child: const Text('Conhecer os vales-presente'),
          ),
        ],
      ),
    );
  }

  Widget _cartaoVale(
    BuildContext context,
    ValePresente vale,
    AppState state,
    bool isDark,
    Color corTexto,
    Color corTextoSecundario,
  ) {
    final status = _statusEfetivo(vale, state);
    final ativo = status == 'ativo';
    final validade = state.validadeValePresente(vale.id);
    final resgatadoEm = state.dataResgateValePresente(vale.id);

    final corFundoCodigo = isDark
        ? DVanilleColors.darkSurface
        : DVanilleColors.blush.withValues(alpha: 0.35);
    final corBorda = isDark ? DVanilleColors.darkBorder : DVanilleColors.line;
    final corSituacao = _corStatus(status);

    return InfoBox(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.card_giftcard,
                size: 34,
                color: DVanilleColors.rose,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vale-presente D’Vanille',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: corTexto,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      money(vale.valor),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: DVanilleColors.rose,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: corSituacao.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: corSituacao),
                ),
                child: Text(
                  _nomeStatus(status),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: isDark ? Colors.white : corSituacao,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: corBorda),
          const SizedBox(height: 12),
          Text(
            'Código do vale',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: corTexto,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: corFundoCodigo,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: corBorda),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    vale.codigo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: corTexto,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copiar código',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: vale.codigo));
                    if (context.mounted) {
                      showToast('Código copiado!', 'copiar.svg');
                    }
                  },
                  icon: Icon(
                    Icons.copy,
                    color: isDark
                        ? DVanilleColors.darkRose
                        : DVanilleColors.darkTaupe,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _detalhe('Destinatário', vale.destinatario, corTexto),
          _detalhe(
              'Data da compra', _formatarDataCompra(vale.criadoEm), corTexto),
          _detalhe(
            'Validade (30 dias úteis)',
            validade == null
                ? 'Não definida'
                : 'Até ${_formatarData(validade)}',
            corTexto,
          ),
          if (resgatadoEm != null)
            _detalhe('Resgatado em', _formatarDataHora(resgatadoEm), corTexto),
          if (vale.mensagem.trim().isNotEmpty)
            _detalhe('Mensagem', vale.mensagem, corTexto),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark ? DVanilleColors.darkSurface : DVanilleColors.cream,
              border: Border.all(color: corBorda),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  ativo
                      ? Icons.storefront_outlined
                      : Icons.info_outline_rounded,
                  color: ativo ? DVanilleColors.rose : corSituacao,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    ativo
                        ? 'Apresente o código na cafeteria física. '
                            'Uso único, com restituição de eventual diferença de valor. '
                            'Não é válido para pedidos no site ou aplicativo.'
                        : 'Este vale está ${_nomeStatus(status).toLowerCase()} '
                            'e não pode ser resgatado novamente.',
                    style: TextStyle(
                      color: corTextoSecundario,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _gerarPdf(context, vale),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Salvar vale em PDF'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detalhe(String titulo, String valor, Color corTexto) {
    if (valor.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: corTexto,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              valor,
              style: TextStyle(color: corTexto),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _gerarPdf(
    BuildContext context,
    ValePresente vale,
  ) async {
    try {
      // Consulta o estado atual antes de preparar o PDF.
      final state = AppState.instance;
      final status = _statusEfetivo(vale, state);
      final validade = state.validadeValePresente(vale.id);
      final resgatadoEm = state.dataResgateValePresente(vale.id);

      final documento = pw.Document();

      final fonteNormal = pw.Font.helvetica();
      final fonteNegrito = pw.Font.helveticaBold();

      const corRose = PdfColor.fromInt(0xFFC98F8C);
      const corTaupe = PdfColor.fromInt(0xFF7C6C58);
      const corCreme = PdfColor.fromInt(0xFFFFF4E8);
      const corBlush = PdfColor.fromInt(0xFFF6DEDC);
      const corTexto = PdfColor.fromInt(0xFF2B2420);

      documento.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pdfContext) {
            return pw.Center(
              child: pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(30),
                decoration: pw.BoxDecoration(
                  color: corCreme,
                  border: pw.Border.all(
                    color: corRose,
                    width: 2,
                  ),
                  borderRadius: pw.BorderRadius.circular(18),
                ),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      "D'Vanille",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonteNegrito,
                        fontSize: 32,
                        color: corTaupe,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      width: 80,
                      height: 2,
                      color: corRose,
                    ),
                    pw.SizedBox(height: 24),
                    pw.Text(
                      'UM PRESENTE ESPECIAL PARA VOCÊ',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonteNegrito,
                        fontSize: 16,
                        color: corTaupe,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Vale-presente',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonteNormal,
                        fontSize: 13,
                        color: corTexto,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      money(vale.valor),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonteNegrito,
                        fontSize: 34,
                        color: corRose,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'STATUS: ${_nomeStatus(status).toUpperCase()}',
                      style: pw.TextStyle(
                        font: fonteNegrito,
                        fontSize: 12,
                        color: corTaupe,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(18),
                      decoration: pw.BoxDecoration(
                        color: corBlush,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'CÓDIGO DO VALE',
                            style: pw.TextStyle(
                              font: fonteNegrito,
                              fontSize: 10,
                              color: corTaupe,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            vale.codigo,
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              font: fonteNegrito,
                              fontSize: 20,
                              color: corTexto,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 24),
                    if (vale.destinatario.trim().isNotEmpty) ...[
                      pw.Text(
                        'Preparado especialmente para',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: fonteNormal,
                          fontSize: 11,
                          color: corTaupe,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        vale.destinatario,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: fonteNegrito,
                          fontSize: 18,
                          color: corTexto,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                    ],
                    if (vale.mensagem.trim().isNotEmpty) ...[
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Text(
                          vale.mensagem,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: fonteNormal,
                            fontSize: 12,
                            color: corTexto,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 18),
                    ],
                    pw.Text(
                      'Data da compra: ${_formatarDataCompra(vale.criadoEm)}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonteNormal,
                        fontSize: 10,
                        color: corTaupe,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      validade == null
                          ? 'Validade não informada'
                          : 'Válido até ${_formatarData(validade)}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonteNegrito,
                        fontSize: 10,
                        color: corTaupe,
                      ),
                    ),
                    if (resgatadoEm != null) ...[
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Resgatado em ${_formatarDataHora(resgatadoEm)}',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: fonteNormal,
                          fontSize: 10,
                          color: corTaupe,
                        ),
                      ),
                    ],
                    pw.SizedBox(height: 15),
                    pw.Text(
                      status == 'ativo'
                          ? "Apresente este código na cafeteria física D'Vanille."
                          : 'Este vale não está disponível para resgate.',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonteNegrito,
                        fontSize: 10,
                        color: corTexto,
                      ),
                    ),
                    pw.SizedBox(height: 7),
                    pw.Text(
                      'Uso exclusivamente presencial; 30 dias úteis de validade. '
                      'A diferença de valor deve ser restituída.',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonteNormal,
                        fontSize: 9,
                        color: corTaupe,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'Um momento doce merece ser compartilhado.',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonteNegrito,
                        fontSize: 12,
                        color: corTaupe,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      final bytes = await documento.save();
      final nomeArquivo = 'vale-presente-${vale.codigo}'
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      await Printing.sharePdf(
        bytes: bytes,
        filename: '$nomeArquivo.pdf',
      );
    } catch (erro) {
      if (context.mounted) {
        showToast(
          'Não foi possível gerar o PDF. Tente novamente.',
          '⚠️',
        );
      }
    }
  }
}
