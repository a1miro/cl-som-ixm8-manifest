#!/usr/bin/env bash

# This scripts is used to setup the environment for the Yocto build system.
# It's a wrapper around the oe-init-build-env script. 
ARGS="$@"
MACHINE="imx8mqevk"
DISTRO="fsl-imx-xwayland"

META_LAYERS=(
"meta-compulab" 
"meta-compulab-bsp/meta-desktop"
"meta-compulab-bsp/meta-multimedia"
"meta-compulab-bsp/meta-graphics"
"meta-compulab-bsp/meta-bsp"
"meta-bsp-imx8mq"
)

usage()
{
    echo "Usage:" 
    echo "/t source imx-setup-release.sh <build-dir>"
}

# check if we got the build directory as argument
if [ ! -z "${ARGS[0]}" ]; then
    BUILDDIR="${ARGS[0]}"
fi

# Check if the symlink to imx-setup-release.sh exists
if [ ! -L imx-setup-release.sh ]; then
    echo "ERROR: imx-setup-release.sh symlink not found. Run this script from the root of the build directory."
    exit 1
fi

# Check if the symlink to setup-environment exists
if [ ! -L setup-environment ]; then
    echo "ERROR: setup-environment symlink not found. Run this script from the root of the build directory."
    exit 1
fi

# Check if the build directory exists, if it does not then we source imx_setup_release.sh,
# otherwise we call setup-environment and pass the build directory as an only argument.
if [ -z ${BUILDDIR} ]  || [ ! -d "${BUILDDIR}" ]; then
    BUILDDIR="build"
    MACHINE=${MACHINE} DISTRO=${DISTRO} source ./imx-setup-release.sh -b "${BUILDDIR}"
else
    source ./setup-environment "${BUILDDIR}"
fi

echo "BUILDDIR=${BUILDDIR}"


BBLAYERS_CONF="${BUILDDIR}/conf/bblayers.conf"
LOCAL_CONF="${BUILDDIR}/conf/local.conf"

echo "BBLAYERS_CONF=${BBLAYERS_CONF}"
echo "LOCAL_CONF=${LOCAL_CONF}"

# Now, we inside the build directory, we can now update the local.conf and bblayers.conf files
# Let's add the meta-layers to the bblayers.conf file
for layer in "${META_LAYERS[@]}"; do
    grep -E "^BBLAYERS[[:space:]]?\+\=[[:space:]]?\"\\$\{BSPDIR}\/${layer}\"[[:space:]]?$" ${BBLAYERS_CONF} &> /dev/null
    if [ $? -ne "0" ] ; then
        echo "BBLAYERS += \"\${BSPDIR}/sources/${layer}\"" >> ${BBLAYERS_CONF}
    fi
done

# Update the local.conf with some variables
grep -E "^[[:space:]]?PACKAGE_CLASSES[[:space:]]?\=[[:space:]]?\"package_ipk\"[[:space:]]?$" ${LOCAL_CONF} &> /dev/null
if [ $? -ne "0" ] ; then
  echo 'PACKAGE_CLASSES = "package_deb"' >> ${LOCAL_CONF}
fi

grep -E "^[[:space:]]?EXTRA_IMAGE_FEATURES[[:space:]]?\+\=[[:space:]]?\"package-management\"[[:space:]]?$" ${LOCAL_CONF} &> /dev/null
if [ $? -ne "0" ] ; then
  echo 'EXTRA_IMAGE_FEATURES += "package-management"' >> ${LOCAL_CONF}
fi

grep -E "^[[:space:]]?DL_DIR[[:space:]]?\=[[:space:]]?\"downloads\"[[:space:]]?$" ${LOCAL_CONF} &> /dev/null
if [ $? -ne "0" ] ; then
  echo "DL_DIR = \"/opt/fsl-imx-xwayland/downloads\"" >> ${LOCAL_CONF}
fi

grep -E "^[[:space:]]?SSTATE_DIR[[:space:]]?\=[[:space:]]?\"sstate-dir\"[[:space:]]?$" ${LOCAL_CONF} &> /dev/null
if [ $? -ne "0" ] ; then
  echo "SSTATE_DIR = \"/opt/fsl-imx-xwayland/sstate-dir\"" >> ${LOCAL_CONF}
fi

egrep "^\s*BB_NUMBER_THREADS\s*=\s*\'4\'$" ${LOCAL_CONF} &> /dev/null
if [ $? -ne "0" ] ; then
  echo -e "BB_NUMBER_THREADS = '$(nproc)'" >> ${LOCAL_CONF}
fi