#!/bin/sh
# Clone les dépôts de code de Dramatoons dans l'espace de travail.
# Les dossiers déjà présents ne sont pas touchés.
set -e
cd "$(dirname "$0")"

clone() {
    if [ -d "$2" ]; then
        echo "$2 : déjà présent"
    else
        git clone "git@github.com:remi-leconte/$1.git" "$2"
    fi
}

clone dramatoons-api                api
clone dramatoons-front              front
clone dramatoons-extension-chromium ext-ch
clone dramatoons-extension-firefox  ext-ff
