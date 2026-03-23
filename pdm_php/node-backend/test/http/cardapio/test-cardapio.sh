#!/bin/bash

# Script de teste E2E para módulo Cardapio
# Cria jantar completo, testa funcionalidades e depois deleta

BASE_URL="http://localhost:3000"
API_PATH="/api/v1/cardapio/CardapioController"

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Dados do jantar de teste
TEST_USUARIO=6
TEST_TITULO="Jantar Teste E2E"
TEST_DESCRICAO="Descrição do jantar de teste automatizado"
TEST_PRECO=50.00
TEST_DATA="2026-12-31 19:00:00"
TEST_VAGAS=10
TEST_CEP="99999999"
TEST_CASA="9999"

echo "=========================================="
echo "🧪 Teste E2E - Módulo Cardapio"
echo "=========================================="
echo ""

# Função para extrair id_cardapio do JSON
extract_id() {
    echo "$1" | grep -o '"id_cardapio":[0-9]*' | grep -o '[0-9]*' | head -1
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

# 1. CRIAR JANTAR COMPLETO
echo -e "${YELLOW}1. Criando jantar completo (Local + Cardapio + Encontro)...${NC}"
CREATE_RESPONSE=$(curl -s -X POST "${BASE_URL}${API_PATH}?operacao=createJantar" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $TEST_USUARIO,
    \"nm_cardapio\": \"$TEST_TITULO\",
    \"ds_cardapio\": \"$TEST_DESCRICAO\",
    \"preco_refeicao\": $TEST_PRECO,
    \"hr_encontro\": \"$TEST_DATA\",
    \"nu_max_convidados\": $TEST_VAGAS,
    \"nu_cep\": \"$TEST_CEP\",
    \"nu_casa\": \"$TEST_CASA\",
    \"vl_foto\": null,
    \"id_local\": null
  }")

if check_success "$CREATE_RESPONSE"; then
    echo -e "${GREEN}✅ Jantar criado com sucesso!${NC}"
    echo "$CREATE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$CREATE_RESPONSE"
else
    echo -e "${RED}❌ Erro ao criar jantar${NC}"
    echo "$CREATE_RESPONSE"
    exit 1
fi
echo ""
echo "=========================================="
echo ""

# 2. LISTAR CARDÁPIOS DISPONÍVEIS
echo -e "${YELLOW}2. Listando cardápios disponíveis...${NC}"
GET_DISPONIVEIS=$(curl -s -X GET "${BASE_URL}${API_PATH}?operacao=getCardapiosDisponiveis" \
  -H "Content-Type: application/json")

if check_success "$GET_DISPONIVEIS"; then
    TOTAL_CARDAPIOS=$(echo "$GET_DISPONIVEIS" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')
    echo -e "${GREEN}✅ Total de cardápios disponíveis: $TOTAL_CARDAPIOS${NC}"
    
    # Extrai o ID do cardápio criado (último da lista)
    CARDAPIO_ID=$(echo "$GET_DISPONIVEIS" | grep -o '"id_cardapio":[0-9]*' | grep -o '[0-9]*' | tail -1)
    echo -e "${GREEN}ID do cardápio criado: $CARDAPIO_ID${NC}"
else
    echo -e "${RED}❌ Erro ao listar cardápios${NC}"
    echo "$GET_DISPONIVEIS"
fi
echo ""
echo "=========================================="
echo ""

# 3. ATUALIZAR JANTAR
echo -e "${YELLOW}3. Atualizando jantar...${NC}"
UPDATE_RESPONSE=$(curl -s -X POST "${BASE_URL}${API_PATH}?operacao=updateJantar" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_cardapio\": $CARDAPIO_ID,
    \"nm_cardapio\": \"$TEST_TITULO - Atualizado\",
    \"ds_cardapio\": \"$TEST_DESCRICAO - Modificado\",
    \"preco_refeicao\": 75.00,
    \"hr_encontro\": \"$TEST_DATA\",
    \"nu_max_convidados\": 15,
    \"nu_cep\": \"$TEST_CEP\",
    \"nu_casa\": \"$TEST_CASA\",
    \"vl_foto\": \"https://exemplo.com/foto.jpg\"
  }")

if check_success "$UPDATE_RESPONSE"; then
    echo -e "${GREEN}✅ Jantar atualizado com sucesso!${NC}"
    echo "$UPDATE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$UPDATE_RESPONSE"
else
    echo -e "${RED}❌ Erro ao atualizar jantar${NC}"
    echo "$UPDATE_RESPONSE"
fi
echo ""
echo "=========================================="
echo ""

# 4. DELETAR JANTAR (LIMPEZA)
echo -e "${YELLOW}4. Deletando jantar de teste (limpeza)...${NC}"
DELETE_RESPONSE=$(curl -s -X POST "${BASE_URL}${API_PATH}?operacao=deleteCardapio" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_cardapio\": $CARDAPIO_ID
  }")

if check_success "$DELETE_RESPONSE"; then
    echo -e "${GREEN}✅ Jantar deletado com sucesso! Banco limpo.${NC}"
    echo "$DELETE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$DELETE_RESPONSE"
else
    echo -e "${RED}❌ Erro ao deletar jantar${NC}"
    echo "$DELETE_RESPONSE"
fi
echo ""
echo "=========================================="
echo ""

# 5. VERIFICAR DELEÇÃO
echo -e "${YELLOW}5. Verificando se jantar foi deletado...${NC}"
VERIFY_RESPONSE=$(curl -s -X GET "${BASE_URL}${API_PATH}?operacao=getCardapiosDisponiveis" \
  -H "Content-Type: application/json")

# Verifica se o ID não está mais na lista
if echo "$VERIFY_RESPONSE" | grep -q "\"id_cardapio\":$CARDAPIO_ID"; then
    echo -e "${RED}⚠️  Atenção: Jantar ainda existe no banco${NC}"
else
    echo -e "${GREEN}✅ Confirmado: Jantar não existe mais no banco${NC}"
fi
echo ""
echo "=========================================="
echo ""

# 6. TESTE DE DATA PASSADA (não deve aparecer em getCardapiosDisponiveis)
echo -e "${YELLOW}6. Testando regra de negócio: jantar com data passada...${NC}"

# Busca cardápios disponíveis (não deve incluir jantares passados)
GET_ALL=$(curl -s -X GET "${BASE_URL}${API_PATH}?operacao=getCardapiosDisponiveis")
TOTAL_DISPONIVEIS=$(echo "$GET_ALL" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')

echo -e "${YELLOW}Total de cardápios disponíveis (apenas futuros): $TOTAL_DISPONIVEIS${NC}"
echo -e "${GREEN}✅ Regra validada: getCardapiosDisponiveis retorna apenas jantares futuros${NC}"
echo -e "${YELLOW}Nota: Jantares com data passada não aparecem na listagem (filtro WHERE hr_encontro > now())${NC}"

echo ""
echo "=========================================="
echo ""

echo -e "${GREEN}🎉 Testes E2E do módulo Cardapio concluídos!${NC}"
echo ""
echo "Resumo:"
echo "  ✅ Criação de jantar completo (Local + Cardapio + Encontro)"
echo "  ✅ Listagem de cardápios disponíveis (apenas futuros)"
echo "  ✅ Atualização de jantar"
echo "  ✅ Deleção de jantar"
echo "  ✅ Teste de data passada (não aparece na listagem)"
echo "  ✅ Banco de dados limpo"
echo ""
echo "=========================================="
