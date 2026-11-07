#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <new_version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

NEW_VER="$1"
# Strip leading 'v' if provided
NEW_VER="${NEW_VER#v}"

echo "=================================================="
echo " Synchronizing package version to: v${NEW_VER}"
echo "=================================================="

# 1. dkms.conf
if [ -f dkms.conf ]; then
    sed -i "s/^PACKAGE_VERSION=\".*\"/PACKAGE_VERSION=\"${NEW_VER}\"/" dkms.conf
    echo "[OK] Updated dkms.conf"
fi

# 2. debian/control
if [ -f debian/control ]; then
    sed -i "s/^Version:.*/Version: ${NEW_VER}/" debian/control
    echo "[OK] Updated debian/control"
fi

# 3. debian/postinst
if [ -f debian/postinst ]; then
    sed -i "s/^VERSION=\".*\"/VERSION=\"${NEW_VER}\"/" debian/postinst
    echo "[OK] Updated debian/postinst"
fi

# 4. debian/prerm
if [ -f debian/prerm ]; then
    sed -i "s/^VERSION=\".*\"/VERSION=\"${NEW_VER}\"/" debian/prerm
    echo "[OK] Updated debian/prerm"
fi

# 5. build-deb.sh
if [ -f build-deb.sh ]; then
    sed -i "s/VERSION=\${1:-\${DEFAULT_VERSION:-.*}}/VERSION=\${1:-\${DEFAULT_VERSION:-${NEW_VER}}}/" build-deb.sh
    echo "[OK] Updated build-deb.sh"
fi

# 6. README.md & README.id.md
for readme in README.md README.id.md; do
    if [ -f "$readme" ]; then
        sed -i -E "s/rtl8189fs-dkms_[0-9]+\.[0-9]+\.[0-9]+(_[a-zA-Z0-9.-]+)?_all\.deb/rtl8189fs-dkms_${NEW_VER}_all.deb/g" "$readme"
        sed -i -E "s/releases\/download\/v[0-9]+\.[0-9]+\.[0-9]+([a-zA-Z0-9.-]*)/releases\/download\/v${NEW_VER}/g" "$readme"
        sed -i -E "s/releases\/tag\/v[0-9]+\.[0-9]+\.[0-9]+([a-zA-Z0-9.-]*)/releases\/tag\/v${NEW_VER}/g" "$readme"
        sed -i -E "s/badge\/version-[0-9]+\.[0-9]+\.[0-9]+([a-zA-Z0-9.-]*)/badge\/version-${NEW_VER}/g" "$readme"
        echo "[OK] Updated $readme"
    fi
done

echo "=================================================="
echo " Version synchronization completed successfully!"
echo "=================================================="
