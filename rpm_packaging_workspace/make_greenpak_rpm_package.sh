#!/bin/bash

set -e 

#Steps:

# 0. Setup environment:
#    sudo apt-get update
#    sudo apt-get install subversion


# 1. Set up variables:
if [ "$1" != "-v" ];
then
    echo_error "Invalid version parameter passed"
    exit 1;
fi

SOFTWARE_VERSION="$2"

# Current path - working directory 
WORKDIR_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Include additional files
. ${WORKDIR_PATH}/global_variables
. ${WORKDIR_PATH}/command_style.sh
. ${WORKDIR_PATH}/built_gp_projects.sh
. ${WORKDIR_PATH}/$RESOURCES_DIR/check_resources.sh
. ${WORKDIR_PATH}/$RESOURCES_DIR/get_qt_resources.sh


RESOURCES_PATH="$WORKDIR_PATH/$RESOURCES_DIR"

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
SOURCES_DIR="SOURCES"
SPECS_DIR="SPECS"

declare -A RPM_BUILD_FOLDERS_PATH=(
	[$BUILD_DIR]="$PACKAGING_PATH/${BUILD_DIR}"
	[$BUILDROOT_DIR]="$PACKAGING_PATH/${BUILDROOT_DIR}"
	[$RPMS_DIR]="$PACKAGING_PATH/${RPMS_DIR}"
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


# 5. Check packaging resources (see resources/check_resources.sh)
check_resources


# 6. Get required Qt resources (see resources/get_qt_resources.sh)
get_required_qt_resources


# 7. Setup sandbox
check_folder_and_go $PACKAGING_PATH

# 7.1 Create sandbox (<package_name>-<version> format)
mkdir -p "$SANDBOX_PATH"


# 7.2. Copy all the resources to sandbox
check_folder_and_go "$RESOURCES_PATH"

for folder in ${RESOURCES_FOLDERS[@]};
do
    if [ ! -d  $folder ];
    then
         echo_error "No $folder folder is missed in $RESOURCES_PATH"
    fi

    cp -P -r $folder "$SANDBOX_PATH"
done


# 7.3. Copy rpm .spec file to SPECS folder
spec_file_path="$RESOURCES_PATH/$CONTROL_FILES_DIR/$RPM_SPEC_FILE"
cp "$spec_file_path" "${RPM_BUILD_FOLDERS_PATH[$SPECS_DIR]}"


# 7.4. Compress $SANDBOX_PATH folder
check_folder_and_go "${RPM_BUILD_FOLDERS_PATH[$SOURCES_DIR]}"

PACKED_SANDBOX=$SANDBOX_NAME.tar.gz
tar -czf "$PACKED_SANDBOX" "$SANDBOX_NAME"


# 8. Build .rpm package
echo_title "Building installation package..."


# 8.1. Run dpkg-buildpackage tool in $SANDBOX_PATH 
check_folder_and_go "${RPM_BUILD_FOLDERS_PATH[$SPECS_DIR]}"
run_and_check_silent rpmbuild -bb -vv "$spec_file_path"


# 8.2. Remove $SANDBOX_PATH if required
rm -rf "$SANDBOX_PATH"


# 8.3. Verify if .rpm package created
if [ "ls *.rpm > /dev/null" ]; 
then 
    echo_title "Installation package successfully created"
else 
    echo_error "Error while creating installation package"
fi


# 8.4 Move .rpm packache to packaging folder
package_file_name="$PACKAGE_NAME-$SOFTWARE_VERSION.$ARCH_PREFIX.rpm"
cp "$RPM_OUT_FOLDER/$package_file_name" "$PACKAGING_PATH"


# 8.5 Remove special build folders if required
cd "$PACKAGING_PATH"
for folder_path in ${RPM_BUILD_FOLDERS_PATH[@]};
do
    rm -rf "$folder_path";
done


# 8.6. Check .rpm package with rpmlint tool
#echo_title "Checking .deb package with rpmlint tool..."

#cd "$PACKAGING_PATH"
#rpmlint $package_file_name
