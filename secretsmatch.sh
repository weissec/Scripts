#!/usr/bin/bash

clear

                                                   
echo "                     _                 _       _   "
echo " ___ ___ ___ ___ ___| |_ ___ _____ ___| |_ ___| |_ "
echo "|_ -| -_|  _|  _| -_|  _|_ -|     | .'|  _|  _|   |"
echo "|___|___|___|_| |___|_| |___|_|_|_|__,|_| |___|_|_|"
echo                                                 


usage() {
	echo
	echo "This script matches cracked passwords with relative usernames from a NTDS file (useful in certain situations)."
	echo "The format accepted for the NTDS file, is the output from the Secretsdump impacket script."
	echo "E.g. secretsdump.py -just-dc-ntlm --users-status Domain.local/username:password@192.168.10.12 > ntds.dit"
	echo "The cracked hashes format is the Hashcat potfile."
	echo "E.g. hashcat -m 1000 ./ntds.dit /wordlists/rockyou.txt -r /rules/OneRuleToRuleThemAll.rule -O"
	echo "To combine the plaintext passwords with the users then run this script as per the following:"
	echo
	echo "Usage: secretsmatch.sh -n ntds.dit -p hashcat.potfile -o output.txt"
	echo
	echo " option:           description:"
	echo " -n                path of secretsdump.py ntds file output"
	echo " -p                path of hashcat potfile (format: ntlmhash:password)"
	echo " -o                path of output file for the results"
	echo " -h                display this help message"
	echo
}

while getopts "h:n:p:o:" option; do
	case "${option}" in
    		n) ntds=${OPTARG};;
		p) potfile=${OPTARG};;
	    	o) output=${OPTARG};;
	    	h) usage; exit;;
	    	*) usage; exit;;
 	esac
done

if [[ $# = 0 ]]; then
	usage
	exit
fi

# Cleaning up from previous runs
if [ -f Errors.txt ]; then
	rm Errors.txt
fi
if [ -f .ntds-cleaned.tmp ]; then
	rm .ntds-cleaned.tmp
fi
if [ -f .$output.tmp ]; then
	rm .$output.tmp
fi
if [ -f $output ]; then
	rm $output
fi

# Script start
echo "[+] Extracting hashes from NTDS file.."
grep ":::" $ntds > .ntds-cleaned.tmp

i=1
tot=$(($(wc -l < $potfile) + 0))

echo "[-] Found "$tot" unique cracked passwords."
echo "[+] Matching cracked passwords with compromised users.."
echo

percentBar ()  {
    		local prct totlen=$((8*$2)) lastchar barstring blankstring;
    		printf -v prct %.2f "$1"
    		((prct=10#${prct/.}*totlen/10000, prct%8)) &&
        	printf -v lastchar '\\U258%X' $(( 16 - prct%8 )) ||
            	lastchar=''
    		printf -v barstring '%*s' $((prct/8)) ''
    		printf -v barstring '%b' "${barstring// /\\U2588}$lastchar"
    		printf -v blankstring '%*s' $(((totlen-prct)/8)) ''
    		printf -v "$3" '%s%s' "$barstring" "$blankstring"
}

# Setting field separator to remove error for passwords containing spaces: e.g. this password
IFS=$'\n'

for line in $(cat $potfile); do

	ntlm=$(echo $line | cut -d ":" -f1)
	plain=$(echo $line | cut -d ":" -f2-)

 	# 1f is the aproximation to decimal. e.g. 10.4 %
	prog=$(awk -v v1="$i" -v v2="$tot" 'BEGIN{printf "%.1f", v1/v2 * 100}')
 
	percentBar $prog 40 bar
	printf '\rProgress: \e[47;32m%s\e[0m%6.2f%%' '$bar'  $prog 

	# Check that all lines are in the correct format (hash size of 32 characters).
	if [[ ${#ntlm} = 32 ]] ; then

 		grep $ntlm .ntds-cleaned.tmp | cut -d ":" -f1 | sed "s|$|:$plain|"  >> .$output.tmp

	else
		echo $ntlm":"$plain >> Errors.txt
 	fi
  
  	((i++))
done
echo
echo
echo "[+] Cleaning output file.."
sort -u .$output.tmp > $output
echo "[+] Removing temporary files.."
usernum=$(($(wc -l < .ntds-cleaned.tmp) + 0))
owned=$(($(wc -l < $output) + 0))
percent=$(awk -v t1="$owned" -v t2="$usernum" 'BEGIN{printf "%.0f", t1/t2 * 100}')
rm .$output.tmp
rm .ntds-cleaned.tmp
echo "[+] Finished!"
echo
echo "-------------------------------------------------"
echo "Total of users accounts:           "$usernum
echo "Total of unique cracked passwords: "$tot
echo "Accounts compromised:              "$owned " ("$percent"%)"
echo "-------------------------------------------------"
# if errors exits, print message:
if [ -f Errors.txt ]; then
	echo "[Attention] The scripts found some unrecognised entries in the potfile. Please see the 'Errors.txt' file."
fi
echo
exit
