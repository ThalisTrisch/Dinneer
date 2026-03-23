@echo off
REM Script de teste E2E para módulo Cardapio - Windows

setlocal enabledelayedexpansion

set BASE_URL=http://localhost:3000
set API_PATH=/api/v1/cardapio/CardapioController

set TEST_USUARIO=6
set TEST_TITULO=Jantar Teste E2E
set TEST_DESCRICAO=Descricao do jantar de teste
set TEST_PRECO=50.00
set TEST_DATA=2026-12-31 19:00:00
set TEST_VAGAS=10
set TEST_CEP=99999999
set TEST_CASA=9999

echo ==========================================
echo Teste E2E - Modulo Cardapio
echo ==========================================
echo.

echo 1. Criando jantar completo...
curl -s -X POST "%BASE_URL%%API_PATH%?operacao=createJantar" ^
  -H "Content-Type: application/json" ^
  -d "{\"id_usuario\":%TEST_USUARIO%,\"nm_cardapio\":\"%TEST_TITULO%\",\"ds_cardapio\":\"%TEST_DESCRICAO%\",\"preco_refeicao\":%TEST_PRECO%,\"hr_encontro\":\"%TEST_DATA%\",\"nu_max_convidados\":%TEST_VAGAS%,\"nu_cep\":\"%TEST_CEP%\",\"nu_casa\":\"%TEST_CASA%\",\"vl_foto\":null,\"id_local\":null}" > temp_create.json

type temp_create.json
echo.
echo ==========================================
echo.

echo 2. Listando cardapios disponiveis...
curl -s -X GET "%BASE_URL%%API_PATH%?operacao=getCardapiosDisponiveis" > temp_list.json
type temp_list.json
echo.
echo ==========================================
echo.

REM Extrair ID (simplificado)
for /f "tokens=2 delims=:" %%a in ('findstr "id_cardapio" temp_list.json') do (
    set CARDAPIO_ID=%%a
    goto :found_id
)
:found_id
set CARDAPIO_ID=%CARDAPIO_ID:,=%
set CARDAPIO_ID=%CARDAPIO_ID: =%

echo ID do cardapio: %CARDAPIO_ID%
echo.

echo 3. Deletando jantar (limpeza)...
curl -s -X POST "%BASE_URL%%API_PATH%?operacao=deleteCardapio" ^
  -H "Content-Type: application/json" ^
  -d "{\"id_cardapio\":%CARDAPIO_ID%}" > temp_delete.json

type temp_delete.json
echo.
echo ==========================================
echo.

del temp_*.json 2>nul

echo Testes E2E do modulo Cardapio concluidos!
echo.
echo ==========================================

endlocal
