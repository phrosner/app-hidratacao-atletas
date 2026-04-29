package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * Recomendações individualizadas geradas após análise da sessão
 * Múltiplas recomendações podem ser geradas por sessão
 */
@Entity
@Table(name = "recomendacoes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Recomendacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Sessão é obrigatória")
    @ManyToOne
    @JoinColumn(name = "sessao_id", nullable = false)
    private Sessao sessao;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private TipoRecomendacao tipo;

    @Column(name = "faixa_alvo_ingestao_ml_h")
    private Integer faixaAlvoIngestaoMlPorHora;

    @Column(name = "volume_minimo_ml_h")
    private Integer volumeMinimoMlPorHora;

    @Column(name = "volume_maximo_ml_h")
    private Integer volumeMaximoMlPorHora;

    @Column(name = "intervalo_fracionamento_minutos")
    private Integer intervaloFracionamentoMinutos;

    @Column(name = "volume_por_intervalo_ml")
    private Integer volumePorIntervaloMl;

    @Enumerated(EnumType.STRING)
    @Column(name = "nivel_alerta", length = 20)
    private NivelAlerta nivelAlerta;

    @Column(name = "mensagem_alerta", columnDefinition = "TEXT")
    private String mensagemAlerta;

    @Column(columnDefinition = "TEXT")
    private String descricao;

    @Column(name = "recomendacao_eletroliticos", columnDefinition = "TEXT")
    private String recomendacaoEletroliticos;

    @Column(name = "foi_aplicada")
    private Boolean foiAplicada = false;

    @Column(name = "data_aplicacao")
    private LocalDateTime dataAplicacao;

    @CreationTimestamp
    @Column(name = "data_criacao", nullable = false, updatable = false)
    private LocalDateTime dataCriacao;

    @Column(columnDefinition = "TEXT")
    private String observacoes;

    public enum TipoRecomendacao {
        HIDRATACAO_GERAL,
        AJUSTE_VOLUME,
        FRACIONAMENTO,
        ELETROLITICOS,
        ALERTA_DESIDRATACAO,
        ALERTA_SUPERINGESTAO,
        ALERTA_HIPONATREMIA,
        ESTRATEGIA_PERSONALIZAD
    }

    public enum NivelAlerta {
        INFORMATIVO,    // Apenas informação
        ATENCAO,        // Requer atenção
        CUIDADO,        // Situação de risco moderado
        URGENTE,        // Situação de risco alto
        CRITICO         // Requer intervenção imediata
    }
}
