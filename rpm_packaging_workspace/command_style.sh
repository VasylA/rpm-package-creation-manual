#!/bin/bash

#
# General variables
#
COLOR_black="\033[0;30m"
COLOR_red="\033[0;31m"
COLOR_green="\033[0;32m"
COLOR_yellow="\033[0;33m"
COLOR_blue="\033[0;34m"
COLOR_magenta="\033[0;35m"
COLOR_cyanic="\033[0;36m"
COLOR_white="\033[0;37m"

COLOR_BLACK="\033[1;30m"
COLOR_RED="\033[1;31m"
COLOR_GREEN="\033[1;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_BLUE="\033[1;34m"
COLOR_MAGENTA="\033[1;35m"
COLOR_CYANIC="\033[1;36m"
COLOR_WHITE="\033[1;37m"

COLOR_reset="\033[0;00m"

#
# Functions
#
echo_title()
{
	echo
	echo -e "${COLOR_MAGENTA}${@}${COLOR_reset}"
	echo
}

echo_subtitle()
{
	echo
	echo -e "${COLOR_YELLOW}${@}${COLOR_reset}"
}

echo_variable()
{
	echo -e "${COLOR_CYANIC}${@}${COLOR_reset}"
}

echo_error()
{
	echo
	echo -e "${COLOR_RED}${@}${COLOR_reset}"
	echo

	exit 1;
}

run_and_check()
{
	echo -e "Running ${COLOR_green}${@}${COLOR_reset} from ${COLOR_cyanic}${PWD}${COLOR_reset}"

	$@ || exit 1
}

run_and_check_silent()
{
	echo -en "Running ${COLOR_green}${@}${COLOR_reset} from ${COLOR_cyanic}${PWD}${COLOR_reset}"

	if ! err=$($@ 2>&1 >/dev/null) ;
	then
		echo
		echo
		echo -e "${COLOR_RED}Error output:${COLOR_reset}"
		echo -e "${COLOR_red}$err${COLOR_reset}"
		echo
		echo -e "${COLOR_green}${@}${COLOR_reset} in ${COLOR_cyanic}${PWD}${COLOR_reset}: Failure"
		exit 1
	fi

	echo ": Success"
}

run_silent()
{
        if ! err=$($@ 2>&1 >/dev/null) ;
        then
                echo
                echo
                echo -e "${COLOR_RED}Error output:${COLOR_reset}"
                echo -e "${COLOR_red}$err${COLOR_reset}"
                echo
                echo -e "${COLOR_green}${@}${COLOR_reset} in ${COLOR_cyanic}${PWD}${COLOR_reset}: Failure"
                exit 1
        fi
}

check_folder_and_go()
{
	local dir_name=${@};

	if [ ! -d "$dir_name" ];
	then
	    echo_error "Folder $dir_name is missed"
	fi

	cd $dir_name
}
