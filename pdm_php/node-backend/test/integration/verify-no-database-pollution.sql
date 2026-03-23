-- Script para verificar que os testes de integração NÃO poluem o banco
-- Execute este script ANTES e DEPOIS de rodar: npm test
-- Os números devem ser IDÊNTICOS, provando que os testes usam apenas MOCKS

-- ============================================
-- CONTAGEM DE REGISTROS EM TODAS AS TABELAS
-- ============================================

SELECT 'tb_usuario_dn' as tabela, COUNT(*) as total FROM public.tb_usuario_dn
UNION ALL
SELECT 'tb_local_dn' as tabela, COUNT(*) as total FROM public.tb_local_dn
UNION ALL
SELECT 'tb_cardapio_dn' as tabela, COUNT(*) as total FROM public.tb_cardapio_dn
UNION ALL
SELECT 'tb_encontro_dn' as tabela, COUNT(*) as total FROM public.tb_encontro_dn
UNION ALL
SELECT 'tb_encontro_usuario_dn' as tabela, COUNT(*) as total FROM public.tb_encontro_usuario_dn
UNION ALL
SELECT 'tb_avaliacao_encontro_dn' as tabela, COUNT(*) as total FROM public.tb_avaliacao_encontro_dn
UNION ALL
SELECT 'tb_imagem_dn' as tabela, COUNT(*) as total FROM public.tb_imagem_dn
UNION ALL
SELECT 'tb_sequence_dn' as tabela, COUNT(*) as total FROM public.tb_sequence_dn
UNION ALL
SELECT 'tb_tipo_avaliacao_dn' as tabela, COUNT(*) as total FROM public.tb_tipo_avaliacao_dn
ORDER BY tabela;

-- ============================================
-- RESULTADO ESPERADO:
-- Os números devem ser EXATAMENTE OS MESMOS antes e depois de rodar npm test
-- Isso prova que os testes de integração NÃO modificam o banco de dados
-- ============================================
