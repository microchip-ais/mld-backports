# MOST<sup>&#174;</sup> Linux Driver Backport Patches

This document describes how to build **out-of-tree kernel modules** of the
MOST<sup>&#174;</sup> Linux Driver from the kernel version 5.3 on the kernels
of different versions.

The latest version of this document can be found
[here](https://github.com/microchip-ais/mld-backports/tree/master/README.md).

To build the latest MOST Linux Driver on the specific kernel version, you may
need MOST Linux Driver **backport patches** maintained by this project.

Current version of backport patches supports the kernel versions v4.4 - v5.4.

## Download

The steps below help to download MOST<sup>&#174;</sup> Linux Driver
**sources**, a **Makefile** example and the kernel specific **backport
patches** into the new directory that is automatically generated or specified
by the user.

```sh
$ git clone https://github.com/microchip-ais/mld-backports.git
$ cd mld-backports
$ git tag  # show tags, optional
$ git checkout v5.3  # checkout version v5.3 of the fetch ecosystem, optional
```

Download all needed MOST Linux Driver sources and copy backport patches,
scripts and Makefile example into the working directory:
```sh
$ OUT_DIR=out ./fetch-driver-sources.sh && cd out
```

## Build modules

Export environment variables:
```sh
$ export KDIR=... # the path to the kernel sources, default is /lib/modules/$(uname -r)/build
$ export CROSS_COMPILE=... # the binutils prefix
$ export ARCH=... # the target architecture (arm, arm64, etc.)
```

### Patch

This applies the backport patches specific for your kernel:
```sh
$ make patch
```

### Build

This builds the MOST Linux Driver components and interfaces (**core**,
**cdev**, **net**, **sound**, **video**, **usb**, **dim2**):
```sh
$ make
```

Built artifacts:
```sh
$ ls *.ko

inic_cdev.ko  inic_core.ko  inic_dim2.ko  inic_net.ko
inic_sound.ko  inic_usb.ko  inic_video.ko
```

Change the `Makefile` if you need to enable/disable some components.

## Helpful commands

command | action
-|-
`make patch` | applies all kernel specific backport patches and recommended patches
`make unpatch` | reverts all applied patches
`make` or `make modules` | makes kernel modules
`make clean` | cleans built artifacts
`cat .patched` | shows all applied patches
`ls *.ko` | shows built modules
`make help` | shows help of the Makefile

