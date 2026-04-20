-- Schema para banco local Dinneer
-- Baseado nas queries reais usadas no código

-- Tabela de sequências (para gerar IDs)
CREATE TABLE IF NOT EXISTS tb_sequence_dn (
    id_sequence SERIAL PRIMARY KEY,
    nm_sequence CHAR(1) NOT NULL
);

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS tb_usuario_dn (
    id_usuario INTEGER PRIMARY KEY,
    nu_cpf CHAR(11) NOT NULL UNIQUE,
    nm_usuario VARCHAR(100) NOT NULL,
    nm_sobrenome VARCHAR(100) NOT NULL,
    vl_email VARCHAR(100) NOT NULL UNIQUE,
    vl_senha VARCHAR(100) NOT NULL,
    vl_foto VARCHAR(255),
    fl_anfitriao VARCHAR(10) DEFAULT 'false'
);

-- Tabela de locais
CREATE TABLE IF NOT EXISTS tb_local_dn (
    id_local INTEGER PRIMARY KEY,
    id_usuario INTEGER NOT NULL,
    nu_cep VARCHAR(10) NOT NULL,
    nu_casa VARCHAR(20) NOT NULL,
    nu_cnpj CHAR(14),
    dc_complemento VARCHAR(255),
    FOREIGN KEY (id_usuario) REFERENCES tb_usuario_dn(id_usuario) ON DELETE CASCADE
);

-- Tabela de cardápios
CREATE TABLE IF NOT EXISTS tb_cardapio_dn (
    id_cardapio INTEGER PRIMARY KEY,
    id_local INTEGER NOT NULL,
    nm_cardapio VARCHAR(100) NOT NULL,
    ds_cardapio TEXT NOT NULL,
    preco_refeicao DECIMAL(10,2) NOT NULL,
    vl_foto_cardapio VARCHAR(255),
    FOREIGN KEY (id_local) REFERENCES tb_local_dn(id_local) ON DELETE CASCADE
);

-- Tabela de encontros
CREATE TABLE IF NOT EXISTS tb_encontro_dn (
    id_encontro INTEGER PRIMARY KEY,
    id_local INTEGER NOT NULL,
    id_cardapio INTEGER NOT NULL,
    hr_encontro TIMESTAMP NOT NULL,
    nu_max_convidados INTEGER NOT NULL,
    fl_anfitriao_confirma VARCHAR(10) DEFAULT 'true',
    FOREIGN KEY (id_local) REFERENCES tb_local_dn(id_local) ON DELETE CASCADE,
    FOREIGN KEY (id_cardapio) REFERENCES tb_cardapio_dn(id_cardapio) ON DELETE CASCADE
);

-- Tabela de relação encontro-usuário (participantes)
CREATE TABLE IF NOT EXISTS tb_encontro_usuario_dn (
    id_encontro INTEGER NOT NULL,
    id_usuario INTEGER NOT NULL,
    nu_dependentes INTEGER DEFAULT 0,
    fl_anfitriao VARCHAR(10) DEFAULT 'false',
    fl_status CHAR(1) DEFAULT 'P', -- P=Pendente, C=Confirmado, R=Rejeitado
    PRIMARY KEY (id_encontro, id_usuario),
    FOREIGN KEY (id_encontro) REFERENCES tb_encontro_dn(id_encontro) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES tb_usuario_dn(id_usuario) ON DELETE CASCADE
);

-- Tabela de tipos de avaliação
CREATE TABLE IF NOT EXISTS tb_tipo_avaliacao_dn (
    id_avaliacao SERIAL PRIMARY KEY,
    nm_tipo_avaliacao VARCHAR(50) NOT NULL UNIQUE,
    fl_avaliador BOOLEAN DEFAULT true
);

-- Tabela de avaliações de encontros
CREATE TABLE IF NOT EXISTS tb_avaliacao_encontro_dn (
    id_usuario INTEGER NOT NULL,
    id_encontro INTEGER NOT NULL,
    vl_avaliacao INTEGER NOT NULL CHECK (vl_avaliacao >= 1 AND vl_avaliacao <= 5),
    id_avaliacao INTEGER NOT NULL,
    PRIMARY KEY (id_usuario, id_encontro, id_avaliacao),
    FOREIGN KEY (id_usuario) REFERENCES tb_usuario_dn(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_encontro) REFERENCES tb_encontro_dn(id_encontro) ON DELETE CASCADE,
    FOREIGN KEY (id_avaliacao) REFERENCES tb_tipo_avaliacao_dn(id_avaliacao) ON DELETE CASCADE
);

-- Tabela de imagens
CREATE TABLE IF NOT EXISTS tb_imagem_dn (
    id_imagem SERIAL PRIMARY KEY,
    id_sequence INTEGER NOT NULL,
    vl_url VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_sequence) REFERENCES tb_sequence_dn(id_sequence) ON DELETE CASCADE
);

-- Inserir tipos de avaliação padrão
INSERT INTO tb_tipo_avaliacao_dn (nm_tipo_avaliacao, fl_avaliador) VALUES
    ('Qualidade da Comida', true),
    ('Atendimento', true),
    ('Ambiente', true),
    ('Custo-Benefício', true),
    ('Experiência Geral', true)
ON CONFLICT (nm_tipo_avaliacao) DO NOTHING;

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_usuario_email ON tb_usuario_dn(vl_email);
CREATE INDEX IF NOT EXISTS idx_local_usuario ON tb_local_dn(id_usuario);
CREATE INDEX IF NOT EXISTS idx_cardapio_local ON tb_cardapio_dn(id_local);
CREATE INDEX IF NOT EXISTS idx_encontro_cardapio ON tb_encontro_dn(id_cardapio);
CREATE INDEX IF NOT EXISTS idx_encontro_data ON tb_encontro_dn(hr_encontro);
CREATE INDEX IF NOT EXISTS idx_encontro_usuario_status ON tb_encontro_usuario_dn(fl_status);
