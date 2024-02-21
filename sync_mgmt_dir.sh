working_dir="/Backup"
logs="$working_dir/nectar_backup.log"
mgmt_dir="$HOME/MGMT"
red='\033[0;31m'
green='\033[0;32m'
bold='\033[1;37m'
reset='\033[0m'
logprefix="${bold}$(date)${reset}"

diff_output=$(diff -r "$working_dir" "$mgmt_dir" )
is_different=$?

# Make sure all directories exist
# If that passes, check if there is a difference between mgmt and Backup dirs
# if there's a diff, update the links in mgmt
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

echo -e "$logprefix ######## END Sync MGMT DIR ########\n" >> "$logs"
