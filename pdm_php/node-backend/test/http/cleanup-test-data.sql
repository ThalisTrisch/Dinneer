-- Script de limpeza COMPLETA dos dados de teste E2E
-- Remove TODOS os registros criados durante os testes
-- Mantém apenas os dados originais do banco

-- ============================================
-- LIMPEZA COMPLETA DE DADOS DE TESTE
-- ============================================

-- IMPORTANTE: Anote o maior ID ANTES de rodar os testes!
-- Execute: SELECT MAX(id_sequence) FROM tb_sequence_dn;
-- Exemplo: Se retornar 148, use esse número abaixo

-- 1. Deletar sequences criadas pelos testes
-- AJUSTE O NÚMERO 148 PARA O MAIOR ID DO SEU BANCO ORIGINAL!
DELETE FROM tb_sequence_dn WHERE id_sequence > 148;

-- 2. Verificar resultado
SELECT 
    'tb_sequence_dn' as tabela, 
    COUNT(*) as total,
    'Deve ser 148 (ou o número original)' as esperado
FROM tb_sequence_dn;

-- ============================================
-- ALTERNATIVA: Se não souber o ID original
-- ============================================

-- Opção A: Deletar por timestamp (requer coluna created_at)
-- DELETE FROM tb_sequence_dn 
-- WHERE created_at > NOW() - INTERVAL '1 hour';

-- Opção B: Deletar TUDO e reconstruir
-- CUIDADO: Isso apaga TUDO!
-- DELETE FROM tb_sequence_dn;
-- -- Depois reconstrua com seus dados originais

-- ============================================
-- PARA DESCOBRIR O ID ORIGINAL
-- ============================================

-- Execute ANTES de rodar os testes E2E:
-- SELECT MAX(id_sequence) as maior_id_original FROM tb_sequence_dn;
-- Anote esse número e use na linha 15 acima!
