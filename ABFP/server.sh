#!/bin/bash

PORT=2021
FILE="input_file.vaca"

echo "(0) SERVER ABFP"

echo "(1) Listening ($PORT) HEADERS"

HEADER=`nc -l -p $PORT`

echo "ABFP TESTING $HEADER"

PREFIX=`echo $HEADER | cut -d " " -f 1`
IP_CLIENT=`echo $HEADER | cut -d " " -f 2`

echo "(4) CALCULATING RESPONSE..."

if [ "$PREFIX" != "ABFP" ]; then
	
	echo "ERROR in HEADER"
	
	sleep 1
	echo "KO_CONN"| nc -q 1 $IP_CLIENT $PORT
	
	exit 1
fi

sleep 1
echo "OK_CONN" | nc -q 1 $IP_CLIENT $PORT

echo "(5) LISTENING TEST..."

HANDSHAKE=`nc -l -p $PORT`

echo "HANDSHAKE TESTING $HANDSHAKE"

echo "(8) CALCULATING RESPONSE..."

if [ "$HANDSHAKE" != "THIS_IS_MY_CLASSROOM" ]; then
	echo "ERROR during HANDSHAKE"
	sleep 1
	echo "KO_HANDSHAKE" | nc -q 1 $IP_CLIENT $PORT
fi

sleep 1
echo "YES_IT_IS" | nc -q 1 $IP_CLIENT $PORT

#LEER NUM ARCHIVOS A RECIBIR

echo "(8b) LISTEN NUM_FILES"

NUM_FILES=`nc -l -p $PORT`

PREFIX=`echo $NUM_FILES | cut -d " " -f 1`
NUM=`echo $NUM_FILES | cut -d " " -f 2`

if [ "$PREFIX" != "NUM_FILES" ]; then
	echo "Error: Prefijo NUM_FILES incorrecto"
	sleep 1
	echo "K0_NUM_FILES" | nc -q 1 $IP_CLIENT $PORT
	
	exit 2
fi

sleep 1
echo "OK_NUM_FILES" | nc -q 1 $IP_CLIENT $PORT
echo "NUM_FILES: $NUM"
#BUCLE

for NUMBER in `seq $NUM`; do

	echo "(9) Listening FILE_NAME... "

	FILE_NAME=`nc -l -p $PORT`

	PREFIX=`echo $FILE_NAME | cut -d " " -f 1`
	NAME=`echo $FILE_NAME | cut -d " " -f 2`
	NAME_MD5=`echo $FILE_NAME | cut -d " " -f 3`
	
	if [ "$PREFIX" != "FILE_NAME" ]; then
		echo "ERROR in FILE_NAME"
	
		sleep 1
		echo "KO_FILE_NAME" | nc -q l $IP_CLIENT $PORT
	
		exit 3
	fi

	TEMP_MD5=`echo $NAME | cut -d " " -f 4`

	if [ "$NAME_MD5" != "$TEMP_MD5" ]; then
		echo "ERROR in FILE_NAME"
	
		sleep 1
		echo "KO_FILE_NAME" | nc -q l $IP_CLIENT $PORT
	
		exit 4
	fi

	echo "(12) FILE_NAME($NAME) RESPONSE..."
	sleep 1
	echo "OK_FILE_NAME" | nc -q l $IP_CLIENT $PORT
	echo $OUTPUT_PATH$NAME

	nc -l -p $PORT > $OUTPUT_PATH$NAME
done

echo "(13) Listening DATA..."

DATA=`nc -l -p $PORT`
MD5_CHECK=`md5sum $FILE | cut -d " " -f 1`
DATA_NAME=`echo $DATA | cut -d " " -f 2`
DATA_MD5=`echo $DATA | cut -d " " -f 3`


if [ "$MD5_CHECK" != "$DATA_MD5" ]; then
	sleep 1
	echo "Server MD5 : $MD5_CHECK"
	echo "Client MD5 : $DATA_MD5"
	sleep 1
	echo "DATA STATUS: CORRUPTED"
	echo "KO_DATA" | nc -q l $IP_CLIENT $PORT
	echo "Connection Status: Failed" | mail -s "ABFP-Admin" alejandro_test@mailinator.com
	exit 4
fi
sleep 1
echo "(16) FILE_STATUS RESPONSE..."

echo "OK_DATA" | nc -q l $IP_CLIENT $PORT

echo "File Status: OK ! ¹Server> $MD5_CHECK / ²Server> $DATA_MD5" | mail -s 'ABFP-Admin' alejandro_test@mailinator.com

exit 0
