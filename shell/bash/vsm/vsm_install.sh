#!/bin/bash
# Copyright (c) iThinkVirtual 2018-2023
# All rights reserved
#
# vim: tabstop=4 shiftwidth=4
#
#This script downloads and installs the Linux version of VMware Software Manager (LinuxVSM)
#created by, Edward Haletky aka Texiwill, on RHEL, CentOS, Ubuntu, and Debian Linux
#distributions.  It has some added intelligence around what to download along with picking
#up things available but not strictly listed for download.  Bypassing of packages not created
#yet.  It also downloads my vsm_update script and adds it to cron jobs via symbolic
#link for daily updates of aac-base files and LinuxVSM.
#
# Requires:
# dnf wget
#
#
# example: ./vsm_install.sh America/New_York

# on-screen colors
function colorecho() {
# https://tinyurl.com/prompt-color-using-tput
	str=$1
	col=$2
	docol=1
	if [ Z"$2" = Z"" ]
	then
		docol=0
	fi
	if [ $docol -eq 1 ]
	then
		color=`tput setaf $col`
		nc=`tput sgr0`
		echo ${color}${str}${nc}
	else
		echo ${str}
	fi
}

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

function usage() {
	echo "$0 [-h|--help][-u|--user user][timezone]"
}

while [[ $# -gt 0 ]]
do
	key="$1"
	case "$key" in
		-h|--help)
			usage
			exit
			;;
		-u|--user)
			us=$2
			shift
			;;
		*)
			tz=$1
			;;
	esac
	shift
done

us=`id -un`
if [ Z"$us" = Z"root" ]
then
	colorecho "Error: Requires a valid non-root username to execute script." 1
	usage
	exit
fi

theos=''

findos

which dnf >& /dev/null

if [ $? -eq 1 ]
then
	if [ Z"$theos" = Z"centos" ] || [ Z"$theos" = Z"redhat" ] || [ Z"$theos" = Z"fedora" ]
	then
        	sudo yum install -y epel-release dnf && sudo dnf upgrade -y epel-release
	fi
fi

which wget >& /dev/null

if [ $? -eq 1 ]
then
	if [ Z"$theos" = Z"centos" ] || [ Z"$theos" = Z"redhat" ] || [ Z"$theos" = Z"fedora" ]
	then
        	sudo dnf install -y wget
	elif [ Z"$theos" = Z"debian" ] || [ Z"$theos" = Z"ubuntu" ]
	then
        	sudo apt-get install -y wget
	fi
fi

[ ! -d aac-base ] && mkdir -pvm 755 aac-base

cd aac-base

wget -O aac-base.install https://raw.githubusercontent.com/Texiwill/aac-lib/master/base/aac-base.install

chmod +x aac-base.install

if [ Z"$us" != "" ]
then
	sudo ./aac-base.install -u --user $us $tz
	sudo ./aac-base.install -i LinuxVSM --user $us $tz
else
	sudo ./aac-base.install -u $tz
	sudo ./aac-base.install -i LinuxVSM $tz
fi

[ ! -f $HOME/vsm_cron.sh ] && { cat > $HOME/vsm_cron.sh << EOF
#!/bin/bash
# Copyright (c) iThinkVirtual 2018-2023
# All rights reserved
#
#This script gets added to cron.daily and updates the aac-base files and reinstalls the Linux VMware Software Manager
#(LinuxVSM) created by, Edward Haletky aka Texiwill, on RHEL, CentOS, Ubuntu, and Debian Linux
#distributions.

#Kills any running LinuxVSM processes
pkill -9 vsm.sh

#Updates base files and reinstalls LinuxVSM
cd $HOME/aac-base
./aac-base.install -u $tz
./aac-base.install -i LinuxVSM $tz
EOF
} && chmod +x $HOME/vsm_cron.sh

sudo ln -fs $HOME/vsm_cron.sh /etc/cron.daily/vsm_cron.sh

wget -O $HOME/vsm_update.sh https://raw.githubusercontent.com/virtualex-itv/itv-lib/master/shell/bash/vsm/vsm_update.sh && chmod +x $HOME/vsm_update.sh

( crontab -l; echo "0 6 * * * /usr/local/bin/vsm.sh -y -mr --favorite -c" ) | sort - | uniq - | crontab -

clear

colorecho "LinuxVSM is now in $(which vsm.sh) and ready for use. Enjoy! :)" 5
