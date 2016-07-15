#!/bin/bash

# Current path - working directory 
WORKDIR_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# 0. Include additional files
. ${WORKDIR_PATH}/global_variables
. ${WORKDIR_PATH}/command_style.sh


# 1. Set up variables:
SOURCE_DIR="$WORKDIR_PATH/$PROJECTS_FOLDER"

CORE_NUM=`grep -c -e '^processor' /proc/cpuinfo`
JOBS=$(( ${CORE_NUM} * 2 ))


#==============================Local functions================================
# Checkout or update projects
svn_checkout()
{
	local project=$1

	local CURR_DIR=$SOURCE_DIR

	local project_dir=${PROJECT_DIR[$project]}
	local project_repo=${REPOS[$project]}

	if [[ -d $project_dir ]]
	then
		run_and_check svn switch $project_repo $project_dir
	else
		run_and_check svn checkout $project_repo $project_dir
	fi

	cd $CURR_DIR
}


# Build projects from source
build_project()
{
	local project=$1

	local CURR_DIR=$PWD

	local project_src_dir=${PROJECT_SRC_DIR[$project]}

	echo -e "Building project ${COLOR_green}$project${COLOR_reset} in folder ${COLOR_cyanic}$project_src_dir${COLOR_reset}"

	check_folder_and_go ${SOURCE_DIR}/${project_src_dir}

#	if [[ -f Makefile ]];
#	then
#		run_and_check_silent make distclean
#	fi

	${QMAKE_BIN} ${QMAKE_ARG} ${PRO_FILES[$project]}

#	run_and_check_silent make -j4
	run_and_check_silent make -j${JOBS}
	echo

	check_folder_and_go $CURR_DIR
}

# Main function
get_and_build_greenpak_projects()
{
	mkdir -p $SOURCE_DIR
	check_folder_and_go $SOURCE_DIR

	echo_title "Checkout projects:"

	for project in ${PROJECTS[@]};
	do
		svn_checkout ${project}
	done

	check_folder_and_go $SOURCE_DIR

	echo_title "Building projects:"

	for project in ${PROJECTS[@]};
	do
		build_project ${project}
	done
}
#============================================================================

# 3. Run update and build process
#get_and_build_greenpak_projects
