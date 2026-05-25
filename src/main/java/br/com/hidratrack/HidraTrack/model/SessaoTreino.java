package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "sessoes_treino")
public class SessaoTreino {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "atleta_id", nullable = false)
    private Usuario atleta;

    @Column(nullable = false)
    private LocalDateTime dataInicio;

    private LocalDateTime dataFim;

    private Integer durationMinutos;

    private Double temperaturaAmbiente;

    private Integer umidadeRelativa;

    @Enumerated(EnumType.STRING)
    private StatusSessao status = StatusSessao.EM_ANDAMENTO;

    @OneToMany(mappedBy = "sessao", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<MetricaSudorese> metricas;

    @OneToMany(mappedBy = "sessao", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<ConsumoAgua> consumos;

    @OneToOne(mappedBy = "sessao", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private StatsSessao stats;

    public enum StatusSessao {
        EM_ANDAMENTO,
        PAUSADA,
        CONCLUIDA,
        CANCELADA
    }

    // Getters e Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Usuario getAtleta() {
        return atleta;
    }

    public void setAtleta(Usuario atleta) {
        this.atleta = atleta;
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

    public StatusSessao getStatus() {
        return status;
    }

    public void setStatus(StatusSessao status) {
        this.status = status;
    }

    public List<MetricaSudorese> getMetricas() {
        return metricas;
    }

    public void setMetricas(List<MetricaSudorese> metricas) {
        this.metricas = metricas;
    }

    public List<ConsumoAgua> getConsumos() {
        return consumos;
    }

    public void setConsumos(List<ConsumoAgua> consumos) {
        this.consumos = consumos;
    }

    public StatsSessao getStats() {
        return stats;
    }

    public void setStats(StatsSessao stats) {
        this.stats = stats;
    }
}
