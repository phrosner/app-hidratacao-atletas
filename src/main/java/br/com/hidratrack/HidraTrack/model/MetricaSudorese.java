package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "metricas_sudorese")
public class MetricaSudorese {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "sessao_id", nullable = false)
    private SessaoTreino sessao;

    @Column(nullable = false)
    private Integer tempoDecorridoMinutos;

    @Column(nullable = false)
    private Double taxaSudorese; // Em L/h

    private Integer frequenciaCardiaca;

    private Double velocidadeMedia;

    private String intensidade; // BAIXA, MODERADA, ALTA

    private String observacoes;

    @Column(nullable = false)
    private LocalDateTime timestamp = LocalDateTime.now();

    // Getters e Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public SessaoTreino getSessao() {
        return sessao;
    }

    public void setSessao(SessaoTreino sessao) {
        this.sessao = sessao;
    }

    public Integer getTempoDecorridoMinutos() {
        return tempoDecorridoMinutos;
    }

    public void setTempoDecorridoMinutos(Integer tempoDecorridoMinutos) {
        this.tempoDecorridoMinutos = tempoDecorridoMinutos;
    }

    public Double getTaxaSudorese() {
        return taxaSudorese;
    }

    public void setTaxaSudorese(Double taxaSudorese) {
        this.taxaSudorese = taxaSudorese;
    }

    public Integer getFrequenciaCardiaca() {
        return frequenciaCardiaca;
    }

    public void setFrequenciaCardiaca(Integer frequenciaCardiaca) {
        this.frequenciaCardiaca = frequenciaCardiaca;
    }

    public Double getVelocidadeMedia() {
        return velocidadeMedia;
    }

    public void setVelocidadeMedia(Double velocidadeMedia) {
        this.velocidadeMedia = velocidadeMedia;
    }

    public String getIntensidade() {
        return intensidade;
    }

    public void setIntensidade(String intensidade) {
        this.intensidade = intensidade;
    }

    public String getObservacoes() {
        return observacoes;
    }

    public void setObservacoes(String observacoes) {
        this.observacoes = observacoes;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
}
