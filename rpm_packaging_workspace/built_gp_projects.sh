#!/bin/bash

# Current path - working directory 
WORKDIR_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# 0. Include additional files
. ${WORKDIR_PATH}/global_variables


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
		svn update $project_dir
	else
		svn checkout $project_repo $project_dir
	fi

	cd $CURR_DIR
}


# Build projects from source
build_project()
{
	local project=$1

	local CURR_DIR=$PWD

	local project_src_dir=${PROJECT_SRC_DIR[$project]}

	echo ""
	echo "Building project $project in folder $project_src_dir"

	cd ${SOURCE_DIR}/${project_src_dir}

#	if [[ -f Makefile ]];
#	then
#		make distclean
#	fi

	${QMAKE_BIN} ${QMAKE_ARG} ${PRO_FILES[$project]}
#	make -j4
	make -j${JOBS}

	cd $CURR_DIR
}

# Main function
get_and_build_greenpak_projects()
{
	mkdir -p $SOURCE_DIR
	cd $SOURCE_DIR

	echo ""
	echo ">>>>> Checkout projects:"

	for project in ${PROJECTS[@]};
	do
		svn_checkout ${project}
	done

	cd $SOURCE_DIR

	echo ""	
	echo ">>>>> Building projects:"

	for project in ${PROJECTS[@]};
	do
		build_project ${project}
	done
}
#============================================================================

# 3. Run update and build process
#get_and_build_greenpak_projects
