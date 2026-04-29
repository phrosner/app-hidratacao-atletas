package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Entidade que representa um atleta no sistema
 * Armazena dados demográficos e perfil esportivo
 */
@Entity
@Table(name = "atletas")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Atleta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Código do atleta é obrigatório")
    @Size(max = 50)
    @Column(nullable = false, unique = true, length = 50)
    private String codigo; // Código anônimo para privacidade

    @NotBlank(message = "Nome é obrigatório")
    @Size(max = 100)
    @Column(nullable = false, length = 100)
    private String nome;

    @NotNull(message = "Data de nascimento é obrigatória")
    @Column(name = "data_nascimento", nullable = false)
    private LocalDate dataNascimento;

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private Sexo sexo;

    @Column(length = 100)
    private String modalidadePrincipal;

    @Column(length = 50)
    private String categoria; // Ex: profissional, amador, juvenil

    @Column(columnDefinition = "TEXT")
    private String observacoes;

    @Column(nullable = false)
    private Boolean ativo = true;

    @CreationTimestamp
    @Column(name = "data_cadastro", nullable = false, updatable = false)
    private LocalDateTime dataCadastro;

    // Relacionamento com usuário (1:1 se o atleta tiver acesso ao sistema)
    @OneToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;

    // Relacionamento com sessões (1:N)
    @OneToMany(mappedBy = "atleta", cascade = CascadeType.ALL)
    private List<Sessao> sessoes;

    // Relacionamento com perfis de contexto (1:N)
    @OneToMany(mappedBy = "atleta", cascade = CascadeType.ALL)
    private List<PerfilContexto> perfis;

    public enum Sexo {
        MASCULINO,
        FEMININO,
        OUTRO
    }
}
