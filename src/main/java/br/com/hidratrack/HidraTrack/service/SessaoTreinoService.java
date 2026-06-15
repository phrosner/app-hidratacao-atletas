package br.com.hidratrack.HidraTrack.service;

import br.com.hidratrack.HidraTrack.dto.SessaoTreinoDTO;
import br.com.hidratrack.HidraTrack.dto.MetricaSudoreseDTO;
import br.com.hidratrack.HidraTrack.dto.ConsumoAguaDTO;
import br.com.hidratrack.HidraTrack.dto.StatsSessaoDTO;
import br.com.hidratrack.HidraTrack.model.SessaoTreino;
import br.com.hidratrack.HidraTrack.model.MetricaSudorese;
import br.com.hidratrack.HidraTrack.model.ConsumoAgua;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.repository.SessaoTreinoRepository;
import br.com.hidratrack.HidraTrack.repository.MetricaSudoreseRepository;
import br.com.hidratrack.HidraTrack.repository.ConsumoAguaRepository;
import br.com.hidratrack.HidraTrack.repository.StatsSessaoRepository;
import br.com.hidratrack.HidraTrack.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class SessaoTreinoService {

    @Autowired
    private SessaoTreinoRepository sessaoRepository;

    @Autowired
    private MetricaSudoreseRepository metricaRepository;

    @Autowired
    private ConsumoAguaRepository consumoRepository;

    @Autowired
    private StatsSessaoRepository statsSessaoRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private StatsService statsService;

    /**
     * Cria uma nova sessão de treino.
     */
    public SessaoTreinoDTO criarSessao(SessaoTreinoDTO dto) {
        Optional<Usuario> atleta = usuarioRepository.findById(dto.getAtletaId());
        if (atleta.isEmpty()) {
            throw new IllegalArgumentException("Atleta não encontrado");
        }

        SessaoTreino sessao = new SessaoTreino();
        sessao.setAtleta(atleta.get());
        sessao.setDataInicio(dto.getDataInicio() != null ? dto.getDataInicio() : LocalDateTime.now());
        sessao.setTemperaturaAmbiente(dto.getTemperaturaAmbiente());
        sessao.setUmidadeRelativa(dto.getUmidadeRelativa());
        sessao.setStatus(SessaoTreino.StatusSessao.EM_ANDAMENTO);

        SessaoTreino saved = sessaoRepository.save(sessao);
        return convertToDTO(saved);
    }

    /**
     * Finaliza uma sessão de treino e calcula as estatísticas.
     */
    public SessaoTreinoDTO finalizarSessao(Long sessaoId, Integer durationMinutos) {
        Optional<SessaoTreino> sessaoOpt = sessaoRepository.findById(sessaoId);
        if (sessaoOpt.isEmpty()) {
            throw new IllegalArgumentException("Sessão não encontrada");
        }

        SessaoTreino sessao = sessaoOpt.get();
        sessao.setDataFim(LocalDateTime.now());
        sessao.setDurationMinutos(durationMinutos);
        sessao.setStatus(SessaoTreino.StatusSessao.CONCLUIDA);

        if (durationMinutos == null || durationMinutos <= 0) {
            durationMinutos = (int) Math.max(0,
                    Duration.between(sessao.getDataInicio(), sessao.getDataFim()).toMinutes());
        }
        sessao.setDurationMinutos(durationMinutos);

        SessaoTreino updated = sessaoRepository.save(sessao);

        // Calcular estatísticas
        try {
            statsService.calcularStatsSessionao(updated);
            statsSessaoRepository.findBySessaoId(updated.getId()).ifPresent(updated::setStats);
        } catch (Exception e) {
            // Log erro mas não falha a atualização
            System.err.println("Erro ao calcular stats: " + e.getMessage());
        }

        return convertToDTO(updated);
    }

    /**
     * Registra uma métrica de sudorese para uma sessão.
     */
    public void registrarMetrica(Long sessaoId, MetricaSudoreseDTO dto) {
        Optional<SessaoTreino> sessaoOpt = sessaoRepository.findById(sessaoId);
        if (sessaoOpt.isEmpty()) {
            throw new IllegalArgumentException("Sessão não encontrada");
        }

        MetricaSudorese metrica = new MetricaSudorese();
        metrica.setSessao(sessaoOpt.get());
        metrica.setTempoDecorridoMinutos(dto.getTempoDecorridoMinutos());
        metrica.setTaxaSudorese(dto.getTaxaSudorese());
        metrica.setFrequenciaCardiaca(dto.getFrequenciaCardiaca());
        metrica.setVelocidadeMedia(dto.getVelocidadeMedia());
        metrica.setIntensidade(dto.getIntensidade());
        metrica.setObservacoes(dto.getObservacoes());

        metricaRepository.save(metrica);

        if (sessaoOpt.get().getStatus() == SessaoTreino.StatusSessao.CONCLUIDA) {
            try {
                statsService.calcularStatsSessionao(sessaoOpt.get());
                statsSessaoRepository.findBySessaoId(sessaoOpt.get().getId())
                        .ifPresent(sessaoOpt.get()::setStats);
            } catch (Exception e) {
                System.err.println("Erro ao recalcular stats após métrica registrada: " + e.getMessage());
            }
        }
    }

    /**
     * Registra consumo de água durante uma sessão.
     */
    public void registrarConsumo(Long sessaoId, ConsumoAguaDTO dto) {
        Optional<SessaoTreino> sessaoOpt = sessaoRepository.findById(sessaoId);
        if (sessaoOpt.isEmpty()) {
            throw new IllegalArgumentException("Sessão não encontrada");
        }

        ConsumoAgua consumo = new ConsumoAgua();
        consumo.setSessao(sessaoOpt.get());
        consumo.setTempoDecorridoMinutos(dto.getTempoDecorridoMinutos());
        consumo.setQuantidadeMl(dto.getQuantidadeMl());
        consumo.setTipoLiquido(dto.getTipoLiquido());

        consumoRepository.save(consumo);

        if (sessaoOpt.get().getStatus() == SessaoTreino.StatusSessao.CONCLUIDA) {
            try {
                statsService.calcularStatsSessionao(sessaoOpt.get());
                statsSessaoRepository.findBySessaoId(sessaoOpt.get().getId())
                        .ifPresent(sessaoOpt.get()::setStats);
            } catch (Exception e) {
                System.err.println("Erro ao recalcular stats após consumo registrado: " + e.getMessage());
            }
        }
    }

    /**
     * Obtém as últimas sessões de um atleta.
     */
    public List<SessaoTreinoDTO> obterSessoesAtleta(Long atletaId) {
        return sessaoRepository.findByAtletaIdOrderByDataInicioDesc(atletaId)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<SessaoTreinoDTO> obterHistoricoPorAtleta(Long atletaId, Integer dias) {
        final LocalDateTime limite = dias != null && dias > 0
                ? LocalDateTime.now().minusDays(dias)
                : null;

        return sessaoRepository.findByAtletaIdOrderByDataInicioDesc(atletaId)
                .stream()
                .filter(sessao -> limite == null || !sessao.getDataInicio().isBefore(limite))
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Obtém detalhes de uma sessão específica.
     */
    public SessaoTreinoDTO obterSessao(Long sessaoId) {
        Optional<SessaoTreino> sessaoOpt = sessaoRepository.findById(sessaoId);
        return sessaoOpt.map(this::convertToDTO).orElse(null);
    }

    /**
     * Converte uma entidade SessaoTreino em DTO.
     */
    private SessaoTreinoDTO convertToDTO(SessaoTreino sessao) {
        SessaoTreinoDTO dto = new SessaoTreinoDTO();
        dto.setId(sessao.getId());
        dto.setAtletaId(sessao.getAtleta().getId());
        dto.setDataInicio(sessao.getDataInicio());
        dto.setDataFim(sessao.getDataFim());
        dto.setDurationMinutos(sessao.getDurationMinutos());
        dto.setTemperaturaAmbiente(sessao.getTemperaturaAmbiente());
        dto.setUmidadeRelativa(sessao.getUmidadeRelativa());
        dto.setStatus(sessao.getStatus().toString());

        // Converter métricas explicitamente via repositório para evitar problemas de lazy loading
        List<MetricaSudorese> metricas = metricaRepository.findBySessaoIdOrderByTempoDecorridoMinutos(sessao.getId());
        if (!metricas.isEmpty()) {
            dto.setMetricas(metricas.stream()
                    .map(this::convertMetricaToDTO)
                    .collect(Collectors.toList()));
        }

        // Converter consumos explicitamente via repositório para evitar problemas de lazy loading
        List<ConsumoAgua> consumos = consumoRepository.findBySessaoIdOrderByTempoDecorridoMinutos(sessao.getId());
        if (!consumos.isEmpty()) {
            dto.setConsumos(consumos.stream()
                    .map(this::convertConsumoToDTO)
                    .collect(Collectors.toList()));
        }

        // Converter stats explicitamente via repositório
        statsSessaoRepository.findBySessaoId(sessao.getId())
                .ifPresent(stats -> dto.setStats(convertStatsToDTO(stats)));

        return dto;
    }

    private MetricaSudoreseDTO convertMetricaToDTO(MetricaSudorese metrica) {
        MetricaSudoreseDTO dto = new MetricaSudoreseDTO();
        dto.setId(metrica.getId());
        dto.setTempoDecorridoMinutos(metrica.getTempoDecorridoMinutos());
        dto.setTaxaSudorese(metrica.getTaxaSudorese());
        dto.setFrequenciaCardiaca(metrica.getFrequenciaCardiaca());
        dto.setVelocidadeMedia(metrica.getVelocidadeMedia());
        dto.setIntensidade(metrica.getIntensidade());
        dto.setObservacoes(metrica.getObservacoes());
        dto.setTimestamp(metrica.getTimestamp());
        return dto;
    }

    private ConsumoAguaDTO convertConsumoToDTO(ConsumoAgua consumo) {
        ConsumoAguaDTO dto = new ConsumoAguaDTO();
        dto.setId(consumo.getId());
        dto.setTempoDecorridoMinutos(consumo.getTempoDecorridoMinutos());
        dto.setQuantidadeMl(consumo.getQuantidadeMl());
        dto.setTipoLiquido(consumo.getTipoLiquido());
        dto.setTimestamp(consumo.getTimestamp());
        return dto;
    }

    private StatsSessaoDTO convertStatsToDTO(br.com.hidratrack.HidraTrack.model.StatsSessao stats) {
        StatsSessaoDTO dto = new StatsSessaoDTO();
        dto.setId(stats.getId());
        dto.setSessaoId(stats.getSessao().getId());
        dto.setTaxaSudoreseMedia(stats.getTaxaSudoreseMedia());
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

    private br.com.hidratrack.HidraTrack.model.StatsSessao convertDTOToStats(StatsSessaoDTO dto, SessaoTreino sessao) {
        br.com.hidratrack.HidraTrack.model.StatsSessao stats = new br.com.hidratrack.HidraTrack.model.StatsSessao();
        stats.setSessao(sessao);
        stats.setTaxaSudoreseMedia(dto.getTaxaSudoreseMedia());
        stats.setVariacaoSudorese(dto.getVariacaoSudorese());
        stats.setPerdaLiquidoTotal(dto.getPerdaLiquidoTotal());
        stats.setPerdaLiquidoAjustada(dto.getPerdaLiquidoAjustada());
        stats.setBalancoTeorico(dto.getBalancoTeorico());
        stats.setDeficitLevel(dto.getDeficitLevel());
        stats.setRecomendacaoIntakeMin(dto.getRecomendacaoIntakeMin());
        stats.setRecomendacaoIntakeMax(dto.getRecomendacaoIntakeMax());
        stats.setIntervaloRecomendado(dto.getIntervaloRecomendado());
        stats.setSodioRecomendado(dto.getSodioRecomendado());
        return stats;
    }
}
