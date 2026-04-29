package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Registro de ingestão de fluidos durante a sessão
 * Múltiplos eventos por sessão
 */
@Entity
@Table(name = "ingestoes_fluido")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class IngestaoFluido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Sessão é obrigatória")
    @ManyToOne
    @JoinColumn(name = "sessao_id", nullable = false)
    private Sessao sessao;

    @NotNull(message = "Data/hora da ingestão é obrigatória")
    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;

    @NotNull(message = "Volume é obrigatório")
    @Positive(message = "Volume deve ser positivo")
    @Column(name = "volume_ml", nullable = false)
    private Integer volumeMl;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_bebida", length = 50)
    private TipoBebida tipoBebida;

    @Column(length = 100)
    private String descricao;

    @Column(name = "contem_eletroliticos")
    private Boolean contemEletroliticos = false;

    @Column(name = "contem_carboidratos")
    private Boolean contemCarboidratos = false;

    @Column(columnDefinition = "TEXT")
    private String observacoes;

    public enum TipoBebida {
        AGUA,
        ISOTONICA,
        HIPOTONICA,
        HIPERTONICA,
        SUCO,
        REFRIGERANTE,
        BEBIDA_ESPORTIVA,
        OUTRO
    }
}
