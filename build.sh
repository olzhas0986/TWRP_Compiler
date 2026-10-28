#!/bin/bash
set -e

# Exports
export VENDOR=xiaomi
export DEVICE=munch
export DTLINK=https://github.com/olzhas0986/twrpdt

# Twrp folder
mkdir -p twrp && cd twrp

# Repo init TWRP
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1

# Sync repos
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

# Clone device repos
git clone $DTLINK device/${VENDOR}/${DEVICE}

# Build TWRP
. build/envsetup.sh && export ALLOW_MISSING_DEPENDENCIES=true && lunch twrp_${DEVICE}-eng && mka bootimage -j$(nproc --all)
