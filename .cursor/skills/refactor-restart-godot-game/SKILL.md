---
name: refactor-restart-godot-game
description: >-
  When the user requests refactoring (refatorar, refactor, code cleanup) on this
  Godot project, after applying changes the agent must kill any running Godot
  process launched for this project and start a fresh game instance. Use when
  the user asks for refactoring, code changes to the game, or explicitly wants
  the game restarted after edits.
---

# Refatoração + reinício do jogo (Godot)

## Quando aplicar

Sempre que o pedido for **refatoração**, **refactor**, reorganização de código ou mudanças no jogo neste repositório, **e** o fluxo exigir validar o jogo rodando: ao **terminar** as edições relevantes, execute o ciclo **matar processo → nova instância**.

Não espere o usuário pedir “reinicie o jogo” se ele já pediu refatoração neste projeto: isso faz parte do fluxo.

## Passos obrigatórios (fim do turno de refatoração)

1. **Encerrar** processos do Godot que estejam rodando este projeto (caminho do projeto e `godot` na linha de comando).
2. **Subir** uma nova instância do jogo com `--path` apontando para a raiz do projeto (onde está `project.godot`).
3. Se o ambiente não tiver display (CI/headless), ainda assim execute o `pkill` e informe que o reinício gráfico precisa ser feito localmente; tente `godot --path ... --headless --quit-after 1` só como checagem de carga de projeto, não como substituto do jogo visível.

## Comando preferido

Execute o script desta skill (raiz do projeto = pasta que contém `project.godot`):

```bash
bash .cursor/skills/refactor-restart-godot-game/scripts/restart-game.sh
```

(A partir da raiz do clone, por exemplo `godot-lampiao-souls/`.)

Ou equivalente: `pkill` por padrão seguro + `GODOT` + `--path` até a raiz do workspace que contém `project.godot`.

## Detecção de processo (Linux)

- Padrão típico da linha de comando: `godot` (ou `Godot_*`) com `--path` contendo o diretório do projeto.
- Use `pkill -f` com um trecho do caminho do projeto (ex.: `godot.*godot-lampiao-souls`) **ou** o script, que usa o caminho absoluto em `${ROOT}`.
- Não use `killall godot` sem critério: pode fechar outros projetos Godot abertos.

## Variáveis

- `GODOT`: binário (padrão `~/.local/bin/godot` se existir, senão `godot` no `PATH`).

## Falhas

- Se `pkill` não achar processo, continue e inique a nova instância (não é erro).
- Se não houver binário Godot, informe o usuário para instalar ou ajustar `GODOT`.
