-- =============================================================================
-- HidraTrack — script MySQL completo e atualizado para o backend atual
-- Banco: hidratrack_db
-- =============================================================================

CREATE DATABASE IF NOT EXISTS hidratrack_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE hidratrack_db;

-- Tabelas criadas na ordem de dependências
DROP TABLE IF EXISTS consumo_agua;
DROP TABLE IF EXISTS stats_sessao;
DROP TABLE IF EXISTS metricas_sudorese;
DROP TABLE IF EXISTS sessoes_treino;
DROP TABLE IF EXISTS usuarios;

CREATE TABLE usuarios (
  id BIGINT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(255) DEFAULT NULL,
  email VARCHAR(255) DEFAULT NULL,
  senha VARCHAR(255) NOT NULL,
  usuario VARCHAR(255) NOT NULL,
  tipo_usuario VARCHAR(50) NOT NULL,
  idade INT DEFAULT NULL,
  altura INT DEFAULT NULL,
  peso DECIMAL(6,2) DEFAULT NULL,
  esporte VARCHAR(100) DEFAULT NULL,
  nivel_treino VARCHAR(100) DEFAULT NULL,
  meta_diaria VARCHAR(255) DEFAULT NULL,
  ativo TINYINT(1) DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uk_usuario (usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sessoes_treino (
  id BIGINT NOT NULL AUTO_INCREMENT,
  atleta_id BIGINT NOT NULL,
  data_inicio DATETIME NOT NULL,
  data_fim DATETIME DEFAULT NULL,
  duration_minutos INT DEFAULT NULL,
  temperatura_ambiente DECIMAL(6,2) DEFAULT NULL,
  umidade_relativa INT DEFAULT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'EM_ANDAMENTO',
  PRIMARY KEY (id),
  KEY idx_sessao_atleta (atleta_id),
  CONSTRAINT fk_sessao_atleta FOREIGN KEY (atleta_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE metricas_sudorese (
  id BIGINT NOT NULL AUTO_INCREMENT,
  sessao_id BIGINT NOT NULL,
  tempo_decorrido_minutos INT NOT NULL,
  taxa_sudorese DECIMAL(10,3) NOT NULL,
  frequencia_cardiaca INT DEFAULT NULL,
  velocidade_media DECIMAL(10,2) DEFAULT NULL,
  intensidade VARCHAR(50) DEFAULT NULL,
  observacoes TEXT DEFAULT NULL,
  timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_metricas_sessao (sessao_id),
  CONSTRAINT fk_metrica_sessao FOREIGN KEY (sessao_id) REFERENCES sessoes_treino(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE stats_sessao (
  id BIGINT NOT NULL AUTO_INCREMENT,
  sessao_id BIGINT NOT NULL,
  taxa_sudorese_media DECIMAL(10,3) NOT NULL,
  variacao_sudorese DECIMAL(10,2) DEFAULT NULL,
  perda_liquido_total DECIMAL(10,3) DEFAULT NULL,
  perda_liquido_ajustada DECIMAL(10,3) DEFAULT NULL,
  balanco_teorico INT DEFAULT NULL,
  deficit_level VARCHAR(50) DEFAULT NULL,
  recomendacao_intake_min INT DEFAULT NULL,
  recomendacao_intake_max INT DEFAULT NULL,
  intervalo_recomendado INT DEFAULT NULL,
  sodio_recomendado INT DEFAULT NULL,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_stats_sessao (sessao_id),
  CONSTRAINT fk_stats_sessao FOREIGN KEY (sessao_id) REFERENCES sessoes_treino(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE consumo_agua (
  id BIGINT NOT NULL AUTO_INCREMENT,
  sessao_id BIGINT NOT NULL,
  tempo_decorrido_minutos INT DEFAULT NULL,
  quantidade_ml INT NOT NULL,
  tipo_liquido VARCHAR(100) DEFAULT NULL,
  timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_consumo_sessao (sessao_id),
  CONSTRAINT fk_consumo_sessao FOREIGN KEY (sessao_id) REFERENCES sessoes_treino(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Usuários de exemplo
INSERT INTO usuarios (nome, email, senha, usuario, tipo_usuario, idade, altura, peso, esporte, nivel_treino, meta_diaria, ativo) VALUES
  ('Atleta Exemplo', 'atleta@example.com', 'senha123', 'atleta_exemplo', 'ATLETA', 24, 178, 72.5, 'Corrida', 'INTERMEDIARIO', 'Manter hidratação após treino', 1),
  ('Treinador Exemplo', 'treinador@example.com', 'senha123', 'treinador_exemplo', 'TREINADOR', NULL, NULL, NULL, NULL, NULL, NULL, 1),
  ('Nutricionista Exemplo', 'nutricionista@example.com', 'senha123', 'nutricionista_exemplo', 'NUTRICIONISTA', NULL, NULL, NULL, NULL, NULL, NULL, 1);

