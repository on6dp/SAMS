#!/bin/bash
############################################
#
# envoi d'un SMS de test vers numéro de tph
#
############################################
num_tel=$(whiptail --title "SYSTEME D'ALERTE SMS - mode test" --inputbox "Quel est votre numéro de téléphone ?" 10 60 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Votre numéro de téléphone est le :" $num_tel
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
cd .. && ./send_sms_tel.sh $num_tel "$msg"
read -p "Appuyer sur une touche pour continuer ..."
./menu.sh


