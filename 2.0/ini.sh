#!/bin/bash
###################################
#
# script d'initialisation du SASMS
#
###################################

#supression du fichier d'alerte
sudo rm alert_output.txt

#supression du fichier token
sudo rm token.txt

#supression du fichier session
sudo rm session.txt

#retour au menu principal
./menu.sh
