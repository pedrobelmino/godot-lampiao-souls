---
name: commit-before-changes
description: >-
  Requires a git checkpoint commit of the current working tree before starting
  file edits or a new change. Use in the ideacao repo (or any git repo) when
  the user asks to commit before changes, checkpoint antes de modificar, or when
  beginning substantive edits so each batch of work sits on its own commit.
---

# Commit antes de modificar

## Regra

Antes de **criar ou alterar** ficheiros (código, cenas, assets) em resposta a um pedido:

1. **`git status`** no repositório do projeto.
2. Se houver alterações por commitar (staged ou unstaged):
   - **`git add`** o que fizer sentido (normalmente tudo o que compõe o estado atual).
   - **`git commit -m "..."`** com mensagem curta e clara: o que já está feito no working tree (não o que vais fazer a seguir).
3. Só depois disso aplicar as novas modificações pedidas.
4. Se o working tree já estiver **limpo** (nada a commitar), não inventes commit vazio; segue para as edições.

## Mensagens

- Preferir **imperativo** ou descrição factual em português ou inglês, alinhada ao projeto.
- Um commit = um **snapshot** do estado antes do próximo trabalho; não misturar na mesma mensagem o “antes” e o “depois” se forem dois passos distintos.

## Exceções

- Pedido explícito para **não** commitar ou para **descartar** alterações: não aplicar esta regra.
- Repositório sem git ou sem permissão: explicar e seguir o pedido do utilizador sem falhar.

## Porquê

Garante histórico reversível: cada bloco de alterações novas pode ser revisto ou revertido sem perder o estado intermédio commitado.
