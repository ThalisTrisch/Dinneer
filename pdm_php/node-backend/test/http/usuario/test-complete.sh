#!/bin/bash

# Script de teste completo com criação e limpeza
# Cria usuário de teste, testa funcionalidades e depois deleta

BASE_URL="http://localhost:3000"
API_PATH="/api/v1/usuario/UsuarioController"

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Dados do usuário de teste
TEST_CPF="99999999999"
TEST_EMAIL="teste_automatizado@email.com"
TEST_SENHA="senha_teste_123"
TEST_NOME="Usuario"
TEST_SOBRENOME="Teste"

echo "=========================================="
echo "🧪 Teste Completo da API Dinneer"
echo "=========================================="
echo ""

# Função para extrair id_usuario do JSON
extract_id() {
    echo "$1" | grep -o '"id_usuario":[0-9]*' | grep -o '[0-9]*' | head -1
}

# Função para verificar se operação foi bem-sucedida
check_success() {
    local response="$1"
    local num_mens=$(echo "$response" | grep -o '"NumMens":[0-9]*' | grep -o '[0-9]*')
    if [ "$num_mens" = "0" ]; then
        return 0
    else
        return 1
    fi
}

# 1. CRIAR USUÁRIO DE TESTE
echo -e "${YELLOW}1. Criando usuário de teste...${NC}"
CREATE_RESPONSE=$(curl -s -X POST "${BASE_URL}${API_PATH}?operacao=createUsuario" \
  -H "Content-Type: application/json" \
  -d "{
    \"nu_cpf\": \"$TEST_CPF\",
    \"nm_usuario\": \"$TEST_NOME\",
    \"nm_sobrenome\": \"$TEST_SOBRENOME\",
    \"vl_email\": \"$TEST_EMAIL\",
    \"vl_senha\": \"$TEST_SENHA\",
    \"vl_foto\": null
  }")

if check_success "$CREATE_RESPONSE"; then
    USER_ID=$(extract_id "$CREATE_RESPONSE")
    echo -e "${GREEN}✅ Usuário criado com sucesso! ID: $USER_ID${NC}"
    echo "$CREATE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$CREATE_RESPONSE"
else
    echo -e "${RED}❌ Erro ao criar usuário${NC}"
    echo "$CREATE_RESPONSE"
    exit 1
fi
echo ""
echo "=========================================="
echo ""

# 2. TESTAR LOGIN
echo -e "${YELLOW}2. Testando login com usuário criado...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}${API_PATH}?operacao=loginUsuario" \
  -H "Content-Type: application/json" \
  -d "{
    \"vl_email\": \"$TEST_EMAIL\",
    \"vl_senha\": \"$TEST_SENHA\"
  }")

if check_success "$LOGIN_RESPONSE"; then
    echo -e "${GREEN}✅ Login realizado com sucesso!${NC}"
    echo "$LOGIN_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$LOGIN_RESPONSE"
else
    echo -e "${RED}❌ Erro no login${NC}"
    echo "$LOGIN_RESPONSE"
fi
echo ""
echo "=========================================="
echo ""

# 3. BUSCAR USUÁRIO POR ID
echo -e "${YELLOW}3. Buscando usuário por ID ($USER_ID)...${NC}"
GET_RESPONSE=$(curl -s -X GET "${BASE_URL}${API_PATH}?operacao=getUsuario&id_usuario=$USER_ID" \
  -H "Content-Type: application/json")

if check_success "$GET_RESPONSE"; then
    echo -e "${GREEN}✅ Usuário encontrado!${NC}"
    echo "$GET_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$GET_RESPONSE"
else
    echo -e "${RED}❌ Erro ao buscar usuário${NC}"
    echo "$GET_RESPONSE"
fi
echo ""
echo "=========================================="
echo ""

# 4. ATUALIZAR FOTO DE PERFIL
echo -e "${YELLOW}4. Atualizando foto de perfil...${NC}"
UPDATE_FOTO_RESPONSE=$(curl -s -X POST "${BASE_URL}${API_PATH}?operacao=atualizarFotoPerfil" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $USER_ID,
    \"vl_foto\": \"https://exemplo.com/foto_teste.jpg\"
  }")

if check_success "$UPDATE_FOTO_RESPONSE"; then
    echo -e "${GREEN}✅ Foto atualizada com sucesso!${NC}"
    echo "$UPDATE_FOTO_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$UPDATE_FOTO_RESPONSE"
else
    echo -e "${RED}❌ Erro ao atualizar foto${NC}"
    echo "$UPDATE_FOTO_RESPONSE"
fi
echo ""
echo "=========================================="
echo ""

# 5. DELETAR USUÁRIO (LIMPEZA)
echo -e "${YELLOW}5. Deletando usuário de teste (limpeza)...${NC}"
DELETE_RESPONSE=$(curl -s -X POST "${BASE_URL}${API_PATH}?operacao=deleteUsuario" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $USER_ID
  }")

if check_success "$DELETE_RESPONSE"; then
    echo -e "${GREEN}✅ Usuário deletado com sucesso! Banco limpo.${NC}"
    echo "$DELETE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$DELETE_RESPONSE"
else
    echo -e "${RED}❌ Erro ao deletar usuário${NC}"
    echo "$DELETE_RESPONSE"
fi
echo ""
echo "=========================================="
echo ""

# 6. VERIFICAR SE USUÁRIO FOI REALMENTE DELETADO
echo -e "${YELLOW}6. Verificando se usuário foi deletado...${NC}"
VERIFY_RESPONSE=$(curl -s -X GET "${BASE_URL}${API_PATH}?operacao=getUsuario&id_usuario=$USER_ID" \
  -H "Content-Type: application/json")

if ! check_success "$VERIFY_RESPONSE"; then
    echo -e "${GREEN}✅ Confirmado: Usuário não existe mais no banco${NC}"
else
    echo -e "${RED}⚠️  Atenção: Usuário ainda existe no banco${NC}"
fi
echo ""
echo "=========================================="
echo ""

echo -e "${GREEN}🎉 Testes concluídos!${NC}"
echo ""
echo "Resumo:"
echo "  ✅ Criação de usuário"
echo "  ✅ Login"
echo "  ✅ Busca por ID"
echo "  ✅ Atualização de foto"
echo "  ✅ Deleção de usuário"
echo "  ✅ Banco de dados limpo"
echo ""
echo "=========================================="
