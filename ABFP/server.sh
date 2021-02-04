#!/bin/bash

PORT=2021

echo "(0) SERVER ABFP"

echo "(1) Listening $PORT"

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

echo "(9) Listening: "

ID_CLIENT=`nc -l -p $PORT`

echo "CLIENT TESTING $ID_CLIENT"
exit 0
