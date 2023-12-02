#!/bin/bash

OBSIDIAN_VAULT_PATH="$HOME/obsidian-vault"
COMMIT_MESSAGE=$(date "+%FT%T%Z")

# цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function printInputMessage() {
	echo -e "$GREEN [ >> ] $NC" $1
}

function printINFO() {
	echo -e "$BLUE [ INFO ] $NC" $1
}

function printDEBUG() {
	echo -e "$YELLOW [ DEBUG ] $NC" $1
}

function printERROR() {
	echo -e "$RED [ ERROR ] $NC" $1
}

function printFATAL() {
	echo -e "$RED [ FATAL ] $NC" $1
}

# проверить существует ли хранилище
if [[ ! -d $OBSIDIAN_VAULT_PATH ]]; then
	printFATAL "Хранилище Obsidian не было найдено. Ожидаемое рассположение хранилища: $OBSIDIAN_VAULT_PATH"
	exit 1
fi

# перейти в хранилище
cd $OBSIDIAN_VAULT_PATH || exit 1

# проверить иницализирован ли git репозиторий в этом хранилище
if [[ ! -d ".git" ]]; then
	printDEBUG "Отсутствует git репозиторий"

	# создать новый git репозиторий
	printDEBUG "Инициазация git репозитория"
	git init &>/dev/null
	git branch -M main

	# настройка git'а - запросить у пользователя user.name если он пуст
	if [[ -z $(git config user.name) ]]; then
		printInputMessage "Введите свой username:"
		IFS= read -r new_git_username
		git config user.name "$new_git_username"
	fi

	# настройка git'а - запросить у пользователя user.email если он пуст
	if [[ -z $(git config user.email) ]]; then
		printInputMessage "Введите свой email: "
		IFS= read -r new_git_email
		git config user.email "$new_git_email"
	fi

	# добавить ссылку на удалённый репозиторий
	printInputMessage "Укажите ссылку на удалённый репозиторий:"
	IFS= read -r remoteRepoURL
	git remote add origin "$remoteRepoURL"
	printINFO "Удалённый репозиторий успешно добавлен"
fi

# загрузить последние изменения с сервера
if git pull origin main &>/dev/null; then
	printINFO "Синхронизация прошла успешно"
else
	printFATAL "Ошибка синхронизации: проверьте интернет-соединение"
	exit 1
fi

# вывести список изменений
echo "Список изменений: "
git status -s

# создать новый коммит
if git add . &>/dev/null && git commit -m "$COMMIT_MESSAGE" &>/dev/null; then
	printINFO "Новый коммит успешно создан: $COMMIT_MESSAGE"
else
	exit 0
fi

# отправить новый коммит на сервер
if git push -u origin main &>/dev/null; then
	printINFO "Синхронизация прошла успешно"
else
	printFATAL "Ошибка синхронизации: проверьте интернет-соединение или права доступа на этот репозиторий"

	# откатить коммит, созданный скриптом
	if ! git reset HEAD~ &>/dev/null; then
		printFATAL "Ошибка отката: программа не смогла удалить за сабой коммит"
	fi

	exit 1
fi
