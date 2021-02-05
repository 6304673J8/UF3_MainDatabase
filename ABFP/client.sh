#!/bin/bash

PORT=2021

IP_CLIENT="127.0.0.1"
IP_SERVER="127.0.0.1"

FILE_NAME="output_file.vaca"

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

echo "(10) Sending FILE_NAME"

sleep 1
echo "FILE_NAME $FILE_NAME" | nc -q l $IP_SERVER $PORT

echo "(11) Listening FILE_NAME RESPONSE"

FILE_NAME=`nc -l -p $PORT`

echo "TEST FILE_NAME RESPONSE"

if [ "$FILE_NAME" != "OK_FILE_NAME" ]; then
	echo "ERROR: CORRUPT FILE"
	exit 3
fi

echo "(14) SENDING DATA"

sleep 1
echo $FILE_NAME | nc -q l $IP_SERVER $PORT

exit 0
