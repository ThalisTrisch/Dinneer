@echo off
REM Script de teste E2E para módulo Local - Windows
REM Cria local de teste, testa funcionalidades e depois deleta

setlocal enabledelayedexpansion

set BASE_URL=http://localhost:3000
set API_PATH=/api/v1/local/LocalController

REM Dados do local de teste
set TEST_CEP=99999999
set TEST_CASA=9999
set TEST_USUARIO=6
set TEST_CNPJ=12345678901234
set TEST_COMPLEMENTO=Local de Teste E2E

echo ==========================================
echo Teste E2E - Modulo Local
echo ==========================================
echo.

REM 1. CRIAR LOCAL DE TESTE
echo 1. Criando local de teste...
curl -s -X POST "%BASE_URL%%API_PATH%?operacao=createLocal" ^
  -H "Content-Type: application/json" ^
  -d "{\"nu_cep\":\"%TEST_CEP%\",\"nu_casa\":\"%TEST_CASA%\",\"id_usuario\":%TEST_USUARIO%,\"nu_cnpj\":\"%TEST_CNPJ%\",\"dc_complemento\":\"%TEST_COMPLEMENTO%\"}" > temp_create.json

type temp_create.json
echo.

REM Buscar o ID do local criado
curl -s -X GET "%BASE_URL%%API_PATH%?operacao=getMeusLocais&id_usuario=%TEST_USUARIO%" > temp_locais.json

for /f "tokens=2 delims=:" %%a in ('findstr "id_local" temp_locais.json') do (
    set LOCAL_ID=%%a
    goto :found_id
)
:found_id
set LOCAL_ID=%LOCAL_ID:,=%
set LOCAL_ID=%LOCAL_ID: =%

echo Local criado com ID: %LOCAL_ID%
echo.
echo ==========================================
echo.

REM 2. BUSCAR LOCAL POR ID
echo 2. Buscando local por ID (%LOCAL_ID%)...
curl -s -X GET "%BASE_URL%%API_PATH%?operacao=getLocal&id_local=%LOCAL_ID%" ^
  -H "Content-Type: application/json" > temp_get.json

type temp_get.json
echo.
echo ==========================================
echo.

REM 3. LISTAR TODOS OS LOCAIS
echo 3. Listando todos os locais...
curl -s -X GET "%BASE_URL%%API_PATH%?operacao=getLocais" ^
  -H "Content-Type: application/json" > temp_all.json

type temp_all.json
echo.
echo ==========================================
echo.

REM 4. BUSCAR LOCAIS DO USUÁRIO
echo 4. Buscando locais do usuario (%TEST_USUARIO%)...
curl -s -X GET "%BASE_URL%%API_PATH%?operacao=getMeusLocais&id_usuario=%TEST_USUARIO%" ^
  -H "Content-Type: application/json" > temp_meus.json

type temp_meus.json
echo.
echo ==========================================
echo.

REM 5. DELETAR LOCAL (LIMPEZA)
echo 5. Deletando local de teste (limpeza)...
curl -s -X POST "%BASE_URL%%API_PATH%?operacao=deleteLocal" ^
  -H "Content-Type: application/json" ^
  -d "{\"id_local\":%LOCAL_ID%}" > temp_delete.json

type temp_delete.json
echo.
echo ==========================================
echo.

REM 6. VERIFICAR SE LOCAL FOI REALMENTE DELETADO
echo 6. Verificando se local foi deletado...
curl -s -X GET "%BASE_URL%%API_PATH%?operacao=getLocal&id_local=%LOCAL_ID%" ^
  -H "Content-Type: application/json" > temp_verify.json

type temp_verify.json
echo.
echo ==========================================
echo.

REM Limpar arquivos temporários
del temp_*.json 2>nul

echo Testes E2E do modulo Local concluidos!
echo.
echo Resumo:
echo   - Criacao de local
echo   - Busca por ID
echo   - Listagem de todos os locais
echo   - Listagem de locais do usuario
echo   - Delecao de local
echo   - Banco de dados limpo
echo.
echo ==========================================

endlocal
