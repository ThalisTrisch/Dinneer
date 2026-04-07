# Estrutura de Telas - Dinneer

Esta pasta contém todas as telas do aplicativo organizadas por funcionalidade.

## Estrutura Atual

```
lib/screens/
├── cadastro/
│   ├── tela_cadastro.dart
│   └── components/
│       ├── etapa_credenciais.dart (Etapa 1: Email e senha)
│       └── etapa_dados_pessoais.dart (Etapa 2: Nome, CPF e foto)
│
├── jantar/
│   ├── tela_criar_jantar.dart
│   ├── tela_editar_jantar.dart
│   └── tela_meus_jantares.dart
│
├── detalhes_jantar/
│   ├── tela_detalhes_jantar.dart
│   └── components/
│       ├── jantar_header.dart (AppBar com imagem do jantar)
│       ├── jantar_info_usuario.dart (Informações do anfitrião)
│       ├── jantar_detalhes_adicionais.dart (Data e vagas)
│       ├── jantar_mapa.dart (Mapa de localização)
│       ├── jantar_botoes_anfitriao.dart (Botões Editar/Cancelar)
│       ├── jantar_botao_convidado.dart (Botão Solicitar/Cancelar reserva)
│       └── modal_agendamento.dart (Modal para solicitar reserva)
│
├── perfil/
│   ├── tela_perfil.dart
│   └── components/
│       ├── perfil_header.dart
│       ├── tab_avaliacoes.dart
│       └── tab_meus_locais.dart
│
├── perfil_publico/
│   ├── tela_perfil_publico.dart
│   └── components/
│       ├── perfil_publico_header.dart (Avatar, nome e avaliações)
│       └── lista_jantares_organizados.dart (Lista de jantares do usuário)
│
├── reservas/
│   ├── tela_reservas.dart
│   └── components/
│       ├── filtro_chip.dart (Chip de filtro reutilizável)
│       ├── lista_participacao.dart (Tab "Participei")
│       ├── lista_organizacao.dart (Tab "Organizei")
│       └── modal_gerenciar_participantes.dart (Modal de gerenciamento)
│
├── tela_criar_local.dart
├── tela_home.dart
├── tela_login.dart
└── tela_principal.dart
```

## Benefícios da Refatoração

### 1. Manutenibilidade
- Arquivos menores e mais focados (< 300 linhas)
- Componentes reutilizáveis
- Separação clara de responsabilidades

### 2. Organização
- Estrutura hierárquica por funcionalidade
- Componentes agrupados por tela
- Fácil localização de código

### 3. Escalabilidade
- Facilita adição de novos componentes
- Permite testes unitários de componentes
- Reduz acoplamento entre telas

## Componentes Criados

### Detalhes do Jantar (7 componentes)
Arquivo original: 513 linhas → Dividido em 8 arquivos

### Reservas (4 componentes)
Arquivo original: 437 linhas → Dividido em 5 arquivos

### Cadastro (2 componentes)
Arquivo original: 233 linhas → Dividido em 3 arquivos

### Perfil Público (2 componentes)
Arquivo original: 188 linhas → Dividido em 3 arquivos

## Próximos Passos Sugeridos

1. Refatorar `tela_criar_jantar.dart` (169 linhas)
2. Refatorar `tela_editar_jantar.dart` (138 linhas)
3. Considerar extrair componentes de `tela_home.dart` (134 linhas)
4. Considerar extrair componentes de `tela_meus_jantares.dart` (129 linhas)
