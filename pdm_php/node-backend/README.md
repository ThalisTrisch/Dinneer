# Dinneer API - Node.js + TypeScript

Backend Node.js com Express e TypeScript para o aplicativo Dinneer, migrado do PHP mantendo compatibilidade total.

## 🚀 Tecnologias

- Node.js
- TypeScript
- Express
- PostgreSQL (pg)
- Criptografia AES-256-CBC (compatível com PHP)

## 📋 Pré-requisitos

- Node.js 18+ instalado
- PostgreSQL rodando (mesma base do PHP)
- npm ou yarn

## 🔧 Instalação

1. Entre na pasta do projeto:
```bash
cd node-backend
```

2. Instale as dependências:
```bash
npm install
```

3. Configure as variáveis de ambiente:
O arquivo `.env` já está configurado com as mesmas credenciais do PHP:
```
DB_HOST=200.19.1.18
DB_PORT=5432
DB_USER=thalistrisch
DB_PASSWORD=123456
DB_NAME=thalistrisch
PORT=3000
```

## ▶️ Executar

### Modo desenvolvimento (com hot reload):
```bash
npm run dev
```

### Build para produção:
```bash
npm run build
npm start
```

## 🌐 Endpoints Disponíveis

Base URL: `http://localhost:3000`

### Usuario

#### Login
```
POST /api/v1/usuario/UsuarioController?operacao=loginUsuario
Body: {
  "vl_email": "usuario@email.com",
  "vl_senha": "senha123"
}
```

#### Listar todos os usuários
```
GET /api/v1/usuario/UsuarioController?operacao=getUsuarios
```

#### Buscar usuário por ID
```
GET /api/v1/usuario/UsuarioController?operacao=getUsuario&id_usuario=1
```

#### Criar usuário
```
POST /api/v1/usuario/UsuarioController?operacao=createUsuario
Body: {
  "nu_cpf": "12345678900",
  "nm_usuario": "João",
  "nm_sobrenome": "Silva",
  "vl_email": "joao@email.com",
  "vl_senha": "senha123",
  "vl_foto": "https://..." (opcional)
}
```

#### Deletar usuário
```
POST /api/v1/usuario/UsuarioController?operacao=deleteUsuario
Body: {
  "id_usuario": 1
}
```

#### Atualizar foto de perfil
```
POST /api/v1/usuario/UsuarioController?operacao=atualizarFotoPerfil
Body: {
  "id_usuario": 1,
  "vl_foto": "https://..."
}
```

## 📦 Formato de Resposta

Todas as respostas seguem o mesmo formato do PHP:

```json
{
  "operacao": "loginUsuario",
  "NumMens": 0,
  "Mensagem": "Login bem-sucedido",
  "registros": 1,
  "dados": {
    "id_usuario": 1,
    "nm_usuario": "João",
    "nm_sobrenome": "Silva",
    "vl_email": "joao@email.com",
    "vl_foto": "https://..."
  }
}
```

## 🔐 Segurança

- Criptografia de senhas usando AES-256-CBC (compatível com PHP)
- Mesma chave e IV do PHP para manter compatibilidade
- CORS habilitado para requisições do Flutter

## 📁 Estrutura do Projeto

```
node-backend/
├── src/
│   ├── config/          # Configurações (DB, env)
│   ├── database/        # Classes de banco (Database, BaseService)
│   ├── modules/         # Módulos da aplicação
│   │   └── usuario/     # Módulo de usuário
│   ├── types/           # Tipos TypeScript
│   ├── utils/           # Utilitários (criptografia)
│   ├── app.ts           # Configuração do Express
│   └── server.ts        # Inicialização do servidor
├── package.json
├── tsconfig.json
└── .env
```

## 🔄 Migração do PHP

Este backend mantém:
- ✅ Mesma estrutura de URLs com `?operacao=`
- ✅ Mesmo formato de resposta JSON
- ✅ Mesma criptografia de senhas
- ✅ Mesmo banco de dados e tabelas
- ✅ Sistema manual de sequências

## 🧪 Testando com Flutter

No seu app Flutter, altere a URL base de:
```dart
// PHP
http://localhost/pdm/api/v1/usuario/UsuarioController.php?operacao=loginUsuario

// Node.js
http://localhost:3000/api/v1/usuario/UsuarioController?operacao=loginUsuario
```

## 📝 Próximos Passos

- [ ] Migrar módulo Cardapio
- [ ] Migrar módulo Encontro
- [ ] Migrar módulo Local
- [ ] Migrar módulo Avaliacao
- [ ] Migrar módulo Imagem
