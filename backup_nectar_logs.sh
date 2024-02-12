#!/bin/bash

logs="/Backup/nectar_backup.log"
if [[ ! -f "${logs}" ]]; then
	touch "${logs}"
fi

red='\033[0;31m'
green='\033[0;32m'
reset='\033[0m'
bold='\033[1;37m'
Remote="/Backup/Remote_Dir"
Local="/Backup/Local_Dir"
rsync -av "${Remote}" "${Local}" >> "${logs}"
if [[ $? -eq 0 ]]; then
	echo -e "rsync backup ${green}completed${reset} on ${bold}$(date)${reset}\n" >> "${logs}"
else
	echo -e "rsync backup ${red}failed${reset} on ${bold}$(date)${reset}\n" >> "${logs}"
fi
Local_size=$(du -sh "${Local}" | cut -d " " -f1)
echo -e "Current Backup Size: ${Local_size}\n" >> "${logs}"
echo -e "#############END################\n\n" >> "${logs}"
