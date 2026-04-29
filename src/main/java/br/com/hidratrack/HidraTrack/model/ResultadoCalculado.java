package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Resultados calculados automaticamente após a sessão
 * Inclui taxa de sudorese, balanço hídrico e indicadores
 */
@Entity
@Table(name = "resultados_calculados")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ResultadoCalculado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Sessão é obrigatória")
    @OneToOne
    @JoinColumn(name = "sessao_id", nullable = false, unique = true)
    private Sessao sessao;

    @Column(name = "perda_massa_corporal_kg", precision = 5, scale = 3)
    private BigDecimal perdaMassaCorporalKg;

    @Column(name = "perda_massa_ajustada_kg", precision = 5, scale = 3)
    private BigDecimal perdaMassaAjustadaKg;

    @Column(name = "taxa_sudorese_l_h", precision = 5, scale = 3)
    private BigDecimal taxaSudoreseLitroPorHora;

    @Column(name = "percentual_variacao_massa", precision = 5, scale = 2)
    private BigDecimal percentualVariacaoMassa;

    @Column(name = "total_ingestao_ml")
    private Integer totalIngestaoMl;

    @Column(name = "total_eliminacao_ml")
    private Integer totalEliminacaoMl;

    @Column(name = "balanco_hidrico_ml")
    private Integer balancoHidricoMl;

    @Column(name = "deficit_hidrico_ml")
    private Integer deficitHidricoMl;

    @Enumerated(EnumType.STRING)
    @Column(name = "status_hidratacao", length = 30)
    private StatusHidratacao statusHidratacao;

    @Column(name = "dados_inconsistentes")
    private Boolean dadosInconsistentes = false;

    @Column(name = "motivo_inconsistencia", columnDefinition = "TEXT")
    private String motivoInconsistencia;

    @CreationTimestamp
    @Column(name = "data_calculo", nullable = false, updatable = false)
    private LocalDateTime dataCalculo;

    @Column(columnDefinition = "TEXT")
    private String observacoes;

    public enum StatusHidratacao {
        BEM_HIDRATADO,              // < 1% perda de massa
        LEVEMENTE_DESIDRATADO,      // 1-2% perda de massa
        MODERADAMENTE_DESIDRATADO,  // 2-3% perda de massa
        DESIDRATADO,                // 3-5% perda de massa
        SEVERAMENTE_DESIDRATADO,    // > 5% perda de massa
        HIPERIDRATADO,              // Ganho de massa
        INCONSISTENTE               // Dados implausíveis
    }
}
