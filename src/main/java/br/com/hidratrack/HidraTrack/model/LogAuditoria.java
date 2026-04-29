package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * Log de auditoria para rastreabilidade de ações no sistema
 * Registra quem acessou/modificou dados, quando e de onde
 */
@Entity
@Table(name = "logs_auditoria", indexes = {
    @Index(name = "idx_usuario_id", columnList = "usuario_id"),
    @Index(name = "idx_data_hora", columnList = "data_hora"),
    @Index(name = "idx_tipo_acao", columnList = "tipo_acao")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LogAuditoria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "Usuário é obrigatório")
    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @NotNull(message = "Tipo de ação é obrigatório")
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_acao", nullable = false, length = 30)
    private TipoAcao tipoAcao;

    @NotBlank(message = "Descrição é obrigatória")
    @Column(nullable = false, columnDefinition = "TEXT")
    private String descricao;

    @Column(name = "entidade_afetada", length = 100)
    private String entidadeAfetada; // Ex: "Sessao", "Atleta"

    @Column(name = "id_entidade_afetada")
    private Long idEntidadeAfetada;

    @Column(name = "ip_origem", length = 45) // IPv6
    private String ipOrigem;

    @Column(name = "user_agent", length = 255)
    private String userAgent;

    @Column(name = "dados_antes", columnDefinition = "TEXT")
    private String dadosAntes; // JSON dos dados antes da alteração

    @Column(name = "dados_depois", columnDefinition = "TEXT")
    private String dadosDepois; // JSON dos dados após a alteração

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private Severidade severidade;

    @CreationTimestamp
    @Column(name = "data_hora", nullable = false, updatable = false)
    private LocalDateTime dataHora;

    public enum TipoAcao {
        LOGIN,
        LOGOUT,
        CRIAR,
        VISUALIZAR,
        ATUALIZAR,
        DELETAR,
        EXPORTAR,
        IMPORTAR,
        CALCULO_EXECUTADO,
        RECOMENDACAO_GERADA,
        ACESSO_NEGADO,
        ERRO_SISTEMA
    }

    public enum Severidade {
        INFO,       // Informação normal
        AVISO,      // Ação que requer atenção
        ERRO,       // Erro no sistema
        CRITICO     // Erro crítico ou violação de segurança
    }
}
