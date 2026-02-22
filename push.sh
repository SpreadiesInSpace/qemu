#!/bin/bash

# Minimal Error Handling function
die() { echo -e "\033[1;31mError:\033[0m $*" >&2; exit 1; }

# Detect QEMU Package
if ! compgen -G "qemu-*.t?z" > /dev/null; then
    die "No QEMU file found."
fi

# Generate Install Script
echo '#!/bin/bash

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
installpkg qemu-${version}-x86_64-1_SBo.tgz || die "Failed to install QEMU."' > install.sh

# Make script executable
chmod +x install.sh || die "Failed to make install.sh executable."

# Generate README.md
echo '## Steps to Install

1. Clone this repo
```bash
git clone https://github.com/spreadiesinspace/qemu
```
2. Head to qemu folder
```bash
cd qemu
```
3. Run script with sudo
```bash
sudo ./install.sh
```' > README.md

# Remove Old parts
rm -rf qemu_part_* || die "Failed to remove old .part files."

# Extract version from the original file name
version=$(ls qemu-*.tgz | grep -oP '(?<=qemu-)[0-9.]+(?=-x86_64)') || die "Failed to extract version name."

# Split Archive into 50MB parts
split -b 50M --additional-suffix=-${version} qemu-*.tgz qemu_part_ || die "Failed to split QEMU package into parts."

# Delete Original File
rm -rf qemu-*.tgz || die "Failed to remove original QEMU package."

# Remove git history
rm -rf .git || die "Failed to remove git history."

# Initialize
git init || die "Failed to initialize repo."
git remote add origin https://github.com/SpreadiesInSpace/qemu || die "Failed to set git remote."
git add . || die "Failed to add files."
git commit -m "add qemu version $version" || die "Commit failed."

# Set branch name from master to main then force push
git branch -m main  || die "Failed to set branch name to main."
git push -f -u origin main || die "Failed to push to repo."
