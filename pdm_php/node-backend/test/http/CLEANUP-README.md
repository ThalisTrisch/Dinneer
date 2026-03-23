## ⚠️ Problema: Testes E2E Poluem a tb_sequence_dn

### 🔴 O Problema

Os testes E2E (End-to-End) batem no banco de dados REAL e criam registros na tabela `tb_sequence_dn` que não são limpos automaticamente.

**Por quê isso acontece?**
- Quando criamos um usuário/local/cardápio nos testes, geramos um novo ID
- Esse ID é registrado na `tb_sequence_dn`
- Mesmo deletando o usuário/local/cardápio, a sequence permanece

**Exemplo:**
```
ANTES dos testes: tb_sequence_dn tem 148 registros
DEPOIS dos testes: tb_sequence_dn tem 160 registros ❌
```

### ✅ Solução 1: Limpeza Manual (Recomendado)

Execute o script SQL após rodar os testes E2E:

```sql
-- No pgAdmin, DBeaver, ou qualquer cliente PostgreSQL
-- Execute: node-backend/test/http/cleanup-test-data.sql
```

Este script:
- ✅ Remove APENAS sequences criadas pelos testes
- ✅ Mantém os dados originais do banco
- ✅ É seguro e reversível

### ✅ Solução 2: Workflow Completo

```bash
# 1. Anote o estado inicial
psql -d seu_banco -f test/http/verify-initial-state.sql

# 2. Execute os testes E2E
npm run test:e2e:summary

# 3. Limpe os dados de teste
psql -d seu_banco -f test/http/cleanup-test-data.sql

# 4. Verifique que voltou ao estado inicial
psql -d seu_banco -f test/http/verify-initial-state.sql
```

### 🎯 Alternativa: Use Testes de Integração (Mocks)

Se você quer testes que **NÃO poluem o banco**, use os testes de integração:

```bash
# Estes testes NÃO modificam o banco:
npm test
```

**Localização:** `node-backend/test/integration/`
- ❌ NÃO batem no banco
- ✅ Usam apenas MOCKS
- ✅ 100% seguros
- ⚡ Muito mais rápidos (~1.5s vs ~11s)

### 📊 Comparação

| Aspecto | Testes E2E | Testes Integração |
|---------|------------|-------------------|
| **Polui banco?** | ⚠️ SIM | ❌ NÃO |
| **Velocidade** | 🐌 ~11s | ⚡ ~1.5s |
| **Limpeza** | 🧹 Manual | ✅ Automática |
| **Uso** | Validação final | Desenvolvimento |

### 🔧 Ajustando o Script de Limpeza

O script `cleanup-test-data.sql` assume que seu banco original tem sequences até ID 148. Se for diferente, ajuste:

```sql
-- Opção 1: Deletar por ID
DELETE FROM tb_sequence_dn WHERE id_sequence > 148;

-- Opção 2: Deletar por timestamp (se tiver coluna created_at)
DELETE FROM tb_sequence_dn 
WHERE created_at > NOW() - INTERVAL '10 minutes';

-- Opção 3: Deletar por tipo (se souber quais são de teste)
DELETE FROM tb_sequence_dn 
WHERE nm_sequence IN ('U', 'L', 'C') 
AND id_sequence > 148;
```

### 💡 Dica: Banco de Teste Separado

Para evitar poluição, considere usar um banco de dados separado para testes:

```env
# .env.test
DATABASE_URL=postgresql://user:pass@localhost:5432/pdm_test
```

Assim você pode:
1. Rodar testes E2E no banco de teste
2. Limpar tudo com `DROP DATABASE pdm_test; CREATE DATABASE pdm_test;`
3. Manter o banco de desenvolvimento limpo

### 📝 Resumo

- **Testes E2E** = Poluem o banco (tb_sequence_dn)
- **Solução** = Execute `cleanup-test-data.sql` após os testes
- **Alternativa** = Use testes de integração (`npm test`) que não poluem

**Escolha a abordagem que melhor se adequa ao seu workflow!** 🎯
