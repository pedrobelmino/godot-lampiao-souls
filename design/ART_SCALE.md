# Escala travada — pixel cru (sertão ritual)

Todos os novos assets devem obedecer estes números.

| Parâmetro | Valor |
|-----------|--------|
| **Tamanho do tile** | **32×32 px** |
| **Altura do personagem** | **36 px** (caixa de sprite; colisão ~14×28 a 16×32) |
| **Contorno** | 1 px (quando aplicável) |
| **Cores por material (tile)** | 4–6 por bloco |
| **Spritesheet personagens** | frames 32×36 px, dispostos em faixa horizontal |

## Paleta base (hex)

- `#1a0f0a` — sombra / contorno
- `#5c3d2e` — terra
- `#8b6914` — ocre
- `#c4a574` — taipa clara
- `#2d4a3e` — verde espinho
- `#8b2942` — vermelho ritual / fita
- `#87ceeb` — céu pálido (uso parcial)

## Godot

- Texturas 2D: filtro **Nearest** (já reforçado em `project.godot` em `rendering/textures`).
- Tileset: `res://assets/tiles/sertao_tileset.png` + `sertao_tileset.tres` (gerado por `tools/build_tileset.gd`).

## IDs de tile (atlas 32×32, fileira única)

| Índice atlas (x) | Uso |
|------------------|-----|
| 0 | Chão barro rachado |
| 1 | Taipa / parede |
| 2 | Plataforma terra |
| 3 | Mandacaru (decoração, sem colisão ou colisão parcial) |
| 4 | Ruína capela (bloco) |
| 5 | Pedra / rocha escura |
| 6 | Vazio / transparente (não usar paint) |
| 7 | Grama seca / detalhe |

Colisão de plataforma: tiles **0, 1, 2, 4, 5** com retângulo completo; **3** opcional sem física.
