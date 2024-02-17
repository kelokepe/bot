#!/bin/bash
declare -A sdir=( [0]="/etc/patoBot" [scp]="/etc/patoBot/scripts" )
declare -A sfile=( [conf]="${sdir[0]}/conf.json" [tmp]="${sdir[0]}/tmp.json" )

msg(){
for((x=1;x<35;x++)); do bar+='=' ; done
case $1 in
 -bar)echo -e "\e[1;34m$bar";;
esac
}

apt-get install toilet lolcat figlet pv jq sudo curl -y &> /dev/null

fun_bar(){
    comando="$1"
    _=$(
        $comando >/dev/null 2>&1
    ) &
    >/dev/null
    pid=$!
    while [[ -d /proc/$pid ]]; do
        echo -ne "  \033[1;33m["
        for ((i = 0; i < 20; i++)); do
            echo -ne "\033[1;31m>"
            sleep 0.08
        done
        echo -ne "\033[1;33m]"
        sleep 0.5s
        echo
        tput cuu1 && tput dl1
    done
    [[ $(dpkg --get-selections | grep -w "$paquete" | head -1) ]] || ESTATUS=$(echo -e "\033[91m  FALLO DE INSTALACION") &>/dev/null
    [[ $(dpkg --get-selections | grep -w "$paquete" | head -1) ]] && ESTATUS=$(echo -e "\033[1;33m       \033[92mINSTALADO") &>/dev/null
    echo -ne "  \033[1;33m[\033[1;31m>>>>>>>>>>>>>>>>>>>>\033[1;33m] $ESTATUS \033[0m\n"
    sleep 0.5s
}

dependencias() {
dpkg --configure -a >/dev/null 2>&1
apt -f install -y >/dev/null 2>&1
soft="sudo grep less zip unzip ufw curl dos2unix python python3 python3-pip openssl cron iptables lsof pv boxes at mlocate gawk bc jq curl socat netcat net-tools cowsay figlet lolcat apache2 ufw"
for i in $soft; do
paquete="$i"
echo -e "\033[93m    ❯ \e[97mINSTALANDO PAQUETE \e[36m $i"
#  [[ $(dpkg --get-selections|grep -w "$i"|head -1) ]] ||
   fun_bar "apt-get install $i -y"
msg -bar
done
}

[[ $1 == '--init' || -z $1 ]] && {
   [[ ! -e ${sfile[conf]} ]] && {
	mkdir -p ${sdir[@]} && touch ${sfile[@]}
	chmod 777 ${sfile[@]} && echo -e "{\n}" > ${sfile[tmp]}
	clear
	msg -bar
	read -p $'\e[1;30mIngrese su id: ' id
	msg -bar
	read -p $'\e[1;30mIngrese su token ' token
	msg -bar
	read -p $'\e[1;30mIngrese su usuario: ' usuario
	msg -bar
	jq --arg token "$token" --arg id "$id" --arg user "$usuario" '.users.data += {token: $token, id: $id, user: $user }' < ${sfile[tmp]} > ${sfile[conf]}
	read -p "enter"
   }
        [[ ! -e /etc/pakinstal ]] && {
		touch /etc/pakinstal
		dependencias
		sudo ufw allow 81 &> /dev/null
		sudo ufw allow 8888 &> /dev/null
		read -p "enter: "
        }
	  [[ ! -d /etc/SCRIPT ]] && {
		    mkdir -p /etc/SCRIPT
		    mkdir -p /root/chukkinstall
		    wget -O $HOME/chukk.tar https://raw.githubusercontent.com/kelokepe/vpsmx/main/chukk.tar &> /dev/null
		    tar xpf $HOME/chukk.tar --directory /root/chukkinstall
		    mv -f /root/chukkinstall /etc/SCRIPT/
		    rm -rf /root/chukkinstall chukk.tar
	   }

[[ -e /bin/http-server.sh ]] && {
	rm /bin/http-server.sh
	killall screen
	pkill -f BotGen-server
	wget -O /etc/patoBot/BotGen-server.sh https://raw.githubusercontent.com/NetVPS/Bot-Gen-MultiScript/main/Rufus/ADM-db/BotGen-server.sh &> /dev/null
  [[ ! -e /etc/systemd/system/BotGen-server.service ]] && {
		cat <<- eof > /etc/systemd/system/BotGen-server.service
		[Unit]
		Description=BotGen-server Service by @drowkid01
		After=network.target
		StartLimitIntervalSec=0

		[Service]
		Type=simple
		User=root
		WorkingDirectory=/root
		ExecStart=/bin/bash /etc/patoBot/BotGen-server.sh -start
		Restart=always
		RestartSec=3s

		[Install]
		WantedBy=multi-user.target
		eof
   }
}

