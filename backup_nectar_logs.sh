#!/bin/bash


working_dir="/Backup"
logs="$working_dir/nectar_backup.log"
red='\033[0;31m'
green='\033[0;32m'
reset='\033[0m'
bold='\033[1;37m'
remote_dir="/$working_dir/Remote_Dir"
local_dir="/$working_dir/Local_Dir"
logprefix="${bold}$(date)${reset}"
remote_server="10.37.3.16"

# Make sure that the Backup directory and .log file are in place as expected
if [[ -d "$working_dir" ]]; then
	echo -e "$logprefix Found $working_dir\n" >> "${logs}"
	if [[ -f "${logs}" ]]; then
		echo -e "$logprefix Found $logs\n" >> "${logs}"
	else
		echo -e "$logprefix $logs not found\n" >> "${logs}"
		echo -e "$logprefix Creating log file...\n" >> "${logs}"
		touch $logs
		if [[ $? -ne 0 ]]; then
			echo -e "$logprefix An error has occured while trying to create the log file at $logs \n" >> "${logs}"
			exit 1
		fi
	fi
else
	echo -e "$logprefix $working_dir not detected...\n" >> "${logs}"
	echo -e "$logprefix Exiting with errors...\n" >> "${logs}"
	exit 1
fi

# Make sure that the Remote dir is mounted at the Remote_dir location

# The actual syncing process
rsync -av "${remote_dir}" "${local_dir}" >> "${logs}"
if [[ $? -eq 0 ]]; then
	echo -e "$logprefix rsync backup ${green}completed${reset}\n" >> "${logs}"
else
	echo -e "$logprefix rsync backup ${red}failed${reset}\n" >> "${logs}"
fi
local_dir_size=$(du -sh "${local_dir}" | cut -d " " -f1)
echo -e "$logprefix Current Backup Size: ${local_dir_size}\n" >> "${logs}"
echo -e "#############END################\n\n" >> "${logs}"
