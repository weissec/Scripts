#!/usr/bin/bash

usage() {
	echo "SecretsMatch"
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

echo "[+] Extracting hashes from secretsdump.py ntds output.."
grep ":::" $ntds > .ntds-cleaned.tmp

i=0
tot=$(wc -l < $potfile)

echo "[+] Matching cracked passwords.."
echo

for line in $(cat $potfile); do

	ntlm=$(echo $line | cut -d ":" -f1)
	plain=$(echo $line |cut -d ":" -f2)
	
 	# echo -ne "\r\e[KProgress: [=                                       ] 0%"
	# echo -ne "\r\e[KProgress: [========================================] 100%"
 	# echo -ne "\r\e[KMatching: "$plain
	prog=$(awk -v v1="$i" -v v2="$tot" 'BEGIN{printf "%.0f", v2/v1 * 100}')
 	echo -ne "\r\e[KProgress: "$prog"%"
  
	for hashes in $(cat .ntds-cleaned.tmp); do

		if [[ $hashes == *$ntlm* ]]; then
  			echo $(echo $hashes | cut -d ":" -f1)":"$plain >> .$output.tmp
		fi

	done
	((i++))
done
echo
echo
echo "[+] Cleaning output file.."
sort -u .$output.tmp > $output
echo "[+] Removing temporary files.."
usernum=$(wc -l < .ntds-cleaned.tmp)
owned=$(wc -l < $output)
percent=$(awk -v t1="$owned" -v t2="$usernum" 'BEGIN{printf "%.0f", t2/t1 * 100}')
rm .$output.tmp
rm .ntds-cleaned.tmp
echo "[+] Finished!"
echo
echo "Total of users accounts:  "$usernum
echo "Accounts compromised:     "$owned " ("$percent"%)"
echo
exit
