package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Entidade principal que representa uma sessão de treino ou competição
 * Agrega todos os dados coletados antes, durante e após a atividade
 */
@Entity
@Table(name = "sessoes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Sessao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Atleta é obrigatório")
    @ManyToOne
    @JoinColumn(name = "atleta_id", nullable = false)
    private Atleta atleta;

    @NotNull(message = "Data/hora da sessão é obrigatória")
    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TipoSessao tipo;

    @Column(length = 100)
    private String modalidade;

    @Positive(message = "Duração prevista deve ser positiva")
    @Column(name = "duracao_prevista_minutos")
    private Integer duracaoPrevistaMinutos;

    @Positive(message = "Duração real deve ser positiva")
    @Column(name = "duracao_real_minutos")
    private Integer duracaoRealMinutos;

    @Column(name = "intensidade_percebida")
    private Integer intensidadePercebida; // Escala 1-10

    @Column(columnDefinition = "TEXT")
    private String observacoes;

    @CreationTimestamp
    @Column(name = "data_criacao", nullable = false, updatable = false)
    private LocalDateTime dataCriacao;

    // Relacionamento 1:1 com dados pré-sessão
    @OneToOne(mappedBy = "sessao", cascade = CascadeType.ALL, orphanRemoval = true)
    private DadosPreSessao dadosPreSessao;

    // Relacionamento 1:1 com condições ambientais
    @OneToOne(mappedBy = "sessao", cascade = CascadeType.ALL, orphanRemoval = true)
    private CondicaoAmbiental condicaoAmbiental;

    // Relacionamento 1:N com ingestões de fluido
    @OneToMany(mappedBy = "sessao", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<IngestaoFluido> ingestoesFluido;

    // Relacionamento 1:N com eliminações urinárias
    @OneToMany(mappedBy = "sessao", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<EliminacaoUrinaria> eliminacoesUrinarias;

    // Relacionamento 1:1 com dados pós-sessão
    @OneToOne(mappedBy = "sessao", cascade = CascadeType.ALL, orphanRemoval = true)
    private DadosPosSessao dadosPosSessao;

    // Relacionamento 1:1 com resultados calculados
    @OneToOne(mappedBy = "sessao", cascade = CascadeType.ALL, orphanRemoval = true)
    private ResultadoCalculado resultadoCalculado;

    // Relacionamento 1:N com recomendações
    @OneToMany(mappedBy = "sessao", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Recomendacao> recomendacoes;

    public enum TipoSessao {
        TREINO,
        COMPETICAO,
        TESTE
    }
}
