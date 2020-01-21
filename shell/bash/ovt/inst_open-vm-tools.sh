#!/bin/bash
# Copyright (c) Alex Lopez 2019
# All rights reserved
# vim: tabstop=4 shiftwidth=4
#
# An installer script for open-vm-tools
#
# Note: place script in users $HOME dir and make it executable
#
# Requires:
# vmtoolsd wget
#
# example: ./inst_open-vm-tools.sh

build="11.0.5"
latestovt="open-vm-tools-11.0.5-15389592"

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
        echo -e "${color}${str}${nc}\n"
    else
        echo ${str}
    fi
}

# find operating systems
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
		colorecho "Do not know this operating system. Install may not work." 1
		theos="unknown"
	fi
}

doit=1
if [ Z"$us" != Z"" ]
then
	grep ${us}: /etc/passwd >& /dev/null
	if [ $? -ne 0 ]
	then
		doit=0
	fi
else
	# are we root?
	us=`id -u`
	if [ $us -eq 0 ]
	then
		doit=0
	else
		doit=1
	fi
fi

if [ $doit -eq 0 ] || [ Z"$us" = Z"root" ]
then
	colorecho "Error: Requires a valid non-root username to execute script." 1
	exit
fi

theos=''

findos

if [ Z"$theos" = Z"centos" ] || [ Z"$theos" = Z"redhat" ] || [ Z"$theos" = Z"fedora" ]
then
		which vmtoolsd >& /dev/null

		if [ $? -eq 1 ]
		then
				sudo yum update -y && sudo yum upgrade -y && sudo autoremove -y && sudo yum cleanall
				sudo yum install -y open-vm-tools
		fi

		which wget >& /dev/null
		
		if [ $? -eq 1 ]
		then
				sudo yum update -y && sudo yum upgrade -y && sudo autoremove -y && sudo yum cleanall
				sudo yum install -y wget
		fi

		sudo yum update -y && sudo yum upgrade -y && sudo autoremove -y && sudo yum cleanall
		sudo yum install -y yum-utils && sudo yum-builddep -y open-vm-tools
		sudo yum -y install gcc libmspack-devel gtk3-devel gtkmm30-devel
		cd /tmp
		sudo wget -O $latestovt.tar.gz https://github.com/vmware/open-vm-tools/releases/download/stable-$build/$latestovt.tar.gz
		sudo tar -zxvf $latestovt.tar.gz
		cd $latestovt
		sudo ./configure --without-ssl
		sudo make
		sudo make install
		
		clear
		
		colorecho "open-vm-tools has been installed." 2
		colorecho "Please reboot for changes to take effect." 3

elif [ Z"$theos" = Z"debian" ] || [ Z"$theos" = Z"ubuntu" ]
then
		which vmtoolsd >& /dev/null

		if [ $? -eq 1 ]
		then
				sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
				sudo apt install -y open-vm-tools
		fi

		which wget >& /dev/null

		if [ $? -eq 1 ]
		then
				sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
				sudo apt install -y wget
		fi

		sudo apt-add-repository -s 'deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted'
		sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
		sudo apt build-dep -y open-vm-tools
		sudo apt install -y gcc libmspack-dev libgtk-3-dev libgtkmm-3.0-dev
		sudo apt update -y && apt upgrade --fix-missing -y && apt autoremove -y && apt autoclean -y
		cd /tmp
		sudo wget -O $latestovt.tar.gz https://github.com/vmware/open-vm-tools/releases/download/stable-$build/$latestovt.tar.gz
		sudo tar -zxvf $latestovt.tar.gz
		cd $latestovt
		sudo ./configure --without-ssl
		sudo make
		sudo make install

		clear

		colorecho "open-vm-tools has been installed." 2
		colorecho "Please reboot for changes to take effect." 3	
fi
