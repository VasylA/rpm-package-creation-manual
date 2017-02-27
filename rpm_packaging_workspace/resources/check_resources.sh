#!/bin/bash

# This script preforms checking of resources required during packaging process.
# All required files are listed here (see "REQUIRED PACKAGE RESOURCES LIST" section below).
# Update this if new files required for target software are added (binaries, libraries, images and so on).
#
# NOTE: Pay attention on section "2.7. Required control files under debian folder" and '$DEBIAN_REQUIRED_FILES' 
# array. There you can find all control files during packaging process.
# Also at the end of the script changelog file is updated for current distribution.


# Current path - resources directory
RESOURCES_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# 0. Include additional files
. ${RESOURCES_PATH}/../global_variables
. ${RESOURCES_PATH}/../command_style.sh



# 1. Set up variables

# *************************************************************************************************
#
# 				REQUIRED PACKAGE RESOURCES LIST
#
# *************************************************************************************************
# Executable files names
BIN_FILES=(
	"GPDownloader"
	"GPLauncher"
	"GP1"
	"GP2"
	"GP3"
	"GP4"
	"GP5"
)

# Executable files resources path
BINFILE_PATH="$RESOURCES_PATH/$ARCH_DEPENDENT_FILES_PREFIX/bin"


# Executable file links
BIN_FILE_LINKS=(
	"GPLauncher"
	"GP1"
	"GP2"
	"GP3"
	"GP4"
	"GP5"
)

# Executable files resources path
BINFILE_LINKS_PATH="$RESOURCES_PATH/usr/bin"


# Libs files names
LIB_FILES=(
	"libSilegoUSB-2.0.so.1.0.0"
	"libprinteditor.so.1.0.0"
	"libComparisonTool.so.1.0.0"
	"libSettingsModule.so.1.0.0"
	"libToolsAPI.so.1.0.0"
)

# Libs resources path
LIBS_RESOURCES_PATH="$RESOURCES_PATH/$ARCH_DEPENDENT_FILES_PREFIX/lib"


# Launcher files names:
LAUNCHER_FILES=(
	"GreenPAK1_designer.desktop"
	"GreenPAK2_designer.desktop"
	"GreenPAK3_designer.desktop"
	"GreenPAK4_designer.desktop"
	"GreenPAK5_designer.desktop"
	"GreenPAK_designer_launcher.desktop"
)

# Launcher files dir path
LAUNCHERS_PATH="$RESOURCES_PATH/usr/share/applications"


# Software documentation folders
HELP_FOLDER=help
DOCUMENTATION_FOLDER="$RESOURCES_PATH/$PREFIX"


# Resources/debian folder path
DEBIAN_RESOURCES_PATH="$RESOURCES_PATH/debian"


# Applications icons
ICON_FILES=(
	"greenpak1.png"
	"greenpak2.png"
	"greenpak3.png"
	"greenpak4.png"
	"greenpak5.png"
	"slg7.png"
)

# Applications icons resources path
ICONS_PATH="$RESOURCES_PATH/usr/share/icons/hicolor/512x512/apps"


# Mime types Icons
MYMETYPE_ICON_FILES=(
	"application-gp1-extension.svg"
	"application-gp2-extension.svg"
	"application-gp3-extension.svg"
	"application-gp4-extension.svg"
	"application-gp5-extension.svg"
)

# Mime types Icons folder path
MIME_TYPE_ICONS_DIR_PATH="$RESOURCES_PATH/usr/share/icons/hicolor/scalable/mimetypes"


# Mime types folder path
MIME_TYPES_FILE_PATH="$RESOURCES_PATH/usr/share/mime/packages"
# Mime types package file
MIME_TYPES_FILE="greenpak.xml"


# Rules folder path
RULES_FOLDER_PATH="$RESOURCES_PATH/lib/udev/rules.d"
# Rules file
RULES_FILE="40-00-silego-devices-access.rules"



# *************************************************************************************************
#
# 				END OF REQUIRED PACKAGE RESOURCES LIST
#
# *************************************************************************************************

echo_check_success()
{
	echo -e "$COLOR_BLUE   ${@}:$COLOR_reset OK"
}


# 2. Check resources
check_resources()
{
	check_folder_and_go "$RESOURCES_PATH"

	echo_title "Checking resources:"


	# 2.0. Make links on binary files
	rm -rf "$BINFILE_LINKS_PATH"
	mkdir -p "$BINFILE_LINKS_PATH"

	for file in ${BIN_FILE_LINKS[@]};
	do
		ln -s "/$ARCH_DEPENDENT_FILES_PREFIX/bin/$file" "$BINFILE_LINKS_PATH/$file"
	done


	# 2.1. Binary files
	check_folder_and_go "$BINFILE_PATH"

	# 2.1.1 Check whether binary files exist
	for file in ${BIN_FILES[@]};
	do
		if [ ! -f $file ];
		then
			echo_error "Some binary files are missed"
		fi
	done

	# 2.1.2 Make binary files executable
	for file in ${BIN_FILES[@]};
	do
		chmod +x -c $file;
	done

	echo_check_success "Binary files"


	# 2.2. Launcher files
	check_folder_and_go "$LAUNCHERS_PATH"

	# 2.2.1 Check whether launcher files exist
	for file in ${LAUNCHER_FILES[@]};
	do
		if [ ! -f $file ];
		then
			echo_error "Some .desktop files are missed"
		fi
	done

	# 2.2.2 Make launcher files executable
	for file in ${LAUNCHER_FILES[@]};
	do
		chmod +x -c $file;
	done

	echo_check_success "Launcher files"


	# 2.3. Library files
	check_folder_and_go "$LIBS_RESOURCES_PATH"

	# 2.3.1 Check whether library files exist
	for file in ${LIB_FILES[@]};
	do
		if [ ! -f $file ];
		then
			echo_error "Some library files are missed"
		fi
	done

	# 2.3.2 Make library files executable
	for file in ${LIB_FILES[@]};
	do
		chmod +x -c $file;
	done

	echo_check_success "Lib files"


	# 2.4. Device .rules file
	check_folder_and_go "$RULES_FOLDER_PATH"

	# 2.4.1 Check whether *.rules file exists
	if [ ! -f "$RULES_FILE" ];
	then
		echo_error "Device .rules file is missed"
	fi

	# 2.4.2 Prevent *.rules file to be executable
	chmod -x -c $RULES_FILE

	echo_check_success "Rules file"


	# 2.5. Application document folders
	check_folder_and_go "$DOCUMENTATION_FOLDER"

	# 2.5.1 Check whether application document folders exist
	if [ ! -d "$HELP_FOLDER" ];
	then
		echo_error "Folder $HELP_FOLDER is missed"
	fi

	# 2.5.2 Prevent help files to be executable
	#chmod -x $HELP_FOLDER

	echo_check_success "Help files"


	# 2.6. Mime type files
	check_folder_and_go "$MIME_TYPES_FILE_PATH"

	# 2.6.1 Check whether definition file exists
	if [ ! -f "$MIME_TYPES_FILE" ];
	then
		echo_error "Mimetypes definition file is missed"
	fi

	# 2.6.2 Prevent mimetypes definition file to be executable
	chmod -x -c $MIME_TYPES_FILE

	# 2.6.3 Check whether mime type icons exist
	check_folder_and_go "$MIME_TYPE_ICONS_DIR_PATH"

	for file in ${MIMETYPE_ICON_FILES[@]};
	do
		if [ ! -f $file ];
		then
			echo_error "Some mime type icons are missed"
		fi
	done

	# 2.6.4 Prevent mime type icon files to be executable
	for file in ${MIMETYPE_ICON_FILES[@]};
	do
		chmod -x -c $file;
	done

	echo_check_success "Mime type icons files"

	echo_title "Resources checking finished"


	# 2.7. Required control files
	echo_title "Checking required control files:"

	check_folder_and_go "$RESOURCES_PATH/$CONTROL_FILES_DIR"

	# 2.7.1 Check whether required control files under debian folder exist
	for file in ${REQUIRED_CONTROL_FILES[@]};
	do
	    if [ ! -f $file ];
	    then
		      echo_error "Rpm $file control file is missed in folder $CONTROL_FILES_DIR"
	    fi
	done

	if [ ! -f $RPM_SPEC_FILE ];
	then
		echo_error "Rpm spec file is missed in folder $CONTROL_FILES_DIR"
	fi
	
	echo_title "Control files checking finished"
}


#check_resources
