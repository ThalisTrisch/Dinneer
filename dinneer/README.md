# 📱 Dinneer Frontend - Flutter

Aplicativo mobile para conectar pessoas através de jantares caseiros. Interface moderna e intuitiva construída com Flutter.

## 📋 Índice

- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Executar](#executar)
- [Estrutura](#estrutura)
- [Funcionalidades](#funcionalidades)
- [Build](#build)

## 🔧 Pré-requisitos

- **Flutter SDK** 3.0+ ([Guia de instalação](https://docs.flutter.dev/get-started/install))
- **Dart** 3.0+
- **Android Studio** (para emulador Android)
- **Xcode** (para iOS - apenas macOS)
- **Backend rodando** na porta 3000

## 📦 Instalação

```bash
# Navegar para o diretório do frontend
cd Dinneer/dinneer

# Instalar dependências
flutter pub get

# Verificar instalação do Flutter
flutter doctor
```

## ⚙️ Configuração

### 1. Configurar Firebase (Opcional)

Se for usar upload de imagens:

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione os arquivos de configuração:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

## 🚀 Executar

### Verificar Dispositivos Disponíveis

```bash
flutter devices
```

### Executar no Emulador/Dispositivo

```bash
# Executar em modo debug
flutter run

# Executar em dispositivo específico
flutter run -d <device_id>

# Executar no Chrome (Web)
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=/tmp/chrome_dev_test"
```

### Hot Reload

Durante o desenvolvimento, use:
- **r** - Hot reload
- **R** - Hot restart
- **q** - Quit

## 📁 Estrutura do Projeto

```
dinneer/
├── lib/
│   ├── main.dart                    # Ponto de entrada
│   │
│   ├── config/                      # Configurações
│   │   └── api_config.dart          # Config da API (Node.js/PHP)
│   │
│   ├── screens/                     # Telas do app
│   │   ├── tela_login.dart
│   │   ├── tela_cadastro.dart
│   │   ├── tela_home.dart
│   │   ├── tela_principal.dart
│   │   ├── tela_criar_jantar.dart
│   │   ├── tela_criar_local.dart
│   │   ├── tela_detalhes_jantar.dart
│   │   ├── tela_editar_jantar.dart
│   │   ├── tela_meus_jantares.dart
│   │   ├── tela_reservas.dart
│   │   ├── tela_perfil_publico.dart
│   │   └── perfil/
│   │       └── tela_perfil.dart
│   │
│   ├── service/                     # Services (API)
│   │   ├── http/
│   │   │   └── HttpService.dart     # Cliente HTTP
│   │   ├── usuario/
│   │   │   └── UsuarioService.dart
│   │   ├── local/
│   │   │   └── LocalService.dart
│   │   ├── refeicao/
│   │   │   ├── Cardapio.dart        # Model
│   │   │   └── cardapioService.dart
│   │   ├── encontro/
│   │   │   └── EncontroService.dart
│   │   ├── avaliacao/
│   │   │   └── AvaliacaoService.dart
│   │   └── sessao/
│   │       └── SessionService.dart  # Gerencia sessão local
│   │
│   └── widgets/                     # Componentes reutilizáveis
│       ├── barra_de_navegacao.dart
│       ├── campo_de_texto.dart
│       ├── card_refeicao.dart
│       └── modal_avaliacao.dart
│
├── android/                         # Configurações Android
├── ios/                             # Configurações iOS
├── web/                             # Configurações Web
├── test/                            # Testes
├── pubspec.yaml                     # Dependências
└── README.md
```

## ✨ Funcionalidades

### Autenticação
- ✅ Login de usuário
- ✅ Cadastro de novo usuário
- ✅ Gerenciamento de sessão

### Jantares
- ✅ Listar jantares disponíveis
- ✅ Criar novo jantar (com ou sem foto)
- ✅ Editar jantar
- ✅ Deletar jantar
- ✅ Ver detalhes do jantar

### Reservas
- ✅ Solicitar reserva em jantar
- ✅ Cancelar reserva
- ✅ Ver minhas reservas (como convidado)
- ✅ Ver meus jantares criados (como anfitrião)

### Gerenciamento de Convidados
- ✅ Ver lista de solicitações
- ✅ Aprovar convidados
- ✅ Rejeitar convidados
- ✅ Ver participantes confirmados

### Perfil
- ✅ Ver perfil público de usuários
- ✅ Ver avaliações e reputação
- ✅ Atualizar foto de perfil
- ✅ Ver jantares organizados

### Avaliações
- ✅ Avaliar anfitrião após jantar
- ✅ Ver média de avaliações
- ✅ Sistema de estrelas (1-5)

### Dados de Teste

Use estas credenciais para testar:

| Nome | Email | Senha |
|------|-------|-------|
| João Silva | joao.silva@email.com | senha123 |
| Maria Santos | maria.santos@email.com | senha123 |
| Pedro Oliveira | pedro.oliveira@email.com | senha123 |