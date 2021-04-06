#!/bin/bash

PORT=2021
INPUT_PATH=salida_server
IP_CLIENT="127.0.0.1"
IP_SERVER="127.0.0.1"

echo "Cliente de ABFP"

echo "(2) Sending HEADERS"

echo "ABFP $IP_CLIENT" | nc -q 1 $IP_SERVER $PORT

echo "(3) Listening Connection RESPONSE"

RESPONSE=`nc -l -p $PORT`

echo "CONNECTION TEST"
if [ "$RESPONSE" != "OK_CONN" ]; then
	echo "Server offline"
	exit 1
fi

echo "(6) HANDSHAKE"
sleep 1
echo "THIS_IS_MY_CLASSROOM" | nc -q 1 $IP_SERVER $PORT

echo "(7) Listening HANDSHAKE RESPONSE..."
HANDSHAKE=`nc -l -p $PORT`

echo "TEST HANDSHAKE RESPONSE"
if [ "$HANDSHAKE" != "YES_IT_IS" ]; then
	echo "Handshake Failed"
	exit 2
fi

#Enviar NUM ARCHIVOS

echo "(7b) SENDING NUM_FILES"
sleep 1
NUM_FILES=`ls $INPUT_PATH | wc -w`

echo "NUM_FILES $NUM_FILES" | nc -q 1 $IP_SERVER $PORT

echo "(7c) LISTEN"
RESPONSE=`nc -l -p $PORT`

if [ "$RESPONSE" != "OK_NUM_FILES" ]; then
	echo "ERROR: Prefijo NUM_FILES incorrect"
	exit 2
fi

#BUCLE

for FILE_NAME in `ls $INPUT_PATH`; do
	FILE_MD5=`echo $FILE_NAME | md5sum | cut -d " " -f l`

	echo "(10) Sending FILE_NAME"

	sleep 1
	echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc -q l $IP_SERVER $PORT

	echo "(11) Listening FILE_NAME RESPONSE"

	RESPONSE=`nc -l -p $PORT`

	if [ "$RESPONSE" != "OK_FILE_NAME" ]; then
		echo "ERROR: CORRUPT FILE"
		exit 2
	fi

	sleep 1

	cat "$INPUT_PATH$FILE_NAME" | nc -q l $IP_SERVER $PORT
done

echo "(14) SENDING DATA"

DATA_NAME="input_file.vaca"
MD5_NAME=`md5sum $DATA_NAME`

sleep 1

echo "FILE_DATA $DATA_NAME $MD5_NAME" | nc -q l $IP_SERVER $PORT

echo "(15) Listening..."
sleep 1
DATA_RESPONSE=`nc -l -p $PORT`

echo "TEST OK_DATA RESPONSE"

if [ "$DATA_RESPONSE" != "OK_DATA" ]; then
	echo "ERROR: KO_DATA"
	exit 4
fi

exit 0
