-- =============================================================================
-- HidraTrack — script MySQL (cole no MySQL Workbench / CLI)
-- Banco: hidratrack_db (ajuste o nome se usar outro no application.properties)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS hidratrack_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE hidratrack_db;

-- Se você JÁ TEM a tabela (ex.: tipo_usuario como ENUM antigo), pode migrar com:
-- ALTER TABLE usuarios MODIFY COLUMN tipo_usuario VARCHAR(50) NOT NULL;

DROP TABLE IF EXISTS usuarios;

CREATE TABLE usuarios (
  id BIGINT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(255) DEFAULT NULL,
  email VARCHAR(255) DEFAULT NULL,
  senha VARCHAR(255) NOT NULL,
  usuario VARCHAR(255) NOT NULL,
  -- VARCHAR alinha com o Hibernate @Enumerated(STRING) + spring.jpa.hibernate.ddl-auto=validate
  tipo_usuario VARCHAR(50) NOT NULL,
  ativo TINYINT(1) DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY UK_usuario (usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Senhas em texto plano (igual ao código atual do Spring: comparação direta).
-- Troque as senhas em produção e use hash (BCrypt) depois.

INSERT INTO usuarios (nome, email, senha, usuario, tipo_usuario, ativo) VALUES
  ('Atleta Teste', 'atleta@hidratrack.local', 'senha123', 'atleta1', 'ATLETA', 1),
  ('Treinador Teste', 'treinador@hidratrack.local', 'senha123', 'treinador1', 'TREINADOR', 1),
  ('Nutricionista Teste', 'nutri@hidratrack.local', 'senha123', 'nutri1', 'NUTRICIONISTA', 1);

SELECT id, nome, usuario, tipo_usuario, ativo FROM usuarios;
