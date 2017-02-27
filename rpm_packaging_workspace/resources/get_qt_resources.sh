#!/bin/bash

# This script preforms checking of Qt resources required by application.
# All required files are listed here (see "REQUIRED QT RESOURCES" section below).
# Update this if new Qt dependencies added (e. g. libraries, plugins, etc).
#
# NOTE: Pay attention on '$required_qml_folders' array. "QtQuick" folder is skipped here
# because only some folders from this dir are required. See required_qtquick_folders array.


# Current path - resources directory
RESOURCES_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# 0. Include additional files
. ${RESOURCES_PATH}/../global_variables
. ${RESOURCES_PATH}/../command_style.sh


#==============================Local functions================================
get_required_qt_resources()
{
	local qt_resources_root=$QT_FOLDER
#	local libusb_resources_root="/opt/projects/libusb/libusb/.libs"
#	local graphviz_resources_root="/opt/greenpak/lib"
#	local required_extra_libs_root="/opt/greenpak/lib"

	# ****************************************************************************************
	#
	# 				REQUIRED QT RESOURCES
	#
	# ****************************************************************************************
	# Update this section in future if required.
	local webengine_bin="$qt_resources_root/libexec/QtWebEngineProcess"
	local xcb_paltform_plugin="$qt_resources_root/plugins/platforms/libqxcb.so"

	local sql_plugins_folder="$qt_resources_root/plugins/sqldrivers/"
	local xcb_plugins_folder="$qt_resources_root/plugins/xcbglintegrations/"
	local imageformats_plugins_folder="$qt_resources_root/plugins/imageformats/"

	local locales_folder="$qt_resources_root/translations/qtwebengine_locales/"

	local qt_libs_folder="$qt_resources_root/lib/"
	local qt_qml_folder="$qt_resources_root/qml/"

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
		"libQt5QuickControls2"
		"libQt5QuickTemplates2"
		"libQt5Sql"
		"libQt5WebChannel"
		"libQt5WebEngine"
		"libQt5WebEngineCore"
		"libQt5WebEngineWidgets"
		"libQt5WebView"
		"libQt5Widgets"
		"libQt5XcbQpa"
		"libQt5Xml"
	)

	local required_imageformat_plugins=(
		"libqjpeg"
		"libqgif"
	)

	local required_qml_folders=(
		"QtQml"
#		"QtQuick"	- handled only some folders from this dir. See required_qtquick_folders array.
		"QtQuick.2"
		"QtGraphicalEffects"
	)

	local required_qtquick_folders=(
		"Controls"
		"Controls.2"
		"Layouts"
		"Templates.2"
		"Window.2"
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
	local plugins_extension="so"


	echo_title "Setting up requred extra resources in local resources folder"

	if [ ! -d "$qt_resources_root" ];
	then
		echo_error "Qt resources were not found in $qt_resources_root"
	fi


	check_folder_and_go $RESOURCES_PATH

	local local_resources_root="$ARCH_DEPENDENT_FILES_PREFIX"
	mkdir -p $local_resources_root


	# 1. Binaries
	check_folder_and_go "$RESOURCES_PATH/$local_resources_root"

	mkdir -p "bin/"
	check_folder_and_go "bin/"

	cp "$webengine_bin" .

	mkdir -p "platforms/"
	cp "$xcb_paltform_plugin" "platforms/"


	# 2. Plugins
	check_folder_and_go "$RESOURCES_PATH/$local_resources_root"

	mkdir -p "plugins/"
	cp -r "$xcb_plugins_folder" "plugins/"
	cp -r "$sql_plugins_folder" "plugins/"

	mkdir -p "plugins/imageformats/"
	for file in ${required_imageformat_plugins[@]};
	do
		filemask=$file.$plugins_extension;
		cp -P $imageformats_plugins_folder/$filemask "plugins/imageformats/";
	done


	# 3. Webengine resources
	check_folder_and_go "$RESOURCES_PATH/$local_resources_root"
	cp -r "$qt_resources_root/resources/" .


	# 4. QML resources
	check_folder_and_go "$RESOURCES_PATH/$local_resources_root"

	mkdir -p "qml/"
	for folder in ${required_qml_folders[@]};
	do
		cp -r "$qt_qml_folder/$folder" "qml/"
	done

	mkdir -p "qml/QtQuick"
	for folder in ${required_qtquick_folders[@]};
	do
		cp -r "$qt_qml_folder/QtQuick/$folder" "qml/QtQuick/"
	done


	# 5. Locales
	check_folder_and_go "$RESOURCES_PATH/$local_resources_root"

	mkdir -p "translations/"
	cp -r "$locales_folder" "translations/"


	# 6. Libraries
	mkdir -p "lib/"
	check_folder_and_go "$qt_libs_folder"

	for file in ${required_qt_libs[@]};
	do
		filemask=$file.$libs_extension;
		cp -P $filemask "$RESOURCES_PATH/$local_resources_root/lib/";
	done


	# 7. GrapgViz libraries
#	check_folder_and_go "$graphviz_resources_root"

#	for file in ${graphviz_required_libs[@]};
#	do
#	    filemask=$file.$libs_extension;
#	    cp -P $filemask "$RESOURCES_PATH/$local_resources_root/lib/";
#	done
#	cp -P -r "$graphviz_plugins_folder" "$RESOURCES_PATH/$local_resources_root/lib/"


#	check_folder_and_go "$libusb_resources_root"
#	cp -P -v "$libusb_lib_name.$libs_extension" "$RESOURCES_PATH/$local_resources_root/lib/"


#	cp -P -r "$required_extra_libs_root" "$RESOURCES_PATH/$local_resources_root/"

	check_folder_and_go $RESOURCES_PATH
}
#=============================================================================


#get_required_qt_resources

