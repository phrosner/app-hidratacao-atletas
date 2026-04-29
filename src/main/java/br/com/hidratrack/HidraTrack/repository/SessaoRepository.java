package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.Sessao;
import br.com.hidratrack.HidraTrack.model.Atleta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Repository para operações de banco de dados com Sessões
 */
@Repository
public interface SessaoRepository extends JpaRepository<Sessao, Long> {

    /**
     * Busca sessões de um atleta
     */
    List<Sessao> findByAtleta(Atleta atleta);

    /**
     * Busca sessões de um atleta ordenadas por data (mais recentes primeiro)
     */
    List<Sessao> findByAtletaOrderByDataHoraDesc(Atleta atleta);

    /**
     * Busca sessões por tipo
     */
    List<Sessao> findByTipo(Sessao.TipoSessao tipo);

    /**
     * Busca sessões de um atleta por tipo
     */
    List<Sessao> findByAtletaAndTipo(Atleta atleta, Sessao.TipoSessao tipo);

    /**
     * Busca sessões por modalidade
     */
    List<Sessao> findByModalidade(String modalidade);

    /**
     * Busca sessões de um atleta em um período
     */
    @Query("SELECT s FROM Sessao s WHERE s.atleta = :atleta AND s.dataHora BETWEEN :inicio AND :fim ORDER BY s.dataHora DESC")
    List<Sessao> findByAtletaAndPeriodo(
        @Param("atleta") Atleta atleta,
        @Param("inicio") LocalDateTime inicio,
        @Param("fim") LocalDateTime fim
    );

    /**
     * Busca sessões recentes de um atleta (últimos N dias)
     */
    @Query("SELECT s FROM Sessao s WHERE s.atleta = :atleta AND s.dataHora >= :dataLimite ORDER BY s.dataHora DESC")
    List<Sessao> findSessoesRecentes(
        @Param("atleta") Atleta atleta,
        @Param("dataLimite") LocalDateTime dataLimite
    );

    /**
     * Busca sessões por modalidade e condições climáticas similares
     */
    @Query("SELECT s FROM Sessao s " +
           "JOIN s.condicaoAmbiental c " +
           "WHERE s.atleta = :atleta " +
           "AND s.modalidade = :modalidade " +
           "AND c.temperaturaCelsius BETWEEN :tempMin AND :tempMax")
    List<Sessao> findByModalidadeEClimaSimilar(
        @Param("atleta") Atleta atleta,
        @Param("modalidade") String modalidade,
        @Param("tempMin") Double tempMin,
        @Param("tempMax") Double tempMax
    );

    /**
     * Conta sessões de um atleta
     */
    long countByAtleta(Atleta atleta);

    /**
     * Conta sessões de um atleta por tipo
     */
    long countByAtletaAndTipo(Atleta atleta, Sessao.TipoSessao tipo);

    /**
     * Busca última sessão de um atleta
     */
    @Query("SELECT s FROM Sessao s WHERE s.atleta = :atleta ORDER BY s.dataHora DESC LIMIT 1")
    Sessao findUltimaSessao(@Param("atleta") Atleta atleta);
}
