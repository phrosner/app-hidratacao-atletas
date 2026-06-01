package br.com.hidratrack.HidraTrack.model;

import jakarta.persistence.*;

@Entity
@Table(name = "usuarios")
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nome;
    private String email;
    private String senha;

    @Column(unique = true)
    private String usuario;

    @Enumerated(EnumType.STRING)
    private TipoUsuario tipoUsuario;

    private Integer idade;
    private Integer altura;
    private Double peso;
    private String esporte;
    private String nivelTreino;
    private String metaDiaria;

    public enum TipoUsuario {
        ATLETA,
        TREINADOR,
        NUTRICIONISTA
    }

    private Boolean ativo;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    public Boolean getAtivo() {
        return ativo;
    }

    public void setAtivo(Boolean ativo) {
        this.ativo = ativo;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public TipoUsuario getTipoUsuario() {
        return tipoUsuario;
    }

    public void setTipoUsuario(TipoUsuario tipoUsuario) {
        this.tipoUsuario = tipoUsuario;
    }

    public Integer getIdade() {
        return idade;
    }

    public void setIdade(Integer idade) {
        this.idade = idade;
    }

    public Integer getAltura() {
        return altura;
    }

    public void setAltura(Integer altura) {
        this.altura = altura;
    }

    public Double getPeso() {
        return peso;
    }

    public void setPeso(Double peso) {
        this.peso = peso;
    }

    public String getEsporte() {
        return esporte;
    }

    public void setEsporte(String esporte) {
        this.esporte = esporte;
    }

    public String getNivelTreino() {
        return nivelTreino;
    }

    public void setNivelTreino(String nivelTreino) {
        this.nivelTreino = nivelTreino;
    }

    public String getMetaDiaria() {
        return metaDiaria;
    }

    public void setMetaDiaria(String metaDiaria) {
        this.metaDiaria = metaDiaria;
    }
}