#!/bin/bash


working_dir="/Backup"
logs="$working_dir/nectar_backup.log"
red='\033[0;31m'
green='\033[0;32m'
reset='\033[0m'
bold='\033[1;37m'
remote_dir="$working_dir/Remote_Dir"
local_dir="$working_dir/Local_Dir"
archive_dir="$working_dir/Archive"
backup_name="NectarLogBackup"
logprefix="${bold}$(date)${reset}"
remote_server="10.37.3.16"
control=5

# Make sure that the Backup directory and .log file are in place as expected
if [[ -d "$working_dir" ]]; then
	echo -e "$logprefix Found $working_dir\n" >> "${logs}"
	if [[ -f "${logs}" ]]; then
		echo -e "$logprefix Found $logs\n" >> "${logs}"
	else
		echo -e "$logprefix $logs not found\n" >> "${logs}"
		echo -e "$logprefix Creating log file...\n" >> "${logs}"
		touch "$logs"
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
if [[ -z "$(df -t cifs)" ]]; then
	df_output=$(df -t cifs)
	df_exit_code=$?
	echo -e "$logprefix Exit code: $df_exit_code\n" >> "${logs}"
	if [[ $df_exit_code -ne 0 ]]; then
		echo -e "$logprefix Failed to find Remote directory\n" >> "${logs}"
		echo -e "$logprefix Exiting with errors...\n" >> "${logs}"
		exit 1
	fi
	echo -e "$logprefix ERROR - Output from df: $df_output\n" >> "${logs}"
else
	echo -e "$logprefix Remote directory detected\n" >> "${logs}"
fi

if [[ ! -f /usr/bin/rsync ]]; then
	echo -e "$logprefix Unable to find rsync binaries...\n" >> "${logs}"
else
	echo -e "$logprefix rsync binaries detected on system\n" >> "${logs}"
fi

# Create a function to archive files if they exceed the size specified by the control
archive_files() {
	tar -czvf "${archive_dir}/$backup_name$(date +%Y%m%d_%H%M%S).tar.gz" "${local_dir}/"* &>"${logs}"
	if [[ $? -eq 0 ]]; then
		echo -e "$logprefix Archiving ${green}completed${reset}\n" >> "${logs}"
		echo -e "$logprefix clearing the contents of the Local Dir....\n" >> "${logs}"
		rm -rf "$local_dir/"*
		if [[ $? -ne 0  ]]; then
			echo -e "$logprefix An error has occured while tring clean the Local dir of old files...\n" >> "${logs}"
			echo -e "$logprefix Exiting...\n" >> "${logs}"
			exit 1
		fi
	else
		echo -e "$logprefix Archiving has ${red}failed${reset}\n" >> "${logs}"
	fi
}

# check the size of the Local_Dir
# If it's larger than 5MB, archive the files and place in the /Archive dir
check_size() {
	current_size=$(du -shm "$local_dir" | awk '{print $1}')
	if [[ $current_size -ge $control ]]; then
		echo -e "$logprefix Local Directory size exceeds ${red}$control MB${reset}\n" >> "${logs}"
		echo -e "$logprefix Archiving Local Directory...\n" >> "${logs}"
		archive_files
	else
		echo -e "$logprefix Local directory is within limitations at: ${green}$current_size MB${reset}\n" >> "${logs}"
	fi
}
check_size

# The actual syncing process
back_it_up() {
	rsync -avz "${remote_dir}/" "${local_dir}" >> "${logs}"
	if [[ $? -eq 0 ]]; then
		echo -e "$logprefix rsync backup ${green}completed${reset}\n" >> "${logs}"
	else
		echo -e "$logprefix rsync backup ${red}failed${reset}\n" >> "${logs}"
	fi
	local_dir_size=$(du -sh "${local_dir}" | cut -d " " -f1)
	echo -e "$logprefix Current Backup Size: ${local_dir_size}\n" >> "${logs}"
}
back_it_up
echo -e "#############END BACKUP################\n\n" >> "${logs}"
