#!/usr/bin/bash

COMMAND=""
OPTION=100


GIT_URL="someGithubLink"
DESTINATION_DIRECTORY="/home/pi/Programming/MesFrontend"
NGINX_DIRECTORY="/var/www/html"


function show_statement(){
	echo "<--------------------------------------------->"
	echo $1
	echo "<--------------------------------------------->"
}

function press_any_key(){
	read -p "Press any key to continue ... "
}

function set_command(){
	echo ${1}
	read COMMAND
}

function reset_command(){
	COMMAND="n"
}

function read_activity_number(){
	show_statement "Choose some activity to do: "
	echo "1. Get project from GitHub"
	echo "2. Build project"
	echo "3. Deploy to NGINX"
	echo "4. Install NodeJs and NPM"
	echo "5. Configure network"
	echo "6. Reboot"
	echo ""
	echo "0. Exit"
	echo ""

	read -p "Enter number: " OPTION
}

function git_clone(){
	git clone "${GIT_URL}" .
}

function git_pull(){
	git pull "${GIT_URL}" master
}


function get_project(){
	show_statement "Creating destination directory"
	if [ -d ${DESTINATION_DIRECTORY} ]
	then
		echo "${DESTINATION_DIRECTORY} already exists"
		reset_command
		set_command "Do you want to clone (Y)  or pull master branch (N)?"
		if [ "${COMMAND}" == "Y" ] || [ "${COMMAND}" == "y" ]
		then
			cd ${DESTINATION_DIRECTORY}
			rm -rf  *
			rm -rf .*
			git_clone
			show_statement "Project downloaded"
		else
			cd ${DESTINATION_DIRECTORY}
			git_pull
			show_statement "Project updated"
		fi
	else
		mkdir -p "${DESTINATION_DIRECTORY}"
		cd "${DESTINATION_DIRECTORY}"
		git_clone
		show_statement "Project downloaded"
	fi
	reset_command
	press_any_key
	clear
}

function build_project(){
	cd ${DESTINATION_DIRECTORY}
	npm install
	npm run build
	show_statement "Project built successfully"
	press_any_key
	clear
}

function deploy_to_nginx(){
	show_statement "Purging nginx directory ... "
	cd ${NGINX_DIRECTORY}
	rm -rf *
	rm -rf .*
	show_statement "Copying project into nginx ... "
	cd "${DESTINATION_DIRECTORY}/build"
	cp -R * "${NGINX_DIRECTORY}"
	show_statement "Restart NGINX service ... "
	sudo service nginx restart
	show_statement "Deploy finished"
	press_any_key
	clear
}

function node_js_configuration(){
	cd "/home/pi"
	show_statement "Downloading  NODE JS ... "
	rm -R node*
	NODE_URL=https://nodejs.org/dist/v14.18.1/node-v14.18.1-linux-armv7l.tar.xz
	wget ${NODE_URL}
	show_statement "Extracting NODE JS ... "
	NODE_ARCHIVE_NAME=$(ls | grep node*tar.xz)
	tar -xf ${NODE_ARCHIVE_NAME}
	rm -R ${NODE_ARCHIVE_NAME}
	show_statement "Installing  NODE JS ..."
	NODE_DIRECTORY_NAME=$(ls | grep node*)
	cd "/home/pi/${NODE_DIRECTORY_NAME}"
	cp -R * /usr/local
	RESULT=$(node -v)
	if [ ${RESULT:0:1} == "v" ]
	then
		show_statement "NODE JS installed successfully"
		show_statement "Your  NODE JS version is: ${RESULT}"
	else
		show_statement "Error during installing  NODE JS"
	fi
	cd /home/pi
	rm -R node*
	press_any_key
	clear
}


function network_configuration(){

	read -p "Enter Ip Address  for RPI: " IP_ADDRESS

	echo "" > /etc/dhcpcd.conf
	set_in_dhcpcd_conf "hostname"
	set_in_dhcpcd_conf "clientid"
	set_in_dhcpcd_conf "persistent"
	set_in_dhcpcd_conf "option rapid_commit"
	set_in_dhcpcd_conf "option domain_name_servers, domain_name, domain_search, host_name"
	set_in_dhcpcd_conf "option classless_static_routes"
	set_in_dhcpcd_conf "option interface_mtu"
	set_in_dhcpcd_conf "require dhcp_server_identifier"
	set_in_dhcpcd_conf "slaac private "
	set_in_dhcpcd_conf "interface eth0"
	set_in_dhcpcd_conf "static ip_address=${IP_ADDRESS}/16"
	set_in_dhcpcd_conf "static routers=192.168.0.249"
	set_in_dhcpcd_conf "static domain_name_servers=192.168.6.52"


	show_statement "Network configured"
	push_some_button
	clear
}

function set_in_dhcpcd_conf(){
	echo $1 >> /etc/dhcpcd.conf
}


function run_activity(){
	if [ ${OPTION} -eq 1 ]
	then
		get_project
	elif [ ${OPTION} -eq 2 ]
	then
		build_project
	elif [ ${OPTION} -eq 3 ]
	then
		deploy_to_nginx
	elif [ ${OPTION} -eq 4 ]
	then
		node_js_configuration
	elif [ ${OPTION} -eq 5 ]
	then
		network_configuration
	elif [ ${OPTION} -eq 6 ]
	then
		reboot
	fi

}


function choose_activity(){
	show_statement "Script to deploy Frontend for MES System"
	show_statement "Created by  PCzech"

	while [ ${OPTION} -ne 0 ]
	do
		read_activity_number
		run_activity
	done
	press_any_key
}




clear
choose_activity
