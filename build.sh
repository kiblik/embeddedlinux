#!/bin/bash
set -x
git clone git://git.buildroot.net/buildroot
cp buildroot.config buildroot/.config
pushd buildroot

make

cp ../mdev.conf output/target/etc/mdev.conf
cp ../myplayer output/target/usr/sbin/myplayer
chmod +x output/target/usr/sbin/myplayer

make

popd
mkdir -p boot
cp buildroot/output/images/rpi-firmware/* buildroot/output/images/bcm2709-rpi-2-b.dtb buildroot/output/images/zImage boot
cp buildroot/output/images/rootfs.ext4 rootfs.img

echo "dtparam=audio=on" >> boot/config.txt
