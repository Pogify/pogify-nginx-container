#!/bin/sh

if [ "$1" = "" ] || [ "$1" = "-h" ]; then
	printf "
Pogify loop sender
Usage:
	./looper.bash <json> <authorization header (secret)> <endpoint>
Prerequisites:
	sleep
	date
	awk
	curl
	jq
"
	exit
fi

while :
do
	running_stamp=0
	for data in $(jq -c .[] $1)
	do
		timestamp=$( echo $data | jq .timestamp )
		if [ $timestamp -ge $running_stamp ]; then
			# sleep $(perl -e "print $timestamp/1000")
			sleep $(echo "$timestamp" | awk '{res = $1/1000;print res}')
		fi
	
		running_stamp=$timestamp
		
		# Changes the json's timestamp to timestamp in milisecs
		changed=$(\
	       	echo $data |\
	       	jq ".timestamp = $(($(date +%s%N)/1000000))")
	
		# Sends in the background
		curl \
			--header "Content-Type: application/json" \
			--header "Authorization: $2" \
			--header "HOST: messages.pogify.net" \
			--request POST \
			--data "$changed" \
			$3 \
			&> /dev/null \
			&
	done
done