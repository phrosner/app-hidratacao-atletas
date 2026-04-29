-- ========================================
-- SCRIPT DE CRIAÇÃO DO BANCO DE DADOS
-- Aplicação: HidraTrack - São Camilo Nutri-Esportiva
-- SGBD: MySQL 8.0+
-- Charset: UTF8MB4 (suporte completo a Unicode)
-- ========================================

-- Criar banco de dados se não existir
CREATE DATABASE IF NOT EXISTS hidratrack_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE hidratrack_db;

-- ========================================
-- TABELA: usuarios
-- Armazena usuários do sistema (atletas, nutricionistas, treinadores, médicos)
-- ========================================
CREATE TABLE IF NOT EXISTS usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL COMMENT 'Hash BCrypt da senha',
    tipo ENUM('ATLETA', 'NUTRICIONISTA', 'TREINADOR', 'MEDICO') NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acesso DATETIME NULL,
    
    INDEX idx_email (email),
    INDEX idx_tipo (tipo),
    INDEX idx_ativo (ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Usuários do sistema com controle de acesso';

-- ========================================
-- TABELA: atletas
-- Dados demográficos e perfil esportivo dos atletas
-- ========================================
CREATE TABLE IF NOT EXISTS atletas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE COMMENT 'Código anônimo para privacidade',
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    sexo ENUM('MASCULINO', 'FEMININO', 'OUTRO') NULL,
    modalidade_principal VARCHAR(100) NULL,
    categoria VARCHAR(50) NULL COMMENT 'Ex: profissional, amador, juvenil',
    observacoes TEXT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT NULL COMMENT 'FK para usuário se atleta tem acesso ao sistema',
    
    INDEX idx_codigo (codigo),
    INDEX idx_modalidade (modalidade_principal),
    INDEX idx_ativo (ativo),
    INDEX idx_categoria (categoria),
    
    CONSTRAINT fk_atleta_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Cadastro de atletas monitorados';

-- ========================================
-- TABELA: sessoes
-- Sessões de treino ou competição
-- ========================================
CREATE TABLE IF NOT EXISTS sessoes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    atleta_id BIGINT NOT NULL,
    data_hora DATETIME NOT NULL,
    tipo ENUM('TREINO', 'COMPETICAO', 'TESTE') NOT NULL,
    modalidade VARCHAR(100) NULL,
    duracao_prevista_minutos INT NULL,
    duracao_real_minutos INT NULL,
    intensidade_percebida INT NULL COMMENT 'Escala 1-10',
    observacoes TEXT NULL,
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_atleta (atleta_id),
    INDEX idx_data_hora (data_hora),
    INDEX idx_tipo (tipo),
    INDEX idx_modalidade (modalidade),
    
    CONSTRAINT fk_sessao_atleta FOREIGN KEY (atleta_id) 
        REFERENCES atletas(id) ON DELETE CASCADE,
    CONSTRAINT chk_intensidade CHECK (intensidade_percebida BETWEEN 1 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Sessões de treino/competição registradas';

-- ========================================
-- TABELA: dados_pre_sessao
-- Dados coletados antes da sessão
-- ========================================
CREATE TABLE IF NOT EXISTS dados_pre_sessao (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sessao_id BIGINT NOT NULL UNIQUE,
    massa_corporal_kg DECIMAL(5,2) NOT NULL,
    cor_urina ENUM('MUITO_CLARA', 'CLARA', 'AMARELO_CLARO', 'AMARELO_ESCURO', 'MARROM') NULL,
    nivel_sede INT NULL COMMENT 'Escala 1-10',
    sintomas VARCHAR(100) NULL,
    tipo_vestimenta VARCHAR(100) NULL,
    equipamento VARCHAR(100) NULL,
    historico_hidratacao TEXT NULL,
    observacoes TEXT NULL,
    
    CONSTRAINT fk_dados_pre_sessao FOREIGN KEY (sessao_id) 
        REFERENCES sessoes(id) ON DELETE CASCADE,
    CONSTRAINT chk_massa_pre CHECK (massa_corporal_kg > 0),
    CONSTRAINT chk_sede_pre CHECK (nivel_sede BETWEEN 1 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Dados coletados antes do início da sessão';

-- ========================================
-- TABELA: condicoes_ambientais
-- Condições climáticas durante a sessão
-- ========================================
CREATE TABLE IF NOT EXISTS condicoes_ambientais (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sessao_id BIGINT NOT NULL UNIQUE,
    temperatura_celsius DECIMAL(4,1) NULL,
    umidade_percentual DECIMAL(4,1) NULL,
    sensacao_termica DECIMAL(4,1) NULL,
    velocidade_vento_kmh DECIMAL(4,1) NULL,
    exposicao_solar ENUM('INTERNO', 'SOMBRA', 'SOL_PARCIAL', 'SOL_PLENO') NULL,
    fonte_dados ENUM('MANUAL', 'API_CLIMA', 'SENSOR_LOCAL') NULL,
    localizacao VARCHAR(100) NULL,
    observacoes TEXT NULL,
    
    INDEX idx_temperatura (temperatura_celsius),
    INDEX idx_umidade (umidade_percentual),
    
    CONSTRAINT fk_condicao_sessao FOREIGN KEY (sessao_id) 
        REFERENCES sessoes(id) ON DELETE CASCADE,
    CONSTRAINT chk_umidade CHECK (umidade_percentual BETWEEN 0 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Condições ambientais durante a sessão';

-- ========================================
-- TABELA: ingestoes_fluido
-- Eventos de ingestão de fluidos durante a sessão
-- ========================================
CREATE TABLE IF NOT EXISTS ingestoes_fluido (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sessao_id BIGINT NOT NULL,
    data_hora DATETIME NOT NULL,
    volume_ml INT NOT NULL,
    tipo_bebida ENUM('AGUA', 'ISOTONICA', 'HIPOTONICA', 'HIPERTONICA', 'SUCO', 'REFRIGERANTE', 'BEBIDA_ESPORTIVA', 'OUTRO') NULL,
    descricao VARCHAR(100) NULL,
    contem_eletroliticos BOOLEAN DEFAULT FALSE,
    contem_carboidratos BOOLEAN DEFAULT FALSE,
    observacoes TEXT NULL,
    
    INDEX idx_sessao (sessao_id),
    INDEX idx_data_hora (data_hora),
    INDEX idx_tipo_bebida (tipo_bebida),
    
    CONSTRAINT fk_ingestao_sessao FOREIGN KEY (sessao_id) 
        REFERENCES sessoes(id) ON DELETE CASCADE,
    CONSTRAINT chk_volume_ingestao CHECK (volume_ml > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Registro de ingestão de fluidos durante sessão';

-- ========================================
-- TABELA: eliminacoes_urinarias
-- Eventos de eliminação urinária durante a sessão
-- ========================================
CREATE TABLE IF NOT EXISTS eliminacoes_urinarias (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sessao_id BIGINT NOT NULL,
    data_hora DATETIME NOT NULL,
    volume_ml INT NOT NULL,
    cor_urina ENUM('MUITO_CLARA', 'CLARA', 'AMARELO_CLARO', 'AMARELO_ESCURO', 'MARROM') NULL,
    observacoes TEXT NULL,
    
    INDEX idx_sessao (sessao_id),
    INDEX idx_data_hora (data_hora),
    
    CONSTRAINT fk_eliminacao_sessao FOREIGN KEY (sessao_id) 
        REFERENCES sessoes(id) ON DELETE CASCADE,
    CONSTRAINT chk_volume_eliminacao CHECK (volume_ml > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Registro de eliminação urinária durante sessão';

-- ========================================
-- TABELA: dados_pos_sessao
-- Dados coletados após a sessão
-- ========================================
CREATE TABLE IF NOT EXISTS dados_pos_sessao (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sessao_id BIGINT NOT NULL UNIQUE,
    massa_corporal_kg DECIMAL(5,2) NOT NULL,
    roupas_encharcadas BOOLEAN DEFAULT FALSE,
    troca_vestimenta BOOLEAN DEFAULT FALSE,
    sintomas_gastrointestinais TEXT NULL,
    nivel_fadiga INT NULL COMMENT 'Escala 1-10',
    tolerancia_plano_hidrico ENUM('EXCELENTE', 'BOA', 'MODERADA', 'RUIM', 'PESSIMA') NULL,
    cor_urina_pos ENUM('MUITO_CLARA', 'CLARA', 'AMARELO_CLARO', 'AMARELO_ESCURO', 'MARROM') NULL,
    observacoes TEXT NULL,
    
    CONSTRAINT fk_dados_pos_sessao FOREIGN KEY (sessao_id) 
        REFERENCES sessoes(id) ON DELETE CASCADE,
    CONSTRAINT chk_massa_pos CHECK (massa_corporal_kg > 0),
    CONSTRAINT chk_fadiga CHECK (nivel_fadiga BETWEEN 1 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Dados coletados após o término da sessão';

-- ========================================
-- TABELA: resultados_calculados
-- Resultados dos cálculos de taxa de sudorese e balanço hídrico
-- ========================================
CREATE TABLE IF NOT EXISTS resultados_calculados (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sessao_id BIGINT NOT NULL UNIQUE,
    perda_massa_corporal_kg DECIMAL(5,3) NULL,
    perda_massa_ajustada_kg DECIMAL(5,3) NULL,
    taxa_sudorese_l_h DECIMAL(5,3) NULL,
    percentual_variacao_massa DECIMAL(5,2) NULL,
    total_ingestao_ml INT NULL,
    total_eliminacao_ml INT NULL,
    balanco_hidrico_ml INT NULL,
    deficit_hidrico_ml INT NULL,
    status_hidratacao ENUM('BEM_HIDRATADO', 'LEVEMENTE_DESIDRATADO', 'MODERADAMENTE_DESIDRATADO', 
                           'DESIDRATADO', 'SEVERAMENTE_DESIDRATADO', 'HIPERIDRATADO', 'INCONSISTENTE') NULL,
    dados_inconsistentes BOOLEAN DEFAULT FALSE,
    motivo_inconsistencia TEXT NULL,
    data_calculo DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacoes TEXT NULL,
    
    INDEX idx_status (status_hidratacao),
    INDEX idx_inconsistentes (dados_inconsistentes),
    
    CONSTRAINT fk_resultado_sessao FOREIGN KEY (sessao_id) 
        REFERENCES sessoes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Resultados calculados de taxa de sudorese e balanço hídrico';

-- ========================================
-- TABELA: recomendacoes
-- Recomendações individualizadas geradas para o atleta
-- ========================================
CREATE TABLE IF NOT EXISTS recomendacoes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sessao_id BIGINT NOT NULL,
    tipo ENUM('HIDRATACAO_GERAL', 'AJUSTE_VOLUME', 'FRACIONAMENTO', 'ELETROLITICOS', 
              'ALERTA_DESIDRATACAO', 'ALERTA_SUPERINGESTAO', 'ALERTA_HIPONATREMIA', 'ESTRATEGIA_PERSONALIZAD') NOT NULL,
    faixa_alvo_ingestao_ml_h INT NULL,
    volume_minimo_ml_h INT NULL,
    volume_maximo_ml_h INT NULL,
    intervalo_fracionamento_minutos INT NULL,
    volume_por_intervalo_ml INT NULL,
    nivel_alerta ENUM('INFORMATIVO', 'ATENCAO', 'CUIDADO', 'URGENTE', 'CRITICO') NULL,
    mensagem_alerta TEXT NULL,
    descricao TEXT NULL,
    recomendacao_eletroliticos TEXT NULL,
    foi_aplicada BOOLEAN DEFAULT FALSE,
    data_aplicacao DATETIME NULL,
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacoes TEXT NULL,
    
    INDEX idx_sessao (sessao_id),
    INDEX idx_tipo (tipo),
    INDEX idx_nivel_alerta (nivel_alerta),
    INDEX idx_foi_aplicada (foi_aplicada),
    
    CONSTRAINT fk_recomendacao_sessao FOREIGN KEY (sessao_id) 
        REFERENCES sessoes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Recomendações individualizadas de hidratação';

-- ========================================
-- TABELA: perfis_contexto
-- Perfis agregados por modalidade e condições climáticas
-- ========================================
CREATE TABLE IF NOT EXISTS perfis_contexto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    atleta_id BIGINT NOT NULL,
    modalidade VARCHAR(100) NULL,
    tipo_clima ENUM('MUITO_FRIO', 'FRIO', 'AMENO', 'QUENTE', 'MUITO_QUENTE', 'UMIDO', 'SECO') NULL,
    duracao_tipica_minutos INT NULL,
    intensidade_tipica INT NULL COMMENT 'Escala 1-10',
    numero_sessoes INT DEFAULT 0,
    taxa_sudorese_media_l_h DECIMAL(5,3) NULL,
    taxa_sudorese_desvio_padrao DECIMAL(5,3) NULL,
    taxa_sudorese_minima_l_h DECIMAL(5,3) NULL,
    taxa_sudorese_maxima_l_h DECIMAL(5,3) NULL,
    ingestao_media_ml_h INT NULL,
    perda_massa_media_percentual DECIMAL(5,2) NULL,
    estrategia_testada TEXT NULL,
    tolerancia_media ENUM('EXCELENTE', 'BOA', 'MODERADA', 'RUIM', 'PESSIMA') NULL,
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    observacoes TEXT NULL,
    
    INDEX idx_atleta (atleta_id),
    INDEX idx_modalidade (modalidade),
    INDEX idx_tipo_clima (tipo_clima),
    INDEX idx_numero_sessoes (numero_sessoes),
    
    CONSTRAINT fk_perfil_atleta FOREIGN KEY (atleta_id) 
        REFERENCES atletas(id) ON DELETE CASCADE,
    CONSTRAINT chk_intensidade_tipica CHECK (intensidade_tipica BETWEEN 1 AND 10),
    CONSTRAINT chk_numero_sessoes CHECK (numero_sessoes >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Perfis de contexto agregando dados históricos';

-- ========================================
-- TABELA: logs_auditoria
-- Logs de auditoria para rastreabilidade
-- ========================================
CREATE TABLE IF NOT EXISTS logs_auditoria (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    tipo_acao ENUM('LOGIN', 'LOGOUT', 'CRIAR', 'VISUALIZAR', 'ATUALIZAR', 'DELETAR', 
                   'EXPORTAR', 'IMPORTAR', 'CALCULO_EXECUTADO', 'RECOMENDACAO_GERADA', 
                   'ACESSO_NEGADO', 'ERRO_SISTEMA') NOT NULL,
    descricao TEXT NOT NULL,
    entidade_afetada VARCHAR(100) NULL COMMENT 'Nome da entidade (ex: Sessao, Atleta)',
    id_entidade_afetada BIGINT NULL,
    ip_origem VARCHAR(45) NULL COMMENT 'IPv4 ou IPv6',
    user_agent VARCHAR(255) NULL,
    dados_antes TEXT NULL COMMENT 'JSON dos dados antes da alteração',
    dados_depois TEXT NULL COMMENT 'JSON dos dados após a alteração',
    severidade ENUM('INFO', 'AVISO', 'ERRO', 'CRITICO') NULL,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_data_hora (data_hora),
    INDEX idx_tipo_acao (tipo_acao),
    INDEX idx_severidade (severidade),
    INDEX idx_entidade (entidade_afetada, id_entidade_afetada),
    
    CONSTRAINT fk_log_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Log de auditoria para rastreabilidade de ações';

-- ========================================
-- VIEWS ÚTEIS
-- ========================================

-- View: Resumo de sessões com resultados
CREATE OR REPLACE VIEW vw_sessoes_resumo AS
SELECT 
    s.id AS sessao_id,
    a.codigo AS atleta_codigo,
    a.nome AS atleta_nome,
    s.data_hora,
    s.tipo,
    s.modalidade,
    s.duracao_real_minutos,
    pre.massa_corporal_kg AS massa_pre,
    pos.massa_corporal_kg AS massa_pos,
    r.taxa_sudorese_l_h,
    r.percentual_variacao_massa,
    r.status_hidratacao,
    r.total_ingestao_ml,
    r.balanco_hidrico_ml
FROM sessoes s
INNER JOIN atletas a ON s.atleta_id = a.id
LEFT JOIN dados_pre_sessao pre ON s.id = pre.sessao_id
LEFT JOIN dados_pos_sessao pos ON s.id = pos.sessao_id
LEFT JOIN resultados_calculados r ON s.id = r.sessao_id;

-- View: Estatísticas por atleta
CREATE OR REPLACE VIEW vw_estatisticas_atleta AS
SELECT 
    a.id AS atleta_id,
    a.codigo AS atleta_codigo,
    a.nome AS atleta_nome,
    a.modalidade_principal,
    COUNT(s.id) AS total_sessoes,
    AVG(r.taxa_sudorese_l_h) AS taxa_sudorese_media,
    STDDEV(r.taxa_sudorese_l_h) AS taxa_sudorese_desvio,
    MIN(r.taxa_sudorese_l_h) AS taxa_sudorese_min,
    MAX(r.taxa_sudorese_l_h) AS taxa_sudorese_max,
    AVG(r.percentual_variacao_massa) AS perda_massa_media,
    AVG(r.total_ingestao_ml) AS ingestao_media
FROM atletas a
LEFT JOIN sessoes s ON a.id = s.atleta_id
LEFT JOIN resultados_calculados r ON s.id = r.sessao_id AND r.dados_inconsistentes = FALSE
GROUP BY a.id, a.codigo, a.nome, a.modalidade_principal;

-- ========================================
-- DADOS INICIAIS (OPCIONAL)
-- ========================================

-- Inserir usuário administrador padrão
-- SENHA: admin123 (hash BCrypt precisa ser gerado pela aplicação)
-- INSERT INTO usuarios (nome, email, senha, tipo, ativo) 
-- VALUES ('Administrador', 'admin@hidratrack.com', '$2a$10$...', 'MEDICO', TRUE);

-- ========================================
-- FIM DO SCRIPT
-- ========================================
