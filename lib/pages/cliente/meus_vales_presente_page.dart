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

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return PageShell(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final usuario = state.usuarioLogado;
          final email = usuario?.email.trim().toLowerCase() ?? '';

          final vales = email.isEmpty
              ? <ValePresente>[]
              : state.valePresentes.where((vale) {
                  return vale.compradorEmail.trim().toLowerCase() == email;
                }).toList()
            ..sort((a, b) => b.criadoEm.compareTo(a.criadoEm));

          return Column(
            children: [
              const SizedBox(height: 48),
              const ContentWidth(
                child: Column(
                  children: [
                    Text(
                      'Meus vales-presente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 46,
                        fontWeight: FontWeight.w400,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Seus presentes especiais, reunidos em um só lugar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: DVanilleColors.darkTaupe,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ContentWidth(
                maxWidth: 850,
                child: vales.isEmpty
                    ? _estadoVazio(context)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            vales.length == 1
                                ? 'Você tem 1 vale-presente'
                                : 'Você tem ${vales.length} vales-presente',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: DVanilleColors.darkTaupe,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (final vale in vales) ...[
                            _cartaoVale(context, vale),
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

  Widget _estadoVazio(BuildContext context) {
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
          const Text(
            'Você ainda não tem vales-presente',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: DVanilleColors.darkTaupe,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Quando você comprar um vale-presente, ele aparecerá aqui '
            'com seu código e seus detalhes.',
            textAlign: TextAlign.center,
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

  Widget _cartaoVale(BuildContext context, ValePresente vale) {
    final usado = vale.status.toLowerCase() == 'usado';

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
                    const Text(
                      'Vale-presente D’Vanille',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: DVanilleColors.darkTaupe,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: usado
                      ? Colors.grey.withValues(alpha: 0.15)
                      : DVanilleColors.blush,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  usado ? 'Utilizado' : 'Ativo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        usado ? Colors.grey.shade700 : DVanilleColors.darkTaupe,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Código do vale',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DVanilleColors.blush.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    vale.codigo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copiar código',
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: vale.codigo),
                    );

                    if (context.mounted) {
                      showToast('Código copiado!', '✓');
                    }
                  },
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _detalhe('Destinatário', vale.destinatario),
          _detalhe('Data da compra', vale.criadoEm),
          if (vale.mensagem.trim().isNotEmpty)
            _detalhe('Mensagem', vale.mensagem),
          const SizedBox(height: 16),
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

  Widget _detalhe(String titulo, String valor) {
    if (valor.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(valor)),
        ],
      ),
    );
  }

  Future<void> _gerarPdf(
    BuildContext context,
    ValePresente vale,
  ) async {
    try {
      final documento = pw.Document();

      // Fontes padrão Helvetica: evitam problemas com caracteres
      // especiais que podem aparecer com algumas fontes incorporadas.
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
                    pw.SizedBox(height: 24),
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
                      'Data da compra: ${vale.criadoEm}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fonteNormal,
                        fontSize: 10,
                        color: corTaupe,
                      ),
                    ),
                    pw.SizedBox(height: 20),
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
