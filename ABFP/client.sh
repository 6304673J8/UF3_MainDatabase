#!/bin/bash

PORT=2021
INPUT_PATH="client_input/"
IP_CLIENT="127.0.0.1"

if [ "$1" == "" ]; then
	IP_SERVER="127.0.0.1"
else
	IP_SERVER="$1"
fi

echo "ABFP Client"

echo "(2) Sending HEADERS to $IP_SERVER"

echo "ABFP $IP_CLIENT" | nc -q 1 $IP_SERVER $PORT

echo "(3) Listening RESPONSE"

RESPONSE=`nc -l -p $PORT`

echo "CONNECTION TEST"
if [ "$RESPONSE" != "OK_CONN" ]; then
	echo "Server offline"
	exit 1
fi

echo "(6) HANDSHAKE"

sleep 1

echo "THIS_IS_MY_CLASSROOM" | nc -q 1 $IP_SERVER $PORT

echo "(7a) Listening HANDSHAKE RESPONSE..."

RESPONSE=`nc -l -p $PORT`

echo "TEST HANDSHAKE RESPONSE"
if [ "$RESPONSE" != "YES_IT_IS" ]; then
	echo "Handshake Failed"
	exit 2
fi

#Send NUM FILES

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
	FILE_MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

	echo "(10) Sending FILE_NAME"

	sleep 1
	echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc -q l $IP_SERVER $PORT

	echo "(11) Listening FILE_NAME RESPONSE"

	RESPONSE=`nc -l -p $PORT`

	if [ "$RESPONSE" != "OK_FILE_NAME" ]; then
		echo "ERROR: CORRUPT FILE"
		exit 3
	fi

	sleep 1

	cat "$INPUT_PATH$FILE_NAME" | nc -q 1 $IP_SERVER $PORT
done

echo "(15) Listening..."
sleep 1
RESPONSE=`nc -l -p $PORT`

echo "TEST OK_DATA RESPONSE"

if [ "$RESPONSE" != "OK_DATA" ]; then
	echo "ERROR: KO_DATA"
	exit 4
fi

exit 0
