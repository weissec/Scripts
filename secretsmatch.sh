#!/usr/bin/bash

usage() {
	echo "Secretsmatch (bash):"
	echo "Match hashcat cracked passwords with relative usernames in the secretsdump.py ntds file output"
	echo
	echo "Usage: secretsmatch.sh -n ntds -p potfile -o output"
	echo
	echo " option:           description:"
	echo " -n                path of secretsdump.py ntds file output"
	echo " -p                path of hashcat potfile (format: ntlmhash:password)"
	echo " -o                path of output file"
	echo " -h                display this help message"
	echo
	echo "Example: secretsmatch.sh -n ./ntds -p ./hashcat.potfile -o ./output.txt"
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
grep ":::" $ntds > ntds-cleaned.tmp

echo "[+] Matching cracked passwords.."
echo

for line in $(cat $potfile); do

	ntlm=$(echo $line | cut -d ":" -f1)
	plain=$(echo $line |cut -d ":" -f2)

	echo -ne "\r\e[KMatching: "$plain

	for hashes in $(cat ntds-cleaned.tmp); do

		if [[ $hashes == *$ntlm* ]]; then
  			echo $(echo $hashes | cut -d ":" -f1)":"$plain >> $output.tmp
		fi

	done

done

echo
echo
echo "[+] Cleaning output file.."
sort -u $output.tmp > $output
echo "[+] Removing temporary files.."
rm $output.tmp
rm ntds-cleaned.tmp
echo "[+] Finished! ("$(wc -l < $output)" users owned!)"

