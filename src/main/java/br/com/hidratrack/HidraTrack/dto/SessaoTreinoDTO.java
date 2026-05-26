package br.com.hidratrack.HidraTrack.dto;

import java.time.LocalDateTime;
import java.util.List;

public class SessaoTreinoDTO {
    private Long id;
    private Long atletaId;
    private LocalDateTime dataInicio;
    private LocalDateTime dataFim;
    private Integer durationMinutos;
    private Double temperaturaAmbiente;
    private Integer umidadeRelativa;
    private String status;
    private List<MetricaSudoroseDTO> metricas;
    private List<ConsumoAguaDTO> consumos;
    private StatsSessaoDTO stats;

    // Getters e Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getAtletaId() {
        return atletaId;
    }

    public void setAtletaId(Long atletaId) {
        this.atletaId = atletaId;
    }

    public LocalDateTime getDataInicio() {
        return dataInicio;
    }

    public void setDataInicio(LocalDateTime dataInicio) {
        this.dataInicio = dataInicio;
    }

    public LocalDateTime getDataFim() {
        return dataFim;
    }

    public void setDataFim(LocalDateTime dataFim) {
        this.dataFim = dataFim;
    }

    public Integer getDurationMinutos() {
        return durationMinutos;
    }

    public void setDurationMinutos(Integer durationMinutos) {
        this.durationMinutos = durationMinutos;
    }

    public Double getTemperaturaAmbiente() {
        return temperaturaAmbiente;
    }

    public void setTemperaturaAmbiente(Double temperaturaAmbiente) {
        this.temperaturaAmbiente = temperaturaAmbiente;
    }

    public Integer getUmidadeRelativa() {
        return umidadeRelativa;
    }

    public void setUmidadeRelativa(Integer umidadeRelativa) {
        this.umidadeRelativa = umidadeRelativa;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<MetricaSudoroseDTO> getMetricas() {
        return metricas;
    }

    public void setMetricas(List<MetricaSudoroseDTO> metricas) {
        this.metricas = metricas;
    }

    public List<ConsumoAguaDTO> getConsumos() {
        return consumos;
    }

    public void setConsumos(List<ConsumoAguaDTO> consumos) {
        this.consumos = consumos;
    }

    public StatsSessaoDTO getStats() {
        return stats;
    }

    public void setStats(StatsSessaoDTO stats) {
        this.stats = stats;
    }
}
