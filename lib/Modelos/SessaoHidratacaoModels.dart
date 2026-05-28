import 'dart:math' as math;

class RegistroInicioSessao {
  const RegistroInicioSessao({
    required this.pesoInicialKg,
    required this.iniciadoEm,
    required this.modalidade,
    required this.duracaoPrevistaMin,
    required this.intensidade,
    required this.temperaturaC,
    required this.umidadeRelativa,
    required this.corUrinaInicial,
    required this.comSede,
  });

  final double pesoInicialKg;
  final DateTime iniciadoEm;
  final String modalidade;
  final int duracaoPrevistaMin;
  final String intensidade;
  final double temperaturaC;
  final int umidadeRelativa;
  final int corUrinaInicial;
  final bool comSede;
}

class RegistroIngestao {
  const RegistroIngestao({
    required this.label,
    required this.quantidadeMl,
    required this.tempoDecorrido,
  });

  final String label;
  final int quantidadeMl;
  final Duration tempoDecorrido;
}

class RegistroPosSessaoArgs {
  const RegistroPosSessaoArgs({
    required this.inicio,
    required this.duracao,
    required this.totalIngeridoMl,
    required this.ingestoes,
  });

  final RegistroInicioSessao inicio;
  final Duration duracao;
  final int totalIngeridoMl;
  final List<RegistroIngestao> ingestoes;
}

class SessaoFinalizada {
  const SessaoFinalizada({
    required this.inicio,
    required this.pesoFinalKg,
    required this.volumeUrinaMl,
    required this.roupasEncharcadas,
    required this.sintomas,
    required this.rpe,
    required this.corUrinaFinal,
    required this.finalizadoEm,
    required this.duracao,
    required this.totalIngeridoMl,
    required this.ingestoes,
  });

  final RegistroInicioSessao inicio;
  final double pesoFinalKg;
  final int volumeUrinaMl;
  final bool roupasEncharcadas;
  final List<String> sintomas;
  final int rpe;
  final int corUrinaFinal;
  final DateTime finalizadoEm;
  final Duration duracao;
  final int totalIngeridoMl;
  final List<RegistroIngestao> ingestoes;

  ResultadoHidratacao get resultado {
    final duracaoHoras = math.max(duracao.inSeconds / 3600, 1 / 60);
    final ingestaoLitros = totalIngeridoMl / 1000;
    final urinaLitros = volumeUrinaMl / 1000;
    final variacaoKg = inicio.pesoInicialKg - pesoFinalKg;
    final perdaAjustadaLitros = math.max(
      0.0,
      variacaoKg + ingestaoLitros - urinaLitros,
    );
    final taxaSudorese = perdaAjustadaLitros / duracaoHoras;
    final variacaoPercentual =
        ((pesoFinalKg - inicio.pesoInicialKg) / inicio.pesoInicialKg) * 100;
    final balancoMl = totalIngeridoMl - (perdaAjustadaLitros * 1000).round();
    final recomendacaoBase = (taxaSudorese * 1000).round();
    final recomendacaoMin = (recomendacaoBase * 0.75).round();
    final recomendacaoMax = recomendacaoBase;

    return ResultadoHidratacao(
      perdaMassaAjustadaLitros: perdaAjustadaLitros,
      taxaSudoreseLitrosHora: taxaSudorese,
      variacaoMassaPercentual: variacaoPercentual,
      balancoHidricoMl: balancoMl,
      recomendacaoMinMlHora: recomendacaoMin,
      recomendacaoMaxMlHora: recomendacaoMax,
      alertaOperacional: _alertaOperacional(
        taxaSudorese: taxaSudorese,
        variacaoPercentual: variacaoPercentual,
        balancoMl: balancoMl,
      ),
    );
  }

  static String _alertaOperacional({
    required double taxaSudorese,
    required double variacaoPercentual,
    required int balancoMl,
  }) {
    if (taxaSudorese < 0.2) {
      return 'Medida possivelmente inconsistente';
    }
    if (variacaoPercentual <= -2) {
      return 'Risco de perda hidrica excessiva';
    }
    if (balancoMl > 1000 || variacaoPercentual > 0.5) {
      return 'Risco de superingestao';
    }
    return 'Dentro do alvo operacional';
  }
}

class ResultadoHidratacao {
  const ResultadoHidratacao({
    required this.perdaMassaAjustadaLitros,
    required this.taxaSudoreseLitrosHora,
    required this.variacaoMassaPercentual,
    required this.balancoHidricoMl,
    required this.recomendacaoMinMlHora,
    required this.recomendacaoMaxMlHora,
    required this.alertaOperacional,
  });

  final double perdaMassaAjustadaLitros;
  final double taxaSudoreseLitrosHora;
  final double variacaoMassaPercentual;
  final int balancoHidricoMl;
  final int recomendacaoMinMlHora;
  final int recomendacaoMaxMlHora;
  final String alertaOperacional;
}

abstract final class SessaoHidratacaoStore {
  static final List<SessaoFinalizada> sessoes = [];

  static void salvar(SessaoFinalizada sessao) {
    sessoes.add(sessao);
  }

  static SessaoFinalizada? get ultima {
    if (sessoes.isEmpty) return null;
    return sessoes.last;
  }
}
