package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.SessaoTreino;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SessaoTreinoRepository extends JpaRepository<SessaoTreino, Long> {
    List<SessaoTreino> findByAtletaIdOrderByDataInicioDesc(Long atletaId);
    List<SessaoTreino> findByAtletaId(Long atletaId);
}
