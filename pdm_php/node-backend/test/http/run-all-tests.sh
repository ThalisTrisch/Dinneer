#!/bin/bash

# Script de execução de todos os testes E2E com resumo consolidado
# Executa todos os módulos e apresenta estatísticas finais

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variáveis de controle
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
START_TIME=$(date +%s)

# Arrays para armazenar resultados
declare -a TEST_NAMES
declare -a TEST_STATUS
declare -a TEST_TIMES

echo ""
echo "=========================================="
echo -e "${CYAN}🧪 EXECUTANDO TODOS OS TESTES E2E${NC}"
echo "=========================================="
echo ""

# Função para executar um teste
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🧪 Executando: $test_name${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    local test_start=$(date +%s)
    local temp_output=$(mktemp)
    
    # Executa o teste e captura a saída
    eval "$test_command" > "$temp_output" 2>&1
    local exit_code=$?
    
    local test_end=$(date +%s)
    local test_duration=$((test_end - test_start))
    
    # Mostra a saída do teste
    cat "$temp_output"
    
    # Armazena resultados
    TEST_NAMES+=("$test_name")
    TEST_TIMES+=("${test_duration}s")
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo ""
    if [ $exit_code -eq 0 ]; then
        TEST_STATUS+=("✅ PASS")
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✅ $test_name - PASSOU (${test_duration}s)${NC}"
    else
        TEST_STATUS+=("❌ FAIL")
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}❌ $test_name - FALHOU (${test_duration}s)${NC}"
        echo -e "${RED}   Verifique a saída acima para detalhes do erro${NC}"
    fi
    
    # Remove arquivo temporário
    rm -f "$temp_output"
    
    echo ""
}

# Executa todos os testes
run_test "Usuario" "npm run test:e2e:usuario"
run_test "Local" "npm run test:e2e:local"
run_test "Cardapio" "npm run test:e2e:cardapio"
run_test "Encontro" "npm run test:e2e:encontro"
run_test "Avaliacao" "npm run test:e2e:avaliacao"
run_test "Imagem" "npm run test:e2e:imagem"

# Calcula tempo total
END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))

# Calcula taxa de sucesso
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
else
    SUCCESS_RATE=0
fi

# Apresenta resumo
echo ""
echo "=========================================="
echo -e "${CYAN}📊 RESUMO FINAL DOS TESTES E2E${NC}"
echo "=========================================="
echo ""

# Cabeçalho da tabela
printf "%-15s %-12s %-10s\n" "Módulo" "Status" "Tempo"
echo "──────────────────────────────────────────"

# Linhas da tabela
for i in "${!TEST_NAMES[@]}"; do
    printf "%-15s %-12s %-10s\n" "${TEST_NAMES[$i]}" "${TEST_STATUS[$i]}" "${TEST_TIMES[$i]}"
done

echo ""
echo "=========================================="
echo -e "${BLUE}Estatísticas:${NC}"
echo "──────────────────────────────────────────"
echo -e "Total de testes:    ${CYAN}$TOTAL_TESTS${NC}"
echo -e "Sucessos:           ${GREEN}$PASSED_TESTS ✅${NC}"
echo -e "Falhas:             ${RED}$FAILED_TESTS ❌${NC}"
echo -e "Taxa de sucesso:    ${CYAN}${SUCCESS_RATE}%${NC}"
echo -e "Tempo total:        ${CYAN}${TOTAL_DURATION}s${NC}"
echo "=========================================="
echo ""

# Mensagem final
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 TODOS OS TESTES PASSARAM COM SUCESSO! 🎉${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}⚠️  ALGUNS TESTES FALHARAM! ⚠️${NC}"
    echo -e "${YELLOW}Por favor, verifique os logs acima para mais detalhes.${NC}"
    echo ""
    exit 1
fi
