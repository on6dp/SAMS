#!/bin/bash
############################################
#
# envoi d'un SMS de test vers numéro de bip
#
############################################
num_bip=$(whiptail --title "SYSTEME D'ALERTE SMS - mode test" --inputbox "Quel est votre numéro de bip?" 10 60 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Votre numéro de bip est le :" $num_bip
else
    echo "Vous avez quittez le mode configuration, retour au menu principal"
	whiptail --title "SYSTEME D'ALERTE SMS - mode test" --msgbox "Vous avez quittez le mode test, retour au menu principal . Cliquer sur Ok pour continuer." 10 60
	cd .. && ./menu.sh
fi

msg=$(whiptail --title "SYSTEME D'ALERTE SMS - mode test" --inputbox "Veuillez saisir le message à envoyer" 10 60 Ceci_est_un_message_de_test_venant_du_SASMS 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Votre message est :" $msg
else
    echo "Vous avez quittez le mode configuration, retour au menu principal"
	whiptail --title "SYSTEME D'ALERTE SMS - mode test" --msgbox "Vous avez quittez le mode test, retour au menu principal . Cliquer sur Ok pour continuer." 10 60
	cd .. && ./menu.sh
fi

#envoi du SMS
cd .. && ./send_sms_bip.sh ./$num_bip.txt "$msg"
read -p "Appuyer sur une touche pour continuer ..."
./menu.sh


