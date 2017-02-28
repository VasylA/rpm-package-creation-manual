#!/bin/bash

set -e

#Steps:

# 0. Setup environment:


# Current path - working directory
WORKDIR_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Include additional files
. ${WORKDIR_PATH}/global_variables
. ${WORKDIR_PATH}/command_style.sh
. ${WORKDIR_PATH}/built_gp_projects.sh
. ${WORKDIR_PATH}/$RESOURCES_DIR/check_resources.sh
. ${WORKDIR_PATH}/$RESOURCES_DIR/get_qt_resources.sh
. ${WORKDIR_PATH}/$RESOURCES_DIR/get_help_materials.sh


print_usage()
{
	echo "Usage: make [options]"
	echo "  -e, --external              Set target installation package version type as external."
	echo "  -h, --help                  Print this message and exit."
	echo "  -i, --internal              Set target installation package version type as internal."
	echo "  -v, --version VERSION       Set target installation package version to VERSION."
	echo "                              VERSION format XX.YY-ZZ, where XX - major version,"
	echo "                                                             YY - minor version,"
	echo "                                                             ZZ - build number."
}


# 1. Set up variables:

for (( i=1; i<=$#; i++));
do
	case "${!i}" in
	# Set external release mode
	-e | --external)
		if [[ "$VERSION_TYPE" == "$INTERNAL_VERSION" ]];
		then
			echo "Invalid parameters passed"
			exit 1;
		fi
                VERSION_TYPE="$EXTERNAL_VERSION"
		echo "External release mode set"
		;;
	# Set internal release mode
	-i | --internal)
		if [[ "$VERSION_TYPE" == "$EXTERNAL_VERSION" ]];
		then
			echo "Invalid parameters passed"
			exit 1;
                fi
		VERSION_TYPE="$INTERNAL_VERSION"
		echo "Internal release mode set"
		;;
	# Print usage help info
	-h | --help)
		print_usage
		exit 0;
		;;
	# Set package version
	-v | --version)
		num=$((i+1))
		SOFTWARE_VERSION="${!num}"
		;;
	# Unknown parameter
	*)
		;;
	esac
done

# Version format XX.YY-ZZ, where XX - major version,
#				 YY - minor version,
#				 ZZ - build number.
if ! [[ $SOFTWARE_VERSION =~ ^[0-9]+\.[0-9]+\-[0-9]+$ ]];
then
	echo "Invalid version parameter passed"
	exit 1;
fi

if [[ "$VERSION_TYPE" == "" ]];
then
	VERSION_TYPE="$EXTERNAL_VERSION"
fi


RESOURCES_PATH="$WORKDIR_PATH/$RESOURCES_DIR"

if [[ "$VERSION_TYPE" == "$EXTERNAL_VERSION" ]];
then
	PACKAGING_FOLDER="external_packages"
else
	PACKAGING_FOLDER="internal_packages"
fi

PACKAGING_PATH="$WORKDIR_PATH/$PACKAGING_FOLDER"


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Temporary workaround as we currently build .rpm package only for 64-bit CentOS
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ARCH_PREFIX=x86_64



BUILD_DIR="BUILD"
BUILDROOT_DIR="BUILDROOT"
RPMS_DIR="RPMS"
SRPMS_DIR="SRPMS"
SOURCES_DIR="SOURCES"
SPECS_DIR="SPECS"

declare -A RPM_BUILD_FOLDERS_PATH=(
	[$BUILD_DIR]="$PACKAGING_PATH/${BUILD_DIR}"
	[$BUILDROOT_DIR]="$PACKAGING_PATH/${BUILDROOT_DIR}"
        [$RPMS_DIR]="$PACKAGING_PATH/${RPMS_DIR}"
        [$SRPMS_DIR]="$PACKAGING_PATH/${SRPMS_DIR}"
	[$SOURCES_DIR]="$PACKAGING_PATH/${SOURCES_DIR}"	
	[$SPECS_DIR]="$PACKAGING_PATH/${SPECS_DIR}"
)

RPM_OUT_FOLDER="${RPM_BUILD_FOLDERS_PATH[$RPMS_DIR]}/$ARCH_PREFIX"


# Sandbox dir name (like <package_name>-<version>)
SANDBOX_NAME="$PACKAGE_NAME-$SOFTWARE_VERSION"
SANDBOX_PATH="${RPM_BUILD_FOLDERS_PATH[$SOURCES_DIR]}/$SANDBOX_NAME"


# 2. Create required folders
mkdir -p "$PACKAGING_PATH"

echo "%_topdir $PACKAGING_PATH" > ~/.rpmmacros

for folder_path in ${RPM_BUILD_FOLDERS_PATH[@]};
do
	rm -rf "$folder_path";
	mkdir -p "$folder_path";
done


# 3. Get projects source and build it (see built_gp_projects.sh)
get_and_build_greenpak_projects


# 4. Copy compiled binaries and libs to packaging folder
check_folder_and_go $WORKDIR_PATH

mkdir -p "$RESOURCES_DIR/$BIN_FILES_RESOURCES_DIR"
cp -P $WORKDIR_PATH/$OUTPUT_BINS_FOLDER/GP* "$RESOURCES_DIR/$BIN_FILES_RESOURCES_DIR"

mkdir -p "$RESOURCES_DIR/$LIB_FILES_RESOURCES_DIR"
cp -P $WORKDIR_PATH/$OUTPUT_BINS_FOLDER/*.so.* "$RESOURCES_DIR/$LIB_FILES_RESOURCES_DIR"


# 5. Generate help materials (see resources/get_help_materials.sh)
get_help_materials


# 6. Check packaging resources (see resources/check_resources.sh)
check_resources


# 7. Get required Qt resources (see resources/get_qt_resources.sh)
get_required_qt_resources


# 8. Setup sandbox
check_folder_and_go $PACKAGING_PATH

# 8.1 Create sandbox (<package_name>-<version> format)
mkdir -p "$SANDBOX_PATH"


# 8.2. Copy all the resources to sandbox
check_folder_and_go "$RESOURCES_PATH"

for folder in ${RESOURCES_FOLDERS[@]};
do
	if [ ! -d  $folder ];
	then
		echo_error "No $folder folder in $RESOURCES_PATH"
	fi

	cp -P -r $folder "$SANDBOX_PATH"
done


# 8.3. Copy rpm .spec file to SPECS folder
spec_file_path="$RESOURCES_PATH/$CONTROL_FILES_DIR/$RPM_SPEC_FILE"
cp "$spec_file_path" "${RPM_BUILD_FOLDERS_PATH[$SPECS_DIR]}"


# 8.4. Compress $SANDBOX_PATH folder
check_folder_and_go "${RPM_BUILD_FOLDERS_PATH[$SOURCES_DIR]}"

PACKED_SANDBOX=$SANDBOX_NAME.tar.gz
tar -czf "$PACKED_SANDBOX" "$SANDBOX_NAME"


# 9. Build .rpm package
echo_title "Building installation package..."


# 9.1. Run rpmbuild tool in $SANDBOX_PATH 
check_folder_and_go "${RPM_BUILD_FOLDERS_PATH[$SPECS_DIR]}"
run_and_check_silent rpmbuild -bb -vv "$spec_file_path"


# 9.2. Remove all unnecessary files from packaging directory
check_folder_and_go "$PACKAGING_PATH"


# 9.3. Remove $SANDBOX_PATH if required
rm -rf "$SANDBOX_PATH"


# 9.4. Verify if .rpm package created
if [ "ls *.rpm > /dev/null" ];
then
	echo_title "Installation package successfully created"
else
	echo_error "Error while creating installation package"
fi


# 9.5 Move .rpm packache to packaging folder
package_file_name="$PACKAGE_NAME-$SOFTWARE_VERSION.$ARCH_PREFIX.rpm"
cp "$RPM_OUT_FOLDER/$package_file_name" "$PACKAGING_PATH"


# 9.6 Remove special build folders if required
cd "$PACKAGING_PATH"
for folder_path in ${RPM_BUILD_FOLDERS_PATH[@]};
do
	rm -rf "$folder_path";
done


# 9.7. Check .rpm package with rpmlint tool
#echo_title "Checking .rpm package with rpmlint tool..."

#cd "$PACKAGING_PATH"
#rpmlint $package_file_name
