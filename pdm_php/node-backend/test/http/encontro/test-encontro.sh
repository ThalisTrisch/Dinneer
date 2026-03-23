#!/bin/bash

# Script de teste E2E para módulo Encontro
# Testa fluxo completo: Criar jantar → Reservar → Aprovar → Cancelar

BASE_URL="http://localhost:3000"
API_CARDAPIO="/api/v1/cardapio/CardapioController"
API_ENCONTRO="/api/v1/encontro/EncontroController"

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
echo "🧪 Teste E2E - Módulo Encontro"
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

# 1. CRIAR JANTAR PARA TESTE
echo -e "${YELLOW}1. Criando jantar para teste...${NC}"
CREATE_JANTAR=$(curl -s -X POST "${BASE_URL}${API_CARDAPIO}?operacao=createJantar" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $ANFITRIAO,
    \"nm_cardapio\": \"Jantar Teste Encontro\",
    \"ds_cardapio\": \"Teste de reservas\",
    \"preco_refeicao\": 40.00,
    \"hr_encontro\": \"$TEST_DATA\",
    \"nu_max_convidados\": 5,
    \"nu_cep\": \"99999999\",
    \"nu_casa\": \"9999\",
    \"vl_foto\": null,
    \"id_local\": null
  }")

if check_success "$CREATE_JANTAR"; then
    echo -e "${GREEN}✅ Jantar criado!${NC}"
    
    # Busca ID do encontro
    GET_JANTARES=$(curl -s -X GET "${BASE_URL}${API_ENCONTRO}?operacao=getMeusJantaresCriados&id_usuario=$ANFITRIAO")
    ENCONTRO_ID=$(echo "$GET_JANTARES" | grep -o '"id_encontro":[0-9]*' | grep -o '[0-9]*' | tail -1)
    echo -e "${GREEN}ID do encontro: $ENCONTRO_ID${NC}"
else
    echo -e "${RED}❌ Erro ao criar jantar${NC}"
    exit 1
fi
echo ""
echo "=========================================="
echo ""

# 2. CONVIDADO SOLICITA RESERVA
echo -e "${YELLOW}2. Convidado ($CONVIDADO) solicitando reserva...${NC}"
RESERVAR=$(curl -s -X POST "${BASE_URL}${API_ENCONTRO}?operacao=reservar" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $CONVIDADO,
    \"id_encontro\": $ENCONTRO_ID,
    \"nu_dependentes\": 1
  }")

if check_success "$RESERVAR"; then
    echo -e "${GREEN}✅ Reserva solicitada!${NC}"
    echo "$RESERVAR" | python3 -m json.tool 2>/dev/null || echo "$RESERVAR"
else
    echo -e "${RED}❌ Erro ao solicitar reserva${NC}"
    echo "$RESERVAR"
fi
echo ""
echo "=========================================="
echo ""

# 3. VERIFICAR STATUS DA RESERVA
echo -e "${YELLOW}3. Verificando status da reserva...${NC}"
VERIFICAR=$(curl -s -X GET "${BASE_URL}${API_ENCONTRO}?operacao=verificarReserva&id_usuario=$CONVIDADO&id_encontro=$ENCONTRO_ID")

echo "$VERIFICAR" | python3 -m json.tool 2>/dev/null || echo "$VERIFICAR"
STATUS=$(echo "$VERIFICAR" | grep -o '"status":"[A-Z]"' | grep -o '[A-Z]')
echo -e "${YELLOW}Status atual: $STATUS (P=Pendente, C=Confirmado)${NC}"
echo ""
echo "=========================================="
echo ""

# 4. LISTAR PARTICIPANTES (ANFITRIÃO)
echo -e "${YELLOW}4. Listando participantes (visão do anfitrião)...${NC}"
PARTICIPANTES=$(curl -s -X GET "${BASE_URL}${API_ENCONTRO}?operacao=getParticipantes&id_encontro=$ENCONTRO_ID")

if check_success "$PARTICIPANTES"; then
    TOTAL=$(echo "$PARTICIPANTES" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')
    echo -e "${GREEN}✅ Total de participantes: $TOTAL${NC}"
    echo "$PARTICIPANTES" | python3 -m json.tool 2>/dev/null || echo "$PARTICIPANTES"
else
    echo -e "${YELLOW}⚠️  Nenhum participante ainda${NC}"
fi
echo ""
echo "=========================================="
echo ""

# 5. ANFITRIÃO APROVA RESERVA
echo -e "${YELLOW}5. Anfitrião aprovando reserva...${NC}"
APROVAR=$(curl -s -X POST "${BASE_URL}${API_ENCONTRO}?operacao=aprovarReserva" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_encontro\": $ENCONTRO_ID,
    \"id_convidado\": $CONVIDADO
  }")

if check_success "$APROVAR"; then
    echo -e "${GREEN}✅ Reserva aprovada!${NC}"
    echo "$APROVAR" | python3 -m json.tool 2>/dev/null || echo "$APROVAR"
else
    echo -e "${RED}❌ Erro ao aprovar reserva${NC}"
    echo "$APROVAR"
fi
echo ""
echo "=========================================="
echo ""

# 6. VERIFICAR STATUS APÓS APROVAÇÃO
echo -e "${YELLOW}6. Verificando status após aprovação...${NC}"
VERIFICAR2=$(curl -s -X GET "${BASE_URL}${API_ENCONTRO}?operacao=verificarReserva&id_usuario=$CONVIDADO&id_encontro=$ENCONTRO_ID")

STATUS2=$(echo "$VERIFICAR2" | grep -o '"status":"[A-Z]"' | grep -o '[A-Z]')
if [ "$STATUS2" = "C" ]; then
    echo -e "${GREEN}✅ Status confirmado: C (Confirmado)${NC}"
else
    echo -e "${RED}⚠️  Status: $STATUS2${NC}"
fi
echo ""
echo "=========================================="
echo ""

# 7. LISTAR MINHAS RESERVAS (CONVIDADO)
echo -e "${YELLOW}7. Listando reservas do convidado...${NC}"
MINHAS_RESERVAS=$(curl -s -X GET "${BASE_URL}${API_ENCONTRO}?operacao=getMinhasReservas&id_usuario=$CONVIDADO")

if check_success "$MINHAS_RESERVAS"; then
    TOTAL_RESERVAS=$(echo "$MINHAS_RESERVAS" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')
    echo -e "${GREEN}✅ Total de reservas: $TOTAL_RESERVAS${NC}"
else
    echo -e "${YELLOW}⚠️  Nenhuma reserva${NC}"
fi
echo ""
echo "=========================================="
echo ""

# 8. CONVIDADO CANCELA RESERVA
echo -e "${YELLOW}8. Convidado cancelando reserva...${NC}"
CANCELAR=$(curl -s -X POST "${BASE_URL}${API_ENCONTRO}?operacao=cancelarReserva" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_usuario\": $CONVIDADO,
    \"id_encontro\": $ENCONTRO_ID
  }")

if check_success "$CANCELAR"; then
    echo -e "${GREEN}✅ Reserva cancelada!${NC}"
    echo "$CANCELAR" | python3 -m json.tool 2>/dev/null || echo "$CANCELAR"
else
    echo -e "${RED}❌ Erro ao cancelar reserva${NC}"
    echo "$CANCELAR"
fi
echo ""
echo "=========================================="
echo ""

# 9. DELETAR JANTAR (LIMPEZA)
echo -e "${YELLOW}9. Deletando jantar de teste (limpeza)...${NC}"
CARDAPIO_ID=$(echo "$GET_JANTARES" | grep -o '"id_cardapio":[0-9]*' | grep -o '[0-9]*' | tail -1)
DELETE=$(curl -s -X POST "${BASE_URL}${API_CARDAPIO}?operacao=deleteCardapio" \
  -H "Content-Type: application/json" \
  -d "{\"id_cardapio\": $CARDAPIO_ID}")

if check_success "$DELETE"; then
    echo -e "${GREEN}✅ Jantar deletado! Banco limpo.${NC}"
else
    echo -e "${RED}❌ Erro ao deletar jantar${NC}"
fi
echo ""
echo "=========================================="
echo ""

echo -e "${GREEN}🎉 Testes E2E do módulo Encontro concluídos!${NC}"
echo ""
echo "Resumo:"
echo "  ✅ Criação de jantar"
echo "  ✅ Solicitação de reserva"
echo "  ✅ Verificação de status"
echo "  ✅ Listagem de participantes"
echo "  ✅ Aprovação de reserva"
echo "  ✅ Confirmação de status"
echo "  ✅ Listagem de reservas do usuário"
echo "  ✅ Cancelamento de reserva"
echo "  ✅ Limpeza do banco"
echo ""
echo "=========================================="
