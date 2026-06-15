package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.EquipeAtleta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EquipeAtletaRepository extends JpaRepository<EquipeAtleta, Long> {
    List<EquipeAtleta> findByEquipeIdOrderByVinculadoEmDesc(Long equipeId);

    List<EquipeAtleta> findByEquipeGestorId(Long gestorId);

    Optional<EquipeAtleta> findByEquipeIdAndAtletaId(Long equipeId, Long atletaId);

    boolean existsByEquipeIdAndAtletaId(Long equipeId, Long atletaId);

    @Query("SELECT ea FROM EquipeAtleta ea WHERE ea.atleta.id = :atletaId")
    List<EquipeAtleta> findByAtletaId(@Param("atletaId") Long atletaId);

    void deleteByEquipeIdAndAtletaId(Long equipeId, Long atletaId);

    long countByEquipeId(Long equipeId);
}
