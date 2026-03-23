# Testes de Integração - Backend Node.js

## 📋 Visão Geral

Testes de integração que **NÃO batem no banco de dados real**. Todos os testes usam **mocks** (simulações) para garantir:

- ✅ **Velocidade** - ~1.5s para 61 testes
- ✅ **Isolamento** - Sem side effects
- ✅ **Segurança** - Não polui o banco
- ✅ **Confiabilidade** - 100% de taxa de sucesso

## 🎯 Módulos Testados (6/6)

| Módulo | Testes | Arquivo |
|--------|--------|---------|
| Usuario | 9 | `usuario.service.test.ts` |
| Local | 9 | `local.service.test.ts` |
| Cardapio | 12 | `cardapio.service.test.ts` |
| Imagem | 6 | `imagem.service.test.ts` |
| Avaliacao | 10 | `avaliacao.service.test.ts` |
| Encontro | 15 | `encontro.service.test.ts` |
| **TOTAL** | **61** | **6 arquivos** |

## 🚀 Como Executar

### Executar todos os testes:
```bash
npm test
```

### Executar em modo watch:
```bash
npm run test:watch
```

### Gerar relatório de cobertura:
```bash
npm run test:coverage
```

## 🔒 Verificar que NÃO Polui o Banco

Para **provar** que os testes de integração NÃO modificam o banco de dados:

### 1️⃣ Execute o script SQL ANTES dos testes:
```sql
-- No seu cliente PostgreSQL (pgAdmin, DBeaver, etc)
-- Execute: node-backend/test/integration/verify-no-database-pollution.sql
```

**Anote os resultados!** Exemplo:
```
tabela                      | total
----------------------------|-------
tb_avaliacao_encontro_dn   | 0
tb_cardapio_dn             | 74
tb_encontro_dn             | 74
tb_encontro_usuario_dn     | 0
tb_imagem_dn               | 0
tb_local_dn                | 74
tb_sequence_dn             | 148
tb_tipo_avaliacao_dn       | 3
tb_usuario_dn              | 10
```

### 2️⃣ Execute os testes de integração:
```bash
cd node-backend
npm test
```

### 3️⃣ Execute o script SQL DEPOIS dos testes:
```sql
-- Execute novamente: verify-no-database-pollution.sql
```

### 4️⃣ Compare os resultados:

**Os números devem ser IDÊNTICOS!** ✅

Se os números forem diferentes, significa que os testes estão modificando o banco (o que NÃO deve acontecer).

## 🧪 Como Funcionam os Mocks

Os testes usam **Jest mocks** para simular o banco:

```typescript
// Mock da conexão do banco
mockConexao = {
  query: jest.fn(),  // ← Função FALSA
};

// Simula resposta do banco
mockConexao.query.mockResolvedValueOnce({
  rows: [{ id: 1, nome: 'Teste' }],  // ← Dados FALSOS
});
```

### Resultado:
- ❌ Nenhuma query SQL real é executada
- ❌ Nenhuma conexão ao PostgreSQL é feita
- ❌ Nenhum dado é inserido/atualizado/deletado
- ✅ Apenas a lógica de negócio é testada

## 📊 Diferença: Testes de Integração vs E2E

| Aspecto | Testes de Integração (Mocks) | Testes E2E (HTTP) |
|---------|-------------------------------|-------------------|
| **Bate no banco?** | ❌ NÃO | ✅ SIM |
| **Velocidade** | ⚡ Muito rápido (~1.5s) | 🐌 Mais lento (~11s) |
| **Isolamento** | ✅ 100% isolado | ⚠️ Pode ter side effects |
| **Segurança** | ✅ Não polui o banco | ⚠️ Pode deixar lixo |
| **Foco** | Lógica de negócio | API HTTP completa |

## 🎯 Quando Usar Cada Tipo

### Use Testes de Integração (Mocks) quando:
- ✅ Testar lógica de negócio
- ✅ Desenvolvimento rápido (TDD)
- ✅ CI/CD (sem banco de teste)
- ✅ Testar casos edge

### Use Testes E2E (HTTP) quando:
- ✅ Validar API completa
- ✅ Testar integração real
- ✅ Smoke tests em produção
- ✅ Validar contratos de API

## 📝 Exemplo de Teste

```typescript
describe('UsuarioService', () => {
  it('deve criar um usuário com sucesso', async () => {
    // Arrange - Prepara os mocks
    mockConexao.query
      .mockResolvedValueOnce({ rows: [{ id_sequence: 100 }] })
      .mockResolvedValueOnce({ rows: [] });

    // Act - Executa a ação
    await usuarioService.createUsuario(novoUsuario);

    // Assert - Verifica o resultado
    expect(mockConexao.query).toHaveBeenCalledTimes(2);
    expect(mockDatabase.setDados).toHaveBeenCalled();
  });
});
```

## 🏆 Benefícios

1. **Rápidos** - Executam em ~1.5 segundos
2. **Confiáveis** - 100% de taxa de sucesso
3. **Isolados** - Sem dependências externas
4. **Seguros** - Não modificam o banco
5. **Manuteníveis** - Código limpo e organizado
6. **Documentação** - Servem como documentação viva

## 📚 Tecnologias

- **Jest** - Framework de testes
- **ts-jest** - Suporte TypeScript
- **@jest/globals** - Tipos TypeScript
- **Mocks** - Simulação de dependências

## ✅ Conclusão

Os testes de integração são **100% seguros** e **NÃO modificam o banco de dados**. Use o script `verify-no-database-pollution.sql` para comprovar isso sempre que necessário!
