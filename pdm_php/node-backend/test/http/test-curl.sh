#!/bin/bash

# Script de testes para API Dinneer usando curl
# Execute: chmod +x test-curl.sh && ./test-curl.sh

BASE_URL="http://localhost:3000"
API_PATH="/api/v1/usuario/UsuarioController"

echo "=========================================="
echo "Testando API Dinneer - Node.js Backend"
echo "=========================================="
echo ""

# Teste 1: Listar todos os usuários
echo "1. Listando todos os usuários..."
curl -X GET "${BASE_URL}${API_PATH}?operacao=getUsuarios" \
  -H "Content-Type: application/json" \
  | json_pp
echo ""
echo "=========================================="
echo ""

# Teste 2: Buscar usuário por ID
echo "2. Buscando usuário ID=1..."
curl -X GET "${BASE_URL}${API_PATH}?operacao=getUsuario&id_usuario=1" \
  -H "Content-Type: application/json" \
  | json_pp
echo ""
echo "=========================================="
echo ""

# Teste 3: Login (PRINCIPAL)
echo "3. Testando login..."
echo "   (Substitua email e senha por credenciais válidas)"
curl -X POST "${BASE_URL}${API_PATH}?operacao=loginUsuario" \
  -H "Content-Type: application/json" \
  -d '{
    "vl_email": "teste@email.com",
    "vl_senha": "senha123"
  }' \
  | json_pp
echo ""
echo "=========================================="
echo ""

# Teste 4: Criar usuário
echo "4. Criando novo usuário..."
curl -X POST "${BASE_URL}${API_PATH}?operacao=createUsuario" \
  -H "Content-Type: application/json" \
  -d '{
    "nu_cpf": "98765432100",
    "nm_usuario": "Teste",
    "nm_sobrenome": "Curl",
    "vl_email": "testecurl@email.com",
    "vl_senha": "senha123",
    "vl_foto": null
  }' \
  | json_pp
echo ""
echo "=========================================="
echo ""

echo "Testes concluídos!"
