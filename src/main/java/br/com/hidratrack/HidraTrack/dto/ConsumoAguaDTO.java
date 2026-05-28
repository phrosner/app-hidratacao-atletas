package br.com.hidratrack.HidraTrack.dto;

import java.time.LocalDateTime;

public class ConsumoAguaDTO {
    private Long id;
    private Integer tempoDecorridoMinutos;
    private Integer quantidadeMl;
    private String tipoLiquido;
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

    public Integer getQuantidadeMl() {
        return quantidadeMl;
    }

    public void setQuantidadeMl(Integer quantidadeMl) {
        this.quantidadeMl = quantidadeMl;
    }

    public String getTipoLiquido() {
        return tipoLiquido;
    }

    public void setTipoLiquido(String tipoLiquido) {
        this.tipoLiquido = tipoLiquido;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
}
