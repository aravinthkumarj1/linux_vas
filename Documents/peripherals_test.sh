#!/system/bin/sh
## Automation test for Prevas ESIP board
## Status of all the peripherals testing will be dumped to a text file
## CAN test is not added, because of cable unavailability

############# ETHERNET Test ###############################
ifconfig eth0 up
export ethernet=`cat /sys/class/net/eth0/carrier`
if [ $ethernet -eq 1 ]
then
        echo "Ethernet cable connected"
        echo "Starting Ethernet test"
        udhcpc -i eth0
        ping -I eth0 google.com -c 1
        export e_test=`echo $?`
        echo "e_test:"
        echo $e_test
        if [ $e_test -eq 0 ]
        then
                echo "Ethernet test successful" > /TestResults.txt
        else
                echo "Ethernet test not successful" > /TestResults.txt
        fi
else
        echo "Ethernet cable not connected"
fi

############ Audio In Test ################################
export mike=`cat /sys/bus/platform/drivers/imx-wm8962/amic`
echo "mike:"
echo $mike
if [ "$mike" == "amic" ]
then
        echo "Mike connected"                           
        echo "starting Audio in test"
	arecord -D plughw:0,0 -d 10 /unit_tests/test.wav
	export m_test=`echo $?`
        echo "m_test:"
        echo $m_test
        if [ $m_test -eq 0 ]
	then
		echo "Audio in test successful" > /TestResults.txt
	else
		
		echo "Audio in test not successful" > /TestResults.txt
	fi
else
	echo "mike not connected"
fi

############# AUDIO OUT Test ##############################
export Audio=`cat /sys/bus/platform/drivers/imx-wm8962/headphone`
echo "Audio:"
echo $Audio
if [ "$Audio" == "headphone" ]
then
        echo "Headphone connected"                           
        echo "starting Audio out test"
	aplay -D plughw:0,0 /unit_tests/test.wav
        export a_test=`echo $?`
        echo "a_test:"
        echo $a_test
        if [ $a_test -eq 0 ]
	then
		echo "Audio test successful" > /TestResults.txt
	else
		
		echo "Audio test not successful" > /TestResults.txt
	fi
else
	echo "Headphone not connected"
fi

############# HDMI Test ###################################
export HDMI=`cat /sys/devices/platform/mxc_hdmi/cable_state`
echo "HDMI:"
echo $HDMI
if [ "$HDMI" == "plugin" ]
then
	echo "HDMI cable connected"
	echo "starting HDMI test"
	cat /iwtest/1080p1.bin > /dev/fb0
	export h_test=`echo $?`
	echo "h_test:"
	echo $h_test
	if [ $h_test -eq 0 ]
	then
		echo "HDMI test successful" > /TestResults.txt
	else
		echo "HDMI test not successful" > /TestResults.txt
	fi
else
	echo "HDMI cable not connected"
fi

############# LVDS LCD Test ###############################
echo "starting LVDS LCD test"
cat /iwtest/LCD.bin > /dev/fb1
export l_test=`echo $?`
echo "l_test:"
echo $l_test
if [ $l_test -eq 0 ]
then
	echo "HDMI test successful" > /TestResults.txt
else
	echo "HDMI test not successful" > /TestResults.txt
fi

############ USB-OTG Host Test ############################
export USB=`cat /sys/bus/usb/devices/usb1/power/runtime_status`
echo "USB:"
echo $USB
if [ "$USB" == "active" ]
then
	echo "USB-Pendrive connected"
	[ -f /mnt/usb ] && echo "Found" || mkdir /mnt/usb
	mount /dev/sda1 /mnt/usb
	echo "starting USB-Pendrive file copy"
	cp /TestResults.txt /mnt/usb/
	export usb_write_test=`echo $?`
	echo "usb_write_test:"
	echo $usb_write_test
	if [ $usb_write_test -eq 0 ]
	then
		 echo "usb Write Successful"
	else
		echo " usb Write not success"
	fi
	cp /mnt/usb/TestResults.txt /TestResults.txt
	export usb_read_test=`echo $?`
	echo "usb_read_test:"
	echo $usb_read_test
	if [ $usb_read_test -eq 0 ]
	then
		 echo "usb Read Successful"
	else
		echo " usb Read not success"
	fi
else
	echo "USB-Pendrive not connected"
fi

############ USB Host Test ################################
export USB=`cat /sys/bus/usb/devices/usb1/power/runtime_status`
echo "USB:"
echo $USB
if [ "$USB" == "active" ]
then
	echo "Pendrive connected in Host port"
	[ -f /mnt/udisk ] && echo "Found" || mkdir /mnt/udisk
	mount /dev/sda1 /mnt/udisk
	echo "starting USB-Pendrive file copy"
	cp /TestResults.txt /mnt/udisk/
	export usb_write_test=`echo $?`
	echo "usb_write_test:"
	echo $usb_write_test
	if [ $usb_write_test -eq 0 ]
	then
		 echo "usb host Write Successful"
	else
		echo " usb host Write Failure"
	fi
	cp /mnt/udisk/TestResults.txt /TestResults.txt
	export usb_read_test=`echo $?`
	echo "usb_read_test:"
	echo $usb_read_test
	if [ $usb_read_test -eq 0 ]
	then
		 echo "usb host Read Successful"
	else
		echo " usb host Read Failure"
	fi
else
	echo "Pendrive not connected in Host port"
fi

############ SATA Test ####################################
[ -f /mnt/sata ] && echo "Found" || mkdir /mnt/sata
mount /dev/ /mnt/sata #### Need to fill the mountpoint
echo "starting SATA file copy"
cp /TestResults.txt /mnt/sata/
export sata_write_test=`echo $?`
echo "sata_write_test:"
echo $sata_write_test
if [ $sata_write_test -eq 0 ]
then
	 echo "SATA Write Successful"
else
	 echo "SATA Write Failure"
fi
cp /mnt/sata/TestResults.txt /TestResults.txt
export sata_read_test=`echo $?`
echo "sata_read_test:"
echo $sata_read_test
if [ $sata_read_test -eq 0 ]
then
	 echo "SATA Read Successful"
else
	echo " SATA Read Failure"
fi

############ eMMC Test ####################################
echo "starting eMMC file copy"
touch /emmc_test.txt
export emmc_write_test=`echo $?`
echo "emmc_write_test:"
echo $emmc_write_test
if [ $emmc_write_test -eq 0 ]
then
	 echo "eMMC Write Successful"
else
	 echo "eMMC Write Failure"
fi
cp /emmc_test.txt /emmc_test_copy.txt
export emmc_read_test=`echo $?`
echo "emmc_read_test:"
echo $emmc_read_test
if [ $emmc_read_test -eq 0 ]
then
	 echo "eMMC Read Successful"
else
	echo " eMMC Read Failure"
fi

############ Wi-Fi PCI Test ###############################
echo "Starting Wi-Fi-PCI test"
ifconfig wlan0 up
udhcpc -i wlan0
ping -I wlan0 google.com -c 1
export w_test=`echo $?`
echo "w_test:"
echo $w_test
if [ $w_test -eq 0 ]
then
        echo "WiFi test successful" > /TestResults.txt
else
        echo "WiFi test not successful" > /TestResults.txt
fi

############ USB-OTG Device Test ##########################
export OTG=`cat /sys/devices/platform/fsl-ehci.0/usb1/power/runtime_status`
echo "OTG:"
echo $OTG
if [ "$USB" == "active" ]
then
	echo "USB-OTG cable connected"
	echo "starting USB-OTG test"
	insmod /iwtest/g_file_storage.ko file=/dev/mmcblk1p1 removable=1
	export o_test=`echo $?`
if [ "$OTG" == "active" ]
	echo "o_test:"
	echo $o_test
	if [ $o_test -eq 0 ]
	then
		echo "USB-OTG test successful" > /TestResults.txt
	else
		echo "USB-OTG test not successful" > /TestResults.txt
	fi 
else
	echo "USB-OTG cable not connected"
fi

############ CAN Test #####################################
export CAN=`cat /proc/3243/net/dev`
echo "Starting CAN test"
#### Will be tested directly in Movis Board

# bitrate can be 33.333 kbps, 83.333 kbps, 100 kbps, 125 kbps, 250 kbps and 500kbps
# ip link set <CAN_DEVICE> up type can bitrate 250
# cantest <candev_no>
# cantest <candev_no> 123#AABBCCDD
