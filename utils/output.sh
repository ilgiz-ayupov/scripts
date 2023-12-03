#!/bin/bash

# цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Inputln выводит строку ввода сообщения
function Inputln() {
    echo -e "${GREEN}[>>]${NC} $1"
}

# Infoln выводит INFO сообщение
function Infoln() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Debugln выводит DEBUG сообщение
function Debugln() {
    echo -e "${YELLOW}[DEBUG]${NC} $1"
}

# Errorln выводит ERROR сообщение
function Errorln() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fatalln выводит FATAL сообщение
function Fatalln() {
    echo -e "${RED}[FATAL]${NC} $1"
}
