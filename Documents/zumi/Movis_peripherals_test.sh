#!/system/bin/sh
# Zumi :- Movis Peripherals Test
# Status of all the peripherals testing will be dumped to a text file

		###### Create Test Result file ######

name=/zumi/TestResult_log
if [[ -e $name0.txt ]] ; then
    i=1
    while [[ -e $name$i.txt ]] ; do
        let i++
    done
    name=$name$i
fi
touch $name0.txt

echo -e "######## \e[1m Movis Peripherals Test \e[0m########"		| tee -a $name.txt 
echo ""
echo "  ******* Choose the below option *******"
echo "" 
echo "    1.Test All peripherals Automatically"				
echo "    2.Test All peripherals Manually"				
echo ""

input_validate()
{
	read -p "Enter your option " auto
}

while true; do
  input_validate

	if [ $auto == 1 ]; then
		echo "#### Automatic peripherals test started ####" 	| tee -a $name.txt
		break
	elif [ $auto == 2 ]; then
		echo "#### Manual peripherals test started ####" 	| tee -a $name.txt
		break
	else		
		echo -e "\e[31m Invalid option \e[0m"
	fi
done
	echo "#### Available Test peripherals ####" 


peripherals()
	{
		echo -e "\t 1.SATA"	
		echo -e "\t 2.eMMC"	
		echo -e "\t 3.Audio"	
		echo -e "\t 4.CAN"	
		echo -e "\t 5.USB-WiFi"	
		echo -e "\t 6.USB-OTG"	
		echo -e "\t 7.USB-Host"	
		echo -e "\t 8.Exit"
		echo ""			
	}

while true; do
	peripherals

	if [ $auto == 2 ]; then
		read -p "Which peripherals you want to test " p_no
	fi

		############## SATA TEST ###############

if [ "$p_no" == "1" ] || [ "$auto" == "1"  ]; then
	echo "### SATA Test started ###"				

		read -p "Enter the SATA mount point(ie:sda3) " sata
		[ -f /mnt/sata ] && echo "Found" || mkdir /mnt/sata
		mount /dev/$sata /mnt/sata
		cp /$name.txt /mnt/sata/
		export sata_write_test=`echo $?`
		if [ $sata_write_test -eq 0 ]; then
	 		echo -e "SATA Write \e[32m Successful \e[0m"	| tee -a $name.txt
		else
	 		echo -e "SATA Write \e[31m Failure \e[0m"	| tee -a $name.txt
		fi
	
		cp /mnt/sata/$name.txt /$name.txt
		export sata_read_test=`echo $?`
		if [ $sata_read_test -eq 0 ]; then
			echo -e "SATA Read \e[32m Successful \e[0m"	| tee -a $name.txt
		else
	       		echo -e "SATA Read \e[31m Failure \e[0m"	| tee -a $name.txt
		fi
fi

		############## eMMC TEST ##############

if [ "$p_no" == "2" ] || [ "$auto" == "1" ]; then
        echo -e "\n### eMMC Test started ###"				

                read -p "Enter the eMMC mount point(ie:mmcblk3p1) " emmc
                [ -f /mnt/emmc ] && echo "Found" || mkdir /mnt/emmc
                mount /dev/$emmc /mnt/emmc
                cp /$name.txt /mnt/emmc/
                export emmc_write_test=`echo $?`
                if [ $emmc_write_test -eq 0 ]; then
                        echo -e "eMMC Write \e[32m Successful \e[0m"	| tee -a $name.txt
                else
                        echo -e "eMMC Write \e[31m Failure \e[0m"	| tee -a $name.txt
                fi
        
                cp /mnt/emmc/$name.txt /$name.txt
                export emmc_read_test=`echo $?`
                if [ $emmc_read_test -eq 0 ]; then
                        echo -e "eMMC Read \e[32m Successful \e[0m"	| tee -a $name.txt
                else
                        echo -e "eMMC Read \e[31m Failure \e[0m"	| tee -a $name.txt
                fi
fi

		############## AUDIO TEST ##############

if [ "$p_no" == "3" ] || [ "$auto" == "1" ]; then
	echo -e "\n### Audio Test started ###"			
	
		######### AUDIO-OUT TEST ##########

		echo -e  "\e[5m\e[93m Connect the HeadPhone \e[0m"
		echo -e "After the connection press \e[1m ENTER \e[0m"
		read -s -n 1  key
		aplay /zumi/munb.wav 
		export ao_test=`echo $?`
		if [ $ao_test -eq 0 ]; then
			echo -e "Audio-Out Test \e[32m successful \e[0m"	| tee -a $name.txt
		else
			echo -e "Audio-Out Test \e[31m\e[5m Failure \e[0m"	| tee -a $name.txt
		fi
		
		######### AUDIO-IN TEST ##########

		echo -e  "\e[5m\e[93m Connect the Loopback cable And remove HeadPhone\e[0m"
                echo -e "After the connection press \e[1m ENTER \e[0m"
                read -s -n 1  key1
                arecord -d 15 /zumi/munb-rec.wav & aplay /zumi/munb.wav 
                export ai_test=`echo $?`
		echo -e  "\e[5m\e[93m Connect the HeadPhone And remove Loopback cable \e[0m"
                echo -e "After the connection press \e[1m ENTER \e[0m"
                read -s -n 1  key2
		aplay /zumi/munb-rec.wav 
		export aio_test=`echo $?`
                if [ $ai_test -eq 0 ] || [ $aio_test -eq 0 ]; then
                        echo -e "Audio-In Test \e[32m successful \e[0m"		| tee -a $name.txt
                else
                        echo -e "Audio-In Test \e[31m Failure \e[0m"		| tee -a $name.txt
                fi
fi

		############## CAN TEST ##############

if [ "$p_no" == "4" ] || [ "$auto" == "1" ]; then
        echo -e "\n### CAN Test started ###"                       
		
                can()
		{
			echo -e "\t 1.CAN0"     
                	echo -e "\t 2.CAN1"    
		}
		while true; do
       			 can
			read -p "Which CAN you want to test: " can_no
			if [ $can_no == 1 ] || [ $can_no == 2 ]; then
				break 
			else 
				echo -e "\e[31m Invalid Input, Try again... \e[0m"
			fi		
		done
                ######### CAN send TEST ##########

		ip link set can$can_no up type can bitrate 125000
		echo -e  "\e[5m\e[93m Connect the CAN device and set bitrate \e[95m125kbps\e[0m"
                echo -e "After the connection press \e[1m ENTER \e[0m"
                read -s -n 1  key
		cansend can$can_no 5A1#11.2233.44556677.88
		can_send()
			{
				read -p "If data received or not in receiver end.? press Y/N " ans
			}

		while true; do
			can_send

				if [ "$ans" == "Y" ] || [ "$ans" == "y" ]; then 
					echo -e "CAN send Test \e[32m successful \e[0m"		| tee -a $name.txt
					break
				elif [ "$ans" == "N" ] || [ "$ans" == "n" ]; then
					echo -e "CAN send Test \e[31m Failure \e[0m" 		| tee -a $name.txt
					break
				else 
					echo -e "\e[31m Invalid Input, Try again... \e[0m"
				fi
		done
		
		######### CAN Receive TEST ##########

		candump can$can_no &
		echo -e  "\e[5m\e[93m send the data from another device and  bitrate \e[95m125kbps\e[0m"
		can_receive()
                        {
                                read -p "If data received or not in Movis board.? press Y/N " ans
                        }

                while true; do
                        can_receive

                                if [ $ans == "Y" ] || [ $ans == "y" ]; then
                                        echo -e "CAN receive Test \e[32m successful \e[0m"	| tee -a $name.txt
                                        break
                                elif [ $ans == "N" ] || [ $ans == "n" ]; then
                                        echo -e "CAN receive Test \e[31m Failure \e[0m" 	| tee -a $name.txt
                                        break
                                else
                                        echo -e "\e[31m Invalid Input, Try again... \e[0m"
                                fi
                done
fi

		############## USB-WiFi TEST ##############

if [ "$p_no" == "5" ] || [ "$auto" == "1" ]; then
	echo -e "\n### USB-WiFi Test started ###"
			ifconfig wlan0 up
			echo -e  "\e[5m\e[93m Create WiFi access_point without security & essid \e[95mmovis\e[0m"
	                echo -e "After the setup press \e[1m ENTER \e[0m"
			read -s -n 1  key2
			iwlist wlan0 scan | grep movis
			export wscan_test=`echo $?`
			if [ $wscan_test == 0 ]; then
				iwconfig wlan0 essid "movis"
				iwconfig | grep movis
				export w_test=`echo $?`
		        	udhcpc -i wlan0
		        	ping -I wlan0 google.com -c 1
				export wping_test=`echo $?`
				if [ $w_test == 0 ] || [ $wping_test == 0 ]; then 
					echo -e "USB-WiFi Test \e[32m successful \e[0m"		| tee -a $name.txt
						else
					echo -e "USB-WiFi Test \e[31m Failure \e[0m"		| tee -a $name.txt
				fi
				if [ $wping_test >= 1 ]; then
					echo -e "USB-WiFi pinging \e[31m Failure \e[0m"		| tee -a $name.txt
				fi
			else 
				echo -e "USB-WiFi Test \e[31m Failure \e[0m"			| tee -a $name.txt
			fi

fi

		############## USB-OTG TEST ##############

if [ "$p_no" == "6" ] || [ "$auto" == "1" ]; then
        echo -e "\n### USB-OTG Test started ###"
			
		read -p "Enter the USB mount point " otg
                [ -f /mnt/otg ] && echo "Found" || mkdir /mnt/otg
                mount /dev/$otg /mnt/otg
                cp /$name.txt /mnt/otg/
                export otg_write_test=`echo $?`
                if [ $otg_write_test -eq 0 ]; then
                        echo -e "USB-OTG Write \e[32m Successful \e[0m"    			| tee -a $name.txt
                else
                        echo -e "USB-OTG Write \e[31m Failure \e[0m"       			| tee -a $name.txt	
                fi

                cp /mnt/otg/$name.txt /$name.txt
                export otg_read_test=`echo $?`
                if [ $otg_read_test -eq 0 ]; then
                        echo -e "USB-OTG Read \e[32m Successful \e[0m"     			| tee -a $name.txt
                else
                        echo -e "USB-OTG Read \e[31m Failure \e[0m"        			| tee -a $name.txt
                fi
fi

		############## USB-HOST TEST ##############

if [ "$p_no" == "7" ] || [ "$auto" == "1" ]; then
        echo -e "\n### USB-HOST Test started ###"

                read -p "Enter the USB mount point " usb
                [ -f /mnt/usb ] && echo "Found" || mkdir /mnt/usb
                mount /dev/$usb /mnt/usb
                cp /$name.txt /mnt/usb/
                export usb_write_test=`echo $?`
                if [ $usb_write_test -eq 0 ]; then
                        echo -e "USB-HOST Write \e[32m Successful \e[0m"			| tee -a $name.txt
                else
                        echo -e "USB-HOST Write \e[31m Failure \e[0m"				| tee -a $name.txt
                fi

                cp /mnt/usb/$name.txt /$name.txt
                export usb_read_test=`echo $?`
                if [ $usb_read_test -eq 0 ]; then
                        echo -e "USB-HOST Read \e[32m Successful \e[0m"				| tee -a $name.txt
                else
                        echo -e "USB-HOST Read \e[31m Failure \e[0m"        			| tee -a $name.txt
                fi
fi
if [ $auto == 1 ] || [ $p_no == 8 ]; then
	echo -e "\e[32m Movis Peripherals Test Done \e[0m"					| tee -a $name.txt
	exit
fi
done
