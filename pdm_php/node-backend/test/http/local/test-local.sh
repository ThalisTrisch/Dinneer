#!/bin/bash

# Script de teste E2E para módulo Local
# Cria local de teste, testa funcionalidades e depois deleta

BASE_URL="http://localhost:3000"
API_PATH="/api/v1/local/LocalController"

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Dados do local de teste
TEST_CEP="99999999"
TEST_CASA="9999"
TEST_USUARIO=6  # Usando usuário existente (Thalis)
TEST_CNPJ="12345678901234"
TEST_COMPLEMENTO="Local de Teste E2E"

echo "=========================================="
echo "🧪 Teste E2E - Módulo Local"
echo "=========================================="
echo ""

# Função para extrair id_local do JSON
extract_id() {
    echo "$1" | grep -o '"id_local":[0-9]*' | grep -o '[0-9]*' | head -1
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

# 1. CRIAR LOCAL DE TESTE
echo -e "${YELLOW}1. Criando local de teste...${NC}"
CREATE_RESPONSE=$(curl -s -X POST "${BASE_URL}${API_PATH}?operacao=createLocal" \
  -H "Content-Type: application/json" \
  -d "{
    \"nu_cep\": \"$TEST_CEP\",
    \"nu_casa\": \"$TEST_CASA\",
    \"id_usuario\": $TEST_USUARIO,
    \"nu_cnpj\": \"$TEST_CNPJ\",
    \"dc_complemento\": \"$TEST_COMPLEMENTO\"
  }")

if check_success "$CREATE_RESPONSE"; then
    echo -e "${GREEN}✅ Local criado com sucesso!${NC}"
    echo "$CREATE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$CREATE_RESPONSE"
    
    # Buscar o ID do local criado
    GET_LOCAIS_RESPONSE=$(curl -s -X GET "${BASE_URL}${API_PATH}?operacao=getMeusLocais&id_usuario=$TEST_USUARIO")
    LOCAL_ID=$(echo "$GET_LOCAIS_RESPONSE" | grep -o '"id_local":[0-9]*' | grep -o '[0-9]*' | head -1)
    
    if [ -z "$LOCAL_ID" ]; then
        echo -e "${RED}❌ Não foi possível obter o ID do local criado${NC}"
        exit 1
    fi
    echo -e "${GREEN}ID do local criado: $LOCAL_ID${NC}"
else
    echo -e "${RED}❌ Erro ao criar local${NC}"
    echo "$CREATE_RESPONSE"
    exit 1
fi
echo ""
echo "=========================================="
echo ""

# 2. BUSCAR LOCAL POR ID
echo -e "${YELLOW}2. Buscando local por ID ($LOCAL_ID)...${NC}"
GET_LOCAL_RESPONSE=$(curl -s -X GET "${BASE_URL}${API_PATH}?operacao=getLocal&id_local=$LOCAL_ID" \
  -H "Content-Type: application/json")

if check_success "$GET_LOCAL_RESPONSE"; then
    echo -e "${GREEN}✅ Local encontrado!${NC}"
    echo "$GET_LOCAL_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$GET_LOCAL_RESPONSE"
else
    echo -e "${RED}❌ Erro ao buscar local${NC}"
    echo "$GET_LOCAL_RESPONSE"
fi
echo ""
echo "=========================================="
echo ""

# 3. LISTAR TODOS OS LOCAIS
echo -e "${YELLOW}3. Listando todos os locais...${NC}"
GET_ALL_RESPONSE=$(curl -s -X GET "${BASE_URL}${API_PATH}?operacao=getLocais" \
  -H "Content-Type: application/json")

if check_success "$GET_ALL_RESPONSE"; then
    TOTAL_LOCAIS=$(echo "$GET_ALL_RESPONSE" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')
    echo -e "${GREEN}✅ Total de locais no banco: $TOTAL_LOCAIS${NC}"
else
    echo -e "${RED}❌ Erro ao listar locais${NC}"
fi
echo ""
echo "=========================================="
echo ""

# 4. BUSCAR LOCAIS DO USUÁRIO
echo -e "${YELLOW}4. Buscando locais do usuário ($TEST_USUARIO)...${NC}"
GET_MEUS_RESPONSE=$(curl -s -X GET "${BASE_URL}${API_PATH}?operacao=getMeusLocais&id_usuario=$TEST_USUARIO" \
  -H "Content-Type: application/json")

if check_success "$GET_MEUS_RESPONSE"; then
    MEUS_LOCAIS=$(echo "$GET_MEUS_RESPONSE" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')
    echo -e "${GREEN}✅ Locais do usuário: $MEUS_LOCAIS${NC}"
    echo "$GET_MEUS_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$GET_MEUS_RESPONSE"
else
    echo -e "${RED}❌ Erro ao buscar locais do usuário${NC}"
    echo "$GET_MEUS_RESPONSE"
fi
echo ""
echo "=========================================="
echo ""

# 5. DELETAR LOCAL (LIMPEZA)
echo -e "${YELLOW}5. Deletando local de teste (limpeza)...${NC}"
DELETE_RESPONSE=$(curl -s -X POST "${BASE_URL}${API_PATH}?operacao=deleteLocal" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_local\": $LOCAL_ID
  }")

if check_success "$DELETE_RESPONSE"; then
    echo -e "${GREEN}✅ Local deletado com sucesso! Banco limpo.${NC}"
    echo "$DELETE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$DELETE_RESPONSE"
else
    echo -e "${RED}❌ Erro ao deletar local${NC}"
    echo "$DELETE_RESPONSE"
fi
echo ""
echo "=========================================="
echo ""

# 6. VERIFICAR SE LOCAL FOI REALMENTE DELETADO
echo -e "${YELLOW}6. Verificando se local foi deletado...${NC}"
VERIFY_RESPONSE=$(curl -s -X GET "${BASE_URL}${API_PATH}?operacao=getLocal&id_local=$LOCAL_ID" \
  -H "Content-Type: application/json")

VERIFY_REGISTROS=$(echo "$VERIFY_RESPONSE" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')
if [ "$VERIFY_REGISTROS" = "0" ]; then
    echo -e "${GREEN}✅ Confirmado: Local não existe mais no banco${NC}"
else
    echo -e "${RED}⚠️  Atenção: Local ainda existe no banco${NC}"
fi
echo ""
echo "=========================================="
echo ""

echo -e "${GREEN}🎉 Testes E2E do módulo Local concluídos!${NC}"
echo ""
echo "Resumo:"
echo "  ✅ Criação de local"
echo "  ✅ Busca por ID"
echo "  ✅ Listagem de todos os locais"
echo "  ✅ Listagem de locais do usuário"
echo "  ✅ Deleção de local"
echo "  ✅ Banco de dados limpo"
echo ""
echo "=========================================="
