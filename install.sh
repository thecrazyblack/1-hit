#!/bin/bash

#////////////////////////////////////
# ql-installer
#////////////////////////////////////

ECMD="echo -e"
COLOUR_RESET='\e[0m'
aCOLOUR=(

		'\e[1;33m'	# Yellow	| symbol
		'\e[1m'		# Bold white	|
		'\e[1;32m'	# Green		|
		'\e[1;31m'      # Red

	)
	GREEN_LINE=" ${aCOLOUR[0]}─────────────────────────────────────────────────────$COLOUR_RESET"
	GREEN_BULLET=" ${aCOLOUR[2]}		[+]	$COLOUR_RESET"
	GREEN_WARN=" ${aCOLOUR[3]}            [!]     $COLOUR_RESET"


tools_deb() {
	$ECMD$aCOLOUR1$GREEN_LINE
	$ECMD $GREEN_BULLET "${aCOLOUR[2]}Updating Package ..."
	$ECMD$aCOLOUR1$GREEN_LINE
		apt update -y
		apt upgrade -y
		apt install curl wget net-tools nmap dmidecode lolcat ufw -y
}

tools_rpm() {
	$ECMD$aCOLOUR1$GREEN_LINE
        $ECMD $GREEN_BULLET "${aCOLOUR[2]}Updating Package ..."
        $ECMD$aCOLOUR1$GREEN_LINE
                yes | yum update
                yes | yum upgrade
		yes | yum install epel-release curl wget net-tools ruby nmap dmidecode unzip
}

req() {
        $ECMD$aCOLOUR1$GREEN_LINE
        $ECMD $GREEN_BULLET "${aCOLOUR[2]}Installing Requirements ..."
        $ECMD$aCOLOUR1$GREEN_LINE
                wget https://github.com/poseidon-network/qlauncher-linux/releases/latest/download/ql-linux.tar.gz -O ql.tar.gz
                curl -o /usr/bin/Q https://raw.githubusercontent.com/pethot/1-hit/master/conf/Q
                chmod +x /usr/bin/Q
}

docker() {
	$ECMD$aCOLOUR1$GREEN_LINE
        $ECMD $GREEN_BULLET "${aCOLOUR[2]}Installing Docker ..."
        $ECMD$aCOLOUR1$GREEN_LINE
		curl -sSL https://get.docker.com | sh
}

ql() {
        $ECMD$aCOLOUR1$GREEN_LINE
        $ECMD $GREEN_BULLET "${aCOLOUR[2]}Installing Qlauncher ..."
        $ECMD$aCOLOUR1$GREEN_LINE
	mkdir -p /etc/ql
	tar -vxzf ql.tar.gz -C /etc/ql
	rm ql.tar.gz
}

onboot() {
cat > /etc/systemd/system/qlauncher.service << EOF
[Unit]
Description=qlauncher.service
[Service]
Type=simple
ExecStart=/etc/ql/qlauncher.sh start
ExecStop=/etc/ql/qlauncher.sh stop
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
}

reload() {
	systemctl daemon-reload
	systemctl enable qlauncher
	systemctl start qlauncher
}

lolcat() {
	wget https://github.com/busyloop/lolcat/archive/master.zip
	unzip master.zip
	cd lolcat-master/bin
	gem install lolcat
	cd ; rm -rf lolcat-master master.zip
}

rpm() {
	tools_rpm ; req ; lolcat ; docker ; ql ; onboot ; systemctl stop docker ; systemctl start docker ; systemctl enable docker ; reload >> install.log
}

deb() {
	tools_deb ; req ; docker ; ql ; onboot ; reload >> install.log
}

#Detect root
if [[ $(id -u) -ne 0 ]] ; then
        $ECMD $GREEN_WARN "${aCOLOUR[3]}Please run as root $COLOUR_RESET"
	exit 1
fi

#Fedora 31 and 32 can't install
if cat /etc/os-release | grep ^PRETTY_NAME | 32 ; then
	$ECMD $GREEN_WARN "${aCOLOUR[3]}Can't install $COLOUR_RESET"
	exit 1
fi

if cat /etc/os-release | grep ^PRETTY_NAME | 31 ; then
        $ECMD $GREEN_WARN "${aCOLOUR[3]}Can't install $COLOUR_RESET"
        exit 1
fi

#kickoff
  RPM=$(which yum)
  APT=$(which apt-get)

	if [[ ! -z $RPM ]]; then
    		rpm
		Q --about
	elif [[ ! -z $APT ]]; then
    		deb
		Q --about
	else
    		$ECMD $GREEN_WARN "${aCOLOUR[3]}Can't install $COLOUR_RESET"
    	exit 1 ;
 	fi
