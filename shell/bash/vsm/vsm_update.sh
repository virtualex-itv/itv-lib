#!/bin/bash
# Copyright (c) iThinkVirtual 2018-2020
# All rights reserved
#
# vim: tabstop=4 shiftwidth=4
#
#This script updates the aac-base files and reinstalls the Linux VMware Software Manager
#(VSM) created by, Edward Haletky aka Texiwill, on RHEL, CentOS, Ubuntu, and Debian Linux
#distributions.  It also adds a script to cron jobs via symbolic link for daily updates
#of aac-base files and vsm.
#
# example: ./vsm_update.sh America/New_York

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

[ ! -d aac-base ] && mkdir -pvm 755 aac-base && colorecho "Folder created." 2 || colorecho "Folder already exists." 3

aac_old=$(ls aac-base.* 2> /dev/null | wc -l)
aac_new=$(ls ./aac-base/aac-base.* 2> /dev/null | wc -l)

[ **"$aac_old" != "0"** ] && [ **"$aac_new" = "0"** ] && mv aac-base.* aac-base && colorecho "Files moved." 2 || colorecho "Files already moved to $HOME/aac-base." 3

sleep 2

#Updates base files and reinstalls VSM
cd $HOME/aac-base; ./aac-base.install -u $tz; sudo ./aac-base.install -i vsm $tz

#Creates script to link to cron.daily
[ ! -f $HOME/vsm_cron.sh ] && { cat > $HOME/vsm_cron.sh << EOF
#!/bin/bash
# Copyright (c) iThinkVirtual 2018
# All rights reserved
#
#This script gets added to cron.daily and updates the aac-base files and reinstalls the Linux VMware Software Manager
#(VSM) created by, Edward Haletky aka Texiwill, on RHEL, CentOS, Ubuntu, and Debian Linux
#distributions.

#Kills any running vsm processes
pkill -9 vsm.sh

#Updates base files and reinstalls VSM
cd $HOME/aac-base
./aac-base.install -u $tz
./aac-base.install -i vsm $tz
EOF
} && chmod +x $HOME/vsm_cron.sh

#Creates symbolic link for script in cron.daily
[ ! -f /etc/cron.daily/vsm_cron.sh ] && sudo ln -fs $HOME/vsm_cron.sh /etc/cron.daily/vsm_cron.sh

#Adds cron job to run daily at 6AM
( crontab -l; echo "0 6 * * * /usr/local/bin/vsm.sh -y -mr --favorite -c" ) | sort - | uniq - | crontab -

clear

colorecho "VSM is now updated in /usr/local/bin/vsm.sh and ready for use. Enjoy! :)" 5
