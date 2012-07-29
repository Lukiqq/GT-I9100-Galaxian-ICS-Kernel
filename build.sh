#!/bin/sh

export ARCH=arm
#KernelDir=Galaxian
export CROSS_COMPILE=$HOME/arm-eabi-4.4.3/bin/arm-eabi-
export USE_SEC_FIPS_MODE=true
export KBUILD_BUILD_VERSION="Galaxian"

check_errs()
{
	if [ $? -ne 0 ];then
		echo
		echo "ERROR !!!"
		echo
		exit -1
	fi;
}


rm zImage
rm Galaxian.tar
cd arch/arm/boot/
check_errs

rm zImage
cd ../../../
check_errs

make clean

CPUs=`grep 'processor' /proc/cpuinfo | wc -l` # Return the number of current machine CPUs
echo Purging old compiled modules...
find . -name '*.ko' -exec rm -f {} \;
check_errs

echo
echo Kernel compilation...
echo

make -j$CPUs
check_errs

echo
echo Copying all compiled modules into the initramfs folder...
cd drivers/

find . -name '*.ko' -exec cp -f {} ../initramfs/lib/modules/ \;
cd ..
check_errs

echo
echo Building the final Kernel image...
echo

make -j$CPUs # make only the differences -> create the new kernel image with the latest compiled modules
check_errs

echo
echo Final Kernel image ready!
echo

echo Creating Tar file...
cp arch/arm/boot/zImage zImageOK
#cd ..
dd if=zImageOK of=zImage bs=8387840 conv=sync
tar cvf Galaxian.tar zImage > /dev/null
check_errs

echo
echo "Finished. Look for zImage/Galaxian.tar"

