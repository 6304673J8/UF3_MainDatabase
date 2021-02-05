#!/bin/bash

PORT=2021

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

echo "(9) Listening FILE_NAME... "

FILE_NAME=`nc -l -p $PORT`

PREFIX=`echo $FILE_NAME | cut -d " " -f 1`
NAME=`echo $FILE_NAME | cut -d " " -f 2`

echo "TESTING CLIENT FILE"

if [ "$PREFIX" != "FILE_NAME" ]; then
	echo "ERROR in FILE_NAME"
	
	sleep 1
	echo "KO_FILE_NAME" | nc -q l $IP_CLIENT $PORT
	
	exit 3
fi

echo "(12) FILE_NAME($NAME) RESPONSE..."

sleep 1
echo "OK_FILE_NAME" | nc -q l $IP_CLIENT $PORT

echo "(13) Listening DATA..."

DATA=`nc -l -p $PORT`

echo "###FILE_MD5=`md5sum input_file.vaca`####"
nc -l -p $PORT > input_file.vaca
echo "###md5sum####"

exit 0
