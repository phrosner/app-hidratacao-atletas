package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.ConsumoAgua;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConsumoAguaRepository extends JpaRepository<ConsumoAgua, Long> {
    List<ConsumoAgua> findBySessaoIdOrderByTempoDecorridoMinutos(Long sessaoId);
}
