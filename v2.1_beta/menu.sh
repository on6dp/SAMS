#!/bin/bash
OPTION=$(whiptail --title "SAPEURS-POMPIERS : Systeme d'alerte par SMS" --menu "Faites votre choix :" 15 60 4 \
"start" "Lancement du systeme" \
"init" "Initialisation" \
"config" "Configuration des bips" \
"test" "Test" \
"install" "Installation" \
"uninstall" "Desinstallation" \
"help" "Aide" 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Vous avez choisi la distribution : " $OPTION
	./pegasus.sh --$OPTION
else
    echo "vous avez annulé, vous quitter le menu principal"
fi
