#!/bin/bash

# Current path - resources directory 
RESOURCES_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# 0. Include additional files
. ${RESOURCES_PATH}/../global_variables
. ${RESOURCES_PATH}/../command_style.sh


#==============================Local functions================================
get_required_qt_resources()
{
	local qt_resources_root=$QT_FOLDER
	local libusb_resources_root="/opt/projects/libusb/libusb/.libs"
	local graphviz_resources_root="/opt/greenpak/lib"
	local required_extra_libs_root="/opt/greenpak/lib"

	# ****************************************************************************************
	#
	# 				REQUIRED QT RESOURCES
	#
	# ****************************************************************************************
	# Update this section in future if required.
	local webengine_bin="$qt_resources_root/libexec/QtWebEngineProcess"
	local xcb_paltform_plugin="$qt_resources_root/plugins/platforms/libqxcb.so"
	local plugins_folder="$qt_resources_root/plugins/xcbglintegrations/"
	local locales_folder="$qt_resources_root/translations/qtwebengine_locales/"
	local qt_libs_folder="$qt_resources_root/lib/"
	local required_qt_libs=(
		"libQt5Core"
		"libQt5DBus"
		"libQt5Gui"
		"libQt5Network"
		"libQt5OpenGL"
		"libQt5Positioning"
		"libQt5PrintSupport"
		"libQt5Qml"
		"libQt5Quick"
		"libQt5WebChannel"
		"libQt5WebEngineCore"
		"libQt5WebEngineWidgets"
		"libQt5Widgets"
		"libQt5XcbQpa"
		"libQt5Xml"
	)

	local graphviz_required_libs=(
		"libcdt"
		"libcgraph"
		"libgvc"
		"libgvpr"
		"libpathplan"
		"libxdot"
	)	
	local graphviz_plugins_folder="graphviz"	
	
	local libusb_lib_name="libusb"
	#
	# ****************************************************************************************
	#
	local libs_extension="so.*"


	echo_title "Setting up requred extra resources in local resources folder"

	if [ ! -d "$qt_resources_root" ];
	then 
	    echo_error "Qt resources were not found in $qt_resources_root"
	fi


	check_folder_and_go $RESOURCES_PATH

	local local_resources_root="$ARCH_DEPENDENT_FILES_PREFIX"	
	mkdir -p $local_resources_root

	check_folder_and_go "$RESOURCES_PATH/$local_resources_root"

	mkdir -p "bin/"
	check_folder_and_go "bin/"

	cp "$webengine_bin" .

	mkdir -p "platforms/"
	cp "$xcb_paltform_plugin" "platforms/"


	check_folder_and_go "$RESOURCES_PATH/$local_resources_root"

	mkdir -p "plugins/"
	cp -r "$plugins_folder" "plugins/"

	cp -r "$qt_resources_root/resources/" .

	mkdir -p "translations/"
	cp -r "$locales_folder" "translations/"


	mkdir -p "lib/"
	check_folder_and_go "$qt_libs_folder"

	for file in ${required_qt_libs[@]};
	do
	    filemask=$file.$libs_extension;
	    cp -P $filemask "$RESOURCES_PATH/$local_resources_root/lib/";
	done

	
#	check_folder_and_go "$graphviz_resources_root"
	
#	for file in ${graphviz_required_libs[@]};
#	do
#	    filemask=$file.$libs_extension;
#	    cp -P $filemask "$RESOURCES_PATH/$local_resources_root/lib/";
#	done
#	cp -P -r "$graphviz_plugins_folder" "$RESOURCES_PATH/$local_resources_root/lib/"


#	check_folder_and_go "$libusb_resources_root"
#	cp -P -v "$libusb_lib_name.$libs_extension" "$RESOURCES_PATH/$local_resources_root/lib/"


        cp -P -r "$required_extra_libs_root" "$RESOURCES_PATH/$local_resources_root/"

	check_folder_and_go $RESOURCES_PATH
}
#=============================================================================


#get_required_qt_resources

