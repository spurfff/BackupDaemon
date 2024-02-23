#!/bin/bash


working_dir="/Backup"
logs="$working_dir/nectar_backup.log"
red='\033[0;31m'
green='\033[0;32m'
blue='\033[1;36m'
gray='\033[1;30m'
yellow='\033[1;33m'
bold='\033[1;37m'
underline='\033[4m'
reset='\033[0m'
remote_dir="$working_dir/Remote_Dir"
local_dir="$working_dir/Local_Dir"
archive_dir="$working_dir/Archive"
mgmt_dir="$HOME/MGMT"
backup_name="NectarLogBackup"
logprefix="${bold}$(date)${reset}"
remote_server="10.37.3.16"
control=5

# Make sure that the Backup directory and .log file are in place as expected
check_for_backupsAndLogs() {
if [[ -d "$working_dir" ]]; then
	echo -e "$logprefix ${green}Detected${reset} $working_dir\n" >> "${logs}"
	if [[ -f "${logs}" ]]; then
		echo -e "$logprefix ${green}Detected${reset} $logs\n" >> "${logs}"
	else
		echo -e "$logprefix $logs not found\n" >> "${logs}"
		echo -e "$logprefix Creating log file...\n" >> "${logs}"
		touch "$logs"
		if [[ $? -ne 0 ]]; then
			echo -e "$logprefix An ${red}error${reset} has occured while trying to create the log file at $logs \n" >> "${logs}"
			exit 1
		fi
	fi
else
	echo -e "$logprefix $working_dir not detected...\n" >> "${logs}"
	echo -e "$logprefix Exiting with errors...\n" >> "${logs}"
	exit 1
fi
}

# Make sure that the Remote dir is mounted at the Remote_dir location
check_remote_dir() {
	if [[ -z "$(df -t cifs)" ]]; then
		df_output=$(df -t cifs)
		df_exit_code=$?
		echo -e "$logprefix Exit code: $df_exit_code\n" >> "${logs}"
		if [[ $df_exit_code -ne 0 ]]; then
			echo -e "$logprefix Failed to find Remote directory\n" >> "${logs}"
			echo -e "$logprefix Exiting with errors...\n" >> "${logs}"
			exit 1
		fi
		echo -e "$logprefix ${red}ERROR${reset} - Output from df: $df_output\n" >> "${logs}"
	else
		echo -e "$logprefix ${green}Detected${reset} Remote directory\n" >> "${logs}"
	fi
}

# Create a function to archive files if they exceed the size specified by the control variable
archive_files() {
	tar -czvf "${archive_dir}/$backup_name$(date +%Y%m%d_%H%M%S).tar.gz" "${local_dir}/"* &>"${logs}"
	if [[ $? -eq 0 ]]; then
		echo -e "$logprefix Archiving ${green}completed${reset}\n" >> "${logs}"
		echo -e "$logprefix clearing the contents of the Local Dir....\n" >> "${logs}"
		rm -rf "$local_dir/"*
		if [[ $? -ne 0  ]]; then
			echo -e "$logprefix An error has occured while attempting to clean old files from $local_dir...\n" >> "${logs}"
			echo -e "$logprefix Exiting...\n" >> "${logs}"
			exit 1
		fi
	else
		echo -e "$logprefix Archiving has ${red}failed${reset}\n" >> "${logs}"
	fi
}

# check the size of the Local_Dir
# If it's larger than 5MB, archive the files and place in the /Archive dir
# to accomplish this, use the archive_files
check_size() {
	echo -e "$logprefix ${blue}STARTING:${reset} Check Size and Archive\n" >> "${logs}"
	current_size=$(du -shm "$local_dir" | awk '{print $1}')
	if [[ $current_size -ge $control ]]; then
		echo -e "$logprefix Local Directory size exceeds ${red}$control MB${reset}\n" >> "${logs}"
		echo -e "$logprefix Archiving Local Directory...\n" >> "${logs}"
		archive_files
	else
		echo -e "$logprefix Local directory is within limitations at/under: ${green}$current_size MB${reset}\n" >> "${logs}"
	fi
}

# The actual syncing process
back_it_up() {
	echo -e "$logprefix ${blue}STARTING:${reset} Backup Remote Directory\n" >> "${logs}"
	if [[ ! -f /usr/bin/rsync ]]; then
		echo -e "$logprefix Unable to find rsync binaries...\n" >> "${logs}"
	else
		echo -e "$logprefix ${green}Detected${reset} rsync binaries on system\n" >> "${logs}"
	fi


	rsync -avz "${remote_dir}/" "${local_dir}" >> "${logs}"
	if [[ $? -eq 0 ]]; then
		echo -e "$logprefix ${green}completed${reset} rsync backup\n" >> "${logs}"
	else
		echo -e "$logprefix ${red}failed${reset} rsync backup\n" >> "${logs}"
	fi
	local_dir_size=$(du -sh "${local_dir}" | awk '{ print $1 }')
	echo -e "$logprefix Current Backup Size: ${bold}${underline}${local_dir_size}${reset}\n" >> "${logs}"
	echo -e "$logprefix ######## ${gray}FINISHED Backup${reset} ########\n" >> "${logs}"
}

# In the users home directory, there should be a directory called MGMT
# This dir contains sym links to files important to the script
# This function ensures that the MGMT dir is updated with these links
sync_mgmt_dir() {
	diff_output=$(diff -r "$working_dir" "$mgmt_dir" )
	is_different=$?
	echo -e "$logprefix ${blue}STARTING:${reset} Sync MGMT Directory\n" >> "${logs}"
	if [[ -f "$logs" && -d "$working_dir" && -d "$mgmt_dir" ]]; then
		if [[ $is_different -eq 0  ]]; then
			echo -e "$logprefix $working_dir and $mgmt_dir are ${green}in sync${reset}\n" >> "$logs"
		else
			echo -e "$logprefix $working_dir and $mgmt_dir are out of sync ${red}out of sync${reset}\n" >> "$logs"
			echo -e "$logprefix Updating Sym Links...\n" >> "$logs"
			old_contents=$(ls -1 "$mgmt_dir")
			ln -s "$working_dir"/* "$mgmt_dir" 2>>"$logs"
			new_contents=$(ls -1 "$mgmt_dir")
			echo -e "$logprefix OLD CONTENTS: ${red}$old_contents${reset}\n" >> "$logs"
			echo -e "$logprefix NEW CONTENTS: ${green}$new_contents${reset}\n" >> "$logs"
		fi
	else
		important_dirs=("$logs" "$working_dir" "$mgmt_dir")
		for dir in "${important_dirs[@]}"; do
			if [[ ! -d "$dir" ]]; then
				echo -e "$logprefix $dir does ${red}NOT${reset} exist\n" >> "$logs"
			fi
		done
	fi

	echo -e "$logprefix ######## ${gray}FINISHED Sync MGMT DIR${reset} ########\n" >> "$logs"
}

echo -e "$logprefix ${yellow}STARTING${reset}\n" >> "${logs}"
check_for_backupsAndLogs
check_remote_dir
check_size
back_it_up
sync_mgmt_dir
echo -e "$logprefix ${gray}~~~~END~~~~${reset}\n\n ---- \n\n" >> "${logs}"
