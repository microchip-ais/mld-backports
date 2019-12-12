# Makefile
#
# This sample Makefile may be used to build
# MOST Linux Driver kernel objects
#

ifndef KDIR
    KDIR=/lib/modules/$(shell uname -r)/build
endif

EXTRA_CFLAGS := -I$(src)

obj-m := inic_core.o
inic_core-y := most/core.o most/configfs.o

# Character devices
obj-m += inic_cdev.o
inic_cdev-y := most/cdev/cdev.o

# Linux Networking
obj-m += inic_net.o
inic_net-y := most/net/net.o

# Linux Sound
obj-m += inic_sound.o
inic_sound-y := most/sound/sound.o

# Video for Linux
obj-m += inic_video.o
inic_video-y := most/video/video.o

# I2C interface
obj-m += inic_i2c.o
inic_i2c-y := most/i2c/i2c.o
# obj-m += inic_i2c_pd.o
### only one in the [[
# inic_i2c_pd-y := most/i2c/platform/plat_imx6q.o
# inic_i2c_pd-y := most/i2c/platform/plat_zynq.o
### ]]

# DIM2 interface
obj-m += inic_dim2.o
inic_dim2-y := most/dim2/dim2.o most/dim2/hal.o most/dim2/sysfs.o

# USB interface
obj-m += inic_usb.o
inic_usb-y := most/usb/usb.o


PWD := $(shell pwd)

modules:
	$(MAKE) -C $(KDIR) M=$(PWD) modules || $(MAKE) backport_error

patch:
	@ ./patchwork patch

unpatch:
	@ ./patchwork unpatch

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

backport_error:
	@echo ''
	@echo 'HAVE YOU APPLIED BACKPORT PATCHES?'
	@echo ''
	@echo 'Use "make patch" to apply all mandatory backport patches'
	@echo ''

help:
	@echo 'USAGE'
	@echo '====='
	@echo ''
	@echo '  make [ [<environment variable>=<value> ... ] [<target>]'
	@echo ''
	@echo '<target> may be "patch", "unpatch", "modules", "clean" or "help" (without quotes).'
	@echo 'Default <target> is "modules"'
	@echo ''
	@echo 'Environment variables'
	@echo '====================='
	@echo ''
	@echo 'ARCH defines the target architecture.'
	@echo ''
	@echo 'CROSS_COMPILE defines the binutils prefix.'
	@echo ''
	@echo 'KDIR defines the path to the kernel sources.'
	@echo 'Default: /lib/modules/$$(uname -r)/build'
	@echo ''
	@echo 'EXAMPLES'
	@echo '========'
	@echo ''
	@echo 'Native making for the local host:'
	@echo '  make KDIR=/lib/modules/$$(uname -r)/build'
	@echo 'or'
	@echo '  make'
	@echo ''
	@echo 'Cross making for the embedded platform:'
	@echo '  export KDIR=~/mchp-fsl-bsp/build/tmp/work/imx6qsabreauto-poky-linux-gnueabi/linux-imx/3.14.28-r0/build'
	@echo '  export CROSS_COMPILE=~/mchp-fsl-bsp/build/tmp/sysroots/x86_64-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-'
	@echo '  export ARCH=arm'
	@echo '  make'
	@echo ''
