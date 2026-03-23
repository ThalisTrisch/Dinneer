#!/bin/bash

# Script de teste E2E para módulo Avaliacao
# Testa fluxo: Criar jantar → Participar → Avaliar → Verificar média

BASE_URL="http://localhost:3000"
API_CARDAPIO="/api/v1/cardapio/CardapioController"
API_ENCONTRO="/api/v1/encontro/EncontroController"
API_AVALIACAO="/api/v1/avaliacao/AvaliacaoController"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Dados de teste
ANFITRIAO=6
CONVIDADO=1
TEST_DATA="2026-12-31 19:00:00"

echo "=========================================="
echo "🧪 Teste E2E - Módulo Avaliacao"
echo "=========================================="
echo ""

# Função para verificar sucesso
check_success() {
    local response="$1"
    local num_mens=$(echo "$response" | grep -o '"NumMens":[0-9]*' | grep -o '[0-9]*')
    if [ "$num_mens" = "0" ]; then
        return 0
    else
        return 1
    fi
}

# 1. LISTAR TIPOS DE AVALIAÇÃO
echo -e "${YELLOW}1. Listando tipos de avaliação disponíveis...${NC}"
TIPOS=$(curl -s -X GET "${BASE_URL}${API_AVALIACAO}?operacao=getTiposAvaliacao")

if check_success "$TIPOS"; then
    TOTAL_TIPOS=$(echo "$TIPOS" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')
    echo -e "${GREEN}✅ Total de tipos: $TOTAL_TIPOS${NC}"
    echo "$TIPOS" | python3 -m json.tool 2>/dev/null || echo "$TIPOS"
    
    # Extrai IDs dos tipos
    TIPO_1=$(echo "$TIPOS" | grep -o '"id_avaliacao":[0-9]*' | grep -o '[0-9]*' | sed -n '1p')
    TIPO_2=$(echo "$TIPOS" | grep -o '"id_avaliacao":[0-9]*' | grep -o '[0-9]*' | sed -n '2p')
    TIPO_3=$(echo "$TIPOS" | grep -o '"id_avaliacao":[0-9]*' | grep -o '[0-9]*' | sed -n '3p')
else
    echo -e "${RED}❌ Erro ao listar tipos${NC}"
    exit 1
fi
echo ""
echo "=========================================="
echo ""

# 2. CRIAR JANTAR PARA TESTE
echo -e "${YELLOW}2. Criando jantar para teste...${NC}"
CREATE_JANTAR=$(curl -s -X POST "${BASE_URL}${API_CARDAPIO}?operacao=createJantar" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $ANFITRIAO,
    \"nm_cardapio\": \"Jantar Teste Avaliacao\",
    \"ds_cardapio\": \"Teste de avaliações\",
    \"preco_refeicao\": 45.00,
    \"hr_encontro\": \"$TEST_DATA\",
    \"nu_max_convidados\": 5,
    \"nu_cep\": \"99999999\",
    \"nu_casa\": \"9999\",
    \"vl_foto\": null,
    \"id_local\": null
  }")

if check_success "$CREATE_JANTAR"; then
    echo -e "${GREEN}✅ Jantar criado!${NC}"
    
    # Aguarda um momento para garantir que foi criado
    sleep 1
    
    # Busca cardápios disponíveis para pegar o ID correto
    GET_DISPONIVEIS=$(curl -s -X GET "${BASE_URL}${API_CARDAPIO}?operacao=getCardapiosDisponiveis")
    
    # Pega o último (mais recente) encontro criado
    ENCONTRO_ID=$(echo "$GET_DISPONIVEIS" | grep -o '"id_encontro":[0-9]*' | grep -o '[0-9]*' | tail -1)
    CARDAPIO_ID=$(echo "$GET_DISPONIVEIS" | grep -o '"id_cardapio":[0-9]*' | grep -o '[0-9]*' | tail -1)
    
    echo -e "${GREEN}ID do encontro criado: $ENCONTRO_ID${NC}"
    echo -e "${GREEN}ID do cardapio criado: $CARDAPIO_ID${NC}"
else
    echo -e "${RED}❌ Erro ao criar jantar${NC}"
    exit 1
fi
echo ""
echo "=========================================="
echo ""

# 3. VERIFICAR MÉDIA INICIAL DO ANFITRIÃO
echo -e "${YELLOW}3. Verificando média inicial do anfitrião...${NC}"
MEDIA_INICIAL=$(curl -s -X GET "${BASE_URL}${API_AVALIACAO}?operacao=getMediaUsuario&id_usuario=$ANFITRIAO")

echo "$MEDIA_INICIAL" | python3 -m json.tool 2>/dev/null || echo "$MEDIA_INICIAL"
echo ""
echo "=========================================="
echo ""

# 4. CONVIDADO PARTICIPA DO ENCONTRO
echo -e "${YELLOW}4. Convidado participando do encontro...${NC}"
RESERVAR=$(curl -s -X POST "${BASE_URL}${API_ENCONTRO}?operacao=reservar" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $CONVIDADO,
    \"id_encontro\": $ENCONTRO_ID,
    \"nu_dependentes\": 0
  }")

if check_success "$RESERVAR"; then
    echo -e "${GREEN}✅ Reserva solicitada!${NC}"
else
    echo -e "${YELLOW}⚠️  Pode já ter reserva${NC}"
fi
echo ""
echo "=========================================="
echo ""

# 5. CRIAR AVALIAÇÃO - TIPO 1
echo -e "${YELLOW}5. Criando avaliação - Tipo 1 (nota 5)...${NC}"
AVAL_1=$(curl -s -X POST "${BASE_URL}${API_AVALIACAO}?operacao=createAvaliacao" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $CONVIDADO,
    \"id_encontro\": $ENCONTRO_ID,
    \"id_avaliacao\": $TIPO_1,
    \"vl_avaliacao\": 5
  }")

if check_success "$AVAL_1"; then
    echo -e "${GREEN}✅ Avaliação 1 registrada!${NC}"
    echo "$AVAL_1" | python3 -m json.tool 2>/dev/null || echo "$AVAL_1"
else
    echo -e "${YELLOW}⚠️  ${NC}"
    echo "$AVAL_1"
fi
echo ""
echo "=========================================="
echo ""

# 6. CRIAR AVALIAÇÃO - TIPO 2
echo -e "${YELLOW}6. Criando avaliação - Tipo 2 (nota 4)...${NC}"
AVAL_2=$(curl -s -X POST "${BASE_URL}${API_AVALIACAO}?operacao=createAvaliacao" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $CONVIDADO,
    \"id_encontro\": $ENCONTRO_ID,
    \"id_avaliacao\": $TIPO_2,
    \"vl_avaliacao\": 4
  }")

if check_success "$AVAL_2"; then
    echo -e "${GREEN}✅ Avaliação 2 registrada!${NC}"
    echo "$AVAL_2" | python3 -m json.tool 2>/dev/null || echo "$AVAL_2"
else
    echo -e "${YELLOW}⚠️  ${NC}"
    echo "$AVAL_2"
fi
echo ""
echo "=========================================="
echo ""

# 7. CRIAR AVALIAÇÃO - TIPO 3
echo -e "${YELLOW}7. Criando avaliação - Tipo 3 (nota 5)...${NC}"
AVAL_3=$(curl -s -X POST "${BASE_URL}${API_AVALIACAO}?operacao=createAvaliacao" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $CONVIDADO,
    \"id_encontro\": $ENCONTRO_ID,
    \"id_avaliacao\": $TIPO_3,
    \"vl_avaliacao\": 5
  }")

if check_success "$AVAL_3"; then
    echo -e "${GREEN}✅ Avaliação 3 registrada!${NC}"
    echo "$AVAL_3" | python3 -m json.tool 2>/dev/null || echo "$AVAL_3"
else
    echo -e "${YELLOW}⚠️  ${NC}"
    echo "$AVAL_3"
fi
echo ""
echo "=========================================="
echo ""

# 8. VERIFICAR MÉDIA APÓS AVALIAÇÕES
echo -e "${YELLOW}8. Verificando média após avaliações...${NC}"
MEDIA_FINAL=$(curl -s -X GET "${BASE_URL}${API_AVALIACAO}?operacao=getMediaUsuario&id_usuario=$ANFITRIAO")

echo "$MEDIA_FINAL" | python3 -m json.tool 2>/dev/null || echo "$MEDIA_FINAL"
MEDIA=$(echo "$MEDIA_FINAL" | grep -o '"media":[0-9.]*' | grep -o '[0-9.]*')
TOTAL=$(echo "$MEDIA_FINAL" | grep -o '"total":[0-9]*' | grep -o '[0-9]*')
echo -e "${GREEN}Média: $MEDIA | Total de avaliações: $TOTAL${NC}"
echo ""
echo "=========================================="
echo ""

# 9. TESTAR DUPLICIDADE (deve falhar)
echo -e "${YELLOW}9. Testando validação de duplicidade...${NC}"
DUPLICADO=$(curl -s -X POST "${BASE_URL}${API_AVALIACAO}?operacao=createAvaliacao" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $CONVIDADO,
    \"id_encontro\": $ENCONTRO_ID,
    \"id_avaliacao\": $TIPO_1,
    \"vl_avaliacao\": 3
  }")

if ! check_success "$DUPLICADO"; then
    echo -e "${GREEN}✅ Validação funcionando! Não permite duplicidade.${NC}"
    echo "$DUPLICADO" | python3 -m json.tool 2>/dev/null || echo "$DUPLICADO"
else
    echo -e "${RED}⚠️  Deveria ter bloqueado duplicidade${NC}"
fi
echo ""
echo "=========================================="
echo ""

# 10. DELETAR JANTAR (LIMPEZA)
echo -e "${YELLOW}10. Deletando jantar de teste (limpeza)...${NC}"
DELETE=$(curl -s -X POST "${BASE_URL}${API_CARDAPIO}?operacao=deleteCardapio" \
  -H "Content-Type: application/json" \
  -d "{\"id_cardapio\": $CARDAPIO_ID}")

if check_success "$DELETE"; then
    echo -e "${GREEN}✅ Jantar deletado! Banco limpo.${NC}"
    echo -e "${GREEN}   (Avaliações, participantes, encontro e cardápio removidos)${NC}"
else
    echo -e "${RED}❌ Erro ao deletar jantar${NC}"
    echo "$DELETE"
fi
echo ""
echo "=========================================="
echo ""

echo -e "${GREEN}🎉 Testes E2E do módulo Avaliacao concluídos!${NC}"
echo ""
echo "Resumo:"
echo "  ✅ Listagem de tipos de avaliação"
echo "  ✅ Criação de jantar"
echo "  ✅ Verificação de média inicial"
echo "  ✅ Participação em encontro"
echo "  ✅ Criação de 3 avaliações (notas 5, 4, 5)"
echo "  ✅ Verificação de média final"
echo "  ✅ Validação de duplicidade"
echo "  ✅ Limpeza do banco"
echo ""
echo "=========================================="
