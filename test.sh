#!/bin/bash

dir_size=$(du -sh /Backup/Local_Dir | awk '{ print $1 }')
dir_size_without_suffix=${dir_size//[MGK]/}
echo "$dir_size_without_suffix"
if [ -z "${dir_size_without_suffix//[0-9]}" ]; then
    if [ -n "$dir_size_without_suffix" ]; then
	echo "$0 - integers found."
    fi
else
	echo "$0 - integers NOT found."
fi
