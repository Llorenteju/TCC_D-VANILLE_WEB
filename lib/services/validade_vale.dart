/// Regras de vencimento dos vales-presente da D'Vanille.
///
/// O prazo começa no dia seguinte à emissão. A data do vencimento é
/// inclusiva: o vale pode ser apresentado até o fim desse dia.
///
/// O cálculo ignora sábados, domingos, feriados nacionais fixos e
/// a Paixão de Cristo (feriado móvel).
/// Para feriados estaduais/municipais da cidade da cafeteria, adicione
/// as datas (dia-mês) em [_feriadosLocais]. Feriados móveis locais
/// também precisarão ser cadastrados conforme o calendário de cada ano.
class ValidadeVale {
  ValidadeVale._();

  static const int prazoDiasUteis = 30;

  static const Set<String> _feriadosFixosNacionais = <String>{
    '01-01', // Confraternização Universal
    '21-04', // Tiradentes
    '01-05', // Dia do Trabalho
    '07-09', // Independência
    '12-10', // Nossa Senhora Aparecida
    '02-11', // Finados
    '15-11', // Proclamação da República
    '20-11', // Dia Nacional de Zumbi e da Consciência Negra
    '25-12', // Natal
  };

  // Exemplo para a cidade de São Paulo, caso a cafeteria esteja lá:
  // '25-01' (aniversário da cidade) e '09-07' (feriado estadual).
  static const Set<String> _feriadosLocais = <String>{};

  static DateTime apenasData(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  /// Entende datas no formato ISO (2026-11-11) e brasileiro (11/11/2026).
  static DateTime? interpretarEmissao(String valor) {
    final entrada = valor.trim();
    if (entrada.isEmpty) return null;

    final iso = DateTime.tryParse(entrada);
    if (iso != null) return apenasData(iso);

    final br = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$')
        .firstMatch(entrada);
    if (br == null) return null;
    final dia = int.parse(br.group(1)!);
    final mes = int.parse(br.group(2)!);
    final ano = int.parse(br.group(3)!);
    final data = DateTime(ano, mes, dia);
    if (data.day != dia || data.month != mes || data.year != ano) {
      return null;
    }
    return data;
  }

  /// Data da Páscoa no calendário gregoriano; a Paixão de Cristo
  /// (feriado nacional) ocorre dois dias antes.
  static DateTime _pascoa(int ano) {
    final a = ano % 19;
    final b = ano ~/ 100;
    final c = ano % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final mes = (h + l - 7 * m + 114) ~/ 31;
    final dia = (h + l - 7 * m + 114) % 31 + 1;
    return DateTime(ano, mes, dia);
  }

  static bool _ehDiaUtil(DateTime data) {
    if (data.weekday == DateTime.saturday ||
        data.weekday == DateTime.sunday) {
      return false;
    }
    final chave = '${data.day.toString().padLeft(2, '0')}-'
        '${data.month.toString().padLeft(2, '0')}';
    final sextaFeiraSanta = _pascoa(data.year).subtract(
      const Duration(days: 2),
    );
    if (apenasData(data) == apenasData(sextaFeiraSanta)) return false;
    return !_feriadosFixosNacionais.contains(chave) &&
        !_feriadosLocais.contains(chave);
  }

  /// Calcula o 30º dia útil após a compra.
  static DateTime calcular(DateTime emissao) {
    var data = apenasData(emissao);
    var contados = 0;
    while (contados < prazoDiasUteis) {
      data = DateTime(data.year, data.month, data.day + 1);
      if (_ehDiaUtil(data)) contados++;
    }
    return data;
  }
}
