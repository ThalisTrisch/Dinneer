-- Migration: Adicionar tabela de categorias e FK em tb_cardapio_dn

CREATE TABLE IF NOT EXISTS tb_categoria_dn (
    id_categoria SERIAL PRIMARY KEY,
    nm_categoria VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO tb_categoria_dn (nm_categoria) VALUES
    ('Brasileira'),
    ('Italiana'),
    ('Japonesa'),
    ('Mexicana'),
    ('Árabe'),
    ('Vegetariana'),
    ('Churrasco'),
    ('Massa'),
    ('Doce')
ON CONFLICT (nm_categoria) DO NOTHING;

ALTER TABLE tb_cardapio_dn
    ADD COLUMN IF NOT EXISTS id_categoria INTEGER REFERENCES tb_categoria_dn(id_categoria);
