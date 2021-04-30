#!/bin/bash
clear
#Make sure script has root privileges:
if [ `id -u` = 0 ]
then
    printf '\033[1;32mWelcome to server setup.\n'
else
    printf '\033[1;31mYou need to execute this program as root.\033[0m\n'
    exit 1
fi

#Begin by updating:
printf "\033[1;32mLets go!\n\033[1;31mYou should not stop this process once it is running.\nUpdate:\n\033[0m\n"
apt update

#Add new main account:
printf "\n\033[1;32mFirst, we will add the new users.\nWhats your name? (name):\033[0m"
read name
printf "\033[1;33mChoose a safe password!\n\033[0m\n"
adduser $name
adduser $name adm
adduser $name dialout
adduser $name cdrom
adduser $name floppy
adduser $name sudo
adduser $name audio
adduser $name dip
adduser $name video
adduser $name plugdev
adduser $name netdev
adduser $name lxd
id $name
printf "\n"

#Add other users:
printf "\033[1;32mDo you want to add another user? (y/n):\033[0m"
read newuser
while [ "$newuser" = "y" ]
do
    printf "\033[1;32mWhats his name? (name):\033[0m"
    read newname
    printf "\n"
    adduser $newname
    id $newname
    printf "\n"

    printf "\033[1;32mDo you want to add $newname to following recommended groups?\ndialout\naudio\nplugdev\n(y/n):\033[0m"
    read newgroup
    if [ "$newgroup" = "y" ]
    then
        printf "\n"
        adduser $newname dialout
        adduser $newname audio
        adduser $newname plugdev
        id $newname
        printf "\n"
    fi
    printf "\033[1;32mDo you want to add another user? (y/n):\033[0m"
    read newuser
done

#Add guest:
printf "\033[1;32mDo you want to add a guest user? (y/n):\033[0m"
read guestuser
if [ "$guestuser" = "y" ]
then
    printf "\n"
    adduser guest --gecos ""
    id guest
    printf "\n"
fi

#Delete old ubuntu user:
printf "\033[1;32mDo you want to delete the old \"ubuntu\" user? (y/n):\033[0m"
read olduser
if [ "$olduser" = "y" ]
then
    printf "\n"
    deluser ubuntu
    id ubuntu
    printf "\n"
fi

#Rename machine:
printf "\033[1;32mRename machine? (y/n):\033[0m"
read rena
if [ "$rena" = "y" ]
then
    printf "\033[1;32mNew Name: (name):\033[0m"
    read nameo
    printf "\nWriting to /etc/hosts:\n"
    sed -i "2i\127.0.0.1 $nameo" /etc/hosts
    printf "Writing to /etc/hostname:\n"
    echo "$nameo" > /etc/hostname
    hostname -F /etc/hostname
    printf "\n"
fi

#Setup ssh:
printf "\033[1;32mDo you want to setup ssh? (y/n):\033[0m"
read sssh
if [ "$sssh" = "y" ]
then
    printf "\033[1;32mSet new banner? (y/n):\033[0m"
    read sshban
    if [ "$sshban" = "y" ]
    then
        ban1="Welcome on the SFVM Assistance Server!"
        ban2="Support is provided by EliServices (eliservices.server@gmail.com)."
        printf "\nWriting to /etc/banner:\n"
        echo "$ban1" > /etc/banner
        echo "$ban2" >> /etc/banner
        printf "Finished\n\n"
    fi

    printf "\033[1;32mOverwrite sshd_config? (y/n):\033[0m"
    read ssshd
    if [ "$ssshd" = "y" ]
    then
        sshpath="/etc/ssh/sshd_config"
        printf "\nWriting to $sshpath:\n"
        echo "Include /etc/ssh/sshd_config.d/*.conf" > $sshpath
        echo "Port 37597" >> $sshpath
        echo "MaxAuthTries 1" >> $sshpath
        echo "MaxSessions 5" >> $sshpath
        echo "PermitRootLogin yes" >> $sshpath
        echo "AllowUsers $name" >> $sshpath
        echo "PasswordAuthentication yes" >> $sshpath
        echo "ChallengeResponseAuthentication no" >> $sshpath
        echo "UsePAM yes" >> $sshpath
        echo "X11Forwarding yes" >> $sshpath
        echo "PrintMotd no" >> $sshpath
        echo "MaxStartups 10:30:60" >> $sshpath
        echo "Banner /etc/banner" >> $sshpath
        echo "AcceptEnv LANG LC_*" >> $sshpath
        echo "Subsystem sftp  /usr/lib/openssh/sftp-server" >> $sshpath
        printf "Finished\n\n"
    fi
fi

#Install recommended packages:
printf "\033[1;32mDo you wish to install the following recommended packages?\n"
printf "tree\n"
printf "fail2ban\n"
printf "python3-pip\n"
printf "(y/n)\033[0m:"
read installnew1
if [ "$installnew1" = "y" ]
then
    printf "\033[1;33mPlease confirm if necessary!\033[0m\n\n"
    apt install tree fail2ban python3-pip
    printf "\n"
fi

printf "\033[1;32mDo you wish to install the following recommended packages for python dev?\n"
printf "build-essential\n"
printf "libssl-dev\n"
printf "libffi-dev\n"
printf "python3-dev\n"
printf "python3-venv\n"
printf "wheel & twine (via pip3)"
printf "(y/n):\033[0m"
read installnew2
if [ "$installnew2" = "y" ]
then
    printf "\033[1;33mPlease confirm if necessary!\033[0m\n\n"
    apt install build-essential libssl-dev libffi-dev python3-dev python3-venv
    pip3 install wheel
    pip3 install twine
    printf "\n"
fi

#Create virtual environment:
printf "\033[1;32mDo you want to create a virtual environment in your home folder?\n"
printf "(y/n):\033[0m"
read pyvenv
if [ "$pyvenv" = "y" ]
then
    printf "\n"
    mkdir /home/$name/pyvenv/
    cd /home/$name/pyvenv/
    mkdir ./projects/
    python3 -m venv virtual
    printf "\n"

    printf "\033[1;32mDo you want to write supportive activate / deactivate scripts?\n"
    printf "(y/n):\033[0m"
    read supscri
    if [ "$supscri" = "y" ]
    then
        printf "\n"
        cd /home/$name/
        touch ./activate.sh
        printf "cd /home/$name/pyvenv/\nsource ./bin/activate\necho \"Welcome\"\necho \"If you want to get to the libs, run:\"\necho \"cd ./lib/python3.8/site-packages/GA/\"\n" > ./activate.sh
        touch ./deactivate.sh
        printf "cd /home/$name/\ndeactivate\necho \"Goodbye\"\n" > ./deactivate.sh
        ln -s /home/$name/deactivate.sh /home/$name/pyvenv/deactivate.sh
        printf "\n"
    fi

    printf "\033[1;32mDo you want to import project GA?\n"
    printf "(y/n):\033[0m"
    read impga
    if [ "$impga" = "y" ]
    then
       printf "\n"
       cd /home/$name/pyvenv/projects/
       git clone https://github.com/EliServices/GA.git
       printf "\n"
    fi
    cd
fi

#Update:
printf "\033[1;32mDo you want to update & upgrade your system now?\n"
printf "(y/n):\033[0m"
read grade
if [ "$grade" = "y" ]
then
    printf "\033[1;33mPlease confirm if necessary.\n\033[0m\n"
    apt update
    apt upgrade
    printf "\n"
fi

printf "\033[1;32mDone.\033[0m\n"

#Reboot:
printf "\033[1;32mReboot?\n"
printf "(y/n):\033[0m"
read reb
if [ "$reb" = "y" ]
then
    printf "\n"
    reboot now
fi
