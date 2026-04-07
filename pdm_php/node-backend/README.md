# 🚀 Dinneer Backend - Node.js + TypeScript

API REST para o aplicativo Dinneer, construída com Node.js, TypeScript, Express e PostgreSQL.

## 📋 Índice

- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Executar](#executar)
- [Estrutura](#estrutura)
- [API Endpoints](#api-endpoints)
- [Testes](#testes)

## 🔧 Pré-requisitos

- **Node.js** 18+ 
- **PostgreSQL** 14+
- **npm** ou **yarn**

## 📦 Instalação

```bash
# Navegar para o diretório do backend
cd Dinneer/pdm_php/node-backend

# Instalar dependências
npm install
```

## ⚙️ Configuração

### 1. Criar arquivo .env

```bash
cp .env.example .env
```

### 2. Editar .env

```env
# Configurações do Banco de Dados
DB_HOST=localhost
DB_PORT=5432
DB_USER=seu_usuario
DB_PASSWORD=sua_senha
DB_NAME=dinneer_local

# Configurações do Servidor
PORT=3000
NODE_ENV=development
```

### 3. Criar Banco de Dados

```bash
# Conectar ao PostgreSQL
psql postgres

# Criar banco
CREATE DATABASE dinneer_local;

# Sair
\q
```

### 4. Criar Tabelas (Migration)

```bash
psql dinneer_local -f src/database/schema-local.sql
```

### 5. Popular com Dados de Teste (Seed)

```bash
psql dinneer_local -f src/database/seed-data.sql
```

## 🚀 Executar

### Modo Desenvolvimento

```bash
npm run dev
```

Servidor rodando em: `http://localhost:3000`

### Modo Produção

```bash
npm run build
npm start
```

### Verificar se está rodando

```bash
curl http://localhost:3000
```

Resposta esperada:
```json
{
  "message": "Dinneer API - Node.js + TypeScript",
  "version": "1.0.0",
  "endpoints": [...]
}
```

## 📁 Estrutura do Projeto

```
node-backend/
├── src/
│   ├── app.ts                 # Configuração do Express
│   ├── server.ts              # Inicialização do servidor
│   │
│   ├── config/                # Configurações
│   │   └── database.config.ts
│   │
│   ├── database/              # Banco de Dados
│   │   ├── Database.ts        # Classe de conexão
│   │   ├── BaseService.ts     # Service base
│   │   ├── schema-local.sql   # Schema (CREATE TABLE)
│   │   └── seed-data.sql      # Dados de teste
│   │
│   ├── modules/               # Módulos da API
│   │   ├── usuario/
│   │   │   ├── usuario.controller.ts
│   │   │   ├── usuario.service.ts
│   │   │   └── usuario.routes.ts
│   │   │
│   │   ├── local/
│   │   ├── cardapio/
│   │   ├── encontro/
│   │   ├── avaliacao/
│   │   └── imagem/
│   │
│   ├── types/                 # TypeScript types
│   └── utils/                 # Utilitários
│
├── test/                      # Testes
│   ├── http/                  # Testes HTTP (REST Client)
│   └── integration/           # Testes de integração
│
├── .env.example               # Exemplo de configuração
├── package.json
├── tsconfig.json
└── README.md
```

## 🌐 API Endpoints

### Base URL
```
http://localhost:3000/api/v1
```

### Usuários (`/usuario/UsuarioController`)

| Operação | Método | Descrição |
|----------|--------|-----------|
| `getUsuarios` | GET | Lista todos os usuários |
| `getUsuario` | GET | Busca usuário por ID |
| `loginUsuario` | POST | Autentica usuário |
| `createUsuario` | POST | Cria novo usuário |
| `deleteUsuario` | POST | Deleta usuário |
| `atualizarFotoPerfil` | POST | Atualiza foto do perfil |

### Locais (`/local/LocalController`)

| Operação | Método | Descrição |
|----------|--------|-----------|
| `getLocais` | GET | Lista todos os locais |
| `getLocal` | GET | Busca local por ID |
| `getMeusLocais` | GET | Lista locais do usuário |
| `createLocal` | POST | Cria novo local |
| `deleteLocal` | POST | Deleta local |

### Cardápios (`/cardapio/CardapioController`)

| Operação | Método | Descrição |
|----------|--------|-----------|
| `getCardapiosDisponiveis` | GET | Lista jantares disponíveis |
| `getCardapio` | GET | Busca cardápio por ID |
| `createJantarCompleto` | POST | Cria jantar completo |
| `updateJantar` | POST | Atualiza jantar |
| `deleteJantar` | POST | Deleta jantar |

### Encontros (`/encontro/EncontroController`)

| Operação | Método | Descrição |
|----------|--------|-----------|
| `addUsuarioEncontro` | POST | Solicita reserva |
| `aprovarReserva` | POST | Aprova convidado |
| `rejeitarReserva` | POST | Rejeita convidado |
| `getParticipantes` | GET | Lista participantes |
| `verificarReserva` | GET | Verifica se já reservou |
| `deleteUsuarioEncontro` | POST | Cancela reserva |
| `getMinhasReservas` | GET | Minhas reservas (convidado) |
| `getMeusJantaresCriados` | GET | Meus jantares (anfitrião) |

### Avaliações (`/avaliacao/AvaliacaoController`)

| Operação | Método | Descrição |
|----------|--------|-----------|
| `createAvaliacao` | POST | Cria avaliação |
| `getTiposAvaliacao` | GET | Lista tipos de avaliação |
| `getMediaAvaliacaoUsuario` | GET | Média do anfitrião |

## 📝 Exemplos de Uso

### Listar Usuários

```bash
curl "http://localhost:3000/api/v1/usuario/UsuarioController?operacao=getUsuarios" | jq
```

### Login

```bash
curl -X POST "http://localhost:3000/api/v1/usuario/UsuarioController?operacao=loginUsuario" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "vl_email=joao.silva@email.com&vl_senha=senha123" | jq
```

### Listar Jantares Disponíveis

```bash
curl "http://localhost:3000/api/v1/cardapio/CardapioController?operacao=getCardapiosDisponiveis" | jq
```

### Criar Jantar

```bash
curl -X POST "http://localhost:3000/api/v1/cardapio/CardapioController?operacao=createJantarCompleto" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "id_usuario=1&nm_cardapio=Teste&ds_cardapio=Descrição&preco_refeicao=50&nu_max_convidados=10&hr_encontro=2026-12-31T20:00:00&id_local=1" | jq
```

## 🧪 Testes

### Testar Conexão com Banco

```bash
node test-db-quick.js
```

### Testar Endpoints (REST Client)

Use os arquivos `.http` na pasta `test/http/`:

```
test/http/
├── usuario/
│   └── usuario.http
├── cardapio/
│   └── cardapio.http
└── encontro/
    └── encontro.http
```

Abra no VS Code com a extensão REST Client instalada.

## 🗄️ Banco de Dados

### Tabelas

- `tb_usuario_dn` - Usuários
- `tb_local_dn` - Locais dos anfitriões
- `tb_cardapio_dn` - Cardápios/Jantares
- `tb_encontro_dn` - Encontros/Eventos
- `tb_encontro_usuario_dn` - Participantes
- `tb_tipo_avaliacao_dn` - Tipos de avaliação
- `tb_avaliacao_encontro_dn` - Avaliações
- `tb_imagem_dn` - Imagens
- `tb_sequence_dn` - Controle de IDs

## 🐛 Troubleshooting

### Porta 3000 já está em uso

```bash
# Encontrar processo
lsof -ti:3000

# Matar processo
lsof -ti:3000 | xargs kill -9
```