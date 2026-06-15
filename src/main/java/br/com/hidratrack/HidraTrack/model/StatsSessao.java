package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "stats_sessao")
public class StatsSessao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "sessao_id", nullable = false)
    private SessaoTreino sessao;

    @Column(name = "taxa_sudorese_media", nullable = false)
    private Double taxaSudoreseMedia = 0.0; // Média em L/h

    private Double variacaoSudorese; // Em percentual

    private Double perdaLiquidoTotal; // Em L

    private Double perdaLiquidoAjustada; // Considerando reposição

    private Integer balancoTeorico; // Em mL

    private String deficitLevel = "NORMAL"; // NORMAL, ALERTA, CRITICO

    private Integer recomendacaoIntakeMin; // Em mL/h

    private Integer recomendacaoIntakeMax; // Em mL/h

    private Integer intervaloRecomendado; // Em minutos

    private Integer sodioRecomendado; // Em mg/L

    @Column(nullable = false)
    private LocalDateTime criadoEm = LocalDateTime.now();

    private LocalDateTime atualizadoEm = LocalDateTime.now();

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
