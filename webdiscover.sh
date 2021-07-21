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
			
			# subfinder
			if which subfinder 2>&1 > /dev/null; then echo "subfinder found!"; else apt install subfinder; fi
			echo " "
			
			# whatweb
			if which whatweb 2>&1 > /dev/null; then echo "whatweb found!"; else apt install whatweb; fi
			echo " "

			# gospider
			if which gospider 2>&1 > /dev/null; then echo "gospider found!"; else apt install gospider; fi
			echo " "

			# nuclei
			if which nuclei 2>&1 > /dev/null; then echo "nuclei found!" && nuclei -ut 2>&1 > /dev/null; else wget https://github.com/projectdiscovery/nuclei/releases/download/v2.4.0/nuclei_2.4.0_linux_amd64.zip && unzip nuclei_2.4.0_linux_amd64.zip && mv nuclei /usr/bin/nuclei && cd /opt && git clone https://github.com/projectdiscovery/nuclei-templates.git; fi
			echo " "
			
			# searchsploit
			#searchsploit -u && echo "exploit-db updated!"
			echo " "
			echo " "	
			#########################################################################
			####################### Variables and Functions #########################
			#########################################################################

			echo "==> Set your target (Ex. google.com)" ; read target
			echo " "

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
					echo "## Nuclei ##"
					echo " "
					cd result_$target
					nuclei -u $i -t /opt/nuclei-templates/ -irr -me nuclei_reports &&
					cd ..
			
			
					echo " "	
					echo "### FFUF ###"
					echo " "
					ffuf -c -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt -u http://$i/FUZZ -mc 200 | tee result_$target/ffuf_$i.txt

				done
			}

			#########################################################################
			############################## Starting Scan ############################
			#########################################################################
			echo " "
			echo "Let's go!!!" 
			echo " "

			# Create directory
			mkdir result_$target
			
			# nmap
			
			echo "### NMAP ###"
			echo " "

			rm -rf /tmp/nmap.txt
			nmap -sV -sC -O -p 80,443 $target -oX result_$target/nmap.xml


			echo "### DNSRecon ###"
			echo " "

			dnsrecon -d $target -t axfr -s 2>/dev/null | tee result_$target/dnsrecon_axfr.txt

			dnsrecon -d $target -t zonewalk 2>/dev/null | tee result_$target/dnsrecon_zonewal.txt

			dnsrecon -d $target -D /usr/share/namelist.txt -r brt 2>/dev/null | tee result_$target/dnsrecon_subdomain.txt


			echo " "
			echo "## Subfinder ##"
			subfinder -d $target -v -o result_$target/subfinder.txt && 
			echo " "
			echo " "	
				
			echo "### WhatWeb ###"
			echo " "

			rm -rf result_$target/whatweb.txt
			whatweb --no-errors -a 3 -v $target | tee result_$target/whatweb.txt &&
			
			echo " "
			echo "### SearchSploit ##"
			echo " "
			
			# Tks to @Gr1nch for this insight
			
			echo " "
			echo "==> Web Technology"

			if cat result_$target/whatweb.txt | grep -e "X\-Powered\-By\:";then TECH=`cat result_$target/whatweb.txt | grep -e "X\-Powered\-By\:" | awk '{print $2}' | sed 's/-/ /g' | sed -E 's/\// /g' | sed 's/,//g' | awk '{print $1,$2}' | head -n1` && searchsploit -s $TECH | tee result_$target/webtech_sploit.txt;else echo "Can't understand technology...";fi
			
			echo " "
			echo "==> Web Server"
			if ! cat result_$target/whatweb.txt | grep -e "Server:" | awk '{print $2}' | sed 's/-/ /g' | sed -E 's/\// /g' | sed 's/,//g' | awk '{print $2}';then echo "Can't define server version...";else SRV=`cat result_$target/whatweb.txt | grep -e "Server:" | awk '{print $2}' | sed 's/-/ /g' | sed -E 's/\// /g' | sed 's/,//g' | awk '{print $1,$2}' | head -n1` && searchsploit -s $SRV | tee result_$target/webserver_sploit.txt;fi
			
			echo " "
					
			## CMS

			# WordPress
			rm -rf /tmp/2.txt

			echo "==> CMS - WordPress"

			if cat result_$target/whatweb.txt 2>&1 > /dev/null | awk '/WordPress/';then cat result_$target/whatweb.txt | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' > /tmp/2.txt;else echo "";fi

			VER1=`cat /tmp/2.txt | grep -E -o "WordPress\[.*" | grep -E -o "([0-9]\.[0-9]\.[0-9])"` && searchsploit -s wordpress $VER1 | tee result_$target/wordpress_sploit.txt
			
			
			# Joomla
			rm -rf /tmp/3.txt

			echo "==> CMS - Joomla"

			if cat result_$target/whatweb.txt 2>&1 > /dev/null | awk '/Joomla/';then cat result_$target/whatweb.txt | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' > /tmp/3.txt;else echo "";fi

			VER1=`cat /tmp/3.txt | grep -E -o "Joomla\[.*" | grep -E -o "([0-9]\.[0-9]\.[0-9])"` && searchsploit -s joomla $VER1 | tee result_$target/joomla_sploit.txt
			
			
			# WPScan
			#if whatweb --plugins=wordpress | grep "WordPress";then echo "Scanning Wordpress..." && echo " " && wpscan --url $target; else echo ""; fi

			# JoomScan
			#if whatweb --plugins=joomla | grep "Joomla";then echo "Scanning Joomla..." && echo " " && joomscan --url $target; else echo ""; fi
				
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

# End of file
