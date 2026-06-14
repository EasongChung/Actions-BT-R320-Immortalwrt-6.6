
define Device/bt_r320-emmc
  DEVICE_VENDOR := BT
  DEVICE_MODEL := BT-R320 (eMMC)
  DEVICE_DTS := mt7981b-globitel-bt-r320-emmc
  DEVICE_DTS_DIR := ../dts
  DEVICE_PACKAGES := fitblk kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware \
    kmod-usb3 kmod-mmc automount e2fsprogs f2fsck mkf2fs \
    kmod-fs-ext4 exfat-mkfs dosfstools f2fs-tools
  KERNEL := kernel-bin | lzma | fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb
  KERNEL_INITRAMFS := kernel-bin | lzma | \
    fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb with-initrd | pad-to 64k
  KERNEL_IN_UBI := 1
  UBOOTENV_IN_UBI := 1
  IMAGES := sysupgrade.itb
  IMAGE_SIZE := $$(shell expr 64 + $$(CONFIG_TARGET_ROOTFS_PARTSIZE))m
  IMAGE/sysupgrade.itb := append-kernel | \
    fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb \
    external-with-rootfs | pad-rootfs | append-metadata
  UBINIZE_OPTS := -E 5
  BLOCKSIZE := 128k
  PAGESIZE := 2048
endef
TARGET_DEVICES += bt_r320-emmc
