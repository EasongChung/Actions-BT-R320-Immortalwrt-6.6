#!/bin/bash
set -e

patch_file() {
  local file="$1"
  local marker="$2"
  local insert="$3"
  python3 - "$file" "$marker" "$insert" <<'PY'
import sys
path, marker, insert = sys.argv[1:4]
with open(path, 'r', encoding='utf-8') as f:
    data = f.read()
if insert not in data:
    if marker not in data:
        raise SystemExit(f'marker not found in {path}: {marker}')
    data = data.replace(marker, insert + marker, 1)
with open(path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(data)
PY
}

echo "=========================================="
echo "  Preparing bt-r320 board files"
echo "=========================================="

cp -f "$GITHUB_WORKSPACE/dts/mt7981b-globitel-bt-r320-emmc.dts" \
      "target/linux/mediatek/dts/mt7981b-globitel-bt-r320-emmc.dts"
echo "[OK] DTS file copied"

cat "$GITHUB_WORKSPACE/dts/filogic.mk" >> "target/linux/mediatek/image/filogic.mk"
echo "[OK] filogic.mk appended"

patch_file \
  "target/linux/mediatek/filogic/base-files/etc/board.d/01_leds" \
  "openwrt,one)" \
  $'globitel,bt-r320)\n\tucidef_set_led_netdev "wanact" "WANACT" "red:status" "eth0" "rx tx"\n\tucidef_set_led_netdev "wanlink" "WANLINK" "green:status" "eth0" "link"\n\tucidef_set_led_netdev "lanact" "LANACT" "green:status" "eth1" "rx tx"\n\tucidef_set_led_netdev "lanlink" "LANLINK" "blue:status" "eth1" "link"\n\t;;\n'
echo "[OK] 01_leds patched"

patch_file \
  "target/linux/mediatek/filogic/base-files/etc/board.d/02_network" \
  $'openwrt,one|\\\n' \
  $'globitel,bt-r320|\\\n'
echo "[OK] 02_network patched"

patch_file \
  "target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh" \
  $'openwrt,one|\\\n' \
  $'\tglobitel,bt-r320|\\\n'
echo "[OK] platform.sh patched"

patch_file \
  "package/boot/uboot-envtools/files/mediatek_filogic" \
  $'bt,r320|\\\n' \
  $'globitel,bt-r320|\\\n'
echo "[OK] mediatek_filogic patched"

echo ""
echo "=========================================="
echo "  Installing argon theme"
echo "=========================================="

rm -rf feeds/luci/themes/luci-theme-argon package/luci-theme-argon 2>/dev/null
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

rm -rf feeds/luci/applications/luci-app-argon-config package/luci-app-argon-config 2>/dev/null
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

echo "[OK] argon theme installed"

echo ""
echo "=========================================="
echo "  Setting image build prefix"
echo "=========================================="

sed -i 's|IMG_PREFIX:=|IMG_PREFIX:=$(shell TZ="Asia/Shanghai" date +"%Y%m%d")-24.10-6.6-|' include/image.mk

echo "[OK] Image prefix set"
echo ""
echo "=========================================="
echo "  Build preparation complete"
echo "  Please configure security settings via LuCI"
echo "=========================================="