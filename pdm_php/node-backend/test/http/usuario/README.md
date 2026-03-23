# 🧪 Testes E2E - Módulo Usuario

Scripts de teste End-to-End para o módulo de usuários.

## 📋 Arquivos

- `test-complete.sh` - Script de teste Unix/Linux/Mac
- `test-complete.bat` - Script de teste Windows
- `usuario.http` - Testes manuais (REST Client)

## 🚀 Como Executar

### Opção 1: NPM Script (Recomendado)
```bash
npm run test:e2e:usuario
```

### Opção 2: Diretamente

#### Windows:
```cmd
cd node-backend\test\http\usuario
test-complete.bat
```

#### Unix/Linux/Mac:
```bash
cd node-backend/test/http/usuario
chmod +x test-complete.sh
./test-complete.sh
```

## 📊 O que é testado

1. ✅ **Criação de usuário**
   - Gera ID automaticamente
   - Criptografa senha
   - Valida CPF e email únicos

2. ✅ **Login**
   - Valida email e senha
   - Retorna dados do usuário
   - Remove senha do retorno

3. ✅ **Busca por ID**
   - Retorna dados completos
   - Valida existência

4. ✅ **Atualização de foto**
   - Atualiza URL da foto
   - Mantém outros dados

5. ✅ **Deleção**
   - Remove usuário
   - Limpa banco de dados

6. ✅ **Verificação**
   - Confirma deleção
   - Valida limpeza

## 🎯 Dados de Teste

```json
{
  "nu_cpf": "99999999999",
  "nm_usuario": "Usuario",
  "nm_sobrenome": "Teste",
  "vl_email": "teste_automatizado@email.com",
  "vl_senha": "senha_teste_123",
  "vl_foto": null
}
```

## 📝 Endpoints Testados

- `POST /api/v1/usuario/UsuarioController?operacao=createUsuario`
- `POST /api/v1/usuario/UsuarioController?operacao=loginUsuario`
- `GET /api/v1/usuario/UsuarioController?operacao=getUsuario&id_usuario={id}`
- `POST /api/v1/usuario/UsuarioController?operacao=atualizarFotoPerfil`
- `POST /api/v1/usuario/UsuarioController?operacao=deleteUsuario`

## ⚙️ Pré-requisitos

- Servidor rodando em `http://localhost:3000`
- PostgreSQL conectado
- curl instalado

## 🔄 Fluxo do Teste

```
1. Criar usuário → Extrai ID
2. Login com credenciais → Valida autenticação
3. Buscar por ID → Confirma criação
4. Atualizar foto → Testa UPDATE
5. Deletar usuário → Remove do banco
6. Verificar deleção → Confirma limpeza
```

## ✅ Resultado Esperado

```
==========================================
🧪 Teste Completo da API Dinneer
==========================================

1. Criando usuário de teste...
✅ Usuário criado com sucesso! ID: 50

2. Testando login com usuário criado...
✅ Login realizado com sucesso!

3. Buscando usuário por ID (50)...
✅ Usuário encontrado!

4. Atualizando foto de perfil...
✅ Foto atualizada com sucesso!

5. Deletando usuário de teste (limpeza)...
✅ Usuário deletado com sucesso! Banco limpo.

6. Verificando se usuário foi deletado...
✅ Confirmado: Usuário não existe mais no banco

🎉 Testes concluídos!
