#!/bin/bash
whiptail --title "SYSTEME D'ALERTE SMS - mode configuration" --msgbox "!ATTENTION! Vous entrer en mode configuration." 12 60
whiptail --title "SYSTEME D'ALERTE SMS - mode configuration" --msgbox "Dans la prochaine fenêtre il vous sera demandé de saisir votre numéro de bip. Veuillez le saisir sous la forme 261234, sans la lettre. Votre numéro de bip est disponible sur Systel, dans l'onglet Alerte locale, ou sur votre bip. Cliquer sur Ok pour continuer." 12 60
num_bip=$(whiptail --title "SYSTEME D'ALERTE SMS - mode configuration" --inputbox "Quel est votre numéro de bip ?"  10 60 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Numéro de bip :" $num_bip
	whiptail --title "SYSTEME D'ALERTE SMS - mode configuration" --msgbox "Dans la prochaine fenêtre, veuillez renseigner le ou les numéros de téléphone à assigner à votre bip. Vous quitterez cette fenêtre grâce aux touches ctrl+x puis valider avec le o et entrée . Cliquer sur Ok pour continuer." 10 60
	nano $num_bip.txt
	./menu.sh
else
    echo "Vous avez quittez le mode configuration, retour au menu principal"
	whiptail --title "SYSTEME D'ALERTE SMS - mode configuration" --msgbox "Vous avez quittez le mode configuration, retour au menu principal . Cliquer sur Ok pour continuer." 10 60
	./menu.sh
	
fi
