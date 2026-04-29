package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Perfil de contexto que agrega dados históricos por modalidade e condições similares
 * Permite personalização e aprendizado para sessões futuras
 */
@Entity
@Table(name = "perfis_contexto")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PerfilContexto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Atleta é obrigatório")
    @ManyToOne
    @JoinColumn(name = "atleta_id", nullable = false)
    private Atleta atleta;

    @Column(length = 100)
    private String modalidade;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_clima", length = 30)
    private TipoClima tipoClima;

    @Column(name = "duracao_tipica_minutos")
    private Integer duracaoTipicaMinutos;

    @Column(name = "intensidade_tipica")
    private Integer intensidadeTipica; // Escala 1-10

    @Column(name = "numero_sessoes")
    private Integer numeroSessoes = 0;

    @Column(name = "taxa_sudorese_media_l_h", precision = 5, scale = 3)
    private BigDecimal taxaSudoreseMediaLitroPorHora;

    @Column(name = "taxa_sudorese_desvio_padrao", precision = 5, scale = 3)
    private BigDecimal taxaSudoreseDesvioPadrao;

    @Column(name = "taxa_sudorese_minima_l_h", precision = 5, scale = 3)
    private BigDecimal taxaSudoreseMinimaLitroPorHora;

    @Column(name = "taxa_sudorese_maxima_l_h", precision = 5, scale = 3)
    private BigDecimal taxaSudoreseMaximaLitroPorHora;

    @Column(name = "ingestao_media_ml_h")
    private Integer ingestaoMediaMlPorHora;

    @Column(name = "perda_massa_media_percentual", precision = 5, scale = 2)
    private BigDecimal perdaMassaMediaPercentual;

    @Column(name = "estrategia_testada", columnDefinition = "TEXT")
    private String estrategiaTestada;

    @Enumerated(EnumType.STRING)
    @Column(name = "tolerancia_media", length = 20)
    private DadosPosSessao.ToleranciaPlano toleranciaMedia;

    @CreationTimestamp
    @Column(name = "data_criacao", nullable = false, updatable = false)
    private LocalDateTime dataCriacao;

    @UpdateTimestamp
    @Column(name = "data_atualizacao")
    private LocalDateTime dataAtualizacao;

    @Column(columnDefinition = "TEXT")
    private String observacoes;

    public enum TipoClima {
        MUITO_FRIO,      // < 10°C
        FRIO,            // 10-18°C
        AMENO,           // 18-25°C
        QUENTE,          // 25-32°C
        MUITO_QUENTE,    // > 32°C
        UMIDO,           // Alta umidade (>70%)
        SECO             // Baixa umidade (<30%)
    }
}
