#!/bin/bash
########################################
#
# script d'installation global du SASMS
#
########################################

function usage(){
	whiptail --title "Installation du système d'alerte par SMS" --msgbox "Bienvenu dans le programme d'installation du système d'alerte par SMS. Cliquer sur Ok pour continuer." 10 60

	OPTION=$(whiptail --title "Installation du système d'alerte par SMS" --menu "Faite votre choix :" 15 60 4 \
	"global" "Installation globale du système" \
	"maj" "Mise à jour de la machine" \
	"outils" "Installation des outils nécessaire" \
	"pilotes" "Installation des pilôtes de la clé SDR" \
	"reception" "Installation du sytème de réception" \
	"decodeur" "Installation du décodeur POCSAG" \
	"help" "Aide"  3>&1 1>&2 2>&3)
 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
    		echo "Vous avez choisi la distribution : " $OPTION
		./install_dial.sh --$OPTION
	else
    		echo "vous avez annulé"
		exit
	fi
}
 
if [ $# -eq 0 ]
then
	usage
fi
 
function global(){
	echo "installation globale";
		
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
	
	#installation des outils nécessaire
	echo "installation des outils nécessaire";
	sudo apt-get -y install git cmake build-essential libusb-1.0 libusb-1.0-0-dev qt4-qmake libpulse-dev libxll-dev;

	#redémarrage
	echo "Veuillez vérifier qu'il n'y ai pas d'erreur avant de continuer, puis" && read -p "appuyer sur une touche pour continuer ...";
	sudo reboot;
}

function pilotes(){
	echo "installation des pilotes";

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

function aide(){
	./script_install_v2.sh;
	exit
}
 
OPTS=$( getopt -o h -l global,maj,outils,pilotes,reception,decodeur,help,nb_fichiers: -- "$@" )
if [ $? != 0 ]
then
    exit 1
fi
 
eval set -- "$OPTS"
 
while true ; do
    case "$1" in
        --global) global;
                shift;;
        --maj) maj;
                shift;;
        --outils) outils;
                shift;;
        --pilotes) pilotes;
                shift;;
        --reception) reception;
                shift;;
        --decodeur) decodeur;
                shift;;
        --help) aide;
		exit                
		shift;;
    esac
done
 
exit 0
