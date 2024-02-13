#!/bin/bash


working_dir="/Backup"
logs="$working_dir/nectar_backup.log"
red='\033[0;31m'
green='\033[0;32m'
reset='\033[0m'
bold='\033[1;37m'
remote_dir="/Backup/remote_dir_Dir"
local_dir="/Backup/local_dir_Dir"
logprefix=""
remote_server="10.37.3.16"

# Make sure that the Backup directory and .log file are in place as expected
if [[ -d "$working_dir" ]]; then
	echo -e "Found $working_dir ${bold}$(date)${reset}\n" >> "${logs}"
	if [[ -f "${logs}" ]]; then
		echo -e "Found $logs ${bold}$(date)${reset}\n" >> "${logs}"
	else
		echo -e "$logs not found ${bold}$(date)${reset}\n" >> "${logs}"
		echo -e "Creating log file...${bold}$(date)${reset}\n" >> "${logs}"
		touch $logs
		if [[ $? -ne 0 ]]; then
			echo -e "An error has occured while trying to create the log file at $logs ${bold}$(date)${reset}" >> "${logs}"
			exit 1
		fi
	fi
else
	echo -e "$working_dir not detected...${bold}$(date)${reset}\n" >> "${logs}"
	echo -e "Exiting with errors...${bold}$(date)${reset}\n" >> "${logs}"
	exit 1
fi

# Make sure that the Remote dir is mounted at the Remote_dir location

# The actual syncing process
rsync -av "${remote_dir}" "${local_dir}" >> "${logs}"
if [[ $? -eq 0 ]]; then
	echo -e "rsync backup ${green}completed${reset} on ${bold}$(date)${reset}\n" >> "${logs}"
else
	echo -e "rsync backup ${red}failed${reset} on ${bold}$(date)${reset}\n" >> "${logs}"
fi
local_dir_size=$(du -sh "${local_dir}" | cut -d " " -f1)
echo -e "Current Backup Size: ${local_dir_size}\n" >> "${logs}"
echo -e "#############END################\n\n" >> "${logs}"
