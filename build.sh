#!/bin/bash
#
# build.sh (DIY Part 2) — Post-feed-install customizations
#
# This script runs AFTER ./scripts/feeds install -a
# It copies DTS files, applies board-specific configs, and
# installs third-party packages/themes.

# ============================================================================
# 1. Copy bt-r320-specific board files into the ImmortalWrt tree
# ============================================================================

echo "=========================================="
echo "  Copying bt-r320 board files"
echo "=========================================="

# Device tree source — clean version based on upstream openwrt,one
cp -f "$GITHUB_WORKSPACE/dts/mt7981b-globitel-bt-r320-emmc.dts" \
      "target/linux/mediatek/dts/mt7981b-globitel-bt-r320-emmc.dts"
echo "[OK] DTS file copied"

# Image build rules — add globitel_bt-r320-emmc to filogic.mk
cp -f "$GITHUB_WORKSPACE/dts/filogic.mk" \
      "target/linux/mediatek/image/filogic.mk"
echo "[OK] filogic.mk copied"

# Board LED configuration
cp -f "$GITHUB_WORKSPACE/dts/01_leds" \
      "target/linux/mediatek/filogic/base-files/etc/board.d/01_leds"
echo "[OK] 01_leds copied"

# Board network configuration
cp -f "$GITHUB_WORKSPACE/dts/02_network" \
      "target/linux/mediatek/filogic/base-files/etc/board.d/02_network"
echo "[OK] 02_network copied"

# Platform upgrade script
cp -f "$GITHUB_WORKSPACE/dts/platform.sh" \
      "target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh"
echo "[OK] platform.sh copied"

# U-Boot environment tools
cp -f "$GITHUB_WORKSPACE/dts/mediatek_filogic" \
      "package/boot/uboot-envtools/files/mediatek_filogic"
echo "[OK] mediatek_filogic (uboot-envtools) copied"

echo ""
echo "All board files copied successfully."

# ============================================================================
# 2. Install argon theme
# ============================================================================

echo ""
echo "=========================================="
echo "  Installing argon theme"
echo "=========================================="

rm -rf feeds/luci/themes/luci-theme-argon 2>/dev/null
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

rm -rf feeds/luci/applications/luci-app-argon-config 2>/dev/null
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

echo "[OK] argon theme installed"

# ============================================================================
# 3. Set build timestamp in image prefix
# ============================================================================

echo ""
echo "=========================================="
echo "  Setting image build prefix"
echo "=========================================="

sed -i 's|IMG_PREFIX:=|IMG_PREFIX:=$(shell TZ="Asia/Shanghai" date +"%Y%m%d")-24.10-6.6-|' include/image.mk

echo "[OK] Image prefix set"

# ============================================================================
# 4. Security Notes (NOT applied — per-device configuration)
# ============================================================================
#
# The following customizations are deliberately NOT applied automatically:
#
#   a) Root password: "password" — Set via LuCI interface after first boot
#   b) WiFi SSID/password: Change via LuCI → Network → Wireless
#   c) Hostname: Set to "bt-r320" via uci-defaults/99-system-defaults
#   d) Third-party package feeds: See Packages.sh for all package sources
#
# These security-sensitive settings should be configured per-device,
# not hardcoded in build scripts.

echo ""
echo "=========================================="
echo "  Build preparation complete"
echo "  Please configure security settings via LuCI"
echo "=========================================="
