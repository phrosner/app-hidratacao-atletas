package br.com.hidratrack.HidraTrack.service;

import br.com.hidratrack.HidraTrack.dto.SessaoTreinoDTO;
import br.com.hidratrack.HidraTrack.dto.StatsSessaoDTO;
import br.com.hidratrack.HidraTrack.model.SessaoTreino;
import br.com.hidratrack.HidraTrack.repository.SessaoTreinoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
}
