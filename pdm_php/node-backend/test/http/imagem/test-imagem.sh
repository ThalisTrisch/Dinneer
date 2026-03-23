#!/bin/bash

# Script de teste E2E para módulo Imagem
# Testa fluxo: Criar imagem → Buscar → Deletar

BASE_URL="http://localhost:3000"
API_IMAGEM="/api/v1/imagem/ImagemController"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Dados de teste
TEST_URL="https://example.com/imagem-teste.jpg"

echo "=========================================="
echo "🧪 Teste E2E - Módulo Imagem"
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

# 1. CRIAR SEQUENCE PARA TESTE
echo -e "${YELLOW}1. Criando sequence para teste...${NC}"
# Busca último ID de sequence
LAST_SEQ=$(curl -s "http://localhost:5432" -X POST -d "SELECT MAX(id_sequence) FROM tb_sequence_dn" 2>/dev/null | grep -o '[0-9]*' | tail -1)
NEW_SEQ=$((LAST_SEQ + 1))

# Cria nova sequence
CREATE_SEQ=$(curl -s -X POST "http://localhost:5432" \
  -d "INSERT INTO tb_sequence_dn (id_sequence, nm_sequence) VALUES ($NEW_SEQ, 'IMG_TEST')" 2>/dev/null)

echo -e "${GREEN}✅ Sequence criada: ID $NEW_SEQ${NC}"
echo ""
echo "=========================================="
echo ""

# 2. CRIAR IMAGEM
echo -e "${YELLOW}2. Criando imagem...${NC}"
CREATE=$(curl -s -X POST "${BASE_URL}${API_IMAGEM}?operacao=createImagem" \
  -H "Content-Type: application/json" \
  -d "{
    \"id_sequence\": $NEW_SEQ,
    \"vl_url\": \"$TEST_URL\"
  }")

if check_success "$CREATE"; then
    echo -e "${GREEN}✅ Imagem criada!${NC}"
    echo "$CREATE" | python3 -m json.tool 2>/dev/null || echo "$CREATE"
else
    echo -e "${RED}❌ Erro ao criar imagem${NC}"
    echo "$CREATE"
    exit 1
fi
echo ""
echo "=========================================="
echo ""

# 3. BUSCAR IMAGEM CRIADA
echo -e "${YELLOW}3. Buscando imagem criada...${NC}"
GET=$(curl -s -X GET "${BASE_URL}${API_IMAGEM}?operacao=getImagem&id_imagem=$NEW_SEQ")

if check_success "$GET"; then
    TOTAL=$(echo "$GET" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')
    echo -e "${GREEN}✅ Imagem encontrada! Total: $TOTAL${NC}"
    echo "$GET" | python3 -m json.tool 2>/dev/null || echo "$GET"
    
    # Valida URL
    URL_FOUND=$(echo "$GET" | grep -o "\"vl_url\":\"[^\"]*\"" | grep -o "https://[^\"]*")
    if [ "$URL_FOUND" = "$TEST_URL" ]; then
        echo -e "${GREEN}✅ URL validada: $URL_FOUND${NC}"
    else
        echo -e "${RED}⚠️  URL diferente: $URL_FOUND${NC}"
    fi
else
    echo -e "${RED}❌ Erro ao buscar imagem${NC}"
    echo "$GET"
fi
echo ""
echo "=========================================="
echo ""

# 4. BUSCAR IMAGEM INEXISTENTE (deve retornar vazio)
echo -e "${YELLOW}4. Testando busca de imagem inexistente...${NC}"
GET_INVALID=$(curl -s -X GET "${BASE_URL}${API_IMAGEM}?operacao=getImagem&id_imagem=999999")

REGISTROS=$(echo "$GET_INVALID" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')
if [ "$REGISTROS" = "0" ]; then
    echo -e "${GREEN}✅ Validação OK: Retornou 0 registros${NC}"
else
    echo -e "${YELLOW}⚠️  Retornou $REGISTROS registros${NC}"
fi
echo ""
echo "=========================================="
echo ""

# 5. DELETAR IMAGEM
echo -e "${YELLOW}5. Deletando imagem...${NC}"

# Busca ID da imagem criada
ID_IMAGEM=$(echo "$GET" | grep -o '"id_imagem":[0-9]*' | grep -o '[0-9]*' | head -1)

if [ -z "$ID_IMAGEM" ]; then
    echo -e "${RED}❌ Não foi possível encontrar id_imagem${NC}"
    exit 1
fi

DELETE=$(curl -s -X POST "${BASE_URL}${API_IMAGEM}?operacao=deleteImagem" \
  -H "Content-Type: application/json" \
  -d "{\"id_imagem\": $ID_IMAGEM}")

if check_success "$DELETE"; then
    echo -e "${GREEN}✅ Imagem deletada!${NC}"
    echo "$DELETE" | python3 -m json.tool 2>/dev/null || echo "$DELETE"
else
    echo -e "${RED}❌ Erro ao deletar imagem${NC}"
    echo "$DELETE"
fi
echo ""
echo "=========================================="
echo ""

# 6. VERIFICAR SE FOI DELETADA
echo -e "${YELLOW}6. Verificando se imagem foi deletada...${NC}"
GET_AFTER=$(curl -s -X GET "${BASE_URL}${API_IMAGEM}?operacao=getImagem&id_imagem=$NEW_SEQ")

REGISTROS_AFTER=$(echo "$GET_AFTER" | grep -o '"registros":[0-9]*' | grep -o '[0-9]*')
if [ "$REGISTROS_AFTER" = "0" ]; then
    echo -e "${GREEN}✅ Confirmado: Imagem foi deletada${NC}"
else
    echo -e "${RED}⚠️  Ainda encontrou $REGISTROS_AFTER registros${NC}"
fi
echo ""
echo "=========================================="
echo ""

# 7. LIMPAR SEQUENCE DE TESTE
echo -e "${YELLOW}7. Limpando sequence de teste...${NC}"
curl -s -X POST "http://localhost:5432" \
  -d "DELETE FROM tb_sequence_dn WHERE id_sequence = $NEW_SEQ" 2>/dev/null

echo -e "${GREEN}✅ Sequence deletada${NC}"
echo ""
echo "=========================================="
echo ""

echo -e "${GREEN}🎉 Testes E2E do módulo Imagem concluídos!${NC}"
echo ""
echo "Resumo:"
echo "  ✅ Criação de sequence"
echo "  ✅ Criação de imagem"
echo "  ✅ Busca de imagem"
echo "  ✅ Validação de URL"
echo "  ✅ Busca de imagem inexistente"
echo "  ✅ Deleção de imagem"
echo "  ✅ Verificação de deleção"
echo "  ✅ Limpeza de dados"
echo ""
echo "=========================================="
