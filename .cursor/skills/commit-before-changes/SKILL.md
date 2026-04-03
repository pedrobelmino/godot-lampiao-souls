---
name: commit-before-changes
description: >-
  Requires a git checkpoint commit before starting file edits; and after every
  10 commits ahead of master, open a pull request and merge into master. Use in
  ideacao or when the user asks commit antes de modificar, checkpoint, PR a cada
  10 commits, or merge na master.
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

## A cada 10 commits: PR e merge na `master`

Depois de um **`git commit`** (incluindo commits feitos por esta skill), verificar se deve abrir PR e fundir na **`master`**:

1. **Fetch** remoto: `git fetch origin` (para `origin/master` estar atualizado).
2. **Contar** commits no ramo atual que ainda não estão em `master`:
   - `git rev-list --count origin/master..HEAD`  
   - Se o remoto usar `main` em vez de `master`, usar `origin/main` como base de comparação.
3. Se esse **número for > 0** e **múltiplo de 10** (10, 20, 30, …):
   - **`git push -u origin <ramo-atual>`** se ainda não estiver pushed.
   - Abrir **pull request** do ramo atual → **`master`** (título/descrição curtos: soma dos últimos 10 commits ou tema comum).
   - **Mergear** o PR na `master` (merge commit ou squash conforme convenção do repo; se não houver regra, merge normal está ok).

### Ferramentas

- Preferir **GitHub CLI** se existir: `gh pr create --base master` (ou `--base main`) e `gh pr merge` (ou merge pelo URL no browser).
- Sem `gh` ou sem rede: descrever os comandos que o utilizador pode correr e não falhar silenciosamente.

### Exceções

- Sem `origin/master` / repo sem remoto: não forçar PR; avisar.
- Política do projeto for **só `develop`**: adaptar a base do PR ao ramo principal acordado, mas este projeto pede **merge na `master`** quando esta regra dispara.

## Exceções (commit inicial)

- Pedido explícito para **não** commitar ou para **descartar** alterações: não aplicar esta regra.
- Repositório sem git ou sem permissão: explicar e seguir o pedido do utilizador sem falhar.

## Porquê

Garante histórico reversível e integração periódica na `master` em blocos de 10 commits.
