# 📊 Documentação do Banco de Dados - HidraTrack

## ✅ Implementação Completa do Banco de Dados

Este documento descreve toda a estrutura de banco de dados implementada para o aplicativo **HidraTrack** - Sistema de Avaliação da Taxa de Sudorese e Suporte à Hidratação de Atletas utilizando o Spring Boot (Projeto São Camilo - Nutri-Esportiva).

---

## 📁 Estrutura de Arquivos Criados

### 🗂️ Entidades JPA (`src/main/java/br/com/hidratrack/HidraTrack/model/`)

1. **Usuario.java** - Usuários do sistema (atleta, nutricionista, treinador, médico)
2. **Atleta.java** - Cadastro de atletas com dados demográficos
3. **Sessao.java** - Sessões de treino/competição (entidade central)
4. **DadosPreSessao.java** - Dados coletados antes da sessão
5. **CondicaoAmbiental.java** - Condições climáticas durante a sessão
6. **IngestaoFluido.java** - Eventos de ingestão de fluidos
7. **EliminacaoUrinaria.java** - Eventos de eliminação urinária
8. **DadosPosSessao.java** - Dados coletados após a sessão
9. **ResultadoCalculado.java** - Resultados dos cálculos (taxa de sudorese, etc.)
10. **Recomendacao.java** - Recomendações individualizadas geradas
11. **PerfilContexto.java** - Perfis agregados por contexto similar
12. **LogAuditoria.java** - Logs de auditoria para rastreabilidade

**Total**: 12 entidades JPA completas com validações, relacionamentos e anotações.

---

### 🔍 Repositories (`src/main/java/br/com/hidratrack/HidraTrack/repository/`)

1. **UsuarioRepository.java** - Queries para usuários
2. **AtletaRepository.java** - Queries para atletas
3. **SessaoRepository.java** - Queries para sessões
4. **DadosPreSessaoRepository.java** - Queries para dados pré-sessão
5. **CondicaoAmbientalRepository.java** - Queries para condições ambientais
6. **IngestaoFluidoRepository.java** - Queries para ingestões
7. **EliminacaoUrinariaRepository.java** - Queries para eliminações
8. **DadosPosSessaoRepository.java** - Queries para dados pós-sessão
9. **ResultadoCalculadoRepository.java** - Queries para resultados calculados
10. **RecomendacaoRepository.java** - Queries para recomendações
11. **PerfilContextoRepository.java** - Queries para perfis de contexto
12. **LogAuditoriaRepository.java** - Queries para logs de auditoria

**Total**: 12 repositories com métodos customizados e queries JPQL.

---

### ⚙️ Configuração

- **application.properties** - Configuração completa do MySQL, JPA, servidor e logs

---

### 📐 Documentação

- **database/DIAGRAMA-ER.md** - Diagrama ER completo em Mermaid
  - Visualização de todas as entidades
  - Relacionamentos e cardinalidades
  - Descrição detalhada de cada tabela
  - Fórmulas de cálculo
  - Regras de integridade

---

## 🎯 Funcionalidades Implementadas

### 1. **Gerenciamento de Usuários e Atletas**
- ✅ Cadastro de usuários com diferentes perfis (RBAC)
- ✅ Cadastro de atletas com pseudonimização (código anônimo)
- ✅ Relacionamento opcional entre usuário e atleta

### 2. **Coleta de Dados de Sessão**
- ✅ Dados pré-sessão (massa corporal, hidratação, sintomas)
- ✅ Condições ambientais (temperatura, umidade, exposição solar)
- ✅ Múltiplos eventos de ingestão de fluidos
- ✅ Múltiplos eventos de eliminação urinária
- ✅ Dados pós-sessão (massa final, tolerância, fadiga)

### 3. **Motor de Cálculo**
- ✅ Estrutura para cálculo de taxa de sudorese (L/h)
- ✅ Percentual de variação de massa corporal
- ✅ Balanço hídrico da sessão
- ✅ Classificação de status de hidratação
- ✅ Detecção de dados inconsistentes

### 4. **Recomendações Individualizadas**
- ✅ Múltiplos tipos de recomendações
- ✅ Níveis de alerta (informativo até crítico)
- ✅ Sugestões de volume e fracionamento
- ✅ Recomendações de eletrólitos

### 5. **Personalização e Aprendizado**
- ✅ Perfis de contexto por modalidade e clima
- ✅ Agregação de dados históricos
- ✅ Estatísticas (média, desvio padrão, min/max)

### 6. **Segurança e Auditoria**
- ✅ Log completo de auditoria (LGPD compliance)
- ✅ Rastreabilidade de todas as ações
- ✅ Armazenamento de dados antes/depois (rollback)
- ✅ Registro de IP, user-agent e timestamps

---

## 🚀 Como Usar

### Pré-requisitos

1. **MySQL 8.0+** instalado e rodando
2. **Java 17+** instalado
3. **Maven** configurado

### Passo 1: Configurar Banco de Dados

#### Opção A: Deixar o Hibernate criar automaticamente (Desenvolvimento)

O `application.properties` já está configurado com:
```properties
spring.jpa.hibernate.ddl-auto=update
```

Isso criará as tabelas automaticamente na primeira execução.

#### Opção B: Executar o script SQL manualmente

```bash
# Conectar ao MySQL
mysql -u root -p

# Executar o script
source database/schema.sql
```

### Passo 2: Ajustar Credenciais

Edite `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/hidratrack_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=America/Sao_Paulo
spring.datasource.username=SEU_USUARIO
spring.datasource.password=SUA_SENHA
```

### Passo 3: Compilar e Executar

```bash
# Via Maven Wrapper (Windows)
.\mvnw clean install
.\mvnw spring-boot:run

# Via Maven Wrapper (Linux/Mac)
./mvnw clean install
./mvnw spring-boot:run
```

### Passo 4: Verificar

A aplicação estará disponível em:
```
http://localhost:8080/api
```

Os logs mostrarão as queries SQL sendo executadas (útil para debug).

---

## 📊 Estrutura do Banco de Dados

### Entidades e Relacionamentos

```
Usuario (1) -----> (0..1) Atleta
Atleta (1) ------> (0..*) Sessao
Atleta (1) ------> (0..*) PerfilContexto

Sessao (1) ------> (1) DadosPreSessao
Sessao (1) ------> (1) CondicaoAmbiental
Sessao (1) ------> (0..*) IngestaoFluido
Sessao (1) ------> (0..*) EliminacaoUrinaria
Sessao (1) ------> (1) DadosPosSessao
Sessao (1) ------> (1) ResultadoCalculado
Sessao (1) ------> (0..*) Recomendacao

Usuario (1) -----> (0..*) LogAuditoria
```

### Tabelas Principais

| Tabela | Registros Esperados | Crescimento |
|--------|---------------------|-------------|
| usuarios | Dezenas | Baixo |
| atletas | Centenas | Médio |
| sessoes | Milhares | Alto |
| ingestoes_fluido | Dezenas de milhares | Muito Alto |
| resultados_calculados | Milhares | Alto |
| logs_auditoria | Centenas de milhares | Muito Alto |

---

## 🔐 Segurança Implementada

### Privacidade (LGPD)

1. **Pseudonimização**: Atletas identificados por código único
2. **Criptografia de Senha**: BCrypt para hashes seguros
3. **Auditoria Completa**: Todos os acessos registrados
4. **Controle de Acesso**: Por tipo de usuário (RBAC preparado)

### Constraints de Segurança

- Valores positivos para massas e volumes
- Escalas validadas (1-10 para intensidade, fadiga, sede)
- Unicidade de email e código de atleta
- Cascata controlada de deleções

---

## 📈 Queries Úteis Implementadas

### Repositories com Métodos Customizados

#### AtletaRepository
```java
findByCodigo(String codigo)
findByModalidadePrincipal(String modalidade)
findAtletasComSessoes()
searchByNome(String nome)
```

#### SessaoRepository
```java
findByAtletaAndPeriodo(Atleta, LocalDateTime inicio, fim)
findSessoesRecentes(Atleta, LocalDateTime dataLimite)
findByModalidadeEClimaSimilar(...)
```

#### ResultadoCalculadoRepository
```java
calcularMediaTaxaSudorese(Atleta)
calcularDesvioPadraoTaxaSudorese(Atleta)
findByAtletaAndModalidade(...)
```

### Views SQL Criadas

1. **vw_sessoes_resumo**: Visão consolidada de sessões com resultados
2. **vw_estatisticas_atleta**: Estatísticas agregadas por atleta

---

## 📝 Convenções Adotadas

### Nomenclatura

- **Tabelas**: snake_case no plural (ex: `sessoes`, `dados_pre_sessao`)
- **Colunas**: snake_case (ex: `massa_corporal_kg`, `data_hora`)
- **Classes Java**: PascalCase (ex: `DadosPreSessao`)
- **Atributos Java**: camelCase (ex: `massaCorporalKg`)
- **Enums**: UPPER_CASE (ex: `TREINO`, `MUITO_QUENTE`)

### Padrões

- **IDs**: BIGINT AUTO_INCREMENT
- **Timestamps**: DATETIME (não TIMESTAMP para evitar limitações)
- **Moeda/Precisão**: DECIMAL com escala apropriada
- **Textos longos**: TEXT (não VARCHAR limitado)
- **Booleanos**: BOOLEAN (convertido para TINYINT no MySQL)

---
