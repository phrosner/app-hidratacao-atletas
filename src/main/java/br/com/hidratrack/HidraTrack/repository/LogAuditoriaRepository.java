package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.LogAuditoria;
import br.com.hidratrack.HidraTrack.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Repository para operações de banco de dados com LogAuditoria
 */
@Repository
public interface LogAuditoriaRepository extends JpaRepository<LogAuditoria, Long> {

    /**
     * Busca logs de um usuário
     */
    List<LogAuditoria> findByUsuarioOrderByDataHoraDesc(Usuario usuario);

    /**
     * Busca logs por tipo de ação
     */
    List<LogAuditoria> findByTipoAcaoOrderByDataHoraDesc(LogAuditoria.TipoAcao tipoAcao);

    /**
     * Busca logs por severidade
     */
    List<LogAuditoria> findBySeveridadeOrderByDataHoraDesc(LogAuditoria.Severidade severidade);

    /**
     * Busca logs em um período
     */
    @Query("SELECT l FROM LogAuditoria l WHERE l.dataHora BETWEEN :inicio AND :fim ORDER BY l.dataHora DESC")
    List<LogAuditoria> findByPeriodo(
        @Param("inicio") LocalDateTime inicio,
        @Param("fim") LocalDateTime fim
    );

    /**
     * Busca logs de um usuário em um período
     */
    @Query("SELECT l FROM LogAuditoria l WHERE l.usuario = :usuario " +
           "AND l.dataHora BETWEEN :inicio AND :fim ORDER BY l.dataHora DESC")
    List<LogAuditoria> findByUsuarioAndPeriodo(
        @Param("usuario") Usuario usuario,
        @Param("inicio") LocalDateTime inicio,
        @Param("fim") LocalDateTime fim
    );

    /**
     * Busca logs de erros e críticos
     */
    @Query("SELECT l FROM LogAuditoria l WHERE l.severidade IN ('ERRO', 'CRITICO') ORDER BY l.dataHora DESC")
    List<LogAuditoria> findErrosECriticos();

    /**
     * Busca logs de acesso negado
     */
    List<LogAuditoria> findByTipoAcao(LogAuditoria.TipoAcao tipoAcao);

    /**
     * Busca logs recentes (últimas N horas)
     */
    @Query("SELECT l FROM LogAuditoria l WHERE l.dataHora >= :dataLimite ORDER BY l.dataHora DESC")
    List<LogAuditoria> findLogsRecentes(@Param("dataLimite") LocalDateTime dataLimite);

    /**
     * Busca logs por entidade afetada
     */
    List<LogAuditoria> findByEntidadeAfetadaAndIdEntidadeAfetadaOrderByDataHoraDesc(
        String entidadeAfetada,
        Long idEntidadeAfetada
    );
}
