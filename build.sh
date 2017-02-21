#!/bin/sh
git clone git://git.buildroot.net/buildroot
cp buildroot.config buildroot/.config
cd buildroot

make

echo "sd* root:root 444 @myplayer $MDEV" >> output/target/etc/mdev.conf

cat << EOF > output/target/usr/sbin/myplayer
mkdir -p /mnt/$1
mount /dev/$1 /mnt/$1
find /mnt/$1/ -name '*.mp3' -print0 | xargs -0 mpg123
umount /dev/$1              
EOF
chmod +x output/target/usr/sbin/myplayer

make

cd ..
mkdir -p boot
cp buildroot/output/images/rpi-firmware/* buildroot/output/images/bcm2709-rpi-2-b.dtb buildroot/output/images/zImage boot
cp buildroot/output/images/rootfs.ext4 rootfs.img

echo "dtparam=audio=on" >> boot/config.txt
