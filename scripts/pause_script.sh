#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters; Please provide sleep time as the parameter;"
    exit 1
fi
sleep_time=$1
#sleep_time=300

echo "pause" > ~/leveldb-ledger/scripts/pause

while true; 
do
	pause=`cat ~/leveldb-ledger/scripts/pause`
	if [ "$pause" == "pause" ]
	then	
		echo `date` ' Sleeping for '$sleep_time' seconds . . .'
		sleep $sleep_time
		echo "" > ~/leveldb-ledger/scripts/pause
	else
		break;
	fi
done

echo 'Pause released. Exiting..'
