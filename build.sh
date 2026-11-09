#!/usr/bin/env bash
set -eo pipefail

export VENDOR=xiaomi
export DEVICE=munch
export DTLINK="${DTLINK:-https://github.com/olzhas0986/twrp_device_xiaomi_munch.git}"
DT_REF="${DT_REF:-android-12.1}"
SYNC_JOBS="${SYNC_JOBS:-4}"
BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"
SOURCE_DIR="${SOURCE_DIR:-$PWD/aera}"

for jobs in "$SYNC_JOBS" "$BUILD_JOBS"; do
    if ! [[ "$jobs" =~ ^[1-9][0-9]*$ ]]; then
        echo "Job counts must be positive integers." >&2
        exit 1
    fi
done

mkdir -p "$SOURCE_DIR"
cd "$SOURCE_DIR"
repo init --depth=1 \
    -u https://github.com/AERA-Recovery/android_manifest.git \
    -b aera-16.0 2>&1 | tee init.log

device_path="device/$VENDOR/$DEVICE"
if [ -e "$device_path" ]; then
    echo "$device_path already exists; use a fresh SOURCE_DIR." >&2
    exit 1
fi
# Fetch only the requested branch, tag or commit SHA.
git init "$device_path"
git -C "$device_path" remote add origin "$DTLINK"
git -C "$device_path" fetch --depth=1 origin "$DT_REF"
git -C "$device_path" checkout --detach FETCH_HEAD

# Import extra Qualcomm sources before syncing the AERA manifest.
test -f "$device_path/local_manifest.xml"
test -f "$device_path/aera_munch.mk"
test -f "$device_path/vendorsetup.sh"
mkdir -p .repo/local_manifests
cp "$device_path/local_manifest.xml" .repo/local_manifests/munch.xml
repo sync -c -j"$SYNC_JOBS" --no-clone-bundle --no-tags 2>&1 | tee sync.log
repo manifest -r -o source-manifest.xml
{
    printf 'DT_URL=%s\nDT_REF=%s\n' "$DTLINK" "$DT_REF"
    printf 'DT_COMMIT=%s\n' "$(git -C "$device_path" rev-parse HEAD)"
    printf 'LUNCH=twrp_munch-bp2a-eng\nTARGET=adbd bootimage\n'
} > build-info.txt

# Android envsetup uses unset variables; intentionally avoid set -u.
(
    source build/envsetup.sh
    source "$device_path/vendorsetup.sh" munch
    lunch twrp_munch-bp2a-eng
    mka adbd bootimage -j"$BUILD_JOBS"
) 2>&1 | tee build.log

test -s "out/target/product/$DEVICE/boot.img"
