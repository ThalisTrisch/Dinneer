#!/bin/bash

# Script de demonstração de falha
# Este teste falha propositalmente para demonstrar o sistema de detecção de erros

BASE_URL="http://localhost:3000"
API_USUARIO="/api/v1/usuario/UsuarioController"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "🧪 Teste de Demonstração de Falha"
echo "=========================================="
echo ""

# Teste 1: Sucesso
echo -e "${YELLOW}1. Teste que passa...${NC}"
echo -e "${GREEN}✅ Este teste passou!${NC}"
echo ""

# Teste 2: Sucesso
echo -e "${YELLOW}2. Outro teste que passa...${NC}"
echo -e "${GREEN}✅ Este teste também passou!${NC}"
echo ""

# Teste 3: FALHA PROPOSITAL
echo -e "${YELLOW}3. Teste que vai falhar propositalmente...${NC}"
echo -e "${RED}❌ ERRO: Endpoint não encontrado!${NC}"
echo -e "${RED}   URL: ${BASE_URL}/endpoint-inexistente${NC}"
echo -e "${RED}   Status: 404 Not Found${NC}"
echo ""

# Teste 4: Não será executado devido à falha anterior
echo -e "${YELLOW}4. Este teste não será alcançado...${NC}"
echo ""

echo "=========================================="
echo -e "${RED}❌ Teste falhou no passo 3${NC}"
echo "=========================================="

# Retorna código de erro
exit 1
