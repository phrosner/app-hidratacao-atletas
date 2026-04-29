package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Condições ambientais durante a sessão
 * Dados podem ser inseridos manualmente ou via API de clima
 */
@Entity
@Table(name = "condicoes_ambientais")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CondicaoAmbiental {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Sessão é obrigatória")
    @OneToOne
    @JoinColumn(name = "sessao_id", nullable = false, unique = true)
    private Sessao sessao;

    @Column(name = "temperatura_celsius", precision = 4, scale = 1)
    private BigDecimal temperaturaCelsius;

    @Column(name = "umidade_percentual", precision = 4, scale = 1)
    private BigDecimal umidadePercentual;

    @Column(name = "sensacao_termica", precision = 4, scale = 1)
    private BigDecimal sensacaoTermica;

    @Column(name = "velocidade_vento_kmh", precision = 4, scale = 1)
    private BigDecimal velocidadeVentoKmh;

    @Enumerated(EnumType.STRING)
    @Column(name = "exposicao_solar", length = 20)
    private ExposicaoSolar exposicaoSolar;

    @Enumerated(EnumType.STRING)
    @Column(name = "fonte_dados", length = 20)
    private FonteDados fonteDados;

    @Column(length = 100)
    private String localizacao; // Cidade, local de treino

    @Column(columnDefinition = "TEXT")
    private String observacoes;

    public enum ExposicaoSolar {
        INTERNO,           // Ambiente fechado
        SOMBRA,           // Externo com sombra
        SOL_PARCIAL,      // Sol parcial
        SOL_PLENO         // Exposição direta ao sol
    }

    public enum FonteDados {
        MANUAL,           // Inserido manualmente
        API_CLIMA,        // Obtido via API
        SENSOR_LOCAL      // Medido no local
    }
}
