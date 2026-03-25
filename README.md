<div align="center">

# ♠ TRUCKI ♥

### Contador de Pontos para Truco

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=flat)
![Version](https://img.shields.io/badge/Version-1.0.0-D4AF37?style=flat)

*Elegante. Simples. Feito para a mesa.*

</div>

---

## Sobre o Projeto

**Trucki** é um aplicativo mobile desenvolvido em Flutter para contagem de pontos em partidas de Truco. Com uma identidade visual sofisticada em preto, vermelho e dourado inspirada nos naipes de baralho, o app oferece controle de placar em tempo real e histórico completo de partidas.

---

## Funcionalidades

- 🃏 **Placar ao vivo** — adicione e remova pontos com um toque, com animação a cada alteração
- 🏆 **Detecção de vitória automática** — popup de vencedor ao atingir 12 pontos
- 📜 **Histórico de partidas** — todas as partidas encerradas com placar, vencedor e horário
- 🔍 **Timeline de eventos** — veja cada ponto marcado, por quem e quando
- ⚙️ **Nomes personalizados** — edite o nome das duas equipes (padrão: Nós × Eles)
- 💾 **Estado persistente** — sair para o menu e voltar mantém o placar intacto
- 🗑️ **Gerenciamento do histórico** — exclua partidas individualmente

---

## Telas

| Tela | Descrição |
|------|-----------|
| **Menu** | Tela inicial com navegação para as demais seções |
| **InGame** | Partida ao vivo com placar, botões +/− e navbar |
| **Configurações** | Edição dos nomes das equipes |
| **Histórico** | Lista de partidas encerradas |
| **Detalhes** | Placar final e timeline completa de uma partida |

---

## Estrutura do Projeto

```
lib/
├── main.dart                       # Ponto de entrada, instancia GameState
├── theme/
│   └── app_theme.dart              # Paleta de cores e tema global
├── models/
│   └── match.dart                  # TruckiMatch e ScoreEvent
├── services/
│   ├── game_state.dart             # ChangeNotifier — estado da partida ativa
│   └── storage_service.dart        # Persistência com SharedPreferences
├── widgets/
│   └── suit_widgets.dart           # SuitRow, GoldDivider, LuxCard
└── screens/
    ├── menu_screen.dart            # Tela inicial
    ├── in_game_screen.dart         # Partida ao vivo
    ├── config_screen.dart          # Configurações
    ├── historic_screen.dart        # Histórico de partidas
    └── match_detail_screen.dart    # Detalhes e timeline
```

---

## Instalação

**Pré-requisitos:** Flutter 3.x e Dart 3.x instalados.

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/trucki.git
cd trucki

# 2. Instale as dependências
flutter pub get

# 3. Execute o app
flutter run
```

### Build de produção

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## Dependências

| Pacote | Versão | Uso |
|--------|--------|-----|
| [shared_preferences](https://pub.dev/packages/shared_preferences) | `^2.2.2` | Persistência local de partidas e configurações |
| [intl](https://pub.dev/packages/intl) | `^0.19.0` | Formatação de datas no histórico |
| [google_fonts](https://pub.dev/packages/google_fonts) | `^6.2.1` | Fontes Playfair Display e Lato |

---

## Arquitetura

O estado da partida ativa é gerenciado pelo `GameState` — um `ChangeNotifier` instanciado no topo da árvore de widgets (`main.dart`) e passado por parâmetro às telas que precisam dele. Isso garante que o placar seja preservado ao navegar entre telas.

```
TruckiApp
  └── GameState (ChangeNotifier)
        ├── MenuScreen
        ├── InGameScreen  ← lê e modifica GameState
        ├── ConfigScreen  ← atualiza nomes no GameState
        └── HistoricScreen
              └── MatchDetailScreen
```

### StatefulWidget vs StatelessWidget

| Widget | Tipo | Motivo |
|--------|------|--------|
| `TruckiApp` | Stateful | Mantém o `GameState` vivo |
| `InGameScreen` | Stateful | Controla `AnimationController` e escuta `GameState` |
| `HistoricScreen` | Stateful | Carrega lista de partidas assíncronamente |
| `ConfigScreen` | Stateful | Gerencia `TextEditingController` e estado de loading |
| `MenuScreen` | Stateless | Apenas navega; estado no `GameState` |
| `MatchDetailScreen` | Stateless | Recebe dados prontos via construtor |
| `_ScorePanel`, `_Dot`, `_MatchCard` etc. | Stateless | Puramente visuais, sem estado próprio |

---

## Design

A identidade visual do Trucki é inspirada na sofisticação dos jogos de carta:

| Elemento | Valor |
|----------|-------|
| Fundo principal | `#0A0A0A` (preto profundo) |
| Cor primária (dourado) | `#D4AF37` |
| Cor secundária (vermelho) | `#CC1A1A` |
| Texto principal | `#F5F0E8` (creme) |
| Fonte de títulos | Playfair Display (serif) |
| Fonte de corpo | Lato (sans-serif) |

Os naipes ♠ ♥ ♦ ♣ são usados como elementos decorativos em todas as telas, reforçando o tema do aplicativo.

---

## Regras do Jogo

- Primeiro time a atingir **12 pontos** vence a partida
- A pontuação mínima por equipe é **0** (botão − bloqueado em zero)
- Ao vencer, a partida é **salva automaticamente** no histórico
- O botão **Reiniciar** salva a partida atual antes de zerar o placar
- Ao voltar ao **Menu** durante uma partida, o placar é **preservado** em memória

---

## Favicon (Web)

Para exibir o ícone na aba do navegador em projetos Flutter Web, adicione o `favicon.svg` à pasta `web/` e insira no `web/index.html`:

```html
<link rel="icon" type="image/svg+xml" href="favicon.svg">
```

---

<div align="center">

♠ &nbsp; ♥ &nbsp; ♦ &nbsp; ♣

*Trucki v1.0.0 — Boa sorte na mesa!*

</div>
