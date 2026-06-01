package br.com.hidratrack.HidraTrack.service;

import br.com.hidratrack.HidraTrack.dto.StatsSessaoDTO;
import br.com.hidratrack.HidraTrack.model.MetricaSudorese;
import br.com.hidratrack.HidraTrack.model.SessaoTreino;
import br.com.hidratrack.HidraTrack.model.StatsSessao;
import br.com.hidratrack.HidraTrack.model.ConsumoAgua;
import br.com.hidratrack.HidraTrack.repository.MetricaSudoroseRepository;
import br.com.hidratrack.HidraTrack.repository.StatsSessaoRepository;
import br.com.hidratrack.HidraTrack.repository.ConsumoAguaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

/**
 * Service responsável por calcular todas as estatísticas e métricas de uma sessão de treino.
 * Implementa as fórmulas biomédicas para hidratação em atletismo.
 */
@Service
public class StatsService {

    @Autowired
    private MetricaSudoroseRepository metricaSudoroseRepository;

    @Autowired
    private StatsSessaoRepository statsSessaoRepository;

    @Autowired
    private ConsumoAguaRepository consumoAguaRepository;

    /**
     * Calcula todas as estatísticas de uma sessão de treino.
     * 
     * Fórmulas utilizadas:
     * 1. Taxa média de sudorese = Média aritmética das taxas registradas
     * 2. Variação = ((Taxa final - Taxa inicial) / Taxa inicial) * 100
     * 3. Perda total = Taxa de sudorese média * duração em horas
     * 4. Perda ajustada = Perda total - Consumo de água durante sessão
     * 5. Balanço teórico = (Consumo - Perda) * 1000 (em mL)
     * 6. Recomendação de intake = Taxa de sudorese média * 1000 (com margem de ±100)
     */
    public StatsSessaoDTO calcularStatsSessionao(SessaoTreino sessao) {
        List<MetricaSudorese> metricas = metricaSudoroseRepository.findBySessaoIdOrderByTempoDecorridoMinutos(sessao.getId());
        List<ConsumoAgua> consumos = consumoAguaRepository.findBySessaoIdOrderByTempoDecorridoMinutos(sessao.getId());

        if (metricas.isEmpty()) {
            throw new IllegalArgumentException("Sessão sem métricas de sudorese");
        }

        // 1. Calcular taxa média de sudorese
        double taxaMedia = metricas.stream()
                .mapToDouble(MetricaSudorese::getTaxaSudorese)
                .average()
                .orElse(0.0);

        // 2. Calcular variação de sudorese
        double variacaoSudorese = calcularVariacao(metricas);

        // 3. Calcular perda total de líquido
        int durationMinutos = sessao.getDurationMinutos() != null ? sessao.getDurationMinutos() : 90;
        double durationHoras = durationMinutos / 60.0;
        double perdaTotal = taxaMedia * durationHoras;

        // 4. Calcular consumo total de água
        double consumoTotal = consumos.stream()
                .mapToInt(ConsumoAgua::getQuantidadeMl)
                .sum() / 1000.0; // Converter para litros

        // 5. Calcular perda ajustada
        double perdaAjustada = perdaTotal - consumoTotal;

        // 6. Calcular balanço teórico
        int balancoTeorico = (int) ((consumoTotal - perdaTotal) * 1000);

        // 7. Determinar nível de deficit
        String deficitLevel = determinarDeficitLevel(balancoTeorico);

        // 8. Calcular recomendações de intake
        int intakeMin = (int) (taxaMedia * 1000 - 100);
        int intakeMax = (int) (taxaMedia * 1000 + 250);

        // 9. Recomendação de intervalo e sódio
        int intervaloRecomendado = determinarIntervalo(metricas);
        int sodioRecomendado = 500; // mg/L padrão

        // Criar e salvar entity
        StatsSessao stats = new StatsSessao();
        stats.setSessao(sessao);
        stats.setTaxaSudoroseMedia(Math.round(taxaMedia * 100.0) / 100.0);
        stats.setVariacaoSudorese(Math.round(variacaoSudorese * 100.0) / 100.0);
        stats.setPerdaLiquidoTotal(Math.round(perdaTotal * 100.0) / 100.0);
        stats.setPerdaLiquidoAjustada(Math.round(perdaAjustada * 100.0) / 100.0);
        stats.setBalancoTeorico(balancoTeorico);
        stats.setDeficitLevel(deficitLevel);
        stats.setRecomendacaoIntakeMin(intakeMin);
        stats.setRecomendacaoIntakeMax(intakeMax);
        stats.setIntervaloRecomendado(intervaloRecomendado);
        stats.setSodioRecomendado(sodioRecomendado);

        StatsSessao saved = statsSessaoRepository.save(stats);

        return convertToDTO(saved);
    }

    /**
     * Calcula a variação percentual de sudorese entre o início e fim da sessão.
     */
    private double calcularVariacao(List<MetricaSudorese> metricas) {
        if (metricas.size() < 2) {
            return 0.0;
        }
        double taxaInicial = metricas.get(0).getTaxaSudorese();
        double taxaFinal = metricas.get(metricas.size() - 1).getTaxaSudorese();

        if (taxaInicial == 0) {
            return 0.0;
        }

        return ((taxaFinal - taxaInicial) / taxaInicial) * 100;
    }

    /**
     * Determina o nível de deficit baseado no balanço teórico.
     */
    private String determinarDeficitLevel(int balancoTeorico) {
        if (balancoTeorico < -500) {
            return "CRITICO";
        } else if (balancoTeorico < -200) {
            return "ALERTA";
        } else {
            return "NORMAL";
        }
    }

    /**
     * Determina o intervalo recomendado baseado na intensidade.
     */
    private int determinarIntervalo(List<MetricaSudorese> metricas) {
        // Verificar intensidade predominante
        long altasIntensidades = metricas.stream()
                .filter(m -> "ALTA".equals(m.getIntensidade()))
                .count();

        if (altasIntensidades > metricas.size() / 2) {
            return 15; // Exercício de alta intensidade: intervalos de 15 minutos
        }
        return 20; // Exercício moderado: intervalos de 20 minutos
    }

    /**
     * Obtém as estatísticas de uma sessão pelo ID.
     */
    public StatsSessaoDTO obterStats(Long sessaoId) {
        Optional<StatsSessao> stats = statsSessaoRepository.findBySessaoId(sessaoId);
        return stats.map(this::convertToDTO).orElse(null);
    }

    /**
     * Atualiza os valores de StatsSessao para uma sessão existente.
     * Retorna o DTO atualizado ou lança exceção se não existir.
     */
    public StatsSessaoDTO atualizarStats(Long sessaoId, StatsSessaoDTO dto) {
        Optional<StatsSessao> opt = statsSessaoRepository.findBySessaoId(sessaoId);
        if (opt.isEmpty()) {
            throw new IllegalArgumentException("Stats não encontrado para a sessão: " + sessaoId);
        }

        StatsSessao stats = opt.get();

        if (dto.getTaxaSudoroseMedia() != null) stats.setTaxaSudoroseMedia(dto.getTaxaSudoroseMedia());
        if (dto.getVariacaoSudorese() != null) stats.setVariacaoSudorese(dto.getVariacaoSudorese());
        if (dto.getPerdaLiquidoTotal() != null) stats.setPerdaLiquidoTotal(dto.getPerdaLiquidoTotal());
        if (dto.getPerdaLiquidoAjustada() != null) stats.setPerdaLiquidoAjustada(dto.getPerdaLiquidoAjustada());
        if (dto.getBalancoTeorico() != null) stats.setBalancoTeorico(dto.getBalancoTeorico());
        if (dto.getDeficitLevel() != null) stats.setDeficitLevel(dto.getDeficitLevel());
        if (dto.getRecomendacaoIntakeMin() != null) stats.setRecomendacaoIntakeMin(dto.getRecomendacaoIntakeMin());
        if (dto.getRecomendacaoIntakeMax() != null) stats.setRecomendacaoIntakeMax(dto.getRecomendacaoIntakeMax());
        if (dto.getIntervaloRecomendado() != null) stats.setIntervaloRecomendado(dto.getIntervaloRecomendado());
        if (dto.getSodioRecomendado() != null) stats.setSodioRecomendado(dto.getSodioRecomendado());

        stats.setAtualizadoEm(java.time.LocalDateTime.now());

        StatsSessao saved = statsSessaoRepository.save(stats);
        return convertToDTO(saved);
    }

    /**
     * Converte uma entidade StatsSessao em DTO.
     */
    private StatsSessaoDTO convertToDTO(StatsSessao stats) {
        StatsSessaoDTO dto = new StatsSessaoDTO();
        dto.setId(stats.getId());
        dto.setSessaoId(stats.getSessao().getId());
        dto.setTaxaSudoroseMedia(stats.getTaxaSudoroseMedia());
        dto.setVariacaoSudorese(stats.getVariacaoSudorese());
        dto.setPerdaLiquidoTotal(stats.getPerdaLiquidoTotal());
        dto.setPerdaLiquidoAjustada(stats.getPerdaLiquidoAjustada());
        dto.setBalancoTeorico(stats.getBalancoTeorico());
        dto.setDeficitLevel(stats.getDeficitLevel());
        dto.setRecomendacaoIntakeMin(stats.getRecomendacaoIntakeMin());
        dto.setRecomendacaoIntakeMax(stats.getRecomendacaoIntakeMax());
        dto.setIntervaloRecomendado(stats.getIntervaloRecomendado());
        dto.setSodioRecomendado(stats.getSodioRecomendado());
        dto.setCriadoEm(stats.getCriadoEm());
        dto.setAtualizadoEm(stats.getAtualizadoEm());
        return dto;
    }
}
