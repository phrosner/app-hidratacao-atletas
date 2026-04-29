package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Dados coletados após o término da sessão de treino/competição
 */
@Entity
@Table(name = "dados_pos_sessao")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DadosPosSessao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Sessão é obrigatória")
    @OneToOne
    @JoinColumn(name = "sessao_id", nullable = false, unique = true)
    private Sessao sessao;

    @NotNull(message = "Massa corporal pós é obrigatória")
    @Positive(message = "Massa corporal deve ser positiva")
    @Column(name = "massa_corporal_kg", nullable = false, precision = 5, scale = 2)
    private BigDecimal massaCorporalKg;

    @Column(name = "roupas_encharcadas")
    private Boolean roupasEncharcadas = false;

    @Column(name = "troca_vestimenta")
    private Boolean trocaVestimenta = false;

    @Column(name = "sintomas_gastrointestinais", columnDefinition = "TEXT")
    private String sintomasGastrointestinais;

    @Column(name = "nivel_fadiga")
    private Integer nivelFadiga; // Escala 1-10

    @Enumerated(EnumType.STRING)
    @Column(name = "tolerancia_plano_hidrico", length = 20)
    private ToleranciaPlano toleranciaPlanoHidrico;

    @Enumerated(EnumType.STRING)
    @Column(name = "cor_urina_pos", length = 20)
    private DadosPreSessao.CorUrina corUrinaPos;

    @Column(columnDefinition = "TEXT")
    private String observacoes;

    public enum ToleranciaPlano {
        EXCELENTE,    // Sem desconfortos
        BOA,          // Desconforto mínimo
        MODERADA,     // Algum desconforto
        RUIM,         // Desconforto significativo
        PESSIMA       // Não tolerou o plano
    }
}
