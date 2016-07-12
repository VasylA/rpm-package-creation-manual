#!/bin/bash

# Current path - resources directory 
RESOURCES_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# 0. Include additional files
. ${RESOURCES_PATH}/../global_variables


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


	if [ ! -d "$qt_resources_root" ];
	then 
	    echo "Qt resources were not found in $qt_resources_root"
	    exit 2;
	fi


	cd $RESOURCES_PATH

	local local_resources_root="$ARCH_DEPENDENT_FILES_PREFIX"	
	mkdir -p $local_resources_root

	cd "$RESOURCES_PATH/$local_resources_root"

	mkdir -p "bin/"
	cd "bin/"

	cp "$webengine_bin" .

	mkdir -p "platforms/"
	cp "$xcb_paltform_plugin" "platforms/"


	cd "$RESOURCES_PATH/$local_resources_root"

	mkdir -p "plugins/"
	cp -r "$plugins_folder" "plugins/"

	cp -r "$qt_resources_root/resources/" .

	mkdir -p "translations/"
	cp -r "$locales_folder" "translations/"


	mkdir -p "lib/"
	cd "$qt_libs_folder"

	for file in ${required_qt_libs[@]};
	do
	    filemask=$file.$libs_extension;
	    cp -P $filemask "$RESOURCES_PATH/$local_resources_root/lib/";
	done

	echo "Requred Qt resources were copied to local resources folder"

	
	cd "$graphviz_resources_root"
	
#	for file in ${graphviz_required_libs[@]};
#	do
#	    filemask=$file.$libs_extension;
#	    cp -P $filemask "$RESOURCES_PATH/$local_resources_root/lib/";
#	done
#	cp -P -r "$graphviz_plugins_folder" "$RESOURCES_PATH/$local_resources_root/lib/"


#	cd "$libusb_resources_root"
#	cp -P -v "$libusb_lib_name.$libs_extension" "$RESOURCES_PATH/$local_resources_root/lib/"


        cp -P -r "$required_extra_libs_root" "$RESOURCES_PATH/$local_resources_root/"

	echo "Requred extra resources were copied to local resources folder"

	cd $RESOURCES_PATH
}
#=============================================================================


#get_required_qt_resources

