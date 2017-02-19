#!/bin/bash
set -x

#FOLDERS
mkdir -p boot/{,overlays}
mkdir -p root/{,dev,proc,run,sys,tmp,var,etc/init.d}

#FIRMWARE
pushd boot
wget -nc https://github.com/raspberrypi/firmware/raw/master/boot/bootcode.bin
wget -nc https://github.com/raspberrypi/firmware/raw/master/boot/fixup.dat
wget -nc https://github.com/raspberrypi/firmware/raw/master/boot/start.elf
popd

#TOOLCHAIN
git clone https://github.com/raspberrypi/tools
export PATH=$PATH:`pwd`/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin	
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf- 

#U-BOOT
git clone git://git.denx.de/u-boot.git
pushd u-boot
make rpi_2_defconfig -j5
make -j5
cp u-boot.bin ../boot/kernel.img
popd
cp uboot.env boot

#KERNEL
git clone --depth=1 https://github.com/raspberrypi/linux
pushd linux
export KERNEL=kernel7
make bcm2709_defconfig -j5
make zImage modules dtbs -j5
make INSTALL_MOD_PATH=../root modules_install
scripts/mkknlimg arch/arm/boot/zImage ../boot/zImage-$KERNEL.img
cp arch/arm/boot/dts/*.dtb ../boot/
cp arch/arm/boot/dts/overlays/*.dtb* ../boot/overlays/
cp arch/arm/boot/dts/overlays/README ../boot/overlays/
popd

#BUSYBOX
git clone git://busybox.net/busybox.git
pushd busybox
make defconfig
cp .config .config.old
sed -i \
	-e 's/.*CONFIG_BUSYBOX_EXEC_PATH.*/CONFIG_BUSYBOX_EXEC_PATH="\/bin\/busybox"/' \
	-e 's/.*CONFIG_STATIC.*/CONFIG_STATIC=y/' \
	-e 's/.*CONFIG_FEATURE_SYNC_FANCY.*/# CONFIG_FEATURE_SYNC_FANCY is not set/' \
	-e 's/.*CONFIG_NSENTER.*/# CONFIG_NSENTER is not set/' \
	-e 's/.*CONFIG_FEATURE_NSENTER_LONG_OPTS.*/# CONFIG_FEATURE_NSENTER_LONG_OPTS=y is not set/' \
	.config
make -j5
make install
rsync -arv _install	 ../root
popd

cat > root/etc/init.d/rcS << EOF
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t tmpfs run /run
mount -t tmpfs tmp /tmp
mount -t tmpfs var /var
EOF

chmod +x root/etc/init.d/rcS

cat > root/etc/inittab << EOF
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
tty2::askfirst:-/bin/sh
::ctrlaltdel:/bin/umount -a -r
EOF

#ROOT
#git clone git://git.buildroot.net/buildroot
#pushd buildroot
#make raspberrypi2_defconfig	-j5
#popd

