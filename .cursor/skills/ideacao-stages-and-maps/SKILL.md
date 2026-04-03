---
name: ideacao-stages-and-maps
description: >-
  Explains how stages are built in ideacao: sertao_stage_base.gd, ASCII map
  format, tile character codes, spawn_tile, and per-stage scripts. Use when
  editing TileMaps, adding stages, level design, or when the user mentions
  mapa ASCII, fases, stage_0, or sertao.
---

# Fases e mapas (ideacao)

## Base comum

Todas as fases que usam o padrão **sertão** estendem `scripts/sertao_stage_base.gd` (`extends Node2D` na cena).

Fluxo em `_ready()` da base:

1. Carrega `res://assets/tiles/sertao_tileset.tres` no `TileMapLayer`.
2. Chama `_get_map()` (implementado em cada `stage_0N.gd`) — string multilinha ASCII.
3. `_apply_ascii` converte caracteres em células do tileset (source id `0`).
4. Posiciona o nó `Player` com base em `spawn_tile` (coordenada em **células**) e tamanho do tile do TileSet (ex.: 16×16).

Cada estágio concreto **sobrescreve** `_get_map() -> String` e, se necessário, ajusta `spawn_tile` **antes** de `super._ready()` (ver `stage_01.gd`).

## Caracteres → tiles (`_char_to_tile`)

| Char | Significado (tile id na linha 0 do atlas) |
|------|---------------------------------------------|
| `.` ou espaço | vazio (-1) |
| `g` | 0 |
| `t` | 1 |
| `p` | 2 |
| `m` | 3 |
| `c` | 4 |
| `r` | 5 |
| `x` | 6 |
| `w` | 7 |

Linhas do mapa: índice `y` de cima para baixo; colunas `x` da esquerda para a direita.

## Cena de fase

- Path típico: `scenes/stages/stage_0N.tscn`.
- Deve conter pelo menos: `TileMapLayer` (nome esperado pela base: `TileMapLayer`), script do estágio anexado, nó `Player` se a base for posicionar o spawn.

## Nova fase (checklist)

1. Duplicar uma `stage_0N.tscn` existente ou criar cena com a mesma estrutura da base.
2. Criar `scripts/stage_0N.gd` com `extends "res://scripts/sertao_stage_base.gd"`, `_get_map()` com o desenho ASCII, e `spawn_tile` coerente com o chão.
3. Encadear no jogo: `goal.gd` da fase anterior com `next_scene` apontando para a nova cena; última fase pode apontar para `victory.tscn`.

## Ferramentas relacionadas

- `tools/build_tileset.gd` — manutenção do tileset.
- `design/ART_SCALE.md` — escala visual / pixel art.
