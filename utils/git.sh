#!/bin/bash

# git.sh 
# модуль для работы с git

# Модули
# shellcheck disable=SC1091
source "$HOME/scripts/utils/output.sh"

# initGitRepository инициалицирует git репозиторий
function _initGitRepository() {
    Debugln "Инициазация git репозитория"
    git init &>/dev/null
    git branch -M main
}

# configurateGitUserName устанавливает username
function _configurateGitUserName() {
    if [[ -z $(git config user.name) ]]; then
        Inputln "Введите свой username:"
        IFS= read -r new_git_username
        git config user.name "$new_git_username"
    fi
}

# configurateGitEmail устанавливает email
function _configurateGitEmail() {
    if [[ -z $(git config user.email) ]]; then
        Inputln "Введите свой email: "
        IFS= read -r new_git_email
        git config user.email "$new_git_email"
    fi
}

# addRemoteGitRepositoryURL добавить ссылку на удалённый git репозиторий
function _addRemoteGitRepositoryURL() {
    Inputln "Укажите ссылку на удалённый репозиторий:"
    IFS= read -r remoteRepoURL
    git remote add origin "$remoteRepoURL"
    Infoln "Удалённый репозиторий успешно добавлен"
}

# NewGitRepository создать git репозиторий в текущей папке
function NewGitRepository() {
    _initGitRepository
    _configurateGitUserName
    _configurateGitEmail
    _addRemoteGitRepositoryURL
}

# ShowGitChangedFiles показывает список изменённых файлов
function ShowGitChangedFiles() {
    echo "Git: Список изменений"
    git status -s
}

# GitPull загрузить из удалённого репозиторая
function GitPull() {
    branch="main"
    if [[ -z $1 ]]; then
        branch="$1"
    fi

    if git pull origin "$branch" &>/dev/null; then
        Infoln "Синхронизация прошла успешно"
    else
        Fatalln "Ошибка подключения к удалённому репозиторию: $(git config remote.origin.url)"
        exit 1
    fi
}

# GitPull загрузить из удалённого репозиторая
function GitPush() {
    branch="main"
    if [[ -z $1 ]]; then
        branch="$1"
    fi

    if git push -u origin "$branch" &>/dev/null; then
        Infoln "Синхронизация прошла успешно"
    else
        Fatalln "Ошибка подключения к удалённому репозиторию: $(git config remote.origin.url)"
        exit 1
    fi
}

# GitAddAllAndCreateCommit выбрать все изменённые файлы и создать коммит
function GitAddAllAndCreateCommit() {
    if [[ -z $1 ]]; then
        Fatalln "GitCreateCommit: необходимо указать сообщение"
        exit 1
    fi

    if git add . &>/dev/null && git commit -m "$1" &>/dev/null; then
        Infoln "Новый коммит успешно создан: $1"
    else
        Debugln "Коммит не создан: нет изменений"
        exit 1
    fi
}
