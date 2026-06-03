
define Device/bt_r320-emmc
  DEVICE_VENDOR := BT
  DEVICE_MODEL := BT-R320 (eMMC)
  DEVICE_DTS := mt7981b-globitel-bt-r320-emmc
  DEVICE_DTS_DIR := ../dts
  DEVICE_PACKAGES := kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware \
	kmod-usb3 kmod-mmc automount e2fsprogs f2fsck mkf2fs \
	kmod-nvme kmod-fs-ext4 exfat-mkfs dosfstools f2fs-tools
  KERNEL := kernel-bin | lzma | fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb
  KERNEL_INITRAMFS := kernel-bin | lzma | \
	fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb with-initrd | pad-to 64k
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += bt_r320-emmc