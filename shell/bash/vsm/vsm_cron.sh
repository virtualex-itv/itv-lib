#!/bin/bash
# Copyright (c) iThinkVirtual 2018
# All rights reserved
#
#This script gets added to cron.daily and updates the aac-base files and reinstalls the Linux VMware Software Manager
#(VSM) created by, Edward Haletky aka Texiwill, on RHEL, CentOS, Ubuntu, and Debian Linux
#distributions.

#Updates base files and reinstalls VSM
cd /home/alex/aac-base; ./aac-base.install -u; ./aac-base.install -i vsm
