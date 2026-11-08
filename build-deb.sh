#!/bin/bash
set -e

PACKAGE=rtl8189fs-dkms
DEFAULT_VERSION=$(grep -E "^[[:space:]]*PACKAGE_VERSION=" dkms.conf 2>/dev/null | cut -d'"' -f2)
VERSION=${1:-${DEFAULT_VERSION:-1.0.2}}
TARGET_DEB="${PACKAGE}_${VERSION}_all.deb"

BUILD_DIR=/tmp/${PACKAGE}_build
SRC_DIR=${BUILD_DIR}/usr/src/rtl8189fs-${VERSION}

echo "Building Debian package for Release v${VERSION} (${TARGET_DEB})..."

rm -rf ${BUILD_DIR}
mkdir -p ${SRC_DIR}
mkdir -p ${BUILD_DIR}/DEBIAN

# 1. Copy pure driver source code directly
cp -a core hal include os_dep platform Makefile Kconfig dkms.conf ${SRC_DIR}/
[ -f CHANGELOG.md ] && cp -a CHANGELOG.md ${SRC_DIR}/
[ -f README.md ] && cp -a README.md ${SRC_DIR}/
[ -f LICENSE ] && cp -a LICENSE ${SRC_DIR}/
sed -i "s/PACKAGE_VERSION=\".*\"/PACKAGE_VERSION=\"${VERSION}\"/" ${SRC_DIR}/dkms.conf
find ${SRC_DIR} -type f \( -name "*.o" -o -name "*.o.d" -o -name "*.cmd" -o -name "*.ko" -o -name "*.mod*" \) -delete

# 2. Copy system integration files (sysctl, udev, modprobe)
if [ -d system ]; then
    cp -a system/* ${BUILD_DIR}/
fi
if [ -d "${BUILD_DIR}/lib/firmware" ]; then
    mkdir -p ${BUILD_DIR}/usr/lib/firmware
    cp -a ${BUILD_DIR}/lib/firmware/* ${BUILD_DIR}/usr/lib/firmware/
    rm -rf ${BUILD_DIR}/lib
fi
chmod 755 ${BUILD_DIR}/usr/lib/udev/rtl8189fs-irq-tune.sh 2>/dev/null || true

# 3. Copy Debian package control scripts
cp -a debian/* ${BUILD_DIR}/DEBIAN/
sed -i "s/^Version:.*/Version: ${VERSION}/" ${BUILD_DIR}/DEBIAN/control
sed -i "s/VERSION=\".*\"/VERSION=\"${VERSION}\"/" ${BUILD_DIR}/DEBIAN/postinst ${BUILD_DIR}/DEBIAN/prerm
chmod 755 ${BUILD_DIR}/DEBIAN
chmod 755 ${BUILD_DIR}/DEBIAN/preinst ${BUILD_DIR}/DEBIAN/postinst ${BUILD_DIR}/DEBIAN/prerm

# 4. Install Debian package documentation & copyright (Debian Policy Manual §12.5)
DOC_DIR=${BUILD_DIR}/usr/share/doc/${PACKAGE}
mkdir -p ${DOC_DIR}
[ -f debian/copyright ] && cp -a debian/copyright ${DOC_DIR}/copyright
[ -f CHANGELOG.md ] && cp -a CHANGELOG.md ${DOC_DIR}/changelog
chmod 644 ${DOC_DIR}/* 2>/dev/null || true
rm -f ${BUILD_DIR}/DEBIAN/copyright

dpkg-deb --build ${BUILD_DIR} ${TARGET_DEB}
rm -rf ${BUILD_DIR}

echo "Package created successfully: ${TARGET_DEB}"
