#!/bin/bash

# This script generates help materials (.html files and images) required by application.
# All required files are generated from redmine wiki content using python script
# (see "$SCRIPT_EXEC_PATH" for more details).
# To change revisions list modify 'global_variables' file.


# Current path - resources directory
RESOURCES_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# 0. Include additional files
. ${RESOURCES_PATH}/../global_variables
. ${RESOURCES_PATH}/../command_style.sh

SCRIPT_EXEC_PATH="$RESOURCES_PATH/doc-convert.py"
TARGET_DIR_PATH="$RESOURCES_PATH/$PROGRAM_INSTALLATION_ROOT/help"

#==============================Local functions================================
echo_revision_passed()
{
	echo -e "$COLOR_BLUE   ${@}:$COLOR_reset OK"
}

echo_revision_skipped()
{
	echo -e "$COLOR_BLUE   ${@}:$COLOR_reset SKIPPED"
}

get_help_materials()
{
	echo_title "Help materials generation"

	# 1. Remove target folder it exists
	if [ -d  $TARGET_DIR_PATH ];
	then
		rm -rf $TARGET_DIR_PATH
	fi

	# 2. Create target folder
	mkdir -p $TARGET_DIR_PATH

	# 3. Make help materials for every chip reviison
	for revision in ${CHIP_REVISIONS[@]};
	do
		# 3.1. Don't make help files for internal chip revision in public version
		if [ ${CHIP_REVISIONS_VERSION_MAP[$revision]} == "$INTERNAL_VERSION" ] && [ "$VERSION_TYPE" == "$EXTERNAL_VERSION" ];
		then
			echo_revision_skipped "$revision"
			continue
		fi

		run_silent python $SCRIPT_EXEC_PATH --path $TARGET_DIR_PATH --revision $revision

		# 3.2. Make individual documents (State Machine Editor help materials)
		if [[ $revision =~ ^SLG465[0-9]{2}[M,V]{1}$ ]];
		then
			page_name="State_Machine_Editor_($revision)"
			run_silent python $SCRIPT_EXEC_PATH --path $TARGET_DIR_PATH --page $page_name
		fi

		echo_revision_passed "$revision"
	done
}
#=============================================================================


#get_help_materials
