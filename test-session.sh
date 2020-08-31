#!/bin/bash

if [ $1 = "" ] || [ $1 = "-h" ]; then
	printf "

Pogify loop sender

Usage:
	./test-session.sh json authorization endpoint

Prerequisites:
	apt install jq
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
			sleep "$(( ($timestamp - $running_stamp) / 1000 ))"
		fi
	
		running_stamp=$timestamp
		now=$( date +%s%3N )
		data=$( echo $data | jq --compact-output --arg now "$now" '.timestamp = $now')
		# Sends in the background
		curl \
			-k \
			--header "Content-Type: text/plain" \
			--header "Authorization: $2" \
			--header "HOST: messages.pogify.net" \
			--request POST \
			--data "$data" \
			$3 \
#			&> /dev/null \
#			&
	done
done

