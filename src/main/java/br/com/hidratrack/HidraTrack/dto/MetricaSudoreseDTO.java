package br.com.hidratrack.HidraTrack.dto;

import java.time.LocalDateTime;

public class MetricaSudoreseDTO {
    private Long id;
    private Integer tempoDecorridoMinutos;
    private Double taxaSudorese;
    private Integer frequenciaCardiaca;
    private Double velocidadeMedia;
    private String intensidade;
    private String observacoes;
    private LocalDateTime timestamp;

    // Getters e Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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
