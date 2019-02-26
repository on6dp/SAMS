#!/bin/bash
########################################
#
#
#
########################################



nc -l -u 7355 |     sox -t raw -esigned-integer -b16 -r 48000 - -esigned-integer -b16 -r 22050 -t raw - |     multimon-ng -t raw -a SCOPE -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -f alpha - >>./alert_output.txt& 

#j'ai remplacé la boucle pour lire un fichier txt avec des exemples
#Tu gardes la boucle for avec l'appel à ton script
while read line;
do
	# On sort l'id du contact. note la commande cut qui permet de 
	# n'avoir que le nombre
	contact_id=`echo $line | cut -d " " -f 3`
	echo BIP_ALERT : $contact_id

	if [ ! -e ./$contact_id.txt ]
	then
		echo "Aucune liste de contacts trouvée pour $contact_id"
	else
		# Le message. Cette fois je garde le ":" comme séparateur
		message=`echo $line | cut -d : -f 5 | cut -d "<" -f -1`
		echo MESSAGE : $message

		# Ici ca sera l'appel a ton script d'envoi de SMS
		echo "Envoi message : $message à la luste de contact pour $contact_id"
		./send_sms.sh ./$contact_id.txt "$message"
	fi

done < <(tail -2f ./alert_output.txt)
