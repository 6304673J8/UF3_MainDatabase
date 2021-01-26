#!/bin/bash

PORT=2021

IP_CLIENT="127.0.0.1"
IP_SERVER="127.0.0.1"

echo "Cliente de ABFP"

echo "(2) Sending headers"

echo "ABFP $IP_CLIENT" | nc -q 1 $IP_SERVER $PORT

echo "(3) Listening $PORT"

nc -l -p $PORT
