---
name: ideacao-project-overview
description: >-
  Maps the ideacao repository (Godot 4 platformer "Lampião Souls"): entry scene,
  folders, main gameplay scripts, input, physics layers, and scene flow. Use
  when onboarding, locating files, understanding project layout, or when the
  user asks onde fica, estrutura, overview, or how the game starts.
---

# ideacao — visão geral do projeto

## O que é

- **Nome no README**: Lampião Souls — plataforma 2D no sertão (movimento, pulo, tiro, fases estilo *Souls-like* leve).
- **Nome no Godot** (`project.godot`): `Bellapps`.
- **Motor**: Godot **4.x** (projeto referencia features `4.6`; README sugere 4.4+).
- **Cena principal**: `res://scenes/main.tscn` (`run/main_scene` em `project.godot`).

## Fluxo de cenas (alto nível)

1. `main.tscn` — costuma carregar menu / shell inicial.
2. Menu (`main_menu.gd`): **Play** → `first_stage` (padrão `res://scenes/stages/stage_01.tscn`).
3. Fases em `scenes/stages/stage_0N.tscn` — jogador, tilemap, meta (`goal.gd`), zonas de morte (`kill_zone.gd`).
4. `goal.gd`: ao o jogador entrar na área, troca para `next_scene` (encadeamento de fases ou `victory.tscn`).

## Pastas importantes

| Pasta | Conteúdo |
|-------|----------|
| `scenes/` | Cenas: `main`, menu, `player`, `bullet`, `victory`, `stages/stage_01`… |
| `scripts/` | GDScript de gameplay (jogador, estágios, projétil, meta, kill zone, menu, vitória). |
| `assets/` | Sprites, `tiles/sertao_tileset.tres`, UI (ex.: logo). |
| `design/` | Referência de arte: `ART_SCALE.md`, `MOODBOARD.md`. |
| `tools/` | Utilitários: `build_tileset.gd`, `gen_pixel_assets.py`. |

## Scripts centrais (por responsabilidade)

- **Jogador**: `scripts/player.gd` + `scenes/player.tscn`
- **Projétil**: `scripts/bullet.gd` + `scenes/bullet.tscn`
- **Menu**: `scripts/main_menu.gd`
- **Fases (base)**: `scripts/sertao_stage_base.gd` — mapa ASCII + spawn; estágios concretos: `stage_01.gd`, `stage_02.gd`, `stage_03.gd`
- **Progressão**: `scripts/goal.gd` (troca de cena), `scripts/victory.gd`, `scripts/kill_zone.gd`

## Input (`project.godot`)

- `move_left` / `move_right` — setas e A/D
- `jump` — espaço e seta cima
- `shoot` — **X**

## Camadas 2D physics

1. `player`
2. `world`
3. `projectile`

## Outras skills deste repo

- Refatoração + reinício do Godot: `.cursor/skills/refactor-restart-godot-game/`
- Mapas ASCII e tiles: `.cursor/skills/ideacao-stages-and-maps/`
