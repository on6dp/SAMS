
#!/bin/bash

OPTION=$(whiptail --title "SYSTEME D'ALERTE SMS" --menu "Faite votre choix (en utilisant les flèches) :" 15 60 4 \
"1" "Démarrage" \
"2" "Configuration des bips" \
"3" "Test" \
"ini" "Initialisation"  3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Vous avez choisi l'option : " $OPTION
        ./$OPTION.sh
else
    echo "vous avez annulé"
fi

