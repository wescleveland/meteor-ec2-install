#!/bin/bash

# HOW TO EXECUTE:
#	1.	SSH into a fresh installation of Ubuntu 12.10 64-bit
#	2.	Put this script anywhere, such as /tmp/install.sh
#	3.	$ chmod +x /tmp/install.sh && /tmp/install.sh
#

# NOTES:
#	1.	IMPORTANT: You must create a .#production file in the root of your Meteor
#		app. An example .#production file looks like this:
#
# 		export MONGO_URL='mongodb://user:pass@linus.mongohq.com:10090/dbname'
# 		export ROOT_URL='http://www.mymeteorapp.com'
# 		export NODE_ENV='production'
# 		export PORT=80
#
#	2.	The APPHOST variable below should be updated to the hostname or elastic
#		IP of the EC2 instance you created.
#
#	3.	The SERVICENAME variable below can remain the same, but if you prefer
#		you can name it after your app (example: SERVICENAME=foobar).
#
#	4.	Logs for you app can be found under /var/log/[SERVICENAME].log
#

################################################################################
# Variables you should adjust for your setup
################################################################################

APPHOST=figs.thenuts.in
SERVICENAME=meteor_app

################################################################################
# Internal variables
################################################################################

MAINUSER=$(whoami)
MAINGROUP=$(id -g -n $MAINUSER)

GITBAREREPO=/home/$MAINUSER/$SERVICENAME.git
EXPORTFOLDER=/tmp/$SERVICENAME
APPFOLDER=/home/$MAINUSER/$SERVICENAME
APPEXECUTABLE=/home/$MAINUSER/.$SERVICENAME

################################################################################
# Utility functions
################################################################################

function replace {
	sudo perl -0777 -pi -e "s{\Q$2\E}{$3}gm" "$1"
}

function replace_noescape {
	sudo perl -0777 -pi -e "s{$2}{$3}gm" "$1"
}

function symlink {
	if [ ! -f $2 ]
		then
			sudo ln -s "$1" "$2"
	fi
}

function append {
	echo -e "$2" | sudo tee -a "$1" > /dev/null
}

################################################################################
# Task functions
################################################################################

function apt_update_upgrade {
	echo "--------------------------------------------------------------------------------"
	echo "Update and upgrade all packages"
	echo "--------------------------------------------------------------------------------"

	sudo apt-get -y update
	sudo apt-get -y upgrade
}

function install_fail2ban {
	echo "--------------------------------------------------------------------------------"
	echo "Install fail2ban"
	echo "--------------------------------------------------------------------------------"

	# Reference: http://plusbryan.com/my-first-5-minutes-on-a-server-or-essential-security-for-linux-servers
	sudo apt-get -y install fail2ban
}

function configure_firewall {
	echo "--------------------------------------------------------------------------------"
	echo "Configure firewall"
	echo "--------------------------------------------------------------------------------"

	# Reference: http://plusbryan.com/my-first-5-minutes-on-a-server-or-essential-security-for-linux-servers
	sudo ufw allow 22
	sudo ufw allow 80
	sudo ufw allow 443
}

function configure_automatic_security_updates {
	echo "--------------------------------------------------------------------------------"
	echo "Configure automatic security updates"
	echo "--------------------------------------------------------------------------------"

	# Reference: http://plusbryan.com/my-first-5-minutes-on-a-server-or-essential-security-for-linux-servers
	sudo apt-get -y install unattended-upgrades

	replace "/etc/apt/apt.conf.d/10periodic" \
'APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";' \
'APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";'
}

function install_git {
	echo "--------------------------------------------------------------------------------"
	echo "Install Git"
	echo "--------------------------------------------------------------------------------"

	sudo apt-get -y install git-core
	sudo git config --system user.email "$MAINUSER@$APPHOST"
	sudo git config --system user.name "$MAINUSER"
}

function install_nodejs {
	echo "--------------------------------------------------------------------------------"
	echo "Install Node.js"
	echo "--------------------------------------------------------------------------------"

	sudo apt-get -y install python-software-properties
	sudo add-apt-repository -y ppa:chris-lea/node.js
	sudo apt-get -y update
	sudo apt-get -y install nodejs
}


function install_mongodb {
	echo "--------------------------------------------------------------------------------"
	echo "Install MongoDB"
	echo "--------------------------------------------------------------------------------"

	sudo apt-get -y install mongodb
}

function install_meteor {
	echo "--------------------------------------------------------------------------------"
	echo "Install Meteor"
	echo "--------------------------------------------------------------------------------"

	curl https://install.meteor.com | /bin/sh
        sudo npm install -g meteorite
}


function show_conclusion {
	echo -e "\n\n\n\n\n"
	echo "########################################################################"
	echo " Finished installing! "
	echo "########################################################################"
}

################################################################################

apt_update_upgrade
install_fail2ban
configure_firewall
configure_automatic_security_updates
install_git
install_nodejs
install_npm_packs
install_mongodb
install_meteor
