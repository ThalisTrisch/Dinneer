# 🧪 Testes E2E - Dinneer API

Scripts de teste End-to-End para validar os módulos da API.

## 📁 Estrutura de Diretórios

```
test/http/
├── README.md           # Este arquivo
├── usuario/            # Testes do módulo Usuario
│   ├── test-complete.sh
│   ├── test-complete.bat
│   ├── usuario.http
│   └── README.md
└── local/              # Testes do módulo Local
    ├── test-local.sh
    ├── test-local.bat
    ├── local.http
    └── README.md
```

## 📋 Módulos Disponíveis

### 👤 Usuario
Testes de autenticação e gerenciamento de usuários.
- [Documentação completa](./usuario/README.md)
- Scripts: `test-complete.sh` / `test-complete.bat`

### 🏠 Local
Testes de gerenciamento de locais.
- [Documentação completa](./local/README.md)
- Scripts: `test-local.sh` / `test-local.bat`

## 🚀 Como Executar

### Opção 1: NPM Scripts (Recomendado - Multiplataforma)

Os scripts NPM detectam automaticamente seu sistema operacional:

```bash
# Testar módulo Usuario
npm run test:e2e:usuario

# Testar módulo Local
npm run test:e2e:local

# Testar TODOS os módulos
npm run test:e2e
```

### Opção 2: Executar Diretamente

#### No Windows:
```cmd
cd node-backend\test\http
test-complete.bat
test-local.bat
```

#### No Unix/Linux/Mac:
```bash
cd node-backend/test/http
chmod +x test-complete.sh test-local.sh
./test-complete.sh
./test-local.sh
```

### Opção 3: VS Code REST Client

1. Instale a extensão "REST Client" no VS Code
2. Abra os arquivos `.http`:
   - `usuario.http`
   - `local.http`
3. Clique em "Send Request" acima de cada teste

## 📊 O que os testes fazem

### test-complete (Usuario)
1. ✅ Cria usuário de teste
2. ✅ Testa login
3. ✅ Busca usuário por ID
4. ✅ Atualiza foto de perfil
5. ✅ Deleta usuário
6. ✅ Verifica deleção

### test-local (Local)
1. ✅ Cria local de teste
2. ✅ Busca local por ID
3. ✅ Lista todos os locais
4. ✅ Lista locais do usuário
5. ✅ Deleta local
6. ✅ Verifica deleção

## ⚙️ Pré-requisitos

1. **Servidor rodando**: 
   ```bash
   npm run dev
   ```

2. **curl instalado**:
   - Windows: Já vem instalado no Windows 10+
   - Mac: Já vem instalado
   - Linux: `sudo apt install curl` ou `sudo yum install curl`

3. **Banco de dados PostgreSQL** conectado e rodando

## 🎯 Estrutura dos Scripts

### Scripts Unix (.sh)
- Usa bash
- Cores no terminal (verde/vermelho/amarelo)
- Formatação JSON com `python3 -m json.tool`
- Extração de IDs com `grep` e `sed`

### Scripts Windows (.bat)
- Usa cmd/batch
- Sem cores (para compatibilidade)
- Salva respostas em arquivos temporários
- Extração de IDs com `findstr`
- Limpa arquivos temporários automaticamente

## 🔧 Troubleshooting

### Erro: "curl não encontrado"
**Windows**: Atualize para Windows 10+ ou instale curl manualmente
**Linux/Mac**: Instale curl com seu gerenciador de pacotes

### Erro: "Permissão negada" (Unix)
```bash
chmod +x test/http/*.sh
```

### Erro: "Servidor não responde"
Verifique se o servidor está rodando:
```bash
npm run dev
```

### Erro: "Banco de dados não conectado"
Verifique as credenciais no arquivo `.env`

## 📝 Adicionando Novos Testes

Para criar testes para um novo módulo:

1. **Criar script Unix** (`test-[modulo].sh`):
   ```bash
   #!/bin/bash
   # Copiar estrutura de test-local.sh
   ```

2. **Criar script Windows** (`test-[modulo].bat`):
   ```batch
   @echo off
   REM Copiar estrutura de test-local.bat
   ```

3. **Adicionar ao package.json**:
   ```json
   "test:e2e:[modulo]:unix": "chmod +x test/http/test-[modulo].sh && ./test/http/test-[modulo].sh",
   "test:e2e:[modulo]:win": "test\\http\\test-[modulo].bat",
   "test:e2e:[modulo]": "node -e \"process.platform === 'win32' ? require('child_process').execSync('npm run test:e2e:[modulo]:win', {stdio: 'inherit'}) : require('child_process').execSync('npm run test:e2e:[modulo]:unix', {stdio: 'inherit'})\""
   ```

4. **Atualizar test:e2e principal**:
   ```json
   "test:e2e": "npm run test:e2e:usuario && npm run test:e2e:local && npm run test:e2e:[modulo]"
   ```

## 🎨 Exemplo de Saída

```
==========================================
🧪 Teste E2E - Módulo Usuario
==========================================

1. Criando usuário de teste...
✅ Usuário criado com sucesso! ID: 50

2. Testando login com usuário criado...
✅ Login realizado com sucesso!

...

🎉 Testes E2E concluídos!

Resumo:
  ✅ Criação de usuário
  ✅ Login
  ✅ Busca por ID
  ✅ Atualização de foto
  ✅ Deleção de usuário
  ✅ Banco de dados limpo
```

## 📚 Mais Informações

- [Documentação da API](../../README.md)
- [Guia de Desenvolvimento](../../README.md#desenvolvimento)
