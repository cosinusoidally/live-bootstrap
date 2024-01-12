#!/bin/bash
#
# SPDX-FileCopyrightText: 2023 fosslinux <fosslinux@aussies.space>
#
# SPDX-License-Identifier: GPL-3.0-or-later

. /steps/bootstrap.cfg

set -e

# Perform the actual kexec
if [ "${KERNEL_BOOTSTRAP}" = True ]; then
    sync
    # We don't use the gen_initramfs_list.sh script because it is so *SLOW*
    # This emulates the same thing it does
    find / -xdev -type d -printf "dir %p %m %U %G\n" >> /initramfs.list
    find / -xdev -type f -printf "file %p %p %m %U %G\n" >> /initramfs.list
    find / -xdev -type l -printf "slink %p %l %m %U %G\n" >> /initramfs.list
    kexec-linux "/dev/ram1" "/boot/linux-4.9.10" "!$(command -v gen_init_cpio) /initramfs.list"
else
    mkdir /etc
    # kexec time
    if [ "${BARE_METAL}" = True ]; then
        kexec -l "/boot/linux-4.9.10" \
            --append="root=/dev/sda1 rootfstype=ext3 init=/init rw"
    else
        kexec -l "/boot/linux-4.9.10" --console-serial \
            --append="console=ttyS0 root=/dev/sda1 rootfstype=ext3 init=/init rw"
    fi
    kexec -e
fi
