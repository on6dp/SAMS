#!/bin/bash

contact_file=$1
MESSAGE=$2

./session.sh
./token.sh

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
