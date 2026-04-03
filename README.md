# Lampião Souls

Jogo de plataforma 2D ambientado no sertão, com movimento, pulo, arma e fases em estilo *Souls-like* leve (cenários com risco e progressão).

Este repositório chama-se **ideacao**; o nome da aplicação no Godot é **Lampião Souls** (`project.godot`, campo `config/name`).

<p align="center">
  <img src="assets/ui/bellapps_logo.png" alt="Lampião Souls — logo" width="420" />
</p>

<p align="center">
  <img src="assets/characters/lampiao_maria_sheet.png" alt="Sprites do personagem" width="480" />
</p>

## Tecnologias

| Ferramenta | Uso |
|------------|-----|
| **[Godot Engine 4](https://godotengine.org/)** | Motor do jogo (2D, física, cenas, input) |
| **GDScript** | Lógica do jogador, estágios, projéteis, metas e zonas de dano |
| **TileMap + TileSet** | Cenários a partir de mapas ASCII e *tileset* do sertão |
| **Forward Plus** | *Backend* de renderização configurado no projeto |
| **CanvasItem / stretch** | Janela base 960×540, *stretch* em modo `canvas_items` |
| **Python** (opcional) | Scripts em `tools/` para assets e utilitários de *build* |
| **[Cursor](https://cursor.com/)** | IDE com agentes e *skills* para documentar e evoluir o código de forma consistente |

![Godot](https://img.shields.io/badge/Godot-4.4+-478CBF?style=flat&logo=godot-engine&logoColor=white)
![GDScript](https://img.shields.io/badge/GDScript-gameplay-478CBF?style=flat)

### Detalhes técnicos do projeto

- **Versão alvo do motor**: recursos marcados como **4.4** em `project.godot` (recomenda-se Godot **4.4 ou superior**).
- **Cena de entrada**: `res://scenes/main.tscn`.
- **Autoload**: `GameAudio` (`scripts/game_audio.gd`) — áudio global disponível em todas as cenas.
- **Física 2D** (*layers*): `player`, `world`, `projectile`, `enemy`.
- **Pixel art**: *snap* 2D a pixel e filtro de textura *Nearest* (crisp pixels).

## Fluxo do jogo (alto nível)

1. `main.tscn` — *shell* inicial / transição para o menu.
2. Menu (`main_menu.gd`): **Play** carrega a primeira fase (por defeito `res://scenes/stages/stage_01.tscn`).
3. Fases em `scenes/stages/` — jogador, *TileMap*, meta (`goal.gd`), zonas de morte (`kill_zone.gd`).
4. Ao alcançar a meta, a cena seguinte é carregada (cadeia de fases ou ecrã de vitória).

## Desenvolvimento com Cursor e IA

Este projeto inclui **Agent Skills** em [`.cursor/skills/`](.cursor/skills/) para alinhar assistentes de IA (e humanos) ao contexto do jogo:

| Skill | Função |
|-------|--------|
| `ideacao-project-overview` | Mapa do repositório: pastas, scripts principais, input e fluxo de cenas. |
| `ideacao-stages-and-maps` | Mapas ASCII, `sertao_stage_base.gd`, códigos de *tiles* e criação de fases. |
| `commit-before-changes` | Convenção de *checkpoint* em git antes de alterações maiores e integração periódica. |
| `refactor-restart-godot-game` | Após refatorações, reiniciar o Godot para validar o jogo. |

Se estiveres a usar **Cursor** (ou outro fluxo com agentes) no âmbito de um **curso ou formação em IA aplicada ao código**, estes ficheiros funcionam como *fonte de verdade* local: descrevem convenções do repo para o agente não “inventar” estrutura de pastas nem ignorar o fluxo Godot ↔ GDScript.

## Requisitos

- [Godot 4.x](https://godotengine.org/download) (recomendado **4.4** ou superior)

## Como executar

1. Clone este repositório.
2. Abra o Godot e use **Importar** apontando para a pasta do projeto (onde está `project.godot`).
3. Execute a cena principal (**F5** ou botão Play).

## Controles

| Ação | Entrada |
|------|---------|
| Mover esquerda / direita | Setas ou **A** / **D** |
| Agachar (no chão) | Seta **Baixo** ou **S** |
| Pular | Espaço ou seta **Cima** |
| Atirar | **X** |

## Estrutura (resumo)

| Pasta | Conteúdo |
|-------|-----------|
| `scenes/` | Cenas: menu, jogador, projétil, vitória e fases (`stages/`) |
| `scripts/` | GDScript do *gameplay* |
| `assets/` | *Sprites*, *tileset* e UI |
| `design/` | Referência de arte (escala, *moodboard*) |
| `tools/` | Utilitários (ex.: geração de assets, *tileset*) |

## Licença

Defina a licença desejada (por exemplo MIT) se o repositório for público.
