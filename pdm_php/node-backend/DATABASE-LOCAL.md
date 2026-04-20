# 🗄️ Banco de Dados Local - Dinneer

Guia completo para trabalhar com o banco de dados PostgreSQL local.

## 📋 Configuração Atual

O projeto está configurado para usar **PostgreSQL local** ao invés do servidor remoto.

### Configuração (.env)
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=i589591
DB_PASSWORD=
DB_NAME=dinneer_local
```

## 🚀 Como Usar

### 1. Criar o Banco (primeira vez)
```bash
createdb dinneer_local
```

### 2. Criar as Tabelas
```bash
cd Dinneer/pdm_php/node-backend
psql dinneer_local -f src/database/schema-local.sql
```

### 3. Popular com Dados de Teste
```bash
psql dinneer_local -f src/database/seed-data.sql
```

### 4. Iniciar o Servidor
```bash
npm run dev
```

## 📊 Dados de Teste Incluídos

### Usuários (3)
- **João Silva** (joao.silva@email.com) - Anfitrião
- **Maria Santos** (maria.santos@email.com) - Anfitrião
- **Pedro Oliveira** (pedro.oliveira@email.com) - Convidado

### Jantares (2)
1. **Feijoada Completa** - R$ 45,00
   - Anfitrião: João Silva
   - Data: Daqui a 3 dias
   - Vagas: 8 pessoas
   - Confirmados: 3 (João + Pedro com 1 dependente)

2. **Jantar Italiano** - R$ 65,00
   - Anfitrião: Maria Santos
   - Data: Daqui a 7 dias
   - Vagas: 6 pessoas
   - Confirmados: 1 (Maria)

## 🧪 Testar a API

### Listar Usuários
```bash
curl "http://localhost:3000/api/v1/usuario/UsuarioController?operacao=getUsuarios" | jq
```

### Listar Cardápios Disponíveis
```bash
curl "http://localhost:3000/api/v1/cardapio/CardapioController?operacao=getCardapiosDisponiveis" | jq
```

### Buscar Usuário por ID
```bash
curl "http://localhost:3000/api/v1/usuario/UsuarioController?operacao=getUsuario&id_usuario=1" | jq
```

### Listar Locais
```bash
curl "http://localhost:3000/api/v1/local/LocalController?operacao=getLocais" | jq
```

## 🔧 Comandos Úteis

### Resetar o Banco (CUIDADO: apaga todos os dados)
```bash
psql dinneer_local -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
psql dinneer_local -f src/database/schema-local.sql
psql dinneer_local -f src/database/seed-data.sql
```

### Ver Dados no Banco
```bash
# Conectar ao banco
psql dinneer_local

# Listar tabelas
\dt

# Ver usuários
SELECT * FROM tb_usuario_dn;

# Ver jantares disponíveis
SELECT 
    c.nm_cardapio,
    c.preco_refeicao,
    u.nm_usuario || ' ' || u.nm_sobrenome as anfitriao,
    e.hr_encontro,
    e.nu_max_convidados
FROM tb_cardapio_dn c
JOIN tb_local_dn l ON c.id_local = l.id_local
JOIN tb_usuario_dn u ON l.id_usuario = u.id_usuario
JOIN tb_encontro_dn e ON c.id_cardapio = e.id_cardapio
WHERE e.hr_encontro > NOW();

# Sair
\q
```

### Verificar Contagem de Registros
```bash
psql dinneer_local -c "
SELECT 'USUÁRIOS' as tabela, COUNT(*) as total FROM tb_usuario_dn
UNION ALL SELECT 'LOCAIS', COUNT(*) FROM tb_local_dn
UNION ALL SELECT 'CARDÁPIOS', COUNT(*) FROM tb_cardapio_dn
UNION ALL SELECT 'ENCONTROS', COUNT(*) FROM tb_encontro_dn
UNION ALL SELECT 'PARTICIPANTES', COUNT(*) FROM tb_encontro_usuario_dn
UNION ALL SELECT 'TIPOS AVALIAÇÃO', COUNT(*) FROM tb_tipo_avaliacao_dn;
"
```

### Testar Conexão
```bash
node test-db-quick.js
```

## 📁 Estrutura de Arquivos

```
src/database/
├── schema-local.sql      # Schema completo (CREATE TABLE)
├── seed-data.sql         # Dados de teste
├── Database.ts           # Classe de conexão
└── BaseService.ts        # Classe base para services
```

## 🔄 Voltar para o Banco Remoto

Se precisar voltar a usar o banco remoto, edite o `.env`:

```env
DB_HOST=200.19.1.18
DB_PORT=5432
DB_USER=thalistrisch
DB_PASSWORD=123456
DB_NAME=thalistrisch
```

E reinicie o servidor.

## ⚠️ Observações Importantes

1. **Senhas**: As senhas nos dados de teste são placeholders. Use o endpoint de criação de usuário para gerar senhas válidas.

2. **IDs Manuais**: O sistema usa IDs manuais controlados pela tabela `tb_sequence_dn`. Ao criar novos registros via API, os IDs são gerados automaticamente.

3. **Timestamps**: Os encontros são criados com datas relativas (NOW() + INTERVAL), então sempre aparecem como futuros.

4. **Foreign Keys**: O banco usa CASCADE DELETE, então deletar um usuário remove todos os seus locais, cardápios e encontros.

## 🎯 Próximos Passos

- [ ] Adicionar mais dados de teste se necessário
- [ ] Criar script de backup do banco local
- [ ] Documentar endpoints da API
- [ ] Adicionar testes automatizados

## 💡 Dicas

- Use **TablePlus** ou **pgAdmin** para visualizar o banco graficamente
- Mantenha o `.env` no `.gitignore` para não commitar credenciais
- Faça backup regular do banco local: `pg_dump dinneer_local > backup.sql`
- Restaurar backup: `psql dinneer_local < backup.sql`
