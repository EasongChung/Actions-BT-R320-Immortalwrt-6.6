#
# filogic.mk — BT-R320 (Globitel/JDC-F3) device definition
#
# This file REPLACES target/linux/mediatek/image/filogic.mk
# It contains the bt_r320-emmc device entry ONLY.
# The upstream ImmortalWrt filogic.mk should be used as the base,
# then this entry appended.
#
# Usage: Append the content below to ImmortalWrt's original filogic.mk
#

define Build/append-globitel-bt-r320-eeprom
	dd if=$(STAGING_DIR_IMAGE)/mt7981_eeprom_mt7976_dbdc.bin >> $@
endef

define Device/globitel_bt-r320-emmc
  DEVICE_VENDOR := Globitel
  DEVICE_MODEL := BT-R320 (eMMC)
  DEVICE_DTS := mt7981b-globitel-bt-r320-emmc
  DEVICE_DTS_DIR := ../dts
  DEVICE_DTC_FLAGS := --pad 4096
  DEVICE_PACKAGES := kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware \
	kmod-usb3 kmod-rtc-pcf8563 kmod-phy-airoha-en8811h \
	kmod-mmc automount coremark blkid blockdev fdisk \
	f2fsck mkf2fs kmod-fs-f2fs f2fs-tools \
	kmod-nvme kmod-fs-ext4 exfat-mkfs dosfstools e2fsprogs
  KERNEL_LOADADDR := 0x44000000
  KERNEL := kernel-bin | gzip
  KERNEL_INITRAMFS := kernel-bin | lzma | \
	fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb with-initrd | pad-to 64k
  KERNEL_INITRAMFS_SUFFIX := .itb
  KERNEL_IN_UBI := 1
  UBOOTENV_IN_UBI := 1
  IMAGES := sysupgrade.itb
  IMAGE_SIZE := $$(shell expr 64 + $$(CONFIG_TARGET_ROOTFS_PARTSIZE))m
  IMAGE/sysupgrade.itb := append-kernel | fit gzip $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb external-with-rootfs | pad-rootfs | append-metadata
  ARTIFACTS := \
	nor-preloader.bin nor-bl31-uboot.fip \
	snand-preloader.bin snand-bl31-uboot.fip \
	factory.ubi snand-factory.bin nor-factory.bin
  ARTIFACT/nor-preloader.bin		:= mt7981-bl2 nor-ddr4
  ARTIFACT/nor-bl31-uboot.fip		:= mt7981-bl31-uboot globitel_bt-r320-nor
  ARTIFACT/snand-preloader.bin		:= mt7981-bl2 spim-nand-ubi-ddr4
  ARTIFACT/snand-bl31-uboot.fip		:= mt7981-bl31-uboot globitel_bt-r320-snand
  ARTIFACT/factory.ubi			:= ubinize-image fit squashfs-sysupgrade.itb
  ARTIFACT/snand-factory.bin		:= mt7981-bl2 spim-nand-ubi-ddr4 | pad-to 256k | \
					   mt7981-bl2 spim-nand-ubi-ddr4 | pad-to 512k | \
					   mt7981-bl2 spim-nand-ubi-ddr4 | pad-to 768k | \
					   mt7981-bl2 spim-nand-ubi-ddr4 | pad-to 1024k | \
					   ubinize-image fit squashfs-sysupgrade.itb
  ARTIFACT/nor-factory.bin		:= mt7981-bl2 nor-ddr4 | pad-to 256k | \
					   append-globitel-bt-r320-eeprom | pad-to 1024k | \
					   mt7981-bl31-uboot globitel_bt-r320-nor | pad-to 512k | \
					   append-image-stage initramfs.itb
  UBINIZE_OPTS := -E 5
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  UBINIZE_PARTS := fip=:$(STAGING_DIR_IMAGE)/mt7981_globitel_bt-r320-snand-u-boot.fip \
		   $(if $(IB),recovery=:$(STAGING_DIR_IMAGE)/mediatek-filogic-globitel_bt-r320-initramfs.itb,\
			      recovery=:$(KDIR)/tmp/$$(KERNEL_INITRAMFS_IMAGE)) \
		   $(if $(wildcard $(TOPDIR)/openwrt-mediatek-filogic-globitel_bt-r320-calibration.itb), calibration=:$(TOPDIR)/openwrt-mediatek-filogic-globitel_bt-r320-calibration.itb)
endef
TARGET_DEVICES += globitel_bt-r320-emmc
