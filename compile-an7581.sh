#!/bin/bash

set -e

KERNEL_VERSION="6.12.y"
KERNEL_SOURCE="unifreq"
DTS_FILE="an7581-xg-040g-md.dts"
DTSI_FILE="an7581-nowifi.dtsi"

echo "=== 编译 AN7581 内核 ==="

# 1. 克隆内核源码
if [ ! -d "linux-${KERNEL_VERSION}" ]; then
    echo "克隆内核源码..."
    git clone --depth=1 -b main https://github.com/${KERNEL_SOURCE}/linux-${KERNEL_VERSION}.git
fi

cd linux-${KERNEL_VERSION}

# 2. 复制 DTS 文件到内核源码
echo "复制 DTS 文件..."
DTS_DIR="arch/arm64/boot/dts/airoha"
mkdir -p ${DTS_DIR}
cp ../${DTS_FILE} ${DTS_DIR}/
cp ../${DTSI_FILE} ${DTS_DIR}/

# 3. 修改 Makefile 包含新的 DTS
echo "修改 Makefile..."
if ! grep -q "an7581-xg-040g-md.dtb" ${DTS_DIR}/Makefile; then
    sed -i '/dtb-$(CONFIG_ARCH_AIROHA)/a \\tdtb-$(CONFIG_ARCH_AIROHA) += an7581-xg-040g-md.dtb' ${DTS_DIR}/Makefile
fi

# 4. 使用默认配置
echo "配置内核..."
make ARCH=arm64 defconfig

# 5. 编译
echo "开始编译..."
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc) Image dtbs modules

echo "=== 编译完成 ==="
echo "内核镜像: arch/arm64/boot/Image"
echo "设备树: arch/arm64/boot/dts/airoha/an7581-xg-040g-md.dtb"
