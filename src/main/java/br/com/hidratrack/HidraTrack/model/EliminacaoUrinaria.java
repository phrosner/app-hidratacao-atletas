package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Registro de eliminação urinária durante a sessão
 * Múltiplos eventos por sessão (quando aplicável)
 */
@Entity
@Table(name = "eliminacoes_urinarias")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class EliminacaoUrinaria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Sessão é obrigatória")
    @ManyToOne
    @JoinColumn(name = "sessao_id", nullable = false)
    private Sessao sessao;

    @NotNull(message = "Data/hora da eliminação é obrigatória")
    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;

    @NotNull(message = "Volume é obrigatório")
    @Positive(message = "Volume deve ser positivo")
    @Column(name = "volume_ml", nullable = false)
    private Integer volumeMl;

    @Enumerated(EnumType.STRING)
    @Column(name = "cor_urina", length = 20)
    private DadosPreSessao.CorUrina corUrina;

    @Column(columnDefinition = "TEXT")
    private String observacoes;
}
