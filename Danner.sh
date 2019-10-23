#!/bin/bash

# This script takes two parameters as input, 
# the output of Sublist3r (1 subdomain on each line)
# and the list of targets in scope (1 IP address on each line).
#
# The script will resolve the IP address for each subdomain
# and compare each one to the addresses in scope.
# The output for the tool is a file containing only
# the domains in scope and relative IP address)

# (c) Falanx Cyber

clear
usage() {
	echo " ______  _____ ____  ____  _____  ____ "
	echo "|  __  |(____ |  _ \|  _ \| ___ |/ ___) TM"
	echo "| |__/ // ___ | | | | | | | ____| |    "
	echo "|_____/ \_____|_| |_|_| |_|_____)_|    "
	echo
	echo "Compare subdomains with a list of IP addresses in scope."
	echo
	echo "Usage: Danner.sh -s subdomains.txt -t targets.txt"
	echo
	echo " Option:           Description:"
	echo " -s                path of file containing subdomains"
	echo " -t                path of file containing targets"
	echo " -h                display this help message"
	echo
}

while getopts "h:s:t:" option; do
	case "${option}" in
    		s) subdomains=${OPTARG};;
		t) targets=${OPTARG};;
	    	h) usage; exit;;
	    	*) usage; exit;;
 	esac
done

if [[ $# = 0 ]]; then
	usage
	exit
fi

total=$(wc -l < $subdomains)

# Code
echo " ______  _____ ____  ____  _____  ____ "
echo "|  __  |(____ |  _ \|  _ \| ___ |/ ___) TM"
echo "| |__/ // ___ | | | | | | | ____| |    "
echo "|_____/ \_____|_| |_|_| |_|_____)_|    "
echo
echo -e "[+] Translating subdomains.. ("$total" found)\n"

# Clean up if script run and not terminate
if [[ -e ./.Resolved.tmp ]]; then
	rm ./.Resolved.tmp
fi

for line in $(cat $subdomains); do

	echo -ne "\r\e[KChecking: "$line
	host $line >> .Resolved-dirty.tmp

done
sleep 1
# get rid of IPv6
echo -e "\n\n[+] Cleaning results.."
sed '/IPv6/d' .Resolved-dirty.tmp > .Resolved.tmp
rm .Resolved-dirty.tmp
echo -e "[+] Matching results..\n"	
sleep 2
# counter reset
let i=1

IFS=$'\n'
total=$(wc -l < .Resolved.tmp)

for solved in $(cat .Resolved.tmp); do
		
	# increment counter
	echo -ne "\r\e[KMatching: "$i" of "$total
	
	if [[ $solved == *address* ]]; then
    		
		ipadr=$(echo $solved | cut -d " " -f4)	

		if grep -Fq $ipadr $targets
		then
			plain=$(echo $solved | cut -d " " -f1)
			echo $plain" ("$ipadr")" >> Subdomains-in-Scope.txt
		fi
	fi
	i=$((i+1))
done

echo -e "\n\n[+] Removing temporary files.."
rm .Resolved.tmp
echo "[+] Finished"

if [[ -e ./Subdomains-in-Scope.txt ]]; then
	echo "[+] "$(wc -l < Subdomains-in-Scope.txt)" subdomains are in scope."
	echo "[-] Results saved in: ./Subdomains-in-Scope.txt"
else
	echo "[-] No subdomains found to be in scope."
fi
