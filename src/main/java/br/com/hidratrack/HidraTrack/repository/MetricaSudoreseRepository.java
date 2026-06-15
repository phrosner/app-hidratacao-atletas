package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.MetricaSudorese;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MetricaSudoreseRepository extends JpaRepository<MetricaSudorese, Long> {
    List<MetricaSudorese> findBySessaoIdOrderByTempoDecorridoMinutos(Long sessaoId);
}
