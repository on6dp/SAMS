#!/bin/bash
whiptail --title "SYSTEME D'ALERTE SMS - mode test" --msgbox "Bienvenu en mode test." 12 60
OPTION=$(whiptail --title "SYSTEME D'ALERTE SMS - mode test" --menu "Choisissez votre distriubtion linux" 15 60 4 \
"1" "Envoyer un message vers un numéro de bip" \
"2" "Envoyer un message vers un numéro de téléphone" \
"3" "Aide" 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Vous avez choisi l'option : " $OPTION
	cd test && ./$OPTION.sh
else
    echo "Vous avez quittez le mode test, retour au menu principal"
	whiptail --title "SYSTEME D'ALERTE SMS - mode test" --msgbox "Vous avez quittez le mode test, retour au menu principal . Cliquer sur Ok pour continuer." 10 60
	./menu.sh
fi
