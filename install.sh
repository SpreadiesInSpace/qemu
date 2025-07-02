#!/bin/bash

# Check if script is run as root
die() { echo -e "\033[1;31mError:\033[0m $*" >&2; exit 1; }
if [ "$EUID" -ne 0 ]; then
  die "This script must be run as root."
fi

# Extract version from the split file names
version=$(ls qemu_part_* | grep -oP "(?<=-)[0-9.]+$" | head -n 1) || die "Failed to extract version number."

# Combine Archive
cat qemu_part_* > qemu-${version}-x86_64-1_SBo.tgz || die "Failed to combine QEMU package."

# Install Package
installpkg qemu-${version}-x86_64-1_SBo.tgz || die "Failed to install QEMU."
