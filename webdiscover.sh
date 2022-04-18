#!/bin/bash

echo " "
cat << "EOF"
 __    __     _          ___ _
/ / /\ \ \___| |__      /   (_)___  ___ _____   _____ _ __
\ \/  \/ / _ \ '_ \    / /\ / / __|/ __/ _ \ \ / / _ \ '__|
 \  /\  /  __/ |_) |  / /_//| \__ \ (_| (_) \ V /  __/ |
  \/  \/ \___|_.__/  /___,' |_|___/\___\___/ \_/ \___|_|

EOF
echo "=========================================================="
echo "================== Vuln & Exploit Search ================="
echo "=========== By @v1n1v131r4 and @fepame | DC5551 =========="
echo "=========================================================="
echo " "
echo " "
echo "To run execute: ./webdiscover.sh [target]"
echo " "
echo "Your target must be like domain.com"
echo " "
echo " "

# Check parameter exists

if [ -z "$1" ]
then
	echo "Error: you must supply a target! Ex.: ./webdiscover.sh domain.com"
else

# Check if you are on Kali Linux

if [ "$(cat /etc/debian_version)" = "kali-rolling" ]
	then

# Check if you are root
	if [ "$(whoami)" = "root" ]
		then
			# If you are root,
			# build dependences

			echo "Building dependences..."
			echo " "
                        
			
			# seclists
			if ls -l /usr/share | grep "seclists" 2>&1 > /dev/null; then echo "seclists found!"; else apt -y install seclists; fi
			echo " "
			
			# ffuf
			if which ffuf 2>&1 > /dev/null; then echo "ffuf found!"; else apt -y install ffuf; fi
			echo " " 
			
			# namelist
			if ls -l /usr/share/ | grep "namelist.txt" 2>&1 > /dev/null; then echo "namelist found!"; else wget https://raw.githubusercontent.com/darkoperator/dnsrecon/master/namelist.txt -O /usr/share/namelist.txt; fi
			echo " "
			
			# dnsrecon
			if which dnsrecon 2>&1 > /dev/null; then echo "dnsrecon found!"; else apt -y install dnsrecon; fi
			echo " "
			
			# subfinder
			if which subfinder 2>&1 > /dev/null; then echo "subfinder found!"; else apt -y install subfinder; fi
			echo " "
			
			# whatweb
			if which whatweb 2>&1 > /dev/null; then echo "whatweb found!"; else apt -y install whatweb; fi
			echo " "

			# gospider
			if which gospider 2>&1 > /dev/null; then echo "gospider found!"; else apt -y install gospider; fi
			echo " "

			# nuclei
			if which nuclei 2>&1 > /dev/null; then echo "nuclei found!"; else wget https://github.com/projectdiscovery/nuclei/releases/download/v2.4.0/nuclei_2.4.0_linux_amd64.zip && unzip nuclei_2.4.0_linux_amd64.zip && mv nuclei /usr/bin/nuclei && cd /opt && git clone https://github.com/projectdiscovery/nuclei-templates.git; fi
			nuclei -ut &>/dev/null &
			echo " "

			# searchsploit
			searchsploit -u &>/dev/null & 
			echo "exploit-db updated!"
			echo " "
			
			# aquatone
			if which aquatone 2>&1 > /dev/null; then echo "aquatone found!"; else sudo apt -y install chromium && wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip && unzip aquatone_linux_amd64_1.7.0.zip && sudo mv aquatone /usr/bin; fi
			#echo " "
			echo " "	
			#sleep 2

			#########################################################################
			####################### Variables and Functions #########################
			#########################################################################

			#echo "==> Set your 1 (Ex. google.com)"
			#read 1
			#echo " "
			target=$1
			#echo "Let's play with $target"

			timestamp() {
  				date +"%T" # current time
			}	
			
			MainScan() {
				for i in $(cat result_$target/subfinder.txt);do
					echo " "
					echo " "
					echo "###########################################################"
					echo "=========> Start Scan on $i"
					echo "###########################################################"
					echo " "
					echo " "

					echo " "
					echo "## GoSpider ##"
					echo " "
					gospider -s "https://$i" -c 10 -d 1 | tee result_$target/gospider_$i.txt &&

					
						
					echo " "
					echo "## Aquatone ##"
					echo " "
					cd result_$target
					mkdir aquatone_outputs && cd aquatone_outputs
					cat ../subfinder.txt | aquatone
					cd ../../
						
					echo " "
					echo "## Nuclei ##"
					echo " "
					cd result_$target
					nuclei -l subfinder.txt -t /opt/nuclei-templates -irr -me nuclei_reports && cd nuclei_reports	
					echo " "
			
			
					echo " "	
					echo "### FFUF ###"
					echo " "
					ffuf -c -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-small.txt -u http://$i/FUZZ -mc 200 -recursion | tee result_$target/ffuf_$i.txt

				done
			}

			#########################################################################
			############################## Starting Scan ############################
			#########################################################################
			echo " "
			echo "Let's go!!!" 
			echo " "

			# Create directory
			mkdir result_$1 2>&1 > /dev/null
			
			# nmap
			
			echo "### Running NMAP agains the commom web ports on Target ###"
			echo " "

			rm -rf /tmp/nmap.txt
			nmap -sV -sC -O -p 80,443 $1 -oX result_$1/nmap.xml


			echo "### Running DNSRecon agains the Target ###"
			echo " "

			dnsrecon -d $1 -t axfr -s 2>/dev/null | tee result_$1/dnsrecon_axfr.txt

			dnsrecon -d $1 -t zonewalk 2>/dev/null | tee result_$1/dnsrecon_zonewal.txt

			dnsrecon -d $1 -D /usr/share/namelist.txt -r brt 2>/dev/null | tee result_$1/dnsrecon_subdomain.txt


			echo " "
			echo "## Running Subfinder agains the Target ##"
			subfinder -d $1 -v -o result_$1/subfinder.txt && 
			echo " "
			echo " "	
				
			echo "### Runnig WhatWeb agains the Mains Target ###"
			echo " "

			rm -rf result_$1/whatweb.txt
			whatweb --no-errors -a 3 -v $1 | tee result_$1/whatweb.txt &&
			
			echo " "
			echo "### Running SearchSploit against the Main Target ##"
			echo " "
			
			# Tks to @Gr1nch for this insight
			
			echo " "
			echo "==> Enumerating -> Web Technology"

			if cat result_$1/whatweb.txt | grep -e "X\-Powered\-By\:";then TECH=`cat result_$1/whatweb.txt | grep -e "X\-Powered\-By\:" | awk '{print $2}' | sed 's/-/ /g' | sed -E 's/\// /g' | sed 's/,//g' | awk '{print $1,$2}' | head -n1` && searchsploit -s $TECH | tee result_$1/webtech_sploit.txt;else echo "Can't understand technology...";fi
			
			echo " "
			echo "==> Enumerating -> Web Server"
			if ! cat result_$1/whatweb.txt | grep -e "Server:" | awk '{print $2}' | sed 's/-/ /g' | sed -E 's/\// /g' | sed 's/,//g' | awk '{print $2}';then echo "Can't define server version...";else SRV=`cat result_$1/whatweb.txt | grep -e "Server:" | awk '{print $2}' | sed 's/-/ /g' | sed -E 's/\// /g' | sed 's/,//g' | awk '{print $1,$2}' | head -n1` && searchsploit -s $SRV | tee result_$1/webserver_sploit.txt;fi
			
			echo " "
					
			## CMS

			# WordPress
			rm -rf /tmp/2.txt

			echo "==> Enumerating -> WordPress"

			if cat result_$1/whatweb.txt 2>&1 > /dev/null | awk '/WordPress/';then cat result_$1/whatweb.txt | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' > /tmp/2.txt;else echo "The 1 appears not to have WordPress installed...";fi

			VER1=`cat /tmp/2.txt | grep -E -o "WordPress\[.*" | grep -E -o "([0-9]\.[0-9]\.[0-9])"` && searchsploit -s wordpress $VER1 | tee result_$1/wordpress_sploit.txt
			
			
			# Joomla
			rm -rf /tmp/3.txt

			echo "==> Enumerating -> Joomla"

			if cat result_$1/whatweb.txt 2>&1 > /dev/null | awk '/Joomla/';then cat result_$1/whatweb.txt | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' > /tmp/3.txt;else echo "The 1 appears not to have Joomla installed...";fi

			VER1=`cat /tmp/3.txt | grep -E -o "Joomla\[.*" | grep -E -o "([0-9]\.[0-9]\.[0-9])"` && searchsploit -s joomla $VER1 | tee result_$1/joomla_sploit.txt
			
			
			# WPScan
			#if whatweb --plugins=wordpress | grep "WordPress";then echo "Scanning Wordpress..." && echo " " && wpscan --url $1; else echo ""; fi

			# JoomScan
			#if whatweb --plugins=joomla | grep "Joomla";then echo "Scanning Joomla..." && echo " " && joomscan --url $1; else echo ""; fi
				
			echo " "	
				
				
			MainScan


	else
			# If you're not root
			# you got error
			echo "Sorry, try again with root powers ;)"
	fi

else
	echo " Sorry, i can't run without Kali linux :/"
fi

fi


# End of file
