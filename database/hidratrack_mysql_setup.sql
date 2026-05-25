  -- =============================================================================
  -- HidraTrack — script MySQL completo com Sessões, Métricas e Stats
  -- Banco: hidratrack_db
  -- =============================================================================

  CREATE DATABASE IF NOT EXISTS hidratrack_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

  USE hidratrack_db;

  -- Tabela de Usuários
  DROP TABLE IF EXISTS usuarios;
  CREATE TABLE usuarios (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(255) DEFAULT NULL,
    email VARCHAR(255) DEFAULT NULL,
    senha VARCHAR(255) NOT NULL,
    usuario VARCHAR(255) NOT NULL,
    tipo_usuario VARCHAR(50) NOT NULL,
    ativo TINYINT(1) DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY UK_usuario (usuario)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

  -- Tabela de Sessões de Treino
  DROP TABLE IF EXISTS sessoes_treino;
  CREATE TABLE sessoes_treino (
    id BIGINT NOT NULL AUTO_INCREMENT,
    atleta_id BIGINT NOT NULL,
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME,
    duracao_minutos INT,
    temperatura_ambiente DECIMAL(5,2),
    umidade_relativa INT,
    status VARCHAR(50) DEFAULT 'EM_ANDAMENTO',
    PRIMARY KEY (id),
    FOREIGN KEY (atleta_id) REFERENCES usuarios(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

  -- Tabela de Métricas de Sudorese (registradas durante a sessão)
  DROP TABLE IF EXISTS metricas_sudorese;
  CREATE TABLE metricas_sudorese (
    id BIGINT NOT NULL AUTO_INCREMENT,
    sessao_id BIGINT NOT NULL,
    tempo_decorrido_minutos INT NOT NULL,
    taxa_sudorese DECIMAL(10,3) COMMENT 'Em L/h',
    frequencia_cardiaca INT,
    velocidade_media DECIMAL(10,2),
    intensidade VARCHAR(50),
    observacoes TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (sessao_id) REFERENCES sessoes_treino(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

  -- Tabela de Stats/Resultado da Sessão
  DROP TABLE IF EXISTS stats_sessao;
  CREATE TABLE stats_sessao (
    id BIGINT NOT NULL AUTO_INCREMENT,
    sessao_id BIGINT NOT NULL UNIQUE,
    taxa_sudorese_media DECIMAL(10,3) COMMENT 'Média de L/h',
    variacao_sudorese DECIMAL(10,2) COMMENT 'Em percentual',
    perda_liquido_total DECIMAL(10,3) COMMENT 'Em L',
    perda_liquido_ajustada DECIMAL(10,3) COMMENT 'Considerando reposição',
    balanço_teorico INT COMMENT 'Em mL',
    deficit_level VARCHAR(50),
    recomendacao_intake_min INT COMMENT 'Em mL/h',
    recomendacao_intake_max INT COMMENT 'Em mL/h',
    intervalo_recomendado INT COMMENT 'Em minutos',
    sodio_recomendado INT COMMENT 'Em mg/L',
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (sessao_id) REFERENCES sessoes_treino(id),
    KEY idx_sessao (sessao_id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

  -- Tabela de Consumo de Água registrado durante/após sessão
  DROP TABLE IF EXISTS consumo_agua;
  CREATE TABLE consumo_agua (
    id BIGINT NOT NULL AUTO_INCREMENT,
    sessao_id BIGINT NOT NULL,
    tempo_decorrido_minutos INT,
    quantidade_ml INT NOT NULL,
    tipo_liquido VARCHAR(100),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (sessao_id) REFERENCES sessoes_treino(id),
    KEY idx_sessao_tempo (sessao_id, tempo_decorrido_minutos)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

  -- Dados de teste
  INSERT INTO usuarios (nome, email, senha, usuario, tipo_usuario, ativo) VALUES
    ('Ricardo Silva', 'ricardo@hidratrack.local', 'senha123', 'ricardo', 'ATLETA', 1),
    ('Treinador João', 'joao@hidratrack.local', 'senha123', 'joao', 'TREINADOR', 1),
    ('Nutricionista Maria', 'maria@hidratrack.local', 'senha123', 'maria', 'NUTRICIONISTA', 1);

  -- Sessão de teste
  INSERT INTO sessoes_treino (atleta_id, data_inicio, data_fim, duracao_minutos, temperatura_ambiente, umidade_relativa, status)
  VALUES (1, '2026-05-25 10:00:00', '2026-05-25 11:30:00', 90, 28.0, 65, 'CONCLUIDA');

  -- Métricas da sessão
  INSERT INTO metricas_sudorese (sessao_id, tempo_decorrido_minutos, taxa_sudorese, frequencia_cardiaca, velocidade_media, intensidade)
  VALUES 
    (1, 0, 0.60, 120, 8.5, 'MODERADA'),
    (1, 30, 1.75, 145, 10.2, 'ALTA'),
    (1, 60, 1.92, 155, 11.0, 'ALTA'),
    (1, 90, 1.88, 150, 10.5, 'ALTA');

  -- Stats calculados da sessão
  INSERT INTO stats_sessao (
    sessao_id, taxa_sudorese_media, variacao_sudorese, perda_liquido_total, 
    perda_liquido_ajustada, balanço_teorico, deficit_level,
    recomendacao_intake_min, recomendacao_intake_max, intervalo_recomendado, sodio_recomendado
  ) VALUES (
    1, 1.85, -1.8, 2.78, 2.42, -450, 'DEFICIT',
    500, 750, 15, 500
  );

  -- Consumo de água registrado
  INSERT INTO consumo_agua (sessao_id, tempo_decorrido_minutos, quantidade_ml, tipo_liquido)
  VALUES 
    (1, 15, 300, 'Água'),
    (1, 30, 250, 'Água com Electrólitos'),
    (1, 45, 300, 'Água'),
    (1, 60, 250, 'Água com Electrólitos'),
    (1, 75, 300, 'Água');

