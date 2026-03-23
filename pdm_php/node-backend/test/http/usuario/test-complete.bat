@echo off
REM Script de teste completo para Windows
REM Cria usuário de teste, testa funcionalidades e depois deleta

setlocal enabledelayedexpansion

set BASE_URL=http://localhost:3000
set API_PATH=/api/v1/usuario/UsuarioController

REM Dados do usuário de teste
set TEST_CPF=99999999999
set TEST_EMAIL=teste_automatizado@email.com
set TEST_SENHA=senha_teste_123
set TEST_NOME=Usuario
set TEST_SOBRENOME=Teste

echo ==========================================
echo Teste Completo da API Dinneer
echo ==========================================
echo.

REM 1. CRIAR USUÁRIO DE TESTE
echo 1. Criando usuario de teste...
curl -s -X POST "%BASE_URL%%API_PATH%?operacao=createUsuario" ^
  -H "Content-Type: application/json" ^
  -d "{\"nu_cpf\":\"%TEST_CPF%\",\"nm_usuario\":\"%TEST_NOME%\",\"nm_sobrenome\":\"%TEST_SOBRENOME%\",\"vl_email\":\"%TEST_EMAIL%\",\"vl_senha\":\"%TEST_SENHA%\",\"vl_foto\":null}" > temp_create.json

type temp_create.json
echo.
echo ==========================================
echo.

REM Extrair ID do usuário criado
for /f "tokens=2 delims=:" %%a in ('findstr "id_usuario" temp_create.json') do (
    set USER_ID=%%a
    goto :found_id
)
:found_id
set USER_ID=%USER_ID:,=%
set USER_ID=%USER_ID: =%

echo Usuario criado com ID: %USER_ID%
echo.

REM 2. TESTAR LOGIN
echo 2. Testando login com usuario criado...
curl -s -X POST "%BASE_URL%%API_PATH%?operacao=loginUsuario" ^
  -H "Content-Type: application/json" ^
  -d "{\"vl_email\":\"%TEST_EMAIL%\",\"vl_senha\":\"%TEST_SENHA%\"}" > temp_login.json

type temp_login.json
echo.
echo ==========================================
echo.

REM 3. BUSCAR USUÁRIO POR ID
echo 3. Buscando usuario por ID (%USER_ID%)...
curl -s -X GET "%BASE_URL%%API_PATH%?operacao=getUsuario&id_usuario=%USER_ID%" ^
  -H "Content-Type: application/json" > temp_get.json

type temp_get.json
echo.
echo ==========================================
echo.

REM 4. ATUALIZAR FOTO DE PERFIL
echo 4. Atualizando foto de perfil...
curl -s -X POST "%BASE_URL%%API_PATH%?operacao=atualizarFotoPerfil" ^
  -H "Content-Type: application/json" ^
  -d "{\"id_usuario\":%USER_ID%,\"vl_foto\":\"https://exemplo.com/foto_teste.jpg\"}" > temp_foto.json

type temp_foto.json
echo.
echo ==========================================
echo.

REM 5. DELETAR USUÁRIO (LIMPEZA)
echo 5. Deletando usuario de teste (limpeza)...
curl -s -X POST "%BASE_URL%%API_PATH%?operacao=deleteUsuario" ^
  -H "Content-Type: application/json" ^
  -d "{\"id_usuario\":%USER_ID%}" > temp_delete.json

type temp_delete.json
echo.
echo ==========================================
echo.

REM 6. VERIFICAR SE USUÁRIO FOI REALMENTE DELETADO
echo 6. Verificando se usuario foi deletado...
curl -s -X GET "%BASE_URL%%API_PATH%?operacao=getUsuario&id_usuario=%USER_ID%" ^
  -H "Content-Type: application/json" > temp_verify.json

type temp_verify.json
echo.
echo ==========================================
echo.

REM Limpar arquivos temporários
del temp_*.json 2>nul

echo Testes concluidos!
echo.
echo Resumo:
echo   - Criacao de usuario
echo   - Login
echo   - Busca por ID
echo   - Atualizacao de foto
echo   - Delecao de usuario
echo   - Banco de dados limpo
echo.
echo ==========================================

endlocal
