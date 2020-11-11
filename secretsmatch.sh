#!/usr/bin/bash

usage() {
	echo "SecretsMatch"
	echo
	echo "Match cracked passwords with relative usernames from the output file of the following command:"
	echo "secretsdump.py -just-dc-ntlm --users-status Domain.local/username:password@192.168.10.12 > ntds.dit"
	echo "Crack the hashes (example):"
	echo "hashcat -m 1000 ./ntds.dit /wordlists/rockyou.txt -r /rules/OneRuleToRuleThemAll.rule -O"
	echo
	echo "Usage: secretsmatch.sh -n ntds.dit -p hashcat.potfile -o output.txt"
	echo
	echo " option:           description:"
	echo " -n                path of secretsdump.py ntds file output"
	echo " -p                path of hashcat potfile (format: ntlmhash:password)"
	echo " -o                path of output file"
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

echo "[+] Matching cracked passwords.."
echo

for line in $(cat $potfile); do

	ntlm=$(echo $line | cut -d ":" -f1)
	plain=$(echo $line |cut -d ":" -f2)

	echo -ne "\r\e[KMatching: "$plain

	for hashes in $(cat .ntds-cleaned.tmp); do

		if [[ $hashes == *$ntlm* ]]; then
  			echo $(echo $hashes | cut -d ":" -f1)":"$plain >> .$output.tmp
		fi

	done

done
echo
echo
echo "[+] Cleaning output file.."
sort -u .$output.tmp > $output
echo "[+] Removing temporary files.."
usernum=$(wc -l < .ntds-cleaned.tmp)
owned=$(wc -l < $output)
rm .$output.tmp
rm .ntds-cleaned.tmp
echo "[+] Finished!"
echo
echo "Total of users accounts:  "$usernum
echo "Accounts compromised:     "$owned
echo "To calculate the percentage do: ("$owned" / "$usernum") * 100"
echo
