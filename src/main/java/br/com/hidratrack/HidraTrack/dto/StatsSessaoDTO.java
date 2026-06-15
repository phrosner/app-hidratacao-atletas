package br.com.hidratrack.HidraTrack.dto;

import java.time.LocalDateTime;

public class StatsSessaoDTO {
    private Long id;
    private Long sessaoId;
    private Double taxaSudoreseMedia;
    private Double variacaoSudorese;
    private Double perdaLiquidoTotal;
    private Double perdaLiquidoAjustada;
    private Integer balancoTeorico;
    private String deficitLevel;
    private Integer recomendacaoIntakeMin;
    private Integer recomendacaoIntakeMax;
    private Integer intervaloRecomendado;
    private Integer sodioRecomendado;
    private LocalDateTime criadoEm;
    private LocalDateTime atualizadoEm;

    // Getters e Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getSessaoId() {
        return sessaoId;
    }

    public void setSessaoId(Long sessaoId) {
        this.sessaoId = sessaoId;
    }

    public Double getTaxaSudoreseMedia() {
        return taxaSudoreseMedia;
    }

    public void setTaxaSudoreseMedia(Double taxaSudoreseMedia) {
        this.taxaSudoreseMedia = taxaSudoreseMedia;
    }

    public Double getVariacaoSudorese() {
        return variacaoSudorese;
    }

    public void setVariacaoSudorese(Double variacaoSudorese) {
        this.variacaoSudorese = variacaoSudorese;
    }

    public Double getPerdaLiquidoTotal() {
        return perdaLiquidoTotal;
    }

    public void setPerdaLiquidoTotal(Double perdaLiquidoTotal) {
        this.perdaLiquidoTotal = perdaLiquidoTotal;
    }

    public Double getPerdaLiquidoAjustada() {
        return perdaLiquidoAjustada;
    }

    public void setPerdaLiquidoAjustada(Double perdaLiquidoAjustada) {
        this.perdaLiquidoAjustada = perdaLiquidoAjustada;
    }

    public Integer getBalancoTeorico() {
        return balancoTeorico;
    }

    public void setBalancoTeorico(Integer balancoTeorico) {
        this.balancoTeorico = balancoTeorico;
    }

    public String getDeficitLevel() {
        return deficitLevel;
    }

    public void setDeficitLevel(String deficitLevel) {
        this.deficitLevel = deficitLevel;
    }

    public Integer getRecomendacaoIntakeMin() {
        return recomendacaoIntakeMin;
    }

    public void setRecomendacaoIntakeMin(Integer recomendacaoIntakeMin) {
        this.recomendacaoIntakeMin = recomendacaoIntakeMin;
    }

    public Integer getRecomendacaoIntakeMax() {
        return recomendacaoIntakeMax;
    }

    public void setRecomendacaoIntakeMax(Integer recomendacaoIntakeMax) {
        this.recomendacaoIntakeMax = recomendacaoIntakeMax;
    }

    public Integer getIntervaloRecomendado() {
        return intervaloRecomendado;
    }

    public void setIntervaloRecomendado(Integer intervaloRecomendado) {
        this.intervaloRecomendado = intervaloRecomendado;
    }

    public Integer getSodioRecomendado() {
        return sodioRecomendado;
    }

    public void setSodioRecomendado(Integer sodioRecomendado) {
        this.sodioRecomendado = sodioRecomendado;
    }

    public LocalDateTime getCriadoEm() {
        return criadoEm;
    }

    public void setCriadoEm(LocalDateTime criadoEm) {
        this.criadoEm = criadoEm;
    }

    public LocalDateTime getAtualizadoEm() {
        return atualizadoEm;
    }

    public void setAtualizadoEm(LocalDateTime atualizadoEm) {
        this.atualizadoEm = atualizadoEm;
    }
}
