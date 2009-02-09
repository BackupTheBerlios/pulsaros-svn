#!/bin/bash
trap "" 2 3
HOME=/pulsarroot/bin/setup

post_cleanup()
{
  if [ `df -k|awk '/\/mnt$/ { print $6 }'|wc -l` == 1 ]; then
    /usr/sbin/umount /mnt
  fi
  if [ `lofiadm |wc -l` -gt 1 ]; then
   lofiadm -d /dev/lofi/1
  fi
  if [ -f /tmp/os ]; then
    rm /tmp/os
  fi
}

check_input()
{
  function=$2
  input=$4
  item=$3 
  if [ $input != "" ]; then
    case $1 in
      number)
        lettercheck=`expr match $input '[0-9]*$'`
        if [ $lettercheck != 1 ]; then
          printf "Only numbers are allowed! - Press Return to Continue... "
          read JUNK
          clear
	  post_cleanup
	  $function
        elif [ $input -gt $item ]; then
          printf "Choice doesn't exist! - Press Return to Continue... "
          read JUNK
          clear
	  post_cleanup
	  $function
        fi
        ;;
      *)
        printf "Interface error! - Please inform the developers!"
        ;;
    esac
  else
    printf "Choice doesn't exist! - Press Return to Continue... "
    read JUNK
    clear
    post_cleanup
    $function
  fi
}

displayHeader()
{
  create_line full
  printf " #\t\t\tPulsar OS Installer Main Menu\t\t\t#\n"
  create_line space
  create_line space
  printf " #\t\t\t1. Copy OS to harddisk\t\t\t\t#\n"
  create_line space
  printf " #\t\t\t2. Reboot System\t\t\t\t#\n"
  create_line space
  printf " #\t\t\t0. Exit to command line\t\t\t\t#\n"
  create_line space
  create_line full
}

Main_Menu()
{
  post_cleanup
  displayHeader
  printf "\nEnter option: "
  read OPT1
  case $OPT1 in
    1)
      copy_os;;
    2)
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

create_line()
{
  if [ $1 == "full" ]; then
    echo " ########################################################################"
  else
    printf " #\t\t\t\t\t\t\t\t\t#\n"
  fi
}

copy_os()
{
  # Variables for this function
  number=0
  mount=0
  # ===========================
  devfsadm
  clear
  create_line full
  printf " #\t\tChoose the disk to install the os\t\t\t#\n"
  create_line space
  for i in `iostat -xn|awk '{print $11}'|egrep \^c`; do
    number=`expr $number + 1` 
    disk[$number]=$i
    get_installer $i
    if [ `iostat -En $i|grep -c Model` == 1 ]; then
      size=`iostat -En $i|awk '/Size/ {print $9}'`
    else 
      size=`iostat -En $i|awk '/Size/ {print $2}'`
    fi
    # do not print out the pulsar installer
    if [ $mount == 0 ]; then
      create_line space
      printf " #\t\t$number.)\tDisk: $i\tSize: $size\t\t\t#\n"
    else 
      number=`expr $number - 1`
    fi
  done
  create_line space
  create_line space
  create_line full
  printf "\nEnter option: "
  read OPT1
  check_input number copy_os $number $OPT1
  printf "\nAll data on disk /dev/dsk/${disk[$OPT1]} will be destroyed - ready (y/n)"
  read OPT2
  if [ $OPT2 == "n" ]; then
     clear
     post_cleanup
     Main_Menu
  elif [ $OPT2 == "y" ]; then
    # prepare choosen disk
    printf "\n1. Prepare disk for installation\n"
    rdisk=/dev/rdsk/${disk[$OPT1]}
    disk=/dev/dsk/${disk[$OPT1]}
    fdisk -B ${rdisk}p0 >/dev/null 2>&1
    format -f $HOME/format.cmd ${rdisk}s2 >/dev/null 2>&1
    yes | newfs ${rdisk}s0 >/dev/null 2>&1
    yes | newfs ${rdisk}s1 >/dev/null 2>&1
    check_dir "/coreboot"
    # install os to disk
    printf "2. Install OS to disk (This takes some time - grab a coffee)\n"
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
    printf "3. Make disk bootable\n"
    yes | installgrub -m /coreboot/boot/grub/stage1 /coreboot/boot/grub/stage2 ${rdisk}s0 >/dev/null 2>&1
    umount /pulsar_usr && umount /pulsarimage && umount /mnt
    lofiadm -d /dev/lofi/1
    gzip -9 /coreboot/boot/os
    touch /coreboot/.installed
    printf "\nPulsar OS Installed - Press Return to Continue... "
    read JUNK
    clear
    config_os
  else
    printf "Wrong syntax! Only (y/n) is allowed! - Press Return to Continue... "
    read JUNK
    clear
    post_cleanup
    Main_Menu 
  fi
}

config_os()
{
  # Variables for this function
  number=0
  # ===========================
  if [ ! -f /coreboot/.installed ]; then
    printf "Pulsar os not installed, please install the os first! - Press Return to Continue... "
    read JUNK
    clear
    post_cleanup
    Main_Menu	
  fi
  cp /coreboot/boot/os.gz /tmp
  gzip -d /tmp/os.gz
  lofiadm -a /tmp/os > /dev/null 2>&1
  clear
  # mount the boot image for changes
  mount /dev/lofi/1 /mnt
  # create customized filesystem entries
  cp $HOME/vfstab $HOME/vfstab.work
  echo "${disk}s1 ${disk}s1 /usr ufs - no nologging" >> $HOME/vfstab.work
  echo "${disk}s0 ${disk}s0 /pulsarroot ufs - yes nologging" >> $HOME/vfstab.work
  cp $HOME/vfstab.work /mnt/etc/vfstab
  rm $HOME/vfstab.work
  cp $HOME/.profile /mnt/root/
  # create hostid file
  /usr/bin/hostid > /mnt/etc/hostid
  create_line full
  printf " #\t\t\tPulsar OS network configuration ...\t\t#\n"
  create_line space
  printf " #\tSelect the interface you want to configure for pulsar os:\t#\n"
  create_line space
  for i in `dladm show-phys|tail -1|awk '{print $1}'`; do
    number=`expr $number + 1`
    nwcard[$number]=$i
    printf " #\t\t\t$number.) Interface: $i\t\t\t\t#\n"
  done
  if [ $i == "" ]; then
    printf " #\t\t\t\tNo Interface found!\t\t\t#\n"
  else
    create_line space
    create_line full
    printf "\nEnter option: "
    read OPT1
    check_input number config_os $number $OPT1
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
      echo "" > /mnt/etc/dhcp.${nwcard[$OPT1]}
      if [ -f /mnt/etc/hostname.* ]; then
        rm /mnt/etc/hostname.*
      fi
      echo "" > /mnt/etc/hostname.${nwcard[$OPT1]}
      echo $OPT3 > /mnt/etc/nodename
    fi
    else
      printf "Wrong syntax! Only (y/n) is allowed! - Press Return to Continue... "
      read JUNK
      clear
      post_cleanup
      config_os
    fi
  fi
  umount /mnt
  lofiadm -d /tmp/os
  gzip /tmp/os
  cp /tmp/os.gz /coreboot/boot
  umount /coreboot
  printf "\nInstallation ready! Please eject your cdrom or usb stick after reboot!\n"
  printf "Do you really want to reboot the system now? (y/n)"
  read OPT1
  if [ $OPT1 == "n" ]; then
    clear
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
