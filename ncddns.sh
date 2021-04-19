#!/bin/bash

timestamp() {
  date +%d-%m-%Y' '%T
}

main() {
	while true; do
		ip=$(curl -s https://api.ipify.org/)

		if test -f "$@"; then

			if [ $# -eq 0 ]
			then
				echo "Please type the name of the json file e.g. conf/ddns.json"
				exit 1
			else
				host=$(cat "$@" | jq -r '.[] | .[] | .host')
				domain=$(cat "$@" | jq -r '.[] | .[] | .domain')
				password=$(cat "$@" | jq -r '.[] | .[] | .password')

				hosts=($host)
				domains=($domain)
				passwords=($password)

				for (( i=0; i<${#hosts[@]}; i++ )); do
					output=$(curl -s -o /dev/null -w "%{http_code}" "https://dynamicdns.park-your-domain.com/update?host=${hosts[$i]}&domain=${domains[$i]}&password=${passwords[$i]}&ip=${ip}")
					date=$(timestamp)
					echo "${date} - Successfully updated dynamic DNS: '${hosts[$i]}.${domains[$i]}' to ${ip} - HTTP Status: ${output}"
					echo "${date} - Successfully updated dynamic DNS: '${hosts[$i]}.${domains[$i]}' to ${ip} - HTTP Status: ${output}" >> log/ncddns.log
				done
			fi
		else
			echo "$@ file does not exist."
			exit 1
		fi

# Run every 5 minute
sleep 5m
done
}

main "$@" || exit 1