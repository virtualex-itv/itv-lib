#!/bin/bash
# Copyright (c) iThinkVirtual 2018
# All rights reserved
#
#This script downloads and installs the Linux verison of VMware Software Manager (VSM)
#created by, Edward Haletky aka Texiwill, on RHEL, CentOS, Ubuntu, and Debian Linux
#distributions.  It has some added intelligence around what to download along with picking
#up thingsavailable but not strictly listed for download.  Bypassing of packages not created
#yet.  It also downloads my vsm_update script and adds it to cron jobs via symbolic
#link for daily updates of aac-base files and vsm.
#
# Requires:
# wget
#
# vim: tabstop=4 shiftwidth=4
#
# example: ./vsm_install.sh America/New_York

function findos() {
	if [ -e /etc/os-release ]
	then
		. /etc/os-release
		theos=`echo $ID | tr [:upper:] [:lower:]`
	elif [ -e /etc/centos-release ]
	then
		theos=`cut -d' ' -f1 < /etc/centos-release | tr [:upper:] [:lower:]`
	elif [ -e /etc/redhat-release ]
	then
		theos=`cut -d' ' -f1 < /etc/redhat-release | tr [:upper:] [:lower:]`
	elif [ -e /etc/fedora-release ]
	then
		theos=`cut -d' ' -f1 < /etc/fedora-release | tr [:upper:] [:lower:]`
	elif [ -e /etc/debian-release ]
	then
		theos=`cut -d' ' -f1 < /etc/debian-release | tr [:upper:] [:lower:]`
	else
		colorecho "Do not know this operating system. LinuxVSM may not work." 1
		theos="unknown"
	fi
}

theos=''

findos

which wget >& /dev/null

if [ $? -eq 1 ]
then
	if [ Z"$theos" = Z"centos" ] || [ Z"$theos" = Z"redhat" ] || [ Z"$theos" = Z"fedora" ]
	then
        	sudo yum install -y wget
	elif [ Z"$theos" = Z"debian" ] || [ Z"$theos" = Z"ubuntu" ]
	then
        	sudo apt-get install -y wget
	fi
fi

[ ! -d aac-base ] && mkdir -pvm 755 aac-base

cd aac-base

wget -O aac-base.install https://raw.githubusercontent.com/Texiwill/aac-lib/master/base/aac-base.install

chmod +x aac-base.install

./aac-base.install -u $1
sudo ./aac-base.install -i vsm $1

[ ! -f $HOME/vsm_cron.sh ] && { cat > $HOME/vsm_cron.sh << EOF
#!/bin/bash
# Copyright (c) iThinkVirtual 2018
# All rights reserved
#
#This script gets added to cron.daily and updates the aac-base files and reinstalls the Linux VMware Software Manager
#(VSM) created by, Edward Haletky aka Texiwill, on RHEL, CentOS, Ubuntu, and Debian Linux
#distributions.

#Kills any running vsm processes
pkill -9 vsm

#Updates base files and reinstalls VSM
cd $HOME/aac-base; ./aac-base.install -u $1; ./aac-base.install -i vsm $1
EOF
} && chmod +x $HOME/vsm_cron.sh

sudo ln -fs $PWD/vsm_cron.sh /etc/cron.daily/vsm_cron.sh

wget -O $HOME/vsm_update.sh https://raw.githubusercontent.com/virtualex-itv/itv-lib/master/shell/bash/vsm/vsm_update.sh && chmod +x $HOME/vsm_update.sh

( crontab -l; echo "0 6 * * * /usr/local/bin/vsm.sh -y -mr --favorite -c" ) | sort - | uniq - | crontab -

clear

bold=`tput bold`
blink=`tput blink`
magenta=`tput setaf 5`
nc=`tput sgr0`

echo "${magenta}VSM is now in /usr/local/bin/vsm.sh and ready for use. Enjoy! :)${nc}"
echo ""
