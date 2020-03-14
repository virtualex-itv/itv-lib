#!/bin/bash
# Copyright (c) Alex Lopez 2020
# All rights reserved
# vim: tabstop=4 shiftwidth=4
#
# An initial custom setup/configuration script for linux desktop distros
#
# Note: place script in users $HOME dir and make it executable
#
# example: ./setup.sh

# on-screen colors
function colorecho {
# https://tinyurl.com/prompt-color-using-tput
    str=$1
    col=$2
    docol=1
    if [ Z"$2" = Z"" ]; then docol=0; fi
    if [ $docol -eq 1 ]; then
		color=`tput setaf $col`
		nc=`tput sgr0`
		echo -e "${color}${str}${nc}\n"; else echo ${str}; fi
}

# find operating systems
function findos {
		if [ -e /etc/os-release ]; then
				. /etc/os-release
				theos=`echo $ID | tr [:upper:] [:lower:]`
		if [ Z"$theos" = Z"linuxmint" ]; then
				theos=`echo $ID_LIKE | tr [:upper:] [:lower:]`; fi
		elif [ -e /etc/centos-release ]; then
				theos=`cut -d' ' -f1 < /etc/centos-release | tr [:upper:] [:lower:]`
		elif [ -e /etc/redhat-release ];then
				theos=`cut -d' ' -f1 < /etc/redhat-release | tr [:upper:] [:lower:]`
		elif [ -e /etc/fedora-release ]; then
				theos=`cut -d' ' -f1 < /etc/fedora-release | tr [:upper:] [:lower:]`
		elif [ -e /etc/debian-release ]; then
				theos=`cut -d' ' -f1 < /etc/debian-release | tr [:upper:] [:lower:]`
		else
		# Mac OS
		uname -a | grep Darwin  >& /dev/null
		if [ $? -eq 0 ]; then
				theos="macos"
		else
				colorecho "Do not know this operating system." 1
				theos="unknown"; fi
		fi
}

# find os versions
function findversion {
		thefile=""
		theofile=""
		major=0
		minor=0
		async=0
		for x in /etc/centos-release /etc/redhat-release /etc/fedora-release
		do
				if [ -e $x ]; then
						thefile="$x"
						break
				fi
		done
		if [ Z"$thefile" != Z"" ]; then
		full=`cat $thefile| tr -dc '0-9.'`
		major=`echo $full | cut -d\. -f1`
		minor=`echo $full | cut -d\. -f2`
		async=`echo $full | cut -d\. -f3`
		fi
		# For Ubuntu
		for y in /etc/os-release
		do
				if [ -e $y ]; then
						theofile="$y"
						break
				fi
		done
		if [ Z"theofile" != Z"" ]; then
		verid=`echo $VERSION_ID`
		fi
}

# prompt to reboot
function rebprompt {
		a="" 
		while [ Z"$a" = Z"" ]; do
				colorecho "Reboot now? (Y/n)" 3
				read a
				b=$(echo $a | tr '[:upper:]' '[:lower:]')
				if [ Z"$b" = Z"y" ]; then
					sudo shutdown -r now; fi 
				if [ Z"$b" != Z"y" ]; then 
					a=""; break; fi
		done; exit
}

# check root username
us=`id -un`
if [ Z"$us" = Z"root" ]; then
	colorecho "Error: Requires a valid non-root username to execute script." 1; exit
fi

# Create a system alias file
[ ! -f $HOME/00-aliases.sh ] && { cat > $HOME/00-aliases.sh << EOF
#!/bin/bash
#Put aliases here instead of /etc/profile
#Will symlink to /etc/profile.d and be read

alias vi='vim'
#alias ls='ls -la'
EOF
} && chmod +x $HOME/00-aliases.sh && sudo ln -fs $HOME/00-aliases.sh /etc/profile.d/00-aliases.sh && source /etc/profile

# Create a .vimrc file
[ ! -f $HOME/.vimrc ] && { cat > $HOME/.vimrc << EOF
set tabstop=4
set shiftwidth=4
set autoindent
set incsearch
set complete-=i
set linebreak
syntax enable
set wrap
set ruler
set number
set showcmd
EOF
}

# Create a .tmux.conf file
[ ! -f $HOME/.tmux.conf ] && { cat > $HOME/.tmux.conf << EOF
# Tmux mouse mode
set-option -g mouse on

## Enable mouse with 'm' and disable with 'M'
unbind m
bind m \
 set -g mouse on \;\
 display 'Mouse: ON'
unbind M
  bind M \
  set -g mouse off \;\
  display 'Mouse: OFF'
EOF
}

theos=''
full=''
major=''
minor=''
async=''

findos
findversion

if [ Z"$theos" = Z"centos" ] || [ Z"$theos" = Z"redhat" ] || [ Z"$theos" = Z"fedora" ]; then
	
	# https://medium.com/@adikari/resume-bash-script-after-reboot-6fc0371491c8
	if [ ! -f $HOME/resume-after-reboot ]; then
		colorecho "Running script for the first time..." 3
		
		#require dnf
		which dnf >& /dev/null
		if [ $? -eq 1 ]; then
			sudo yum install -y epel-release && sudo yum install -y dnf && sudo dnf upgrade -y epel-release; else
			sudo dnf install -y epel-release && sudo dnf upgrade -y epel-release;
		fi
		
		# sudo dnf upgrade -y && sudo dnf autoremove -y && sudo dnf clean all
		
		# BEGIN_SEC
		# remove this section when horizon 7.12 GA & prettyping is updated
		if [ Z"$theos" = Z"centos" ]; then
			if [[ $major -eq 8 && $minor -eq 0 ]]; then
				colorecho "Skipping update on $theos $full...breaks Horizon 7.11 compatability...Wait for 7.12." 3
			elif [[ $major -eq 8 && $minor -eq 1 ]] || [ $major -eq 7 ]; then
				sudo dnf upgrade -y && sudo dnf autoremove -y && sudo dnf clean all
			fi
		elif [ Z"$theos" != Z"centos" ]; then
			sudo dnf upgrade -y && sudo dnf autoremove -y && sudo dnf clean all
		fi
		# END_SEC
		
		# Install systems applications
		sudo dnf install -y open-vm-tools-desktop \
		wget \
		curl \
		file \
		git \
		net-tools \
		nmap \
		nfs-utils \
		yum-utils \
		firewalld \
		cockpit \
		vim-enhanced \
		java \
		rkhunter \
		mailx \
		sssd \
		oddjob \
		oddjob-mkhomedir \
		adcli \
		samba-common-tools
		
		if [ Z"$theos" = Z"centos" ]; then
			if [ $major -eq 7 ]; then
				sudo dnf install -y python3-pip python-devel ncurses-devel
			elif [ $major -eq 8 ]; then
				sudo dnf install -y ncurses-compat-libs
			fi
		fi
		
		sudo dnf -y groupinstall "Development Tools"
		
		sudo systemctl start firewalld && sudo systemctl enable firewalld
		sudo systemctl start cockpit && sudo systemctl enable --now cockpit.socket
		sudo firewall-cmd --permanent --zone=public --add-service=cockpit
		sudo firewall-cmd --permanent --zone=public --add-service=ssh
		sudo firewall-cmd --permanent --zone=public --add-service=nfs
		sudo firewall-cmd --reload
		
		sudo sed -i.bak 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
		sudo sed -i.bak 's/#   Protocol 2/\   \Protocol 2/' /etc/ssh/ssh_config
		
		sudo systemctl restart sshd
		
		# Install xRDP
		sudo dnf install -y xrdp && sudo systemctl enable --now xrdp
		sudo sed -i.bak '$a \ \nexec gnome-session' /etc/xrdp/xrdp.ini
		sudo systemctl restart xrdp
		sudo firewall-cmd --new-zone=xrdp --permanent
		sudo firewall-cmd --zone=xrdp --add-port=3389/tcp --permanent
		sudo firewall-cmd --reload
		
		# Install Homebrew
		yes "" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
		sed -i.bak '$a \\nexport PATH=$PATH:"/home/linuxbrew/.linuxbrew/bin"' ~/.bashrc
		
		# Install Snap
		sudo dnf -y install snapd && sudo systemctl enable --now snapd.socket && sudo ln -s /var/lib/snapd/snap /snap
		
		# Install DCLI
		pip3 install --user dcli
		
		# Install PowerShell
		sudo curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo \
		&& sudo dnf install -y powershell
		
		# Install VSCode
		sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
		sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
		sudo dnf check-update && sudo dnf install -y code
		
		# Install Brave Browser
		if [ Z"$theos" = Z"centos" ]; then
			if [ $major -eq 7 ]; then
				colorecho "Skipped...Brave browser is unsupported on $theos $full" 3				
			elif [ $major -eq 8 ]; then
				sudo dnf install -y dnf-plugins-core
				sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
				sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
				sudo dnf install -y brave-browser
			fi
		fi
		
		# Install Google Chrome
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -P ~/Downloads
		sudo dnf install -y ~/Downloads/google-chrome-stable_current_x86_64.rpm
		sudo rm -rf ~/Downloads/google-chrome-*.rpm
		
		# Preparation for reboot
		script="./linux_setup.sh"
		
		sudo echo "$script" >> ~/.bashrc
		# sudo sed -i $"a \\$script" ~/.bashrc ###TESTED;MESSES UP FILE;NOT WORKING PROPERLY----------------------->
		
		# create a flag file to check if we are resuming from reboot.
		sudo touch $HOME/resume-after-reboot
		
		# Reboot
		colorecho "Please reboot and reopen terminal to continue." 3
		rebprompt
		
	elif [ -f $HOME/resume-after-reboot ]; then
		colorecho "resuming script after reboot.." 3
		
		# Remove the line that we added in bashrc/zshrc
		sudo sed -i '$d' ~/.bashrc

		# remove the temporary file that we created to check for reboot
		sudo rm -rf $HOME/resume-after-reboot
		
		# Install homebrew apps
		brew install \
		kubectl \
		tmux \
		tmuxinator \
		bat \
		htop \
		ctop \
		figlet \
		lolcat \
		cowsay \
		asciinema \
		&& brew tap cjbassi/ytop \
		&& brew install ytop gcc
		
		if [ Z"$theos" = "centos" ]; then
			if [[ $major -eq 8 && $minor -eq 1 ]]; then
				colorecho "Skipped...prettyping is currently unsupported $theos $full" 3
			fi
		else
			brew install prettyping
		fi
		
		# Install Oh My Zsh
		sudo dnf install -y zsh && yes "" | sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
		
		# Install Powerline fonts
		git clone https://github.com/powerline/fonts.git --depth=1
		cd fonts && ./install.sh && cd $HOME && rm -rf fonts
		
		git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
			
		# Revisions to ~/.zshrc
		sed -i.bak 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel9k\/powerlevel9k"/' ~/.zshrc
		sed -i '1s/^/export TERM="xterm-256color"\n\n/' ~/.zshrc
		sed -i '$a \\nexport PATH=$PATH:"/home/linuxbrew/.linuxbrew/bin"\n' ~/.zshrc
		sed -i '$a \tmux\nalias c="clear"\nalias k="kubectl"\nalias ping="prettyping"\nalias w="watch -n1"\nalias cat="bat"' ~/.zshrc
		sed -i '$a \\nif [ $commands[kubectl] ]; then source <(kubectl completion zsh); fi' ~/.zshrc
		
		# Change shell to zsh
		grep -Fxq "$(which zsh)" /etc/shells >& /dev/null
		
		if [ $? -eq 1 ]; then
			# sudo sed -i.bak '$a \\/usr\/bin\/zsh' /etc/shells
			sudo sed -i $"a \\$(which zsh)" /etc/shells
		fi
		chsh -s $(which zsh)
		
		source <(kubectl completion zsh)
		
		# Reboot
		colorecho "Please reboot now to complete setup." 3
		rebprompt
		
		exit
	else
		exit
	fi 
	
elif [ Z"$theos" = Z"debian" ] || [ Z"$theos" = Z"ubuntu" ]; then
	
	# https://medium.com/@adikari/resume-bash-script-after-reboot-6fc0371491c8
	if [ ! -f $HOME/resume-after-reboot ]; then
		colorecho "Running script for the first time..." 3

		sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean purge -y
		
		sudo apt install -y open-vm-tools-desktop \
		wget \
		curl \
		file \
		git \
		net-tools \
		nmap \
		nfs-common \
		cockpit \
		vim-gui-common \
		java-common \
		rkhunter \
		bsd-mailx \
		build-essential \
		realmd \
		python3 \
		python3-dbus \
		python-dbus \
		python3-pip \
		python-gobject
		
		sudo systemctl start cockpit && sudo systemctl enable --now cockpit.socket
		
		sudo ufw allow ssh && sudo ufw allow http && sudo ufw allow https \
		&& sudo ufw allow 22/tcp && sudo ufw allow 80/tcp && sudo ufw allow 443/tcp \
		&& sudo ufw allow 9090/tcp
		
		sudo sed -i.bak 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
		sudo sed -i.bak 's/#   Protocol 2/\   \Protocol 2/' /etc/ssh/ssh_config
		
		sudo ufw enable
		
		# Install XRDP
		sudo apt install -y xrdp && sudo adduser xrdp ssl-cert
		sudo ufw allow 3389/tcp && sudo systemctl restart xrdp
		
		# Install Homebrew
		yes "" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
		sed -i.bak '$a \\nexport PATH=$PATH:"/home/linuxbrew/.linuxbrew/bin"' ~/.bashrc
		
		# Install Snap
		sudo apt install -y snapd && sudo systemctl enable --now snapd.socket && sudo ln -s /var/lib/snapd/snap /snap
		
		# Install DCLI
		pip3 install --user dcli
		
		# Install PowerShell
		v=${verid/\.*/}
		if [ $v -eq 18 ]; then
			wget -q https://packages.microsoft.com/config/ubuntu/$verid/packages-microsoft-prod.deb
			sudo apt install -y ./packages-microsoft-prod.deb && sudo apt update && apt autoremove
			sudo apt install -y powershell
			sudo rm -rf ~/packages-*.deb
		elif [ $v -ge 19 ]; then
			sudo snap install powershell --classic
		fi
		
		# Install VSCode
		colorecho "VSCode can also be installed via snap by running: snap install core --classic" 3
		curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
		sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
		sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
		sudo apt-get install apt-transport-https && sudo apt-get update && sudo apt-get install code
		
		# Install Brave Browser
		sudo apt install -y apt-transport-https curl
		curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
		echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
		sudo apt update -y && sudo apt install -y brave-browser
		
		# Install Google Chrome
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P ~/Downloads
		sudo dpkg -i ~/Downloads/google-chrome-stable_current_amd64.deb
		sudo rm -rf ~/Downloads/google-chrome-*.deb
		
		# Preparation for reboot
		script="./linux_setup.sh"
		
		sudo echo "$script" >> ~/.bashrc
		# sudo sed -i $"a \\$script" ~/.bashrc ###TESTED;MESSES UP FILE;NOT WORKING PROPERLY----------------------->
		
		# create a flag file to check if we are resuming from reboot.
		sudo touch $HOME/resume-after-reboot
		
		# Reboot
		colorecho "Please reboot and reopen terminal to continue." 3
		rebprompt
		
	elif [ -f $HOME/resume-after-reboot ]; then
		colorecho "resuming script after reboot.." 3
		
		# Remove the line that we added in bashrc/zshrc
		sudo sed -i '$d' ~/.bashrc

		# remove the temporary file that we created to check for reboot
		sudo rm -rf $HOME/resume-after-reboot
		
		# Install homebrew apps
		brew install \
		kubectl \
		tmux \
		tmuxinator \
		bat \
		htop \
		ctop \
		figlet \
		lolcat \
		cowsay \
		asciinema \
		&& brew tap cjbassi/ytop \
		&& brew install ytop gcc prettyping
		
		# Install snaps
		sudo snap install atom --classic 
		sudo snap install notepadqq && sudo snap install p7zip-desktop && sudo snap install snap-store \
		&& sudo snap install canonical-livepatch && sudo snap install termius-app
		
		# Install Oh My Zsh
		sudo apt install -y zsh && yes "" | sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
		
		# Install Powerline fonts
		sudo apt install -y fonts-powerline
		
		git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
			
		# Revisions to ~/.zshrc
		sed -i.bak 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel9k\/powerlevel9k"/' ~/.zshrc
		sed -i '1s/^/export TERM="xterm-256color"\n\n/' ~/.zshrc
		sed -i '$a \\nexport PATH=$PATH:"/home/linuxbrew/.linuxbrew/bin"\n' ~/.zshrc
		sed -i '$a \\nexport PATH=$PATH:"/snap/bin"\n' ~/.zshrc
		sed -i '$a \tmux\nalias c="clear"\nalias k="kubectl"\nalias ping="prettyping"\nalias w="watch -n1"\nalias cat="bat"' ~/.zshrc
		sed -i '$a \\nif [ $commands[kubectl] ]; then source <(kubectl completion zsh); fi' ~/.zshrc
		
		# Change shell to zsh
		grep -Fxq "$(which zsh)" /etc/shells >& /dev/null
		
		if [ $? -eq 1 ]; then
			# sudo sed -i.bak '$a \\/usr\/bin\/zsh' /etc/shells
			sudo sed -i $"a \\$(which zsh)" /etc/shells
		fi
		chsh -s $(which zsh)
		
		source <(kubectl completion zsh)
		
		# Reboot
		colorecho "Please reboot now to complete setup." 3
		rebprompt
		
		exit
	else
		exit
	fi
fi 