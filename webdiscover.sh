#!/bin/bash

echo "=========================================================="
echo "============ Web Discovery - by v1n1v131r4@pm.me ========="
echo "=========================================================="

# Check if you are on Kali Linux

if [ "$(cat /etc/debian_version)" = "kali-rolling" ]
	then

# Check if you are root
	if [ "$(whoami)" = "root" ]
		then
			# If you are root,
			# build dependences

			echo "Building dependences" & sleep 2
			echo " "

			# seclists
			if ls -l /usr/share | grep "seclists" 2>&1 > /dev/null; then echo "seclists found!"; else apt install seclists; fi
			echo " "
			# ffuf
			if which ffuf 2>&1 > /dev/null; then echo "ffuf found!"; else apt install ffuf; fi
			echo " " 
			# namelist
			if ls -l /usr/share/ | grep "namelist.txt" 2>&1 > /dev/null; then echo "namelist found!"; else wget https://raw.githubusercontent.com/darkoperator/dnsrecon/master/namelist.txt -O /usr/share/namelist.txt; fi
			echo " "
			# dnsrecon
			if which dnsrecon 2>&1 > /dev/null; then echo "dnsrecon found!"; else apt install dnsrecon; fi
			echo " "
			# whatweb
			if which whatweb 2>&1 > /dev/null; then echo "whatweb found!"; else apt install whatweb; fi
			echo " "

			# gospider
			if which gospider 2>&1 > /dev/null; then echo "gospider found!"; else apt install gospider; fi
			echo " "

			# nuclei
			if which nuclei 2>&1 > /dev/null; then echo "nuclei found!"; else wget https://github.com/projectdiscovery/nuclei/releases/download/v2.4.0/nuclei_2.4.0_linux_amd64.zip && unzip nuclei_2.4.0_linux_amd64.zip && mv nuclei /usr/bin/nuclei && cd /opt && git clone https://github.com/projectdiscovery/nuclei-templates.git; fi
			echo " "
			
			# searchsploit
			searchsploit -u && echo "exploit-db updated!"
			echo " "
			echo " "	
			#########################################################################
			################################ Variables ##############################
			#########################################################################

			echo "==> Set your target (Ex. google.com)" ; read target
			echo " "
			

			#########################################################################
			############################## Starting Scan ############################
			#########################################################################
			echo " "
			echo "Let's go!!!" 
			echo " "

			# Create directory
			mkdir result
			
			# nmap
			
			echo "### NMAP ###"
			echo " "

			rm -rf /tmp/nmap.txt
			nmap -sV -sC -O -p 80,443 $target -oX result/nmap.xml


			echo "### DNSRecon ###"
			echo " "

			dnsrecon -d $target -t axfr -s 2>/dev/null | tee result/dnsrecon_axfr.txt

			dnsrecon -d $target -t zonewalk 2>/dev/null | tee result/dnsrecon_zonewal.txt

			dnsrecon -d $target -D /usr/share/namelist.txt -r brt 2>/dev/null | tee result/dnsrecon_subdomain.txt

			echo " "	
			echo "### WhatWeb ###"
			echo " "

			rm -rf result/whatweb.txt
			whatweb --no-errors -a 3 -v $target | tee result/whatweb.txt

			echo " "
			echo "### SearchSploit ##"
			echo " "
			# Tks to @Gr1nch for this insight
			
			#echo " "
			#echo "==> Searchsploit to NMAP"
			#echo " "
			#searchsploit --nmap /tmp/nmap.xml
			#echo " "

			echo " "
			echo "==> Web Technology"

			if cat result/whatweb.txt | grep -e "X\-Powered\-By\:";then TECH=`cat result/whatweb.txt | grep -e "X\-Powered\-By\:" | awk '{print $2}' | sed 's/-/ /g' | sed -E 's/\// /g' | sed 's/,//g' | awk '{print $1,$2}' | head -n1` && searchsploit -s $TECH | tee result/webtech_sploit.txt;else echo "Can't understand technology...";fi
			
			echo " "
			echo "==> Web Server"
			if ! cat result/whatweb.txt | grep -e "Server:" | awk '{print $2}' | sed 's/-/ /g' | sed -E 's/\// /g' | sed 's/,//g' | awk '{print $2}';then echo "Can't define server version...";else SRV=`cat result/whatweb.txt | grep -e "Server:" | awk '{print $2}' | sed 's/-/ /g' | sed -E 's/\// /g' | sed 's/,//g' | awk '{print $1,$2}' | head -n1` && searchsploit -s $SRV | tee result/webserver_sploit.txt;fi
			
			echo " "
			## CMS

			# WordPress
			rm -rf /tmp/2.txt

			echo "==> CMS - WordPress"

			if cat result/whatweb.txt 2>&1 > /dev/null | awk '/WordPress/';then cat result/whatweb.txt | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' > /tmp/2.txt;else echo "";fi

			VER1=`cat /tmp/2.txt | grep -E -o "WordPress\[.*" | grep -E -o "([0-9]\.[0-9]\.[0-9])"` && searchsploit -s wordpress $VER1 | tee result/wordpress_sploit.txt
			
			#VER2=`cat /tmp/2.txt | awk -F "WordPress" '/WordPress\[/{print $2}' | sed 's/\[/ /g' | sed 's/\]/ /g' | sed 's/\,/ /g' | tr -s ' ' | cut -d ' ' -f 3` && searchsploit -s wordpress $VER2
			
			# Joomla
			rm -rf /tmp/3.txt

			echo "==> CMS - Joomla"

			if cat result/whatweb.txt 2>&1 > /dev/null | awk '/Joomla/';then cat result/whatweb.txt | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' > /tmp/3.txt;else echo "";fi

			VER1=`cat /tmp/3.txt | grep -E -o "Joomla\[.*" | grep -E -o "([0-9]\.[0-9]\.[0-9])"` && searchsploit -s joomla $VER1 | tee result/joomla_sploit.txt
			
			#VER2=`cat /tmp/2.txt | awk -F "Joomla" '/Joomla\[/{print $2}' | sed 's/\[/ /g' | sed 's/\]/ /g' | sed 's/\,/ /g' | tr -s ' ' | cut -d ' ' -f 3` && searchsploit -s joomla $VER2
			
			# WPScan
			#if whatweb --plugins=wordpress | grep "WordPress";then echo "Scanning Wordpress..." && echo " " && wpscan --url $target; else echo ""; fi

			# JoomScan
			#if whatweb --plugins=joomla | grep "Joomla";then echo "Scanning Joomla..." && echo " " && joomscan --url $target; else echo ""; fi

			echo " "
			echo "## GoSpider ##"
			echo " "
			gospider -s "https://www.$target" -c 10 -d 1 | tee result/gospider.txt

			echo " "
			echo "## Nuclei ##"
			echo " "
			cd result
			nuclei -ut
			nuclei -u https://www.$target -t /opt/nuclei-templates/ -irr -me nuclei_reports
			cd ..
			
			
			echo " "	
			echo "### FFUF ###"
			echo " "

			ffuf -c -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt -u http://$target/FUZZ -mc 200 | tee result/ffuf.txt

	else
			# If you're not root
			# you got error
			echo "Sorry, try again with root powers ;)"
	fi

else
	echo " Sorry, i can't run without Kali linux :/"
fi

# End of file
