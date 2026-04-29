package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Dados coletados antes do início da sessão de treino/competição
 */
@Entity
@Table(name = "dados_pre_sessao")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DadosPreSessao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Sessão é obrigatória")
    @OneToOne
    @JoinColumn(name = "sessao_id", nullable = false, unique = true)
    private Sessao sessao;

    @NotNull(message = "Massa corporal pré é obrigatória")
    @Positive(message = "Massa corporal deve ser positiva")
    @Column(name = "massa_corporal_kg", nullable = false, precision = 5, scale = 2)
    private BigDecimal massaCorporalKg;

    @Enumerated(EnumType.STRING)
    @Column(name = "cor_urina", length = 20)
    private CorUrina corUrina;

    @Column(name = "nivel_sede")
    private Integer nivelSede; // Escala 1-10

    @Column(length = 100)
    private String sintomas;

    @Column(name = "tipo_vestimenta", length = 100)
    private String tipoVestimenta;

    @Column(length = 100)
    private String equipamento;

    @Column(columnDefinition = "TEXT")
    private String historicoHidratacao;

    @Column(columnDefinition = "TEXT")
    private String observacoes;

    public enum CorUrina {
        MUITO_CLARA,      // 1-2 (bem hidratado)
        CLARA,            // 3-4 (hidratado)
        AMARELO_CLARO,    // 5-6 (minimamente desidratado)
        AMARELO_ESCURO,   // 7-8 (desidratado)
        MARROM            // 9-10 (severamente desidratado)
    }
}
