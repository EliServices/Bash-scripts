#!/bin/bash

#Make sure script has root privileges:
if [ `id -u` = 0 ]
then
    printf '\033[1;32mWelcome to backup.sh\033[0m\n'
else
    printf '\033[1;31mYou need to execute this program with root privileges.\033[0m\n'
    exit 1
fi

#User has to search his device manually:
blk=$(lsblk)
printf "$blk\n\n\033[1;32m/dev/? (sda1/sdb1/...): \033[0m"
read dev

#Mounting the device:
path="/dev/$dev"
printf "\033[1;32m$path -> /media/usb\n"
mount $path /media/usb

#Copying the files (replace with your paths):
printf "Copying"
cp ./lib/python3.8/site-packages/ground_assistant/__init__.py /media/usb/data/GA_daemon/lib/__init__.py
printf "."
cp ./lib/python3.8/site-packages/ground_assistant/main.py /media/usb/data/GA_daemon/lib/main.py
printf "."
cp ./lib/python3.8/site-packages/ground_assistant/load.py /media/usb/data/GA_daemon/lib/load.py
printf "."
cp ./lib/python3.8/site-packages/ground_assistant/data.py /media/usb/data/GA_daemon/lib/data.py
printf "."
cp ./lib/python3.8/site-packages/ground_assistant/utils.py /media/usb/data/GA_daemon/lib/utils.py
printf "."
cp ./backup.sh /media/usb/data/Bash/backup.sh
printf ".\n"

#Unmounting the device:
printf "Unmounting\n"
umount /media/usb
printf "Done.\n\033[0m"
