#!/bin/bash

# Author = "Jameel Nabbo"
# Created Date = "31-Aug-2016"

user=`whoami`
config=`ls | grep "aicmd.config" | wc -l`

if [ "$user" != "root" ]
then
	echo "Error - Please run the this tool with 'root' user or use 'sudo' rights"
elif [ "$config" == "0" ]
then
	echo "Error - Missing the configuration file !!!"
	echo "1. You should download 'aicmd.config' file"
	echo "2. Copy it in the same directory as this script"
	echo "3. Please Re-run this script"
else
	echo "Enter IP address List FileName with Path"
	read file

	l=`wc -l $file | cut -d " " -f1`

	if [ "$l" != "0" ]
	then
		date=`date +%d"-"%m"-"%Y`
		mkdir -p "$date"

 		for (( i=1 ; i <= $l ; i++ ))
		do
			ip=`sed -n ''$i'p' $file`
			check=`cd $date; ls | grep $ip | wc -l; cd ..`

			if [ "$check" == "0" ]
			then
				mkdir "$date"/$ip
				mkdir "$date"/$ip/nmap_result

				time=`date`
				echo "$time:          The TCP Scan has been Started for the ip address: $ip" >> "$date"/enumai.log
				echo
				echo "TCP Scan Started for IP: $ip"

				nmap -T5 -Pn -p1-65535 $ip --system-dns -oA "$date"/$ip/nmap_result/TCP_Scan >> "$date"/$ip/nmap_result/nmap_logs
				
				time=`date`
				echo "$time:          UDP Scan Started for IP: $ip" >> "$date"/enumai.log
				echo
				echo "UDP Scan Started for IP: $ip"

				nmap -T5 -Pn -sU -p49,53,67,68,69,88,113,118,123,135,137,138,143,156,161,162,194,213,220,264,389,444,500,514,520,530,563,1194,1293,1434,1512,1645,1646,1812,2206,3389,5060,5061,5432 $ip --system-dns -oA "$date"/$ip/nmap_result/UDP_Scan >> "$date"/$ip/nmap_result/nmap_logs

				wc=`cat "$date"/$ip/nmap_result/nmap_logs | grep "\sopen\s" | wc -l`

				if [ "$wc" == "0" ]
				then
					time=`date`
					echo "$time:          No open ports were found for IP: $ip" >> "$date"/enumai.log
					echo
					echo "No open ports were found for the ip address: $ip"
				else
					mkdir "$date"/$ip/open_ports
					for (( j=1 ; j <= $wc ; j++ ))
					do
						port=`cat "$date"/$ip/nmap_result/nmap_logs | grep "\sopen\s" | sed -n "$j"p | cut -d "/" -f1`
						echo $port >> "$date"/$ip/open_ports/ports
					done

					sort -u "$date"/$ip/open_ports/ports > "$date"/$ip/open_ports/port_list
					rm "$date"/$ip/open_ports/ports

					port_list="port_list"
					pwc=`wc -l "$date"/$ip/open_ports/$port_list | cut -d " " -f1`
					for (( j=1 ; j <= $pwc ; j++ ))
					do
						port=`sed -n ''$j'p' "$date"/$ip/open_ports/$port_list`
						line=`cat aicmd.config | grep "^$port@" | wc -l`

						time=`date`
						echo "$time:          Testing for $ip: $port" >> "$date"/enumai.log
						echo
						echo "Testing for $ip: $port"

						if [ "$line" != "0" ]
						then
							line=`cat aicmd.config | grep "^$port@"`
							
							at=`echo "$line" | grep -o "@" | wc -l`
							at=`expr "$at" + "1"`
							
							mkdir "$date"/$ip/open_ports/$port

							for (( r=2 ; r <= $at ; r++ ))
							do
								comm=`echo $line | cut -d "@" -f$r`
								tool=`echo $line | cut -d "@" -f$r | cut -d " " -f1`
								
								filename=`echo $tool`
								if [ "$tool" == "nmap" ]
								then
									scr=`echo $line | cut -d "@" -f$r | cut -d "=" -f2 | cut -d " " -f1`
									filename=`echo "$filename"_"$scr"`
								fi
								
								ntp=`echo $tool | grep ntp | wc -l`
								if [ "$ntp" != "0" ]
								then
									scr=`echo $line |  cut -d "@" -f$r | cut -d " " -f3 | grep -Po "[a-zA-Z]+"`
									filename=`echo "$filename"_"$scr"`
								fi

								time=`date`
								echo "$time:          Testing for $ip: $port, Tool: $filename" >> "$date"/enumai.log
								echo "Testing for $ip: $port, Tool: $filename"

								eval $comm > "$date"/$ip/open_ports/$port/result

								size=`cat "$date"/$ip/open_ports/$port/result | wc -l`
								if [ "$size" -gt "30" ]
								then
									k=30
									end=30
									c=1
									t=1

									for (( m=1 ; m <= $size ; ))
									do
										cat "$date"/$ip/open_ports/$port/result | sed -n $m,''$end'p' | convert -background black -fill white -size 1080x720  label:@- "$date"/$ip/open_ports/$port/"$filename_$c".jpg 2>/dev/null
										m=`echo $end`
										end=`expr "$end" + "$k"`
										c=`expr "$c" + "$t"`
									done
									rm "$date"/$ip/open_ports/$port/result
								else
									if [ "$size" -gt "0" ]
									then
										cat "$date"/$ip/open_ports/$port/result | convert -background black -fill white -size 1080x720  label:@- "$date"/$ip/open_ports/$port/$filename.jpg 2>/dev/null
										rm "$date"/$ip/open_ports/$port/result
									fi
								fi
							done
						fi
						mkdir -p "$date"/$ip/open_ports/$port
					
						prot=`echo ",49,53,67,68,69,88,113,118,123,135,137,138,143,156,161,162,194,213,220,264,389,444,500,514,520,530,563,1194,1293,1434,1512,1645,1646,1812,2206,3389,5060,5061,5432," | grep -Po ",$port," | wc -l`
						if [ "$prot" != "0" ]
						then
							nmap -A -p$port -Pn -sU $ip --system-dns | grep "\sopen\s" | sed -n 1p > "$date"/$ip/open_ports/$port/result
							size=`cat "$date"/$ip/open_ports/$port/result | wc -l`
							if [ "$size" -gt "0" ]
							then
								cat "$date"/$ip/open_ports/$port/result | convert -background black -fill white -size 1080x720  label:@- "$date"/$ip/open_ports/$port/running_service_udp.jpg 2>/dev/null
								rm "$date"/$ip/open_ports/$port/result
							fi
						fi
						nmap -A -p$port -Pn $ip --system-dns | grep "\sopen\s" | sed -n 1p > "$date"/$ip/open_ports/$port/result

						size=`cat "$date"/$ip/open_ports/$port/result | wc -l`
						if [ "$size" -gt "0" ]
						then
							cat "$date"/$ip/open_ports/$port/result | convert -background black -fill white -size 1080x720  label:@- "$date"/$ip/open_ports/$port/running_service_tcp.jpg 2>/dev/null
							rm "$date"/$ip/open_ports/$port/result
						fi

						echo "#!/bin/bash" >> "$date"/$ip/open_ports/$port/telnet
						echo >> "$date"/$ip/open_ports/$port/telnet
						echo "expect<<EOF" >> "$date"/$ip/open_ports/$port/telnet
						echo "spawn telnet" >> "$date"/$ip/open_ports/$port/telnet
						echo "expect \"telnet>\"" >> "$date"/$ip/open_ports/$port/telnet
						echo "send \"open $ip $port\n\"" >> "$date"/$ip/open_ports/$port/telnet
						echo "expect -re \"(\\w+)\"" >> "$date"/$ip/open_ports/$port/telnet
						echo "EOF" >> "$date"/$ip/open_ports/$port/telnet

						chmod 777 "$date"/$ip/open_ports/$port/telnet
						"$date"/$ip/open_ports/$port/telnet | sed 1d | convert -background black -fill white -size 1080x720  label:@- "$date"/$ip/open_ports/$port/telnet_banner.jpg 2>/dev/null	
						rm "$date"/$ip/open_ports/$port/telnet

						if [ "$port" == "135" -o "$port" == "137" -o "$port" == "138" -o "$port" == "139" -o "$port" == "445" ]
						then
							echo "#!/bin/bash" >> "$date"/$ip/open_ports/$port/null_session
							echo >> "$date"/$ip/open_ports/$port/null_session
							echo "expect<<EOF" >> "$date"/$ip/open_ports/$port/null_session
							echo "spawn smbclient //$ip/ipc$ -N" >> "$date"/$ip/open_ports/$port/null_session
							echo "expect -re \"(\\w+)\"" >> "$date"/$ip/open_ports/$port/null_session
							echo "exit" >> "$date"/$ip/open_ports/$port/null_session
							echo "EOF" >> "$date"/$ip/open_ports/$port/null_session

							chmod 777 "$date"/$ip/open_ports/$port/null_session
							"$date"/$ip/open_ports/$port/null_session  | sed 1d | convert -background black -fill white -size 1080x720  label:@- "$date"/$ip/open_ports/$port/null_session_status.jpg 2>/dev/null
							rm "$date"/$ip/open_ports/$port/null_session
						fi
					done
				fi
			else
				echo
				time=`date`
				echo "the scanning of the ip address address --> $ip is already complete. skipping this ip address"
				echo "$time:          The scan of the ip address --> $ip is already complete, skipping this ip address" >> "$date"/enumai.log
				pwd=`pwd`
				echo "If you want to rescan this ip address, please manually delete the folder in this path : '$pwd/$date/$ip' and restart the scanning process again!"
				time=`date`
				echo "$time:          To rescan this IP, please manually delete the folder : '$pwd/$date/$ip' and start the scan again !!!" >> "$date"/enumai.log
				echo
			fi

			stat=`expr "$l" - "$i"`
			echo
			time=`date`
			echo "$time:          $stat IP/IPs left..." >> "$date"/enumai.log
			echo $stat "IP/IPs left..."
			echo
		done
	else
		echo
		time=`date`
		echo "$time:          Sorry !! No ip addresses were found !!!" >> "$date"/enumai.log
		echo "Sorry! No ip addresses were found !!!"
		echo
	fi

echo
echo "Scan has been completed :) "
pwd=`pwd`
echo "Please check out the folder ->: '$pwd/$date'"
echo

fi
