#!/bin/bash
set -e

echo "Templar Kernel GKI 5.10 - Clean"
echo "Generic GKI build for HyperOS/MIUI (no KSU)"
echo ""

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$HOME/kernel-output-clean"
BUILD_SUFFIX="-ge4f8b2c-$(date +%y%m%d)"
MAX_JOBS=2

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export CC=clang
export LLVM=1
export LLVM_IAS=1

mkdir -p "$OUTPUT_DIR"
cd "$ROOT_DIR"

# Reset kernel source to clean state
git checkout . 2>/dev/null || true
# Prevent "-dirty" in kernel version string
touch .scmversion

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CC=clang LLVM=1 LLVM_IAS=1 gki_defconfig 2>&1
./scripts/kconfig/merge_config.sh -m -O . \
    arch/arm64/configs/gki_defconfig \
    arch/arm64/configs/hyperos_optimized.fragment \
    arch/arm64/configs/version.fragment 2>&1
echo "CONFIG_LOCALVERSION=\"${BUILD_SUFFIX}\"" >> .config
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CC=clang LLVM=1 LLVM_IAS=1 olddefconfig 2>&1

nice -n 19 make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CC=clang LLVM=1 LLVM_IAS=1 -j$MAX_JOBS 2>&1

if [ ! -f "arch/arm64/boot/Image" ]; then
    echo "ERROR: arch/arm64/boot/Image not found!"
    exit 1
fi

KERNEL_VERSION=$(strings vmlinux | grep "Linux version" | head -1)
echo "Kernel: $KERNEL_VERSION"

cp arch/arm64/boot/Image "$OUTPUT_DIR/Image"

AK3_DIR="/tmp/anykernel3"
if [ ! -d "$AK3_DIR" ]; then
    git clone --depth=1 https://github.com/osm0sis/AnyKernel3.git "$AK3_DIR" 2>&1
fi

cat > "$AK3_DIR/anykernel.sh" << 'AK3'
properties() { '
kernel.string=SrMatdroid Kernel GKI 5.10
do.devicecheck=0
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; }

BLOCK=boot;
IS_SLOT_DEVICE=auto;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

. tools/ak3-core.sh;

dump_boot;
write_boot;
AK3

cp "$OUTPUT_DIR/Image" "$AK3_DIR/Image"
cd "$AK3_DIR"
rm -f "$OUTPUT_DIR/TemplarKernel-GKI5.10-Clean.zip"
zip -r9 "$OUTPUT_DIR/TemplarKernel-GKI5.10-Clean.zip" * \
    -x ".git/*" "README.md" "LICENSE" 2>&1

echo ""
echo "Done -> $OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR/"
echo ""
echo "Zip: TemplarKernel-GKI5.10-Clean.zip"
echo "No root manager included. Use Magisk if needed."
echo "WARNING: Generic GKI. Only for GKI 5.10 devices."
echo "Backup your stock boot.img first."
