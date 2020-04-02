#!/bin/bash
############################################
#
# V2.1_beta
# Script de lancement en mode menu
# 28/02/2019
#
############################################

#le mode menu appel suivant le choix effectué, l'une des fonctions ci après

function usage(){
	printf "Utilisation du système en mode manuel :\n"
	printf "\t--start                  : démarre le système de réception ;\n"
	printf "\t--config                 : démarre le mode config ;\n"
	printf "\t--test                   : démarre le mode test ;\n"
	printf "\t--init                   : démarre une initialisation ;\n"
	printf "\t--install               : démarre l'interface d'installation du système ;\n"
	printf "\t--global                 : démarre l'installation de la globalité du système ;\n"
	printf "\t--maj                    : met à jour la machine ;\n"
	printf "\t--outils                 : installe uniquement les outils ;\n"
	printf "\t--pilotes                : installe uniquement les pilotes de la clé SDR ;\n"
	printf "\t--reception              : installe uniquement le système de réception ;\n"
	printf "\t--decodeur               : installe uniquement le système de décodage ;\n"
	printf "\t--uninstall              : démarre l'interface de désinstallation du système.\n"
	printf "\t--uglobal                : démarre la désinstallation de la globalité du système ;\n"
	printf "\t--uoutils                : démarre la désinstallation des outils ;\n"
	printf "\t--upliotes               : démarre la désinstallation des pilotes ;\n"
	printf "\t--ureception             : démarre la désinstallation du système de réception ;\n"
	printf "\t--udecodeur              : démarre la désinstallation du système décodage ;\n"
	printf "\t--smsbip                 : démarre l'interface d'envoi de SMS par numéro de bip ;\n"
	printf "\t--smstel                 : démarre l'interface d'envoi de SMS par numéro de téléphone ;\n"
	printf "\t--sendsmsbip             : démarre le système d'envoi de SMS par numéro de bip - nécessite l'ajout d'option ;\n"
	printf "\t--sendsmstel             : démarre le système d'envoi de SMS par numéro de téléphone - nécessite l'ajout d'option ;\n"
	printf "\t--sendsmslist            : démarre le système d'envoi de SMS par liste d'envoi - nécessite l'ajout d'option .\n"
}
 
if [ $# -eq 0 ]
then
	usage
fi

function start(){
#lancement du système d'alerte par SMS
	whiptail --title "SYSTEME D'ALERTE SMS - SAPEURS POMPIERS" --msgbox "Bienvenu en mode réception émission, veuillez vérifier que le signal est bien reçu dans la fenêtre ci après. Bonne continuation" 12 60	
	#commande de décodage avec log dans fichier alert_output.txt
	nc -l -u 7355 |     sox -t raw -esigned-integer -b16 -r 48000 - -esigned-integer -b16 -r 22050 -t raw - |     multimon-ng -t raw -a SCOPE -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -f alpha - >>./alert_output.txt& 

	#boucle de lecture du fichier alerte
	while read line;
	do
		# On récupère l'id contact type 26xxxx
		contact_id=`echo $line | cut -d " " -f 3`
		# On affiche le numéro de bip à contacter
		echo BIP_ALERT : $contact_id

		#on vérifie si un fichier de liste de contact lui est attribué
		if [ ! -e ./$contact_id.txt ]
		then
			#s'il n'y en a pas on retour une erreur
			echo "Aucune liste de contacts trouvée pour $contact_id"
		else
			#sinon :
			# On récupère le message alpa en retirant le nul à la fin
			message=`echo $line | cut -d : -f 5,6 | cut -d "<" -f -1`
			echo MESSAGE : $message

			# On appel maintenant le script d'envoi de SMS pour envoyer l'alerte
			echo "Envoi message : $message à la luste de contact pour $contact_id"
			./pegasus.sh --sendsmslist ./$contact_id.txt "$message"
		fi

	done < <(tail -2f ./alert_output.txt)	
}

function config(){
# Lancement du mode configuration
# permet l'ajout de bip et de liste de contact

	#boîte de dialogue
	whiptail --title "SYSTEME D'ALERTE SMS - mode configuration" --msgbox "!ATTENTION! Vous entrer en mode configuration." 12 60
	whiptail --title "SYSTEME D'ALERTE SMS - mode configuration" --msgbox "Dans la prochaine fenêtre il vous sera demandé de saisir votre numéro de bip. Veuillez le saisir sous la forme 261234, sans la lettre. Votre numéro de bip est disponible sur Systel, dans l'onglet Alerte locale, ou sur votre bip. Cliquer sur Ok pour continuer." 12 60
	# on récupère le numéro de bip
	num_bip=$(whiptail --title "SYSTEME D'ALERTE SMS - mode configuration" --inputbox "Quel est votre numéro de bip ?"  10 60 3>&1 1>&2 2>&3)
 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		# on affiche le numéro de bip
		echo "Numéro de bip :" $num_bip
		whiptail --title "SYSTEME D'ALERTE SMS - mode configuration" --msgbox "Dans la prochaine fenêtre, veuillez renseigner le ou les numéros de téléphone à assigner à votre bip. Vous quitterez cette fenêtre grâce aux touches ctrl+x puis valider avec le o et entrée." 10 60
		#on ouvre le fichier numéro de bip .txt avec nano
		nano $num_bip.txt
		#une fois que c'est fini on retourne au menu principal
		./menu.sh
	else
		#si on annule on retourne au menu principal
		echo "Vous avez quittez le mode configuration, retour au menu principal"
		whiptail --title "SYSTEME D'ALERTE SMS - mode configuration" --msgbox "Vous avez quittez le mode configuration, retour au menu principal . Cliquer sur Ok pour continuer." 10 60
		./menu.sh
	
	fi
	
}

function test(){
# la fonction test permet d'envoyer un SMS en donnant soit le numéro de bip soit le numéro de tph

	#boîte de dialogue
	whiptail --title "SYSTEME D'ALERTE SMS - mode test" --msgbox "Bienvenu en mode test." 12 60
	OPTION_test=$(whiptail --title "SYSTEME D'ALERTE SMS - mode test" --menu "Choisissez votre distriubtion linux" 15 60 4 \
	"smsbip" "Envoyer un message vers un numéro de bip" \
	"smstel" "Envoyer un message vers un numéro de téléphone" \
	"help" "Aide" 3>&1 1>&2 2>&3)
 
	exitstatus=$?
	#choix de l'option
	if [ $exitstatus = 0 ]; then
		echo "Vous avez choisi l'option : " $OPTION_test
		#on ouvre le script correspondant
		./pegasus.sh --$OPTION_test
	else
		#si on annule on retourne au menu principal
		echo "Vous avez quittez le mode test, retour au menu principal"
		whiptail --title "SYSTEME D'ALERTE SMS - mode test" --msgbox "Vous avez quittez le mode test, retour au menu principal . Cliquer sur Ok pour continuer." 10 60
		./menu.sh
	fi
	
}

function init(){
#initialisation du script

	#supression du fichier d'alerte
	sudo rm alert_output.txt

	#supression du fichier token
	sudo rm token.txt

	#supression du fichier session
	sudo rm session.txt

	#création du token
	TOKEN=$(curl -s -b session.txt -c session.txt http://192.168.8.1/html/smsinbox.html)
	TOKEN=$(echo $TOKEN | cut -d'"' -f 10)

	echo $TOKEN > token.txt
	
	#ouverture d'une nouvelle session
	curl -b session.txt -c session.txt http://192.168.8.1/html/index.html > /dev/null 2>&1
	
	#retour au menu principal
	./menu.sh

}

function install(){
#mode installation

	whiptail --title "Installation du système d'alerte par SMS" --msgbox "Bienvenu dans le programme d'installation du système d'alerte par SMS. Cliquer sur Ok pour continuer." 10 60

	OPTION_install=$(whiptail --title "Installation du système d'alerte par SMS" --menu "Faite votre choix :" 15 60 4 \
	"global" "Installation globale du système" \
	"maj" "Mise à jour de la machine" \
	"outils" "Installation des outils nécessaire" \
	"pilotes" "Installation des pilôtes de la clé SDR" \
	"reception" "Installation du sytème de réception" \
	"decodeur" "Installation du décodeur POCSAG"  3>&1 1>&2 2>&3)
 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
    		echo "Vous avez choisi l'option : " $OPTION_install
		./pegasus.sh --$OPTION_install
	else
    		echo "vous avez annulé, retour au menu principal"
			./menu.sh
		exit
	fi

}

function global(){
	echo "installation globale";
	whiptail --title "Installation du système d'alerte par SMS" --msgbox "ATTENTION : vous allez démarrer l'installation. Cliquer sur Ok pour continuer." 10 60	
	#mise à jour de la machine
	echo "mise à jour de la machine";
	sudo apt-get update -y;
	sudo apt-get upgrade -y;

	#installation des outils nécessaire
	echo "installation des outils nécessaire";
	sudo apt-get -y install git cmake build-essential libusb-1.0 libusb-1.0-0-dev qt4-qmake libpulse-dev libxll-dev;

	#installation des pilotes de la clé SDR
	echo "installation des pilotes de la clé SDR";
	cd;
	git clone git://git.osmocom.org/rtl-sdr.git;
	cd rtl-sdr;
	mkdir build;
	cd build;
	cmake ../ -DINSTALL_UDEV_RULES=ON;
	make;
	sudo make install;
	sudo ldconfig;
	cd;

	#installation des outils de réception des trames POCSAG
	echo "installation des outils de réception des trames POCSAG";
	sudo cp ./rtl-sdr/rtl-sdr.rules /etc/udev/rules.d/;
	sudo apt-get -y install gqrx-sdr;

	#installation du décodeur POCSAG
	echo "installation du décodeur POCSAG";
	git clone https://github.com/EliasOenal/multimon-ng.git;
	cd multimon-ng;
	mkdir build;
	cd build;
	qmake ../multimon-ng.pro;
	make;
	sudo make install;
	cd;
	sudo apt-get -y install sox;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function maj(){
	echo "Mise à jour du système";
	
	#mise à jour de la machine
	echo "mise à jour de la machine";
	sudo apt-get update -y;
	sudo apt-get upgrade -y;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function outils(){
	echo "installation des outils nécessaire";
	whiptail --title "Installation du système d'alerte par SMS" --msgbox "ATTENTION : vous allez démarrer l'installation. Cliquer sur Ok pour continuer." 10 60	
	#installation des outils nécessaire
	echo "installation des outils nécessaire";
	sudo apt-get -y install git cmake build-essential libusb-1.0 libusb-1.0-0-dev qt4-qmake libpulse-dev libxll-dev;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function pilotes(){
	echo "installation des pilotes";
	whiptail --title "Installation du système d'alerte par SMS" --msgbox "ATTENTION : vous allez démarrer l'installation. Cliquer sur Ok pour continuer." 10 60	
	#installation des pilotes de la clé SDR
	echo "installation des pilotes de la clé SDR";
	cd;
	git clone git://git.osmocom.org/rtl-sdr.git;
	cd rtl-sdr;
	mkdir build;
	cd build;
	cmake ../ -DINSTALL_UDEV_RULES=ON;
	make;
	sudo make install;
	sudo ldconfig;
	cd;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function reception(){
	echo "installation globale";
	whiptail --title "Installation du système d'alerte par SMS" --msgbox "ATTENTION : vous allez démarrer l'installation. Cliquer sur Ok pour continuer." 10 60	
	#installation des outils de réception des trames POCSAG
	echo "installation des outils de réception des trames POCSAG";
	sudo cp ./rtl-sdr/rtl-sdr.rules /etc/udev/rules.d/;
	sudo apt-get -y install gqrx-sdr;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function decodeur(){
	echo "installation globale";
	whiptail --title "Installation du système d'alerte par SMS" --msgbox "ATTENTION : vous allez démarrer l'installation. Cliquer sur Ok pour continuer." 10 60	
	#installation du décodeur POCSAG
	echo "installation du décodeur POCSAG";
	git clone https://github.com/EliasOenal/multimon-ng.git;
	cd multimon-ng;
	mkdir build;
	cd build;
	qmake ../multimon-ng.pro;
	make;
	sudo make install;
	cd;
	sudo apt-get -y install sox;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function uninstall(){
#mode désinstallation

	whiptail --title "Installation du système d'alerte par SMS" --msgbox "Bienvenu dans le programme de désinstallation du système d'alerte par SMS. Cliquer sur Ok pour continuer." 10 60;

	OPTION_uninstall=$(whiptail --title "Désinstallation du système d'alerte par SMS" --menu "Faite votre choix :" 15 60 4 \
	"uglobal" "Désinstallation globale du système" \
	"uoutils" "Désinstallation des outils nécessaire" \
	"upilotes" "Désinstallation des pilôtes de la clé SDR" \
	"ureception" "Désinstallation du sytème de réception" \
	"udecodeur" "Désinstallation du décodeur POCSAG"  3>&1 1>&2 2>&3)
 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
    		echo "Vous avez choisi l'option : " $OPTION_uninstall
		./pegasus.sh --$OPTION_uninstall
	else
    		echo "vous avez annulé, retour au menu principal"
			./menu.sh
		exit
	fi

}

function uglobal(){
	
	echo "désinstallation globale";
	whiptail --title "Désinstallation du système d'alerte par SMS" --msgbox "ATTENTION : vous allez démarrer la désinstallation. Cliquer sur Ok pour continuer." 10 60;	

	#désinstallation des outils nécessaire
	echo "désinstallation des outils nécessaire";
	sudo apt-get -y purge git cmake build-essential libusb-1.0 libusb-1.0-0-dev qt4-qmake libpulse-dev libxll-dev;

	#désinstallation des pilotes de la clé SDR
	echo "désinstallation des pilotes de la clé SDR";
	cd;
	mv rtl-sdr /dev/NULL;
	cd;

	#désinstallation des outils de réception des trames POCSAG
	echo "désinstallation des outils de réception des trames POCSAG";
	sudo apt-get -y purge gqrx-sdr;

	#désinstallation du décodeur POCSAG
	echo "désinstallation du décodeur POCSAG";
	mv multimon-ng /dev/NULL;
	cd multimon-ng;
	sudo apt-get -y purge sox;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function uoutils(){
	
	#désinstallation des outils nécessaire
	echo "désinstallation des outils nécessaire";
	whiptail --title "Désinstallation du système d'alerte par SMS" --msgbox "ATTENTION : vous allez démarrer la désinstallation. Cliquer sur Ok pour continuer." 10 60;
	sudo apt-get -y purge git cmake build-essential libusb-1.0 libusb-1.0-0-dev qt4-qmake libpulse-dev libxll-dev;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function upilotes(){

	#désinstallation des pilotes de la clé SDR
	echo "désinstallation des pilotes de la clé SDR";
	whiptail --title "Désinstallation du système d'alerte par SMS" --msgbox "ATTENTION : vous allez démarrer la désinstallation. Cliquer sur Ok pour continuer." 10 60;	
	cd;
	mv rtl-sdr /dev/NULL;
	cd;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function ureception(){
	
	#désinstallation des outils de réception des trames POCSAG
	echo "désinstallation des outils de réception des trames POCSAG";
	whiptail --title "Désinstallation du système d'alerte par SMS" --msgbox "ATTENTION : vous allez démarrer la désinstallation. Cliquer sur Ok pour continuer." 10 60;
	sudo apt-get -y purge gqrx-sdr;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function udecodeur(){
	
	#désinstallation du décodeur POCSAG
	echo "désinstallation du décodeur POCSAG";
	whiptail --title "Désinstallation du système d'alerte par SMS" --msgbox "ATTENTION : vous allez démarrer la désinstallation. Cliquer sur Ok pour continuer." 10 60;
	mv multimon-ng /dev/NULL;
	cd multimon-ng;
	sudo apt-get -y purge sox;
	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function smsbip(){
	num_bip_test=$(whiptail --title "SYSTEME D'ALERTE SMS - mode test" --inputbox "Quel est votre numéro de bip?" 10 60 3>&1 1>&2 2>&3)
 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		echo "Votre numéro de bip est le :" $num_bip_test
	else
		echo "Vous avez quittez le mode configuration, retour au menu principal"
		whiptail --title "SYSTEME D'ALERTE SMS - mode test" --msgbox "Vous avez quittez le mode test, retour au menu principal . Cliquer sur Ok pour continuer." 10 60
		./pegasus.sh
	fi

	msg_bip_test=$(whiptail --title "SYSTEME D'ALERTE SMS - mode test" --inputbox "Veuillez saisir le message à envoyer" 10 60 Ceci_est_un_message_de_test_venant_du_SASMS 3>&1 1>&2 2>&3)
 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		echo "Votre message est :" $msg_bip_test
	else
		echo "Vous avez quittez le mode configuration, retour au menu principal"
		whiptail --title "SYSTEME D'ALERTE SMS - mode test" --msgbox "Vous avez quittez le mode test, retour au menu principal . Cliquer sur Ok pour continuer." 10 60
		./pegasus.sh
	fi

	#envoi du SMS
	./pegasus.sh --sendsmsbip ./$num_bip_test.txt "$msg_bip_test"
	read -p "Appuyer sur une touche pour continuer ..."
	./pegasus.sh
}

function sendsmsbip(){

	contact_file=$1
	MESSAGE=$2

#./session.sh
#./token.sh

	PHONE_LIST="";
	for number in `cat $contact_file`
	do
		PHONE_LIST="$PHONE_LIST<Phone>$number</Phone>"
	done
	if [ "" == "$PHONE_LIST" ]
	then
		echo "Liste de contact vide - aucun envoi"
		exit 0
	fi

	LENGTH=${#MESSAGE}
	TIME=$(date +"%Y-%m-%d %T")
	TOKEN=$(<token.txt)

	SMS="<request><Index>-1</Index><Phones>$PHONE_LIST</Phones><Sca/><Content>$MESSAGE</Content><Length>$LENGTH</Length><Reserved>1</Reserved><Date>$TIME</Date></request>"

	echo $SMS

	curl -v -b session.txt -c session.txt -H "X-Requested-With: XMLHttpRequest" --data "$SMS" http://192.168.8.1/api/sms/send-sms --header "__RequestVerificationToken: $TOKEN" --header "Content-Type:text/xml"

}

function smstel(){

	num_tel_test=$(whiptail --title "SYSTEME D'ALERTE SMS - mode test" --inputbox "Quel est votre numéro de téléphone ?" 10 60 3>&1 1>&2 2>&3)
 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		echo "Votre numéro de téléphone est le :" $num_tel_test
	else
		echo "Vous avez quittez le mode configuration, retour au menu principal"
		whiptail --title "SYSTEME D'ALERTE SMS - mode test" --msgbox "Vous avez quittez le mode test, retour au menu principal . Cliquer sur Ok pour continuer." 10 60
		./pegasus.sh
	fi

	msg_tel_test=$(whiptail --title "SYSTEME D'ALERTE SMS - mode test" --inputbox "Veuillez saisir le message à envoyer" 10 60 Ceci_est_un_message_de_test_venant_du_SASMS 3>&1 1>&2 2>&3)
 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		echo "Votre message est :" $msg_tel_test
	else
		echo "Vous avez quittez le mode configuration, retour au menu principal"
		whiptail --title "SYSTEME D'ALERTE SMS - mode test" --msgbox "Vous avez quittez le mode test, retour au menu principal . Cliquer sur Ok pour continuer." 10 60
		./pegasus.sh
	fi

	#envoi du SMS
	./pegasus.sh --sendsmstel $num_tel_test "$msg_bip_test"
	read -p "Appuyer sur une touche pour continuer ..."
	./pegasus.sh
}

function sendsmstel(){

	NUMBER=$1
	MESSAGE=$2

	#./session.sh
	#./token.sh

	LENGTH=${#MESSAGE}
	TIME=$(date +"%Y-%m-%d %T")
	TOKEN=$(<token.txt)

	SMS="<request><Index>-1</Index><Phones><Phone>$NUMBER</Phone></Phones><Sca/><Content>$MESSAGE</Content><Length>$LENGTH</Length><Reserved>1</Reserved><Date>$TIME</Date></request>"

	echo $SMS

	curl -v -b session.txt -c session.txt -H "X-Requested-With: XMLHttpRequest" --data "$SMS" http://192.168.8.1/api/sms/send-sms --header "__RequestVerificationToken: $TOKEN" --header "Content-Type:text/xml"

}

function sendsmslist(){

	contact_file=$1
	MESSAGE=$2

	#./session.sh
	#./token.sh

	PHONE_LIST="";
	for number in `cat $contact_file`
	do
		PHONE_LIST="$PHONE_LIST<Phone>$number</Phone>"
	done
	if [ "" == "$PHONE_LIST" ]
	then
		echo "Liste de contact vide - aucun envoi"
		exit 0
	fi

	LENGTH=${#MESSAGE}
	TIME=$(date +"%Y-%m-%d %T")
	TOKEN=$(<token.txt)

	SMS="<request><Index>-1</Index><Phones>$PHONE_LIST</Phones><Sca/><Content>$MESSAGE</Content><Length>$LENGTH</Length><Reserved>1</Reserved><Date>$TIME</Date></request>"

	echo $SMS

	curl -v -b session.txt -c session.txt -H "X-Requested-With: XMLHttpRequest" --data "$SMS" http://192.168.8.1/api/sms/send-sms --header "__RequestVerificationToken: $TOKEN" --header "Content-Type:text/xml"


}

########################################################################################################################
#
#
#
########################################################################################################################


###### début du script ######

#on choisi le mode dans le menu



#partie getopt : liste des options
#pas de printf pour indiquer les options

OPTS=$( getopt -o h -l config,start,config,test,init,install,global,maj,outils,pilotes,reception,decodeur,uninstall,uglobal,uoutils,upilotes,ureception,udecodeur,smsbip,sendsmsbip,smstel,sendsmstel,sendsmslistnb_fichiers: -- "$@" )
if [ $? != 0 ]
then
    exit 1
fi
 
eval set -- "$OPTS"
 
while true ; do
    case "$1" in
        -h) usage;
            exit 0;;
        --config) config;
                shift;;
        --start) start;
                shift;;
        --test) test;
                shift;;
        --init) init;
                shift;;
        --install) install;
                shift;;
        --maj) maj;
                shift;;
        --outils) outils;
                shift;;
        --global) global;
                shift;;
        --pilotes) pilotes;
                shift;;
        --reception) reception;
                shift;;
        --decodeur) decodeur;
                shift;;
        --uninstall) uninstall;
                shift;;
        --uglobal) uglobal;
                shift;;
        --uoutils) uoutils;
                shift;;
        --upilotes) upilotes;
                shift;;
        --ureception) ureception;
                shift;;
        --udecodeur) udecodeur;
                shift;;
        --smsbip) smsbip;
                shift;;
        --sendsmsbip) sendsmsbip;
                shift;;
        --smstel) smstel;
                shift;;
        --sendsmslist) sendsmslist;
                shift;;
        --sendsmslist) sendsmslist;
                shift;;	
        --) shift; break;;
    esac
done
 
exit 0