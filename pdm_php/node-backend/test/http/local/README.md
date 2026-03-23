# 🧪 Testes E2E - Módulo Local

Scripts de teste End-to-End para o módulo de locais.

## 📋 Arquivos

- `test-local.sh` - Script de teste Unix/Linux/Mac
- `test-local.bat` - Script de teste Windows
- `local.http` - Testes manuais (REST Client)

## 🚀 Como Executar

### Opção 1: NPM Script (Recomendado)
```bash
npm run test:e2e:local
```

### Opção 2: Diretamente

#### Windows:
```cmd
cd node-backend\test\http\local
test-local.bat
```

#### Unix/Linux/Mac:
```bash
cd node-backend/test/http/local
chmod +x test-local.sh
./test-local.sh
```

## 📊 O que é testado

1. ✅ **Criação de local**
   - Gera ID automaticamente
   - Associa ao usuário
   - Valida campos obrigatórios

2. ✅ **Busca por ID**
   - Retorna dados completos
   - Valida existência

3. ✅ **Listagem geral**
   - Lista todos os locais
   - Retorna array completo

4. ✅ **Locais do usuário**
   - Filtra por id_usuario
   - Ordena por ID decrescente
   - Retorna lista vazia se não houver

5. ✅ **Deleção**
   - Remove local
   - Remove dependências (cascata)
   - Limpa banco de dados

6. ✅ **Verificação**
   - Confirma deleção
   - Valida limpeza

## 🎯 Dados de Teste

```json
{
  "nu_cep": "99999999",
  "nu_casa": "9999",
  "id_usuario": 6,
  "nu_cnpj": "12345678901234",
  "dc_complemento": "Local de Teste E2E"
}
```

## 📝 Endpoints Testados

- `POST /api/v1/local/LocalController?operacao=createLocal`
- `GET /api/v1/local/LocalController?operacao=getLocal&id_local={id}`
- `GET /api/v1/local/LocalController?operacao=getLocais`
- `GET /api/v1/local/LocalController?operacao=getMeusLocais&id_usuario={id}`
- `POST /api/v1/local/LocalController?operacao=deleteLocal`

## ⚙️ Pré-requisitos

- Servidor rodando em `http://localhost:3000`
- PostgreSQL conectado
- curl instalado
- Usuário com ID 6 existente no banco

## 🔄 Fluxo do Teste

```
1. Criar local → Extrai ID
2. Buscar por ID → Confirma criação
3. Listar todos → Valida inclusão
4. Listar do usuário → Filtra corretamente
5. Deletar local → Remove do banco
6. Verificar deleção → Confirma limpeza
```

## 🗑️ Deleção em Cascata

Ao deletar um local, também são removidos:
- Encontros associados (`tb_encontro_dn`)
- Cardápios associados (`tb_cardapio_dn`)

## ✅ Resultado Esperado

```
==========================================
🧪 Teste E2E - Módulo Local
==========================================

1. Criando local de teste...
✅ Local criado com sucesso!
ID do local criado: 52

2. Buscando local por ID (52)...
✅ Local encontrado!

3. Listando todos os locais...
✅ Total de locais no banco: 9

4. Buscando locais do usuário (6)...
✅ Locais do usuário: 3

5. Deletando local de teste (limpeza)...
✅ Local deletado com sucesso! Banco limpo.

6. Verificando se local foi deletado...
✅ Confirmado: Local não existe mais no banco

🎉 Testes E2E do módulo Local concluídos!
```

## 🔗 Dependências

Este módulo é usado por:
- **Cardapio** - Cardápios pertencem a locais
- **Encontro** - Encontros acontecem em locais
