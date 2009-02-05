#!/bin/bash
trap "" 2 3
HOME=/pulsarroot/bin/setup

displayHeader()
{
echo " ###################################################################"
echo " #                Pulsar OS Installer Main Menu                    #"
echo " #                                                                 #"
echo " #                           Options:                              #"
echo " #                                                                 #"
echo " #                   1. Copy OS to harddisk                        #"
echo " #                                                                 #"
echo " #                   2. Configure OS                               #"
echo " #                                                                 #"
echo " #                   3. Reboot System                              #"
echo " #                                                                 #"
echo " #                   0. Exit to command line                       #"
echo " #                                                                 #"
echo " ###################################################################"
}

Main_Menu()
{
        displayHeader
        printf "Enter option: "
        read OPT1
        case $OPT1 in
                        1)
                                copy_os;;
			2)
				config_os;;
                        3)
                                clear; init 6;;
			0)
                                clear; exit 0;;	
                        *)
                                Menu_Error;;
        esac
}

get_installer()
{
        if [ $mount == 0 ]; then
          if [ `iostat -Enx $i|grep CD|wc -l|awk '{print $1}'` == 1 ]; then
            mount -F hsfs /dev/dsk/${i}s0 /mnt
            if [ -f /mnt/.pulsarinstall ]; then
              mount=1
            else
              umount /mnt
            fi
          else
            if [ `mkfs -m /dev/rdsk/${i}s0|grep ufs|wc -l|awk '{print $1}'` == 1 ]; then
              mount /dev/dsk/${i}s0 /mnt
              if [ -f /mnt/.pulsarinstall ]; then
                mount=1
              else
                umount /mnt
              fi
            fi
          fi
        fi
}

check_dir()
{
        if [ ! -d ${1} ]; then
	  mkdir ${1}
	fi
}

copy_os()
{
        # Variables for this function
        number=1
        mount=0
        # ===========================
	devfsadm
        clear
	printf "Choose the disk to install the os\n"
	for i in `iostat -xn|awk '{print $11}'|egrep \^c`; do
	  disk[$number]=$i
	  get_installer $i
	  size=`iostat -En $i|grep Size|awk '{print $9}'`
	  printf "\n $number.) Disk: $i Size: $size"
	  number=`expr $number + 1`
	done
	printf "\n\nEnter option: "
        read OPT1
	printf "All data on disk /dev/dsk/${disk[$OPT1]} will be destroyed - ready (y/n)"
	read OPT2
	if [ $OPT2 == "n" ]; then
	 clear
	 Main_Menu
	fi
	# prepare choosen disk
	printf "\n\n1. Prepare disk for installation\n\n"
	rdisk=/dev/rdsk/${disk[$OPT1]}
	disk=/dev/dsk/${disk[$OPT1]}
	fdisk -B ${rdisk}p0 >/dev/null 2>&1
	format -f $HOME/format.cmd ${rdisk}s2 >/dev/null 2>&1
	yes | newfs ${rdisk}s0 >/dev/null 2>&1
	yes | newfs ${rdisk}s1 >/dev/null 2>&1
	check_dir "/coreboot"
	# install os to disk
	printf "\n\n2. Install OS to disk (This takes some time - grab a coffee)\n\n"
	mount ${disk}s0 /coreboot
	cp -rp /pulsarroot/bin /pulsarroot/plugins /coreboot/
	mkdir /coreboot/boot
	cp -rp /mnt/boot/grub /mnt/boot/platform /coreboot/boot/
	# create os image
	check_dir "/pulsarimage"
	mkfile 55m /coreboot/boot/os
	lofiadm -a /coreboot/boot/os > /dev/null 2>&1
	yes | newfs -m 0 /dev/rlofi/1 >/dev/null 2>&1
	mount /dev/lofi/1 /pulsarimage
	cd /pulsarimage && tar -xpf /mnt/miniroot.tar . 
	cd / && tar cf - lib sbin kernel platform | ( cd /pulsarimage && tar xpf - ) 
	mkdir /pulsarimage/usr
	check_dir "/pulsar_usr"
	mount ${disk}s1 /pulsar_usr
	cd /usr && tar cf - . | ( cd /pulsar_usr && tar xpf - )
	# install grub on disk
	printf "3. Make disk bootable\n\n"
	yes | installgrub -m /coreboot/boot/grub/stage1 /coreboot/boot/grub/stage2 ${rdisk}s0 >/dev/null 2>&1
	umount /pulsar_usr
	umount /pulsarimage
	umount /mnt
	lofiadm -d /dev/lofi/1
	gzip -9 /coreboot/boot/os
	touch /coreboot/.installed
        printf "Pulsar OS Installed - Press Return to Continue... "
        read JUNK
        clear
	config_os
}

config_os()
{
        # Variables for this function
        number=1
        # ===========================
	if [ ! -f /coreboot/.installed ]; then
 	  printf "Pulsar os not installed, please install the os first! - Press Return to Continue... "
	  read JUNK
	  clear
	  Main_Menu	
	fi
	if [ -f /tmp/os ]; then
	  lofiadm -d /tmp/os
	  rm /tmp/os
	fi
	cp /coreboot/boot/os.gz /tmp
	gzip -d /tmp/os.gz
	lofiadm -a /tmp/os
	clear
	# mount the boot image for changes
	mount /dev/lofi/1 /mnt
	# create customized filesystem entries
	cp $HOME/vfstab $HOME/vfstab.work
 	echo "${disk}s1 ${disk}s1 /usr ufs - no nologging" >> $HOME/vfstab.work
	echo "${disk}s0 ${disk}s0 /pulsarroot ufs - yes nologging" >> $HOME/vfstab.work
	cp $HOME/vfstab.work /mnt/etc/vfstab
	rm $HOME/vfstab.work
	# create hostid file
	/usr/bin/hostid > /mnt/etc/hostid
	printf "Pulsar OS network configuration ...\n"
	printf "Select the interface you want to configure for pulsar os:"
	for i in `dladm show-phys|tail -1|awk '{print $1}'`; do
	  nwcard[$number]=$i
	  printf "\n $number.) Interface: $i"
	  number=`expr $number + 1`
	done
        if [ $i == "" ]; then
	  printf "No Interface found!"
	else
	  printf "\n\nEnter option: "
	  read OPT1
          lettercheck=`expr match $OPT1 '[0-9]*$'`
	  if [ $lettercheck == 0 ]; then
	    printf "Only numbers are allowed! - - Press Return to Continue... "
 	    read JUNK
	    clear
	    config_os
	  fi
	  interface=$OPT1
	  printf "Use DHCP to configure the interface? (y/n)"
	  read OPT2
	  if [ $OPT2 == "n" ]; then
	    printf "Enter IP address: "
	    read OPT3
	    printf "Enter netmask: "
	    read OPT4
	    printf "Enter default gateway: "
	    read OPT5
	    printf "Enter hostname: "
	    read OPT6
	    printf "Enter DNS server: "
	    read OPT7
	    echo "$OPT3 $OPT6" >> /mnt/etc/hosts
	    echo $OPT4 >> /mnt/etc/netmasks
	    echo $OPT5 > /mnt/etc/defaultrouter
	    echo $OPT6 > /mnt/etc/hostname.${interface}
	    echo $OPT6 > /mnt/etc/hostname.${nwcard[$OPT1]}
	    echo $OPT6 > /mnt/etc/nodename
	    echo $OPT7 > /mnt/etc/resolv.conf
	    cp /root/scripts/nsswitch.conf /mnt/etc/nsswitch.conf
	  elif [ $OPT2 == "y" ]; then
	    printf "Enter Hostname: "
	    read OPT3
	    if [ -f dhcp.* ]; then
	      rm /mnt/etc/dhcp.*
	    fi
	    echo "" > /mnt/etc/dhcp.${nwcard[$OPT1]}
	    if [ -f /mnt/etc/hostname.* ]; then
	      rm /mnt/etc/hostname.*
	    fi
	    echo "" > /mnt/etc/hostname.${nwcard[$OPT1]}
	    echo $OPT3 > /mnt/etc/nodename
	  else
	    printf "Wrong syntax! Only (y/n) is allowed! - Press Return to Continue... "
	    read JUNK
	    clear
	    config_os
	  fi
	fi
	umount /mnt
	lofiadm -d /tmp/os
	gzip /tmp/os
	cp /tmp/os.gz /coreboot/boot
	umount /coreboot
	clear
	printf "You are now ready to reboot the system. Please eject your cdrom or usb stick after reboot! Do you realy want to reboot the system now? (y/n)"
	read OPT1
	if [ $OPT1 == "n" ]; then
	  Main_Menu
	else 
	  /usr/sbin/init 6  
        fi
}

Menu_Error()
{
        echo "\n\nOption $OPT1 is Invalid."
        echo "Please Enter a Valid Option.\n\n"
        printf "Press Return to Continue... "
        read JUNK
        clear
        Main_Menu
}

###########################
#Actual script begins here
###########################

clear
Main_Menu