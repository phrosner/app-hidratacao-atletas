# 🚀 Integração com Banco de Dados HidraTrack

## Guia Rápido para Começar a Usar

**Última atualização**: 2026-04-28  
**Status**: ✅ Banco de dados pronto para uso

---

### 1. Pré-requisitos

✅ **Java 17+** instalado  
✅ **Maven 3.6+** instalado  
✅ **MySQL 8.0+** instalado e rodando

### 2. Configurar Banco de Dados

```bash
# Conectar ao MySQL
mysql -u root -p

# Criar banco de dados
CREATE DATABASE hidratrack_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
```

**Opcional**: Criar usuário específico
```sql
CREATE USER 'hidratrack'@'localhost' IDENTIFIED BY 'hidratrack123';
GRANT ALL PRIVILEGES ON hidratrack_db.* TO 'hidratrack'@'localhost';
FLUSH PRIVILEGES;
```

### 3. Configurar Aplicação

Edite: `src/main/resources/application.properties`

```properties
# CONFIGURE AQUI SEU USUÁRIO E SENHA
spring.datasource.username=root
spring.datasource.password=sua_senha_mysql

# URL já está configurada (ajuste apenas se necessário)
spring.datasource.url=jdbc:mysql://localhost:3306/hidratrack_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=America/Sao_Paulo
```

### 4. Executar

```bash
# Compilar e executar
mvn clean spring-boot:run
```

✅ **Pronto!** As 12 tabelas serão criadas automaticamente.

---

## 📊 O Que Você Recebeu

### Entidades JPA (12 tabelas)

| Entidade | Descrição |
|----------|-----------|
| `Usuario` | Usuários do sistema (ATLETA, NUTRICIONISTA, TREINADOR, MEDICO) |
| `Atleta` | Cadastro de atletas com código único |
| `Sessao` | Sessões de treino/competição |
| `DadosPreSessao` | Dados coletados antes da sessão |
| `CondicaoAmbiental` | Condições climáticas durante sessão |
| `IngestaoFluido` | Eventos de ingestão de fluidos |
| `EliminacaoUrinaria` | Eventos de eliminação urinária |
| `DadosPosSessao` | Dados coletados após sessão |
| `ResultadoCalculado` | Resultados dos cálculos de taxa de sudorese |
| `Recomendacao` | Recomendações individualizadas geradas |
| `PerfilContexto` | Perfis agregados por contexto |
| `LogAuditoria` | Logs de auditoria (LGPD) |

### Repositories (12 interfaces)

Todos os repositories já estão prontos com:
- ✅ CRUD completo (`save`, `findAll`, `findById`, `delete`)
- ✅ 40+ queries customizadas
- ✅ Agregações (COUNT, AVG, STDDEV)
- ✅ Buscas específicas

---

## 💻 Como Usar os Repositories

### Exemplo 1: Criar e Buscar Atleta

```java
@Service
public class AtletaService {
    
    @Autowired
    private AtletaRepository atletaRepository;
    
    public Atleta criarAtleta(String nome, LocalDate dataNascimento) {
        Atleta atleta = new Atleta();
        atleta.setNome(nome);
        atleta.setDataNascimento(dataNascimento);
        atleta.setSexo(Atleta.Sexo.MASCULINO);
        atleta.setModalidadePrincipal("Corrida");
        atleta.setAtivo(true);
        
        return atletaRepository.save(atleta);
    }
    
    public List<Atleta> listarAtletasAtivos() {
        return atletaRepository.findByAtivoTrue();
    }
    
    public Atleta buscarPorCodigo(String codigo) {
        return atletaRepository.findByCodigo(codigo)
            .orElseThrow(() -> new RuntimeException("Atleta não encontrado"));
    }
}
```

### Exemplo 2: Criar Sessão Completa

```java
@Service
public class SessaoService {
    
    @Autowired
    private SessaoRepository sessaoRepository;
    @Autowired
    private DadosPreSessaoRepository dadosPreRepository;
    @Autowired
    private AtletaRepository atletaRepository;
    
    @Transactional
    public Sessao criarSessao(Long atletaId) {
        Atleta atleta = atletaRepository.findById(atletaId)
            .orElseThrow(() -> new RuntimeException("Atleta não encontrado"));
        
        // Criar sessão
        Sessao sessao = new Sessao();
        sessao.setAtleta(atleta);
        sessao.setDataHora(LocalDateTime.now());
        sessao.setTipo(Sessao.TipoSessao.TREINO);
        sessao.setModalidade("Corrida");
        sessao.setDuracaoRealMinutos(90);
        sessao = sessaoRepository.save(sessao);
        
        // Criar dados pré-sessão
        DadosPreSessao dadosPre = new DadosPreSessao();
        dadosPre.setSessao(sessao);
        dadosPre.setMassaCorporalKg(new BigDecimal("70.5"));
        dadosPre.setCorUrina(DadosPreSessao.CorUrina.AMARELO_CLARO);
        dadosPre.setNivelSede(3);
        dadosPreRepository.save(dadosPre);
        
        return sessao;
    }
}
```

### Exemplo 3: Queries Customizadas

```java
@Service
public class ConsultaService {
    
    @Autowired
    private SessaoRepository sessaoRepository;
    @Autowired
    private AtletaRepository atletaRepository;
    
    public List<Sessao> buscarSessoesRecentes(Long atletaId) {
        Atleta atleta = atletaRepository.findById(atletaId).orElseThrow();
        LocalDateTime dataLimite = LocalDateTime.now().minusDays(30);
        
        return sessaoRepository.findSessoesRecentes(atleta, dataLimite);
    }
    
    public Long contarSessoesPorAtleta(Long atletaId) {
        return sessaoRepository.countByAtletaId(atletaId);
    }
    
    public List<Atleta> buscarAtletasPorModalidade(String modalidade) {
        return atletaRepository.findByAtivoTrueAndModalidadePrincipal(modalidade);
    }
}
```

---

## 🔍 Verificar Instalação

### 1. Verificar Tabelas Criadas

```sql
USE hidratrack_db;
SHOW TABLES;
```

**Resultado esperado** (12 tabelas):
```
+---------------------------+
| Tables_in_hidratrack_db   |
+---------------------------+
| atletas                   |
| condicoes_ambientais      |
| dados_pos_sessao          |
| dados_pre_sessao          |
| eliminacoes_urinarias     |
| ingestoes_fluido          |
| logs_auditoria            |
| perfis_contexto           |
| recomendacoes             |
| resultados_calculados     |
| sessoes                   |
| usuarios                  |
+---------------------------+
```

### 2. Verificar Estrutura de uma Tabela

```sql
DESCRIBE atletas;
```

### 3. Testar CRUD Básico

```java
@SpringBootTest
class AtletaRepositoryTest {
    
    @Autowired
    private AtletaRepository atletaRepository;
    
    @Test
    void testCriarAtleta() {
        Atleta atleta = new Atleta();
        atleta.setNome("Teste");
        atleta.setDataNascimento(LocalDate.of(1990, 1, 1));
        atleta.setAtivo(true);
        
        Atleta salvo = atletaRepository.save(atleta);
        
        assertNotNull(salvo.getId());
        assertNotNull(salvo.getCodigo()); // Código gerado automaticamente
    }
}
```

---

## 📚 Documentação Disponível

### 1. DATABASE-README.md
**Guia completo do banco de dados**
- Todas as entidades explicadas
- Relacionamentos
- Queries disponíveis
- Como usar cada repository
- Troubleshooting

### 2. database/DIAGRAMA-ER.md
**Diagrama ER visual**
- Diagrama Mermaid de todas as entidades
- Cardinalidades
- Descrição de cada campo
- Fórmulas de cálculo

### 3. database/schema.sql
**Script SQL manual**
- Criação manual do banco (se preferir)
- Todas as tabelas com constraints
- Índices
- 2 views úteis

---

## 🎯 Queries Úteis Prontas

### AtletaRepository

```java
// Buscar atleta por código único
Optional<Atleta> findByCodigo(String codigo);

// Buscar atletas ativos
List<Atleta> findByAtivoTrue();

// Buscar por modalidade
List<Atleta> findByAtivoTrueAndModalidadePrincipal(String modalidade);

// Buscar por nome (parcial)
@Query("SELECT a FROM Atleta a WHERE LOWER(a.nome) LIKE LOWER(CONCAT('%', :nome, '%'))")
List<Atleta> searchByNome(@Param("nome") String nome);

// Atletas com sessões
@Query("SELECT DISTINCT a FROM Atleta a WHERE EXISTS (SELECT s FROM Sessao s WHERE s.atleta = a)")
List<Atleta> findAtletasComSessoes();
```

### SessaoRepository

```java
// Buscar por atleta e período
List<Sessao> findByAtletaAndDataHoraBetween(Atleta atleta, LocalDateTime inicio, LocalDateTime fim);

// Sessões recentes (últimos 30 dias)
@Query("SELECT s FROM Sessao s WHERE s.atleta = :atleta AND s.dataHora >= :dataLimite ORDER BY s.dataHora DESC")
List<Sessao> findSessoesRecentes(@Param("atleta") Atleta atleta, @Param("dataLimite") LocalDateTime dataLimite);

// Contar sessões por atleta
Long countByAtletaId(Long atletaId);
```

### ResultadoCalculadoRepository

```java
// Calcular média da taxa de sudorese
@Query("SELECT AVG(r.taxaSudoreseLitroPorHora) FROM ResultadoCalculado r WHERE r.sessao.atleta = :atleta")
BigDecimal calcularMediaTaxaSudorese(@Param("atleta") Atleta atleta);

// Buscar por status de hidratação
List<ResultadoCalculado> findByStatusHidratacao(ResultadoCalculado.StatusHidratacao status);
```

---

## ⚙️ Configurações Importantes

### application.properties

```properties
# Banco de dados
spring.datasource.url=jdbc:mysql://localhost:3306/hidratrack_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=America/Sao_Paulo
spring.datasource.username=root
spring.datasource.password=root

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect

# Pool de conexões
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=5
```

### DDL-Auto Modes

| Modo | Uso | Descrição |
|------|-----|-----------|
| `update` | ✅ Desenvolvimento | Atualiza schema automaticamente |
| `create` | ⚠️ Testes | Recria schema (perde dados!) |
| `validate` | 🚀 Produção | Apenas valida (não altera) |
| `none` | 📜 Manual | Desabilita auto-DDL |

---

## 💡 Dicas

### 1. Use @Transactional
```java
@Transactional
public void operacaoComplexa() {
    // Múltiplas operações de BD
}
```

### 2. Lazy vs Eager Loading
```java
// Já configurado nas entidades
@OneToMany(fetch = FetchType.LAZY) // Padrão
private List<Sessao> sessoes;
```

### 3. Validações
```java
// Já implementadas nas entidades
@NotBlank
@Size(min = 3, max = 100)
private String nome;
```

---
**Dúvidas?**  
Consulte: **DATABASE-README.md** (documentação completa)

**Bom desenvolvimento!** 🚀
