#!/bin/bash

# ----------------------------
# -------  data.bash ---------
# ---- autor : Leo Sudreau ---
# ---- version : 0.8 ---------
# ----------------------------
#
# Le scripts à pour but de synchroniser différents comptes en lignes, permettant d'avoir tout ces dossier en ligne au lancement de l'environement de travail
# Pour ceci le script comprendra plusieurs fonctions :
#
#   - Une fonction qui definira le dossier ou les différents dossiers seronts installés
#   - Une fonction qui synchronisera, dans le cas ou les dossiers sont deja installé
#   - différentes fonctions pour les différents services de stockages en lignes
#
# Le scripts sera en communiquation avec le project DarkSide, mais sera aussi si l'utilisateur le veut totalement utilisable seul sous la forme de commande.
#
# A la creation de chaque dossier syncronisé, un fichier text contenant une liste de ces dossiers se mettra à jour, il permettra la mise a jour regulieres des dossiers.

# Debut Variable global

default_location=~/Data # L'emplacement par default
install_location=$default_location # L'emplacement final d'instalation des dossiers
date=$( date +%Y%m%d ) # date courante
log_location=/var/tmp/TheDarkSide

# Fin variable grobal

# ----- Function folder ------
#
# Cette fonction permet de determiner le chemin d'instalation du dossier "data"
#
# La fonction comprend un paramètre :
#   location : le chemin absolue voulu, si aucun n'es saisie lors de l'instalation, un chemin par default ( ~/Data ) existe et sera utilisé.
#
# ----- Function folder ------

function folder () { #location
  if [ -d "$1" ] || [ -d "$default_location" ];
  then
    echo "dossier déjâ installé"
    install_location=$default_location
  else
    if [ -n $1 ]
    then
      echo "creation dossier par default"
      mkdir $default_location
      install_location=$default_location
    else
      echo "creation dossier utilisateur"
      install_location=$1
      mkdir "$install_location"
    fi
  fi
  mkdir /var/tmp/TheDarkSide
}


# ----- Function github ------
#
# Cette fonction permet de clonner un dossier github.
# La fonction comprend trois paramètres :
#   folder_name : le nom de dossier qui va etre crée.
#   adresse : L'adresse github permettant le clonage.
#   branche : La branche voulu, ce paramatre est optionnel, si aucune branche n'est écrite, la fonction clonera la branche master du git.
# Si le git est deja cloné, il sera mise à jour.
#
# ----- Function github ------

function github() { # folder_name,adresse,branche
  if [ -d "$install_location/$1" ]
  then
    echo "Le git $1 existe déjà"
    echo " Mise à jour du git ..."
    cd $install_location/$1 | git pull
    log $install_location/$1 "git update" $2
  else
    if [ -n $3 ]
    then
      git clone "$2" "$install_location/$1"
      log $install_location/$1 git $2
    else
      git clone -b "$3" "$2" "$install_location"
      log $install_location/$1 git $2 $3
    fi
  fi
}

# ----- Function log ------
#
# Cette fonction enrengistre tout les actions faites par le scripts
# La fonction comprend 4 paramètres
#   dossier : chemin absolue du dossier
#   type : type d'action en fonction du service utilisé et du type action faites, clonage ou mise à jour
#   adresse : l'adresse qui à permis le clonage
#   branche : Si le service utilisé comprend un systeme de branche, la branche selectionnée
#
# Chaque ligne de log est composée de la maniere suivante :
#
#  [ date : date de l'action ] [ dossier : chemin absolue du dossier] [ type : type de service utilisé] [ adresse : adresse de clonage] [ branche : branche utilisé si besoin ]
#
# ----- Function log ------

function log() { # dossier , type , adresse , branche
  if [ -n $3 ]
  then
    echo " [ date : $date ] [ dossier : $1 ] [ type : $2 ] [ adresse : $3 ] " >> $log_location/datalog.txt
  else
    echo " [ date : $date ] [ dossier : $1 ] [ type : $2 ]  [ adresse : $3 ] [ branche : $4 ] " >> $log_location/datalog.txt
  fi
}

# ----- Function clean ------
# Fonction provisoir pour les test
# ----- Function clean ------

function clean() {
  rm $log_location/datalog.txt
  rm -r $install_location
}

# ----- Function svn ------
#
# Cette fonction permet de clonner un dossier svn.
# La fonction comprend deux paramètres :
#   dossier : chemin absolue du dossier
#   adresse : L'adresse svn permettant le clonage.
#   users : Nom de l'utilisateur voulant accédes au dossier svn
# Si le git est deja cloné, il sera mise à jour.
#
# ----- Function svn ------

function svn() {
  if [ -d "$install_location/$1" ]
  then
    echo "Le svn $1 existe déjà"
    echo " Mise à jour du svn ..."
    cd $install_location/$1 | svn update
    log $install_location/$1 "svn update" $2
  else
    svn checkout --username "$3" --password "svn!$3" "$2" "$install_location/$1"
    log $install_location/$1 svn $2
  fi
}

# ----- Function webserver ------
#
# Cette fonction permet de clonner le contenu d'un serveur web, il comprend les server HTTP, FTP et HTTPS
# La fonction comprend deux paramètres :
#   dossier : chemin absolue du dossier
#   adresse : L'adresse permettant le clonage.

# ----- Function webserver ------

function webserver(){


}

# ----- Function check ------
#
# Cette fonction verifira si le dossier trouvé et présent de le fichier log
# Si c'est le cas, il fera juste mis à jour.
# sinon, il ne fera rien
# la fonction comprend un parametre :
#  Dosser : adresse absolue du dossier trouvé
# ----- Function check ------

function check(){

}

# Main

folder
github IUT https://github.com/LinkIsACake/IUT.git
github OTHERS https://github.com/LinkIsACake/OTHERS.git
