-- Seed Data para Banco Local Dinneer
-- Dados de teste para desenvolvimento

-- Limpar dados existentes (opcional - descomente se quiser resetar)
-- TRUNCATE TABLE tb_avaliacao_encontro_dn, tb_encontro_usuario_dn, tb_encontro_dn, 
--          tb_cardapio_dn, tb_local_dn, tb_usuario_dn, tb_sequence_dn, tb_imagem_dn CASCADE;

-- ============================================
-- 1. SEQUÊNCIAS (para controle de IDs)
-- ============================================
INSERT INTO tb_sequence_dn (id_sequence, nm_sequence) VALUES
(1, 'U'),
(2, 'U'),
(3, 'U'),
(4, 'L'),
(5, 'L'),
(6, 'C'),
(7, 'C'),
(8, 'E'),
(9, 'E')
ON CONFLICT DO NOTHING;

-- ============================================
-- 2. USUÁRIOS (senha: "senha123" criptografada)
-- ============================================
-- Nota: A senha "senha123" criptografada com o sistema atual
-- Você pode usar o endpoint de criação de usuário para gerar senhas corretas
INSERT INTO tb_usuario_dn (id_usuario, nu_cpf, nm_usuario, nm_sobrenome, vl_email, vl_senha, vl_foto, fl_anfitriao) VALUES
(1, '12345678901', 'João', 'Silva', 'joao.silva@email.com', 'U2FsdGVkX1+senha_criptografada_aqui', 'https://i.pravatar.cc/150?img=1', 'true'),
(2, '98765432109', 'Maria', 'Santos', 'maria.santos@email.com', 'U2FsdGVkX1+senha_criptografada_aqui', 'https://i.pravatar.cc/150?img=2', 'true'),
(3, '11122233344', 'Pedro', 'Oliveira', 'pedro.oliveira@email.com', 'U2FsdGVkX1+senha_criptografada_aqui', 'https://i.pravatar.cc/150?img=3', 'false')
ON CONFLICT (id_usuario) DO NOTHING;

-- ============================================
-- 3. LOCAIS
-- ============================================
INSERT INTO tb_local_dn (id_local, id_usuario, nu_cep, nu_casa, nu_cnpj, dc_complemento) VALUES
(4, 1, '01310-100', '123', NULL, 'Apto 45'),
(5, 2, '04567-890', '456', '12345678000190', 'Casa com jardim')
ON CONFLICT (id_local) DO NOTHING;

-- ============================================
-- 4. CARDÁPIOS
-- ============================================
INSERT INTO tb_cardapio_dn (id_cardapio, id_local, nm_cardapio, ds_cardapio, preco_refeicao, vl_foto_cardapio) VALUES
(6, 4, 'Feijoada Completa', 'Feijoada tradicional com todos os acompanhamentos: arroz, couve, farofa, laranja e vinagrete. Inclui sobremesa.', 45.00, 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400'),
(7, 5, 'Jantar Italiano', 'Menu italiano autêntico: entrada de bruschetta, massa carbonara caseira, tiramisù de sobremesa e vinho.', 65.00, 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400')
ON CONFLICT (id_cardapio) DO NOTHING;

-- ============================================
-- 5. ENCONTROS (Jantares agendados)
-- ============================================
-- Encontros futuros para aparecerem na listagem
INSERT INTO tb_encontro_dn (id_encontro, id_local, id_cardapio, hr_encontro, nu_max_convidados, fl_anfitriao_confirma) VALUES
(8, 4, 6, NOW() + INTERVAL '3 days', 8, 'true'),
(9, 5, 7, NOW() + INTERVAL '7 days', 6, 'true')
ON CONFLICT (id_encontro) DO NOTHING;

-- ============================================
-- 6. PARTICIPANTES DOS ENCONTROS
-- ============================================
-- Anfitrião do encontro 8 (João)
INSERT INTO tb_encontro_usuario_dn (id_encontro, id_usuario, nu_dependentes, fl_anfitriao, fl_status) VALUES
(8, 1, 0, 'true', 'C')
ON CONFLICT (id_encontro, id_usuario) DO NOTHING;

-- Convidado confirmado no encontro 8 (Pedro)
INSERT INTO tb_encontro_usuario_dn (id_encontro, id_usuario, nu_dependentes, fl_anfitriao, fl_status) VALUES
(8, 3, 1, 'false', 'C')
ON CONFLICT (id_encontro, id_usuario) DO NOTHING;

-- Anfitrião do encontro 9 (Maria)
INSERT INTO tb_encontro_usuario_dn (id_encontro, id_usuario, nu_dependentes, fl_anfitriao, fl_status) VALUES
(9, 2, 0, 'true', 'C')
ON CONFLICT (id_encontro, id_usuario) DO NOTHING;

-- ============================================
-- 7. IMAGENS (opcional)
-- ============================================
INSERT INTO tb_imagem_dn (id_sequence, vl_url) VALUES
(1, 'https://i.pravatar.cc/150?img=1'),
(2, 'https://i.pravatar.cc/150?img=2'),
(3, 'https://i.pravatar.cc/150?img=3')
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFICAÇÃO DOS DADOS INSERIDOS
-- ============================================
-- Descomente para ver os dados inseridos:

-- SELECT 'USUÁRIOS' as tabela, COUNT(*) as total FROM tb_usuario_dn
-- UNION ALL
-- SELECT 'LOCAIS', COUNT(*) FROM tb_local_dn
-- UNION ALL
-- SELECT 'CARDÁPIOS', COUNT(*) FROM tb_cardapio_dn
-- UNION ALL
-- SELECT 'ENCONTROS', COUNT(*) FROM tb_encontro_dn
-- UNION ALL
-- SELECT 'PARTICIPANTES', COUNT(*) FROM tb_encontro_usuario_dn
-- UNION ALL
-- SELECT 'TIPOS AVALIAÇÃO', COUNT(*) FROM tb_tipo_avaliacao_dn;

-- ============================================
-- QUERIES ÚTEIS PARA TESTES
-- ============================================

-- Ver todos os jantares disponíveis com detalhes:
-- SELECT 
--     c.nm_cardapio,
--     c.preco_refeicao,
--     u.nm_usuario || ' ' || u.nm_sobrenome as anfitriao,
--     e.hr_encontro,
--     e.nu_max_convidados,
--     l.nu_cep,
--     l.nu_casa
-- FROM tb_cardapio_dn c
-- JOIN tb_local_dn l ON c.id_local = l.id_local
-- JOIN tb_usuario_dn u ON l.id_usuario = u.id_usuario
-- JOIN tb_encontro_dn e ON c.id_cardapio = e.id_cardapio
-- WHERE e.hr_encontro > NOW()
-- ORDER BY e.hr_encontro;

-- Ver participantes de um encontro:
-- SELECT 
--     u.nm_usuario || ' ' || u.nm_sobrenome as nome,
--     eu.nu_dependentes,
--     eu.fl_status,
--     eu.fl_anfitriao
-- FROM tb_encontro_usuario_dn eu
-- JOIN tb_usuario_dn u ON eu.id_usuario = u.id_usuario
-- WHERE eu.id_encontro = 8;
