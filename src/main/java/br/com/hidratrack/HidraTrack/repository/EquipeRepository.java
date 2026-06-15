package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.Equipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EquipeRepository extends JpaRepository<Equipe, Long> {
    List<Equipe> findByGestorIdOrderByCriadoEmDesc(Long gestorId);

    @Query("SELECT e FROM Equipe e WHERE e.gestor.tipoUsuario IN ('TREINADOR', 'NUTRICIONISTA') ORDER BY e.criadoEm DESC")
    List<Equipe> findEquipesCompartilhadasEntreGestores();

    @Query("SELECT e FROM Equipe e WHERE e.id = :id AND e.gestor.tipoUsuario IN ('TREINADOR', 'NUTRICIONISTA')")
    Optional<Equipe> findEquipeCompartilhadaPorId(@Param("id") Long id);

    Optional<Equipe> findByCodigoEquipeIgnoreCase(String codigoEquipe);

    Optional<Equipe> findByIdAndGestorId(Long id, Long gestorId);

    boolean existsByCodigoEquipeIgnoreCase(String codigoEquipe);
}
