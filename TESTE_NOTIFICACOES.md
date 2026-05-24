# 🔔 Guia de Teste - Framework de Notificações Push

## 📋 Pré-requisitos

Antes de testar, certifique-se de que:
- ✅ Backend está rodando (`npm run dev` em `pdm_php/node-backend`)
- ✅ Service Account Key do Firebase está configurado
- ✅ Você tem acesso a **2 dispositivos/emuladores** (para testar envio e recebimento)

## 🚀 Como Executar o App

### ⚠️ IMPORTANTE: Execute APENAS UM comando por vez

**Para testar notificações, você precisa rodar o app em 2 dispositivos diferentes simultaneamente.**

### Opção 1: Emulador Android (Recomendado para Notificações)

```bash
cd dinneer
flutter run
```

**Ou especifique o dispositivo:**
```bash
flutter run
```

### Opção 2: Chrome/Web (NÃO suporta notificações push)

```bash
cd dinneer
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=/tmp/chrome_dev_test"
```

⚠️ **Nota:** Notificações push **NÃO funcionam na web**. Use apenas para testar outras funcionalidades.

### Opção 3: Dispositivo Físico (Melhor para Notificações)

```bash
# Liste os dispositivos conectados
flutter devices

# Execute no dispositivo específico
flutter run -d <device-id>
```

## 🧪 Cenário de Teste Ideal

### Setup Recomendado:

**Terminal 1 - Backend:**
```bash
cd pdm_php/node-backend
npm run dev
```

**Terminal 2 - Dispositivo 1 (Emulador Android):**
```bash
cd dinneer
flutter run -d emulator-5554
```

**Terminal 3 - Dispositivo 2 (Outro Emulador ou Dispositivo Físico):**
```bash
cd dinneer
flutter run -d emulator-5556
# OU
flutter run -d <seu-dispositivo-fisico>
```

### ⚠️ Limitações por Plataforma:

| Plataforma | Notificações Push | Chat | Outras Funcionalidades |
|------------|-------------------|------|------------------------|
| Android (Emulador com Play Services) | ✅ Sim | ✅ Sim | ✅ Sim |
| Android (Dispositivo Real) | ✅ Sim | ✅ Sim | ✅ Sim |
| iOS (Dispositivo Real) | ✅ Sim* | ✅ Sim | ✅ Sim |
| Web (Chrome) | ❌ Não | ✅ Sim | ✅ Sim |

*iOS requer configuração adicional de certificados APNs

---

## 🧪 Método 1: Teste Completo (Recomendado)

### Passo 1: Prepare Dois Dispositivos

**Opção A - Dois Emuladores Android:**
```bash
# Terminal 1 - Emulador 1
flutter run -d emulator-5554

# Terminal 2 - Emulador 2
flutter run -d emulator-5556
```

**Opção B - Emulador + Dispositivo Físico:**
```bash
# Liste os dispositivos disponíveis
flutter devices

# Execute em cada um
flutter run -d <device-id>
```

**Opção C - Web + Emulador (para desenvolvimento rápido):**
```bash
# Terminal 1 - Web
flutter run -d chrome

# Terminal 2 - Android
flutter run -d emulator-5554
```

### Passo 2: Faça Login em Cada Dispositivo

**Dispositivo 1:**
- Email: `joao.silva@email.com`
- Senha: `senha123`

**Dispositivo 2:**
- Email: `maria.santos@email.com`
- Senha: `senha123`

### Passo 3: Crie um Jantar (Dispositivo 1)

1. No **Dispositivo 1** (João), vá para "Meus Jantares"
2. Clique em "Criar Novo Jantar"
3. Preencha os dados e crie o jantar

### Passo 4: Faça uma Reserva (Dispositivo 2)

1. No **Dispositivo 2** (Maria), vá para a tela inicial
2. Encontre o jantar criado por João
3. Clique em "Reservar"
4. Aguarde aprovação

### Passo 5: Aprove a Reserva (Dispositivo 1)

1. No **Dispositivo 1** (João), vá para "Meus Jantares"
2. Clique no jantar criado
3. Veja a lista de reservas pendentes
4. Aprove a reserva de Maria

### Passo 6: Teste o Chat e Notificações

1. No **Dispositivo 1** (João), abra o chat do jantar
2. Envie uma mensagem: "Olá Maria, bem-vinda!"
3. **No Dispositivo 2 (Maria)**, você deve receber uma **notificação push** 🔔
4. Abra a notificação e veja a mensagem no chat
5. Responda no chat
6. **No Dispositivo 1 (João)**, você deve receber a notificação 🔔

---

## 🧪 Método 2: Teste Rápido com cURL (Backend)

Se você só quer testar se o backend está enviando notificações:

### Passo 1: Obtenha um FCM Token

Execute o app em um dispositivo e verifique os logs do Flutter:
```bash
flutter run -d <device-id>
```

Procure no console por algo como:
```
FCM token salvo para usuário 1
```

### Passo 2: Adicione o Token Manualmente no Firebase

1. Acesse o Firebase Console: https://console.firebase.google.com/
2. Vá em **Realtime Database**
3. Adicione manualmente:
   ```
   users/
     1/
       fcmToken: "seu-token-aqui"
     2/
       fcmToken: "outro-token-aqui"
   ```

### Passo 3: Teste o Endpoint de Notificação

```bash
curl -X POST http://localhost:3000/api/v1/notification/send-chat \
  -H "Content-Type: application/json" \
  -d '{
    "id_encontro": 1,
    "id_usuario": "1",
    "nm_usuario": "João Silva",
    "tx_mensagem": "Teste de notificação!"
  }'
```

**Resposta esperada:**
```json
{
  "status": 0,
  "mensagem": "1 notificação(ões) enviada(s)"
}
```

---

## 🧪 Método 3: Teste com Firebase Console (Notificação Manual)

### Passo 1: Execute o App

```bash
flutter run -d <device-id>
```

### Passo 2: Faça Login

Use qualquer usuário de teste.

### Passo 3: Envie Notificação Manual pelo Firebase

1. Acesse: https://console.firebase.google.com/
2. Vá em **Cloud Messaging**
3. Clique em **"Enviar sua primeira mensagem"**
4. Preencha:
   - **Título:** "Teste"
   - **Texto:** "Testando notificações"
5. Clique em **"Próximo"**
6. Selecione o app **"Dinneer"**
7. Clique em **"Revisar"** e **"Publicar"**

**Você deve receber a notificação no dispositivo!** 🔔

---

## 🔍 Verificando se Está Funcionando

### ✅ Sinais de Sucesso:

**No Console do Backend:**
```
🚀 Servidor rodando na porta 3000
📍 http://localhost:3000
```

**No Console do Flutter (quando enviar mensagem):**
```
Notificação enviada com sucesso
```

**No Dispositivo que Recebe:**
- 🔔 Notificação aparece na barra de status
- Som de notificação toca
- Ao clicar, abre o chat

### ❌ Problemas Comuns:

**1. "FCM token não encontrado"**
- Solução: Faça login no app primeiro, o token é salvo automaticamente

**2. "Nenhum destinatário encontrado"**
- Solução: Certifique-se de que há outros participantes no jantar

**3. Notificação não aparece**
- Verifique se as permissões de notificação estão ativadas no dispositivo
- No Android: Configurações → Apps → Dinneer → Notificações → Ativar

**4. Backend não inicia**
- Verifique se o Service Account Key está no lugar correto
- Verifique o arquivo `.env`

---

## 🎯 Checklist de Teste Completo

- [ ] Backend rodando sem erros
- [ ] App instalado em 2 dispositivos
- [ ] Login feito em ambos os dispositivos
- [ ] Jantar criado e reserva feita
- [ ] Chat aberto entre os participantes
- [ ] Mensagem enviada do Dispositivo 1
- [ ] Notificação recebida no Dispositivo 2
- [ ] Mensagem enviada do Dispositivo 2
- [ ] Notificação recebida no Dispositivo 1
- [ ] Contador de mensagens não lidas funcionando
- [ ] Som de notificação tocando
- [ ] Ao clicar na notificação, abre o chat correto

---

## 📊 Monitoramento em Tempo Real

### Ver Tokens no Firebase Realtime Database:

1. Acesse: https://console.firebase.google.com/
2. Vá em **Realtime Database**
3. Navegue até `users/`
4. Você verá algo como:
   ```
   users/
     1/
       fcmToken: "dXYz..."
     2/
       fcmToken: "aBcD..."
   ```

### Ver Contador de Não Lidas:

```
unread_counts/
  1/  (id_encontro)
    2/  (id_usuario)
      2  (número de mensagens não lidas)
```

---

## 🚀 Teste Automatizado (Opcional)

Se quiser criar um script de teste:

```bash
# Criar arquivo de teste
cat > test-notification.sh << 'EOF'
#!/bin/bash

echo "🧪 Testando Framework de Notificações..."

# Teste 1: Verificar se backend está rodando
echo "1. Verificando backend..."
curl -s http://localhost:3000 > /dev/null
if [ $? -eq 0 ]; then
  echo "✅ Backend está rodando"
else
  echo "❌ Backend não está rodando"
  exit 1
fi

# Teste 2: Enviar notificação de teste
echo "2. Enviando notificação de teste..."
RESPONSE=$(curl -s -X POST http://localhost:3000/api/v1/notification/send-chat \
  -H "Content-Type: application/json" \
  -d '{
    "id_encontro": 1,
    "id_usuario": "1",
    "nm_usuario": "Teste",
    "tx_mensagem": "Mensagem de teste"
  }')

echo "Resposta: $RESPONSE"

if echo "$RESPONSE" | grep -q "notificação"; then
  echo "✅ Notificação enviada com sucesso"
else
  echo "❌ Erro ao enviar notificação"
fi

echo "✅ Testes concluídos!"
EOF

chmod +x test-notification.sh
./test-notification.sh
```

---

## 📱 Testando em Produção (Futuro)

Quando o app estiver publicado:

1. **Android:**
   - Baixe da Play Store
   - Faça login
   - Teste com outro usuário real

2. **iOS:**
   - Baixe da App Store
   - Faça login
   - Teste com outro usuário real

3. **Monitoramento:**
   - Firebase Console → Cloud Messaging → Estatísticas
   - Veja quantas notificações foram enviadas/entregues

---

## 🎓 Entendendo o Fluxo

```
1. Usuário A envia mensagem no chat
   ↓
2. Flutter chama NotificationService.sendChatNotification()
   ↓
3. Requisição HTTP para backend: POST /api/v1/notification/send-chat
   ↓
4. Backend busca participantes do encontro
   ↓
5. Backend busca FCM tokens no Firebase Realtime Database
   ↓
6. Backend verifica contador de não lidas (máx 2)
   ↓
7. Backend envia notificação via Firebase Cloud Messaging
   ↓
8. Firebase entrega notificação para Usuário B
   ↓
9. Usuário B recebe notificação push 🔔
   ↓
10. Ao clicar, abre o chat
```

---

## 💡 Dicas Extras

- **Teste em modo debug primeiro** para ver os logs
- **Use dois emuladores** para facilitar o teste
- **Verifique o Firebase Console** para ver os tokens salvos
- **Teste com mensagens diferentes** para ver se todas chegam
- **Teste o limite de 2 notificações** enviando 3 mensagens seguidas

---

**Pronto! Agora você sabe como testar completamente o framework de notificações!** 🎉
