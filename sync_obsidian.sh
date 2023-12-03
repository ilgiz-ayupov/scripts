#!/bin/bash

# Модули
# shellcheck disable=SC1091
source "$HOME/scripts/utils/output.sh"
source "$HOME/scripts/utils/git.sh"

OBSIDIAN_VAULT_PATH="$HOME/obsidian-vault"
COMMIT_MESSAGE=$(date "+%FT%T%Z")

# проверить существует ли хранилище
if [[ -d $OBSIDIAN_VAULT_PATH ]]; then
	cd "$OBSIDIAN_VAULT_PATH" || exit 1
else
	Fatalln "Хранилище Obsidian не было найдено. Ожидаемое рассположение хранилища: $OBSIDIAN_VAULT_PATH"
	exit 1
fi

# проверить иницализирован ли git репозиторий в этом хранилище
if [[ ! -d ".git" ]]; then
	Debugln "Отсутствует git репозиторий"
	NewGitRepository
fi

# загрузить последние изменения с сервера
GitPull "main"

# создать новый коммит
if GitAddAllAndCreateCommit "$COMMIT_MESSAGE"; then
	# вывести список изменений
	ShowGitChangedFiles
fi

# отправить новый коммит на сервер
if ! GitPush "main"; then
	# откатить коммит, созданный скриптом
	if ! git reset HEAD~ &>/dev/null; then
		Fatatln "Ошибка отката: программа не смогла удалить за сабой коммит"
	fi

	exit 1
fi
