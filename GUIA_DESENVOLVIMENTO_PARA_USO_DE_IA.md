# 🚀 Guia de Desenvolvimento - Dinneer

---

## 🤖 ATENÇÃO: SE VOCÊ É UMA IA

**LEIA ESTA SEÇÃO COM ATENÇÃO MÁXIMA ANTES DE FAZER QUALQUER CÓDIGO**

### ⚠️ REGRAS CRÍTICAS DE GIT/GITHUB - NÃO NEGOCIÁVEIS

#### 🚫 NUNCA, EM HIPÓTESE ALGUMA:

1. **NUNCA faça commit direto na branch `main`**
   - A branch `main` é SAGRADA
   - Qualquer commit direto na `main` pode quebrar o projeto inteiro
   - SEMPRE crie uma branch separada primeiro

2. **NUNCA faça merge sem aprovação**
   - Pull Requests DEVEM ser revisados por humanos
   - Não assuma que seu código está perfeito
   - Aguarde aprovação antes de qualquer merge

3. **NUNCA ignore conflitos de merge**
   - Se houver conflitos, PARE imediatamente
   - Informe o desenvolvedor humano
   - NÃO tente resolver conflitos complexos sozinho

4. **NUNCA force push (`git push -f`)**
   - Force push pode destruir o trabalho de outros
   - Se você acha que precisa de force push, você está fazendo algo errado
   - Consulte o desenvolvedor humano

#### ✅ SEMPRE FAÇA:

1. **SEMPRE comece com `git pull origin main`**
   - Antes de criar qualquer branch
   - Antes de começar qualquer trabalho
   - Isso evita conflitos futuros

2. **SEMPRE crie uma branch descritiva**
   ```bash
   git checkout -b feature/nome-claro-da-funcionalidade
   # OU
   git checkout -b fix/nome-claro-do-bug
   ```
   - Use nomes que expliquem O QUE está sendo feito
   - Exemplos BONS: `feature/adicionar-filtro-preco`, `fix/corrigir-validacao-email`
   - Exemplos RUINS: `feature/update`, `fix/bug`, `test`

3. **SEMPRE faça commits atômicos e descritivos**
   ```bash
   git commit -m "feat: adiciona validação de email no formulário de cadastro"
   ```
   - Um commit = uma mudança lógica
   - Mensagem deve explicar O QUE e POR QUÊ
   - Use o padrão: `feat:`, `fix:`, `refactor:`, `docs:`

4. **SEMPRE crie Pull Request com descrição completa**
   - Título claro e objetivo
   - Descrição detalhada do que foi feito
   - Como testar as mudanças
   - Screenshots se aplicável
   - Liste arquivos importantes modificados

5. **SEMPRE verifique antes de commitar**
   - Código compila sem erros?
   - Você testou localmente?
   - Removeu `console.log()` e `print()` de debug?
   - Código segue os padrões do projeto?

#### 🎯 FLUXO OBRIGATÓRIO PARA QUALQUER MUDANÇA:

```bash
# 1. SEMPRE comece atualizando
git checkout main
git pull origin main

# 2. Crie branch específica
git checkout -b feature/sua-funcionalidade

# 3. Faça suas mudanças
# ... código aqui ...

# 4. Teste TUDO localmente
# ... testes aqui ...

# 5. Commit com mensagem clara
git add .
git commit -m "feat: descrição clara e completa"

# 6. Push da branch
git push origin feature/sua-funcionalidade

# 7. Crie PR no GitHub
# 8. AGUARDE revisão humana
# 9. NÃO faça merge sozinho
```

### 📝 PADRÕES DE CÓDIGO - SEJA RIGOROSO

#### ❌ CÓDIGO INACEITÁVEL:

```dart
// ❌ NUNCA use variáveis de 1 letra
var u = getUser();
var x = 10;
var c = cardapio;

// ❌ NUNCA use nomes genéricos
var data;
var temp;
var result;
var obj;

// ❌ NUNCA deixe código comentado
// var oldCode = something();
// if (oldCondition) { }

// ❌ NUNCA deixe console.log/print de debug
console.log('debug aqui');
print('testando');
```

#### ✅ CÓDIGO ACEITÁVEL:

```dart
// ✅ Nomes descritivos e claros
var usuarioAtual = getUser();
var numeroMaximoConvidados = 10;
var cardapioSelecionado = cardapio;

// ✅ Nomes específicos
var dadosUsuario;
var cardapioTemporario;
var resultadoBusca;
var objetoConfiguracao;

// ✅ Comentários úteis (explique o PORQUÊ)
// Validamos antes porque a API não aceita valores nulos
// e isso causava crashes em produção
if (preco != null && preco > 0) {
  salvarJantar();
}

// ✅ Tratamento de erros adequado
try {
  await salvarDados();
} catch (e) {
  print('Erro ao salvar: $e');
  mostrarMensagemErro();
}
```

### 🗄️ BANCO DE DADOS - REGRAS ESTRITAS

#### ⚠️ SEMPRE que modificar o banco:

1. **Atualize `schema-local.sql`**
   - Adicione o CREATE TABLE completo
   - Inclua todas as constraints e foreign keys
   - Documente com comentários SQL

2. **Atualize `seed-data.sql`**
   - Adicione dados de teste realistas
   - Mínimo 2-3 registros por tabela
   - Dados devem fazer sentido no contexto

3. **Documente no PR**
   - Explique por que a tabela foi criada
   - Liste as colunas e seus propósitos
   - Indique impacto em outras partes do sistema

4. **Avise o time**
   - Mudanças no banco SEMPRE devem ser comunicadas
   - Outros desenvolvedores precisam atualizar seus bancos locais

### 🔍 ANTES DE CRIAR QUALQUER CÓDIGO:

1. **Entenda o contexto completo**
   - Leia os arquivos relacionados
   - Entenda a arquitetura existente
   - Não assuma, pergunte se tiver dúvida

2. **Verifique o padrão do projeto**
   - Como outros arquivos similares estão estruturados?
   - Qual convenção de nomenclatura está sendo usada?
   - Há algum padrão de design sendo seguido?

3. **Pense nas consequências**
   - Sua mudança afeta outras partes do código?
   - Você está quebrando alguma funcionalidade existente?
   - Há testes que precisam ser atualizados?

### 🚨 QUANDO PARAR E PEDIR AJUDA:

**PARE IMEDIATAMENTE e consulte o desenvolvedor humano se:**

- Você encontrou conflitos de merge
- Você não entende o código existente
- Você não tem certeza da melhor abordagem
- Você está prestes a fazer mudanças grandes
- Você está modificando arquivos críticos (config, database, auth)
- Algo não está funcionando como esperado
- Você está considerando deletar código que não entende

**LEMBRE-SE:** É MELHOR PERGUNTAR do que quebrar o código!

### 📊 CHECKLIST OBRIGATÓRIO ANTES DE CADA COMMIT:

- [ ] Código compila sem erros
- [ ] Testei todas as funcionalidades afetadas
- [ ] Removi TODOS os console.log/print de debug
- [ ] Todas as variáveis têm nomes descritivos (sem letras únicas)
- [ ] Comentei apenas o que é complexo (explicando o PORQUÊ)
- [ ] Removi código comentado desnecessário
- [ ] Código está formatado (Prettier/Dart Format)
- [ ] Se mudei o banco, atualizei schema E seed
- [ ] Criei branch específica (não estou na main)
- [ ] Fiz git pull origin main antes de começar
- [ ] Mensagem de commit é clara e descritiva
- [ ] Estou pronto para criar um PR com descrição completa

### 🎯 RESUMO PARA IA:

**Você é um assistente, não um decisor final.**

- ✅ Sugira código de qualidade
- ✅ Siga os padrões rigorosamente
- ✅ Seja crítico com seu próprio código
- ✅ Documente suas decisões
- ✅ Teste antes de commitar
- ❌ Nunca faça merge sozinho
- ❌ Nunca ignore conflitos
- ❌ Nunca trabalhe direto na main
- ❌ Nunca assuma que está certo sem testar

**Quando em dúvida: PERGUNTE. Sempre.**

---

## 📋 Índice
- [Configuração Inicial](#configuração-inicial)
- [Fluxo de Trabalho Diário](#fluxo-de-trabalho-diário)
- [Boas Práticas de Código](#boas-práticas-de-código)
- [Trabalhando com Git](#trabalhando-com-git)
- [Banco de Dados](#banco-de-dados)
- [Resolução de Problemas](#resolução-de-problemas)
- [Checklist Antes de Commitar](#checklist-antes-de-commitar)

---

## 🔧 Configuração Inicial

### 1. Clone o Repositório
```bash
git clone https://github.com/ThalisTrisch/Dinneer.git
cd Dinneer
```

### 2. Configure o Backend
```bash
cd pdm_php/node-backend

# Instalar dependências
npm install

# Verificar se o .env existe (já deve estar configurado)
# Windows: type .env
# Mac/Linux: cat .env
```

**Configuração do Banco de Dados:**
- Consulte o arquivo `pdm_php/node-backend/DATABASE-LOCAL.md` para instruções detalhadas
- Use uma ferramenta gráfica como **TablePlus**, **pgAdmin** ou **DBeaver** para:
  - Criar o banco `dinneer_local`
  - Executar o script `src/database/schema-local.sql`
  - Executar o script `src/database/seed-data.sql`

### 3. Configure o Frontend
```bash
cd ../../dinneer

# Instalar dependências
flutter pub get

# Verificar instalação
flutter doctor
```

---

## 📅 Fluxo de Trabalho Diário

### 🌅 Ao Começar o Dia

#### 1. SEMPRE Atualize o Código
```bash
# Volte para a branch main
git checkout main

# Puxe as últimas mudanças
git pull origin main
```

⚠️ **IMPORTANTE**: Faça isso TODA VEZ antes de começar a trabalhar!

#### 2. Verifique se Há Atualizações no Banco
Se houver novos arquivos SQL no PR:
- Abra sua ferramenta de banco de dados (TablePlus, pgAdmin, DBeaver)
- Execute os scripts SQL atualizados:
  - `src/database/schema-local.sql`
  - `src/database/seed-data.sql`

#### 3. Inicie os Serviços

**Terminal 1 - Backend:**
```bash
cd pdm_php/node-backend
npm run dev
```

**Terminal 2 - Frontend:**
```bash
cd dinneer
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=/tmp/chrome_dev_test"
```

---

## 💻 Trabalhando com Git

### 🌿 Criando uma Nova Branch

**NUNCA trabalhe direto na main!** Sempre crie uma branch para sua tarefa:

```bash
# Certifique-se de estar na main atualizada
git checkout main
git pull origin main

# Crie uma branch com nome descritivo
git checkout -b feature/nome-da-funcionalidade
# OU
git checkout -b fix/nome-do-bug
```

**Exemplos de nomes de branch:**
- `feature/adicionar-filtro-jantares`
- `feature/tela-notificacoes`
- `fix/corrigir-login-erro`
- `fix/validacao-formulario-jantar`

### 📝 Fazendo Commits

```bash
# Adicione os arquivos modificados
git add .

# Faça commit com mensagem clara
git commit -m "feat: adiciona filtro de jantares por preço"
```

**Padrão de mensagens de commit:**
- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `refactor:` - Refatoração de código
- `docs:` - Documentação
- `style:` - Formatação, ponto e vírgula, etc
- `test:` - Adição de testes

### 🚀 Enviando para o GitHub

```bash
# Envie sua branch
git push origin feature/nome-da-funcionalidade
```

### 🔄 Criando Pull Request

1. Vá para o GitHub: https://github.com/ThalisTrisch/Dinneer
2. Clique em "Compare & pull request"
3. Preencha:
   - **Título**: Descrição clara do que foi feito
   - **Descrição**: 
     - O que foi implementado
     - Como testar
     - Screenshots (se aplicável)
4. Solicite revisão de código
5. **AGUARDE APROVAÇÃO** antes de fazer merge

### ⚠️ Lidando com Conflitos

Se aparecer conflito ao fazer `git pull`:

```bash
# 1. Veja quais arquivos têm conflito
git status

# 2. Se forem POUCOS arquivos e POUCAS mudanças:
#    Abra os arquivos e resolva manualmente
#    Procure por <<<<<<< HEAD

# 3. Se forem MUITOS arquivos ou você não souber o que fazer:
#    PARE e contate o Bruno imediatamente!
#    NÃO tente resolver sozinho se não tiver certeza

# 4. Após resolver:
git add .
git commit -m "fix: resolve conflitos de merge"
```

---

## 📢 Comunicação com o Time

### ✅ Quando Fazer Merge na Main

**SEMPRE avise no grupo quando:**
1. Seu PR foi aprovado e mergeado na main
2. Houve mudanças no banco de dados
3. Houve mudanças em dependências (package.json, pubspec.yaml)

**Mensagem exemplo:**
```
🚀 PR mergeado na main!
Branch: feature/filtro-jantares
Mudanças: Adicionado filtro por preço na tela home

⚠️ Ação necessária:
- Todos devem fazer: git pull origin main
- Nenhuma mudança no banco
```

---

## 🎨 Boas Práticas de Código

### ❌ NÃO FAÇA:
```dart
// ❌ Variáveis com 1 letra
var u = getUser();
var c = cardapio;
int x = 10;

// ❌ Nomes genéricos
var data;
var temp;
var result;
```

### ✅ FAÇA:
```dart
// ✅ Nomes descritivos
var usuario = getUser();
var cardapioAtual = cardapio;
int numeroMaximoConvidados = 10;

// ✅ Nomes claros
var dadosUsuario;
var cardapioTemporario;
var resultadoBusca;
```

### 📏 Padrões de Nomenclatura

**Variáveis e Funções:**
```dart
// camelCase
var nomeCompleto = "João Silva";
void buscarJantares() { }
```

**Classes:**
```dart
// PascalCase
class UsuarioService { }
class CardapioController { }
```

**Constantes:**
```dart
// UPPER_SNAKE_CASE
const int MAX_CONVIDADOS = 20;
const String API_BASE_URL = "http://localhost:3000";
```

### 💬 Comentários

```dart
// ✅ Comente o PORQUÊ, não o QUE
// Precisamos validar antes porque a API não aceita valores nulos
if (preco != null && preco > 0) {
  salvarJantar();
}

// ❌ Não comente o óbvio
// Verifica se o preço não é nulo
if (preco != null) { }
```

### 🤖 Use IA para Manter Padrão

Antes de commitar, peça para a IA revisar:

```
"Revise este código e sugira melhorias seguindo as boas práticas:
- Nomes de variáveis descritivos
- Comentários úteis
- Estrutura clara
- Tratamento de erros"
```

---

## 🗄️ Banco de Dados

### 📊 Adicionando Nova Tabela

**SEMPRE que adicionar uma tabela:**

1. **Crie o SQL de criação** em `src/database/schema-local.sql`
2. **Crie dados de teste** em `src/database/seed-data.sql`
3. **Documente** no PR o que a tabela faz

**Exemplo:**
```sql
-- schema-local.sql
CREATE TABLE tb_notificacao_dn (
    id_notificacao SERIAL PRIMARY KEY,
    id_usuario INTEGER REFERENCES tb_usuario_dn(id_usuario),
    ds_mensagem TEXT NOT NULL,
    dt_criacao TIMESTAMP DEFAULT NOW()
);

-- seed-data.sql
INSERT INTO tb_notificacao_dn (id_usuario, ds_mensagem) VALUES
(1, 'Bem-vindo ao Dinneer!'),
(2, 'Você tem uma nova reserva');
```

### 🔄 Atualizando o Banco Local

Quando houver mudanças no schema:
1. Abra sua ferramenta de banco de dados (TablePlus, pgAdmin, DBeaver)
2. Conecte ao banco `dinneer_local`
3. Execute o script `src/database/schema-local.sql`
4. Execute o script `src/database/seed-data.sql`

### 🧪 Testando Queries

Use sua ferramenta de banco de dados para:
- Ver todas as tabelas
- Executar queries de teste:
  ```sql
  SELECT * FROM tb_usuario_dn;
  SELECT * FROM tb_cardapio_dn;
  ```

---

## 🔍 Revisão de Código

### 📋 Checklist do Revisor

Ao revisar um PR, verifique:

- [ ] Código segue os padrões de nomenclatura
- [ ] Não há variáveis com 1 letra
- [ ] Comentários são úteis (explicam o PORQUÊ)
- [ ] Não há código comentado desnecessário
- [ ] Tratamento de erros está presente
- [ ] Código está formatado corretamente
- [ ] Testes foram feitos (se aplicável)
- [ ] Documentação foi atualizada (se necessário)

### 💡 Dando Feedback

**✅ Feedback Construtivo:**
```
"Sugiro renomear 'x' para 'numeroConvidados' para ficar mais claro"
"Podemos adicionar um try-catch aqui para tratar erros?"
```

**❌ Evite:**
```
"Isso está errado"
"Não faça assim"
```

---

## 🚨 Resolução de Problemas

### Backend não inicia

```bash
# 1. Verifique se a porta 3000 está livre
lsof -ti:3000 | xargs kill -9

# 2. Reinstale dependências
cd pdm_php/node-backend
rm -rf node_modules
npm install

# 3. Verifique o .env
cat .env
```

### Frontend não compila

```bash
# 1. Limpe o cache
cd dinneer
flutter clean

# 2. Reinstale dependências
flutter pub get

# 3. Verifique o Flutter
flutter doctor
```

### Erro de Banco de Dados

1. Abra sua ferramenta de banco de dados (TablePlus, pgAdmin, DBeaver)
2. Verifique se o banco `dinneer_local` existe
3. Se necessário, recrie as tabelas:
   - Execute `src/database/schema-local.sql`
   - Execute `src/database/seed-data.sql`
4. Verifique o arquivo `.env` no backend para confirmar as credenciais

### Git está confuso

```bash
# Se você está perdido, volte para um estado seguro:
git stash  # Salva suas mudanças
git checkout main
git pull origin main

# Depois decida o que fazer com suas mudanças
git stash pop  # Recupera as mudanças
```

---

## ✅ Checklist Antes de Commitar

Antes de fazer `git push`, verifique:

- [ ] Código compila sem erros
- [ ] Testei localmente e funciona
- [ ] Removi `console.log()` e `print()` de debug
- [ ] Nomes de variáveis são descritivos
- [ ] Comentei partes complexas do código
- [ ] Não há código comentado desnecessário
- [ ] Formatei o código (Prettier/Dart Format)
- [ ] Atualizei documentação se necessário
- [ ] Se mudei o banco, atualizei schema e seed

---

## 🆘 Quando Pedir Ajuda

**SEMPRE contate o Bruno se:**
- Tiver conflitos de merge que não sabe resolver
- Não entender o código existente
- Não souber como implementar algo
- Tiver dúvidas sobre arquitetura
- Algo quebrou e você não sabe o porquê

**Melhor perguntar do que quebrar o código!**

---

## 📚 Recursos Úteis

### Documentação
- [Flutter](https://docs.flutter.dev/)
- [Node.js](https://nodejs.org/docs/)
- [PostgreSQL](https://www.postgresql.org/docs/)
- [Git](https://git-scm.com/doc)

### Ferramentas Recomendadas
- **VS Code** - Editor de código
- **Postman** - Testar APIs
- **TablePlus** - Visualizar banco de dados
- **GitKraken** - Interface visual para Git

### IAs Recomendadas
- **ChatGPT** - Ajuda geral com código
- **GitHub Copilot** - Autocompletar código
- **Cline** - Assistente de desenvolvimento

---

## 🎯 Resumo Rápido

```bash
# 1. Sempre comece atualizando
git checkout main
git pull origin main

# 2. Crie uma branch
git checkout -b feature/minha-tarefa

# 3. Trabalhe no código
# ... faça suas mudanças ...

# 4. Commit e push
git add .
git commit -m "feat: descrição clara"
git push origin feature/minha-tarefa

# 5. Crie PR no GitHub

# 6. Após merge, avise o time!
```

---

## 📞 Contatos

**Dúvidas?** Contate:
- **Bruno** - Líder Técnico
- **Grupo do Time** - Para discussões gerais

---

**Lembre-se:** Código limpo é código que outros conseguem entender! 🚀
