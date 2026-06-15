package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "equipe_atletas", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"equipe_id", "atleta_id"})
})
public class EquipeAtleta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipe_id", nullable = false)
    private Equipe equipe;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "atleta_id", nullable = false)
    private Usuario atleta;

    @Column(name = "vinculado_em")
    private LocalDateTime vinculadoEm;

    @PrePersist
    protected void onCreate() {
        if (vinculadoEm == null) {
            vinculadoEm = LocalDateTime.now();
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Equipe getEquipe() {
        return equipe;
    }

    public void setEquipe(Equipe equipe) {
        this.equipe = equipe;
    }

    public Usuario getAtleta() {
        return atleta;
    }

    public void setAtleta(Usuario atleta) {
        this.atleta = atleta;
    }

    public LocalDateTime getVinculadoEm() {
        return vinculadoEm;
    }

    public void setVinculadoEm(LocalDateTime vinculadoEm) {
        this.vinculadoEm = vinculadoEm;
    }
}
