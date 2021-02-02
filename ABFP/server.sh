#!/bin/bash

PORT=2021

echo "(0) SERVER ABFP"

echo "(1) Listening $PORT"

HEADER=`nc -l -p $PORT`

echo "ABFP TESTING $HEADER"

PREFIX=`echo $HEADER | cut -d " " -f 1`
IP_CLIENT=`echo $HEADER | cut -d " " -f 2`

echo "(4) RESPONSE"

if [ "$PREFIX" != "ABFP" ]; then
	
	echo "ERROR in HEADER"
	
	sleep 1
	echo "KO_CONN"| nc -q 1 $IP_CLIENT $PORT
	
	exit 1
fi

sleep 1
echo "OK_CONN" | nc -q 1 $IP_CLIENT $PORT

echo "(5) LISTEN"

HANDSHAKE=`nc -l -p $PORT`

exit 0
