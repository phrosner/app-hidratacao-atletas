package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.Equipe;
import br.com.hidratrack.HidraTrack.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EquipeRepository extends JpaRepository<Equipe, Long> {
    List<Equipe> findByGestorIdOrderByCriadoEmDesc(Long gestorId);

    Optional<Equipe> findByCodigoEquipeIgnoreCase(String codigoEquipe);

    Optional<Equipe> findByIdAndGestorId(Long id, Long gestorId);

    boolean existsByCodigoEquipeIgnoreCase(String codigoEquipe);
}
