package br.com.hidratrack.HidraTrack.service;

import br.com.hidratrack.HidraTrack.dto.SessaoTreinoDTO;
import br.com.hidratrack.HidraTrack.dto.StatsSessaoDTO;
import br.com.hidratrack.HidraTrack.model.SessaoTreino;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.repository.SessaoTreinoRepository;
import br.com.hidratrack.HidraTrack.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class HidratacaoService {

    @Autowired
    private SessaoTreinoRepository sessaoTreinoRepository;

    @Autowired
    private SessaoTreinoService sessaoTreinoService;

    @Autowired
    private StatsService statsService;

    @Autowired
    private UsuarioRepository usuarioRepository;

    public int calcularPercentualHidratacao(Long atletaId) {
        List<SessaoTreino> sessoes = sessaoTreinoRepository.findByAtletaIdOrderByDataInicioDesc(atletaId);
        if (sessoes.isEmpty()) {
            return 100;
        }

        SessaoTreino ultima = sessoes.get(0);
        SessaoTreinoDTO sessaoDto = sessaoTreinoService.obterSessao(ultima.getId());
        if (sessaoDto == null) {
            return 100;
        }

        StatsSessaoDTO stats = sessaoDto.getStats();
        if (stats == null) {
            stats = statsService.obterStats(ultima.getId());
        }

        if (stats == null || stats.getRecomendacaoIntakeMax() == null || stats.getRecomendacaoIntakeMax() <= 0) {
            return 100;
        }

        if (sessaoDto.getConsumos() == null || sessaoDto.getConsumos().isEmpty()) {
            if ("CRITICO".equals(stats.getDeficitLevel())) {
                return 4;
            }
            if ("ALERTA".equals(stats.getDeficitLevel())) {
                return 55;
            }
            return 85;
        }

        double totalMl = sessaoDto.getConsumos().stream()
                .mapToDouble(c -> c.getQuantidadeMl() != null ? c.getQuantidadeMl() : 0.0)
                .sum();

        int percentual = (int) Math.round((totalMl / stats.getRecomendacaoIntakeMax()) * 100.0);
        return Math.max(0, Math.min(100, percentual));
    }

    public String calcularStatusAtleta(Long atletaId) {
        List<SessaoTreino> sessoes = sessaoTreinoRepository.findByAtletaIdOrderByDataInicioDesc(atletaId);

        Optional<SessaoTreino> sessaoAtiva = sessoes.stream()
                .filter(s -> s.getStatus() == SessaoTreino.StatusSessao.EM_ANDAMENTO
                        || s.getStatus() == SessaoTreino.StatusSessao.PAUSADA)
                .findFirst();

        if (sessaoAtiva.isPresent()) {
            return "EM TREINO";
        }

        int hidratacao = calcularPercentualHidratacao(atletaId);
        if (hidratacao < 50) {
            return "DESIDRATACAO CRITICA";
        }
        if (hidratacao < 70) {
            return "ATENCAO";
        }
        return "DESCANSO";
    }

    public Map<String, Object> resumoHidratacao(Long atletaId) {
        Map<String, Object> resumo = new HashMap<>();
        int percentual = calcularPercentualHidratacao(atletaId);
        resumo.put("hidratacao", percentual);
        resumo.put("status", calcularStatusAtleta(atletaId));
        return resumo;
    }

    public double mediaHidratacaoEquipe(List<Long> atletaIds) {
        if (atletaIds.isEmpty()) {
            return 0.0;
        }
        double soma = 0;
        for (Long atletaId : atletaIds) {
            soma += calcularPercentualHidratacao(atletaId);
        }
        return Math.round(soma / atletaIds.size());
    }

    public Map<String, Object> calcularHidratacaoSemanal(Long atletaId) {
        Map<String, Object> resultado = new HashMap<>();
        
        // Obter o atleta para pegar a meta diária
        Optional<Usuario> atletaOpt = usuarioRepository.findById(atletaId);
        if (atletaOpt.isEmpty()) {
            resultado.put("percentualSemanal", 0);
            resultado.put("aguaConsumidaSemana", 0.0);
            resultado.put("metaSemanal", 0.0);
            return resultado;
        }
        
        Usuario atleta = atletaOpt.get();
        
        // Extrair meta diária do campo metaDiaria (formato: "2L de água por dia" ou similar)
        String metaDiariaStr = atleta.getMetaDiaria();
        double metaDiaria = 2.0; // valor padrão
        
        if (metaDiariaStr != null && !metaDiariaStr.isBlank()) {
            // Tentar extrair número do formato "2L de água por dia" ou "2.5L"
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("([0-9]+(?:\\.[0-9]+)?)");
            java.util.regex.Matcher matcher = pattern.matcher(metaDiariaStr);
            if (matcher.find()) {
                metaDiaria = Double.parseDouble(matcher.group(1));
            }
        }
        
        // Calcular meta semanal
        double metaSemanal = metaDiaria * 7;
        
        // Calcular água consumida na última semana (7 dias)
        LocalDateTime dataInicioSemana = LocalDateTime.now().minusDays(7);
        List<SessaoTreino> sessoesSemana = sessaoTreinoRepository.findByAtletaIdAndDataInicioAfter(atletaId, dataInicioSemana);
        
        double aguaConsumidaSemana = 0.0;
        for (SessaoTreino sessao : sessoesSemana) {
            SessaoTreinoDTO sessaoDto = sessaoTreinoService.obterSessao(sessao.getId());
            if (sessaoDto != null && sessaoDto.getConsumos() != null) {
                double totalMl = sessaoDto.getConsumos().stream()
                        .mapToDouble(c -> c.getQuantidadeMl() != null ? c.getQuantidadeMl() : 0.0)
                        .sum();
                aguaConsumidaSemana += totalMl / 1000.0; // Converter para litros
            }
        }
        
        // Calcular percentual semanal
        double percentualSemanal = 0.0;
        if (metaSemanal > 0) {
            percentualSemanal = (aguaConsumidaSemana / metaSemanal) * 100.0;
        }
        
        resultado.put("percentualSemanal", Math.round(percentualSemanal));
        resultado.put("aguaConsumidaSemana", Math.round(aguaConsumidaSemana * 100.0) / 100.0);
        resultado.put("metaSemanal", Math.round(metaSemanal * 100.0) / 100.0);
        
        return resultado;
    }
}
