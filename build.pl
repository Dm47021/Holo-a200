#!/usr/bin/perl -W
use strict;
use Cwd;

my $dir = getcwd;

print "\ncleaning kernel source\n";


print "\nremoving old boot.img\n";
system ("rm boot.img");
system ("rm $dir/zpack/zcwmfiles/boot.img");

print "\nremoving old a200.zip\n";
system ("rm $dir/a200.zip");

print "\ncreating ramdisk from 200 folder\n";
chdir ("$dir/zpack");

 unless (-d "$dir/zpack/a200/data") {
 system ("mkdir a200 | tar -C /$dir/zpack/a200/ -xvf a200.tar");
 }

chdir ("$dir/zpack/a200");
system ("find . | cpio -o -H newc | gzip > $dir/ramdisk-repack.gz");


print "\nbuilding zImage from source\n";
chdir ("$dir");
system ("cp a200_defconfig $dir/.config");
system ("make -j8");

print "\ncreating boot.img\n";
chdir $dir or die "/zpack/a200 $!";;
system ("$dir/zpack/mkbootimg --cmdline '' --kernel $dir/arch/arm/boot/zImage --ramdisk ramdisk-repack.gz -o boot.img --base 0x10000000 --pagesize 2048");

unlink("ramdisk-repack.gz") or die $!;

print "\ncreating flashable zip file\n";
system ("cp drivers/net/wireless/bcm4329/bcm4329.ko $dir/zpack/zcwmfiles/system/lib/modules/");
system ("cp boot.img $dir/zpack/zcwmfiles/");
chdir ("$dir/zpack/zcwmfiles");
system ("zip -9 -r $dir/a200.zip *");
print "\nceated a200.zip\n";

print "\nremoving a200.zip from sdcard\n";
system ("adb shell rm /sdcard/a200.zip");

print "\npushing new a200.zip to sdcard\n";
system ("adb push $dir/a200.zip /sdcard/a200.zip");
print "\ndone\n";
