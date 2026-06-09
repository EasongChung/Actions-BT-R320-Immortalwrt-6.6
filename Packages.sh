#!/bin/bash
#
# Packages.sh — Third-party package installer
#
# Runs after feeds install. Replaces/extends default feeds with
# curated community packages.
#
# zerotier replaced with easytier (lighter, modern).

UPDATE_PACKAGE() {
    local PKG_NAME="$1"
    local PKG_REPO="$2"
    local PKG_BRANCH="$3"
    local PKG_SPECIAL="$4"
    local PKG_LIST=("$PKG_NAME" "${5:-}")
    local REPO_NAME="${PKG_REPO#*/}"

    echo ""
    echo "[Packages] Fetching: $PKG_NAME from $PKG_REPO"

    for NAME in "${PKG_LIST[@]}"; do
        [ -z "$NAME" ] && continue
        echo "  Searching for: $NAME"
        local FOUND_DIRS
        FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)

        if [ -n "$FOUND_DIRS" ]; then
            while IFS= read -r DIR; do
                rm -rf "$DIR"
                echo "  Removed: $DIR"
            done <<< "$FOUND_DIRS"
        else
            echo "  Not found locally: $NAME"
        fi
    done

    git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "https://github.com/$PKG_REPO.git"

    if [[ "$PKG_SPECIAL" == "pkg" ]]; then
        find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
        rm -rf ./$REPO_NAME/
    elif [[ "$PKG_SPECIAL" == "name" ]]; then
        mv -f "$REPO_NAME" "$PKG_NAME"
    fi
}

UPDATE_VERSION() {
    local PKG_NAME="$1"
    local PKG_MARK="${2:-false}"
    local PKG_FILES
    PKG_FILES=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/$PKG_NAME/Makefile" 2>/dev/null)

    if [ -z "$PKG_FILES" ]; then
        echo "$PKG_NAME not found in Makefiles!"
        return
    fi

    echo -e "\n=== Updating: $PKG_NAME ==="

    for PKG_FILE in $PKG_FILES; do
        local PKG_REPO
        PKG_REPO=$(grep -Po "PKG_SOURCE_URL:=https://.*github.com/\K[^/]+/[^/]+(?=.*)" "$PKG_FILE" 2>/dev/null)
        [ -z "$PKG_REPO" ] && continue

        local PKG_TAG
        PKG_TAG=$(curl -sL --connect-timeout 5 "https://api.github.com/repos/$PKG_REPO/releases" \
            | jq -r "map(select(.prerelease == $PKG_MARK)) | first | .tag_name" 2>/dev/null)

        local OLD_VER
        OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" "$PKG_FILE" 2>/dev/null)
        local OLD_URL
        OLD_URL=$(grep -Po "PKG_SOURCE_URL:=\K.*" "$PKG_FILE" 2>/dev/null)
        local OLD_FILE
        OLD_FILE=$(grep -Po "PKG_SOURCE:=\K.*" "$PKG_FILE" 2>/dev/null)
        local OLD_HASH
        OLD_HASH=$(grep -Po "PKG_HASH:=\K.*" "$PKG_FILE" 2>/dev/null)

        [ -z "$OLD_VER" ] && continue

        local PKG_URL="${OLD_URL%/}"
        local NEW_VER
        NEW_VER=$(echo "$PKG_TAG" | sed -E 's/[^0-9]+/\./g; s/^\.|\.$//g')
        [ -z "$NEW_VER" ] && continue

        local NEW_URL="${OLD_URL/\$(PKG_VERSION)/$NEW_VER}"
        NEW_URL="${NEW_URL/\$(PKG_NAME)/$PKG_NAME}"

        local NEW_HASH
        NEW_HASH=$(curl -sL --connect-timeout 10 -o /dev/null -w "" "$NEW_URL" 2>/dev/null || echo "")

        echo "  $PKG_NAME: $OLD_VER -> $NEW_VER"

        if [[ "$NEW_VER" =~ ^[0-9] ]] && dpkg --compare-versions "$OLD_VER" lt "$NEW_VER" 2>/dev/null; then
            sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$PKG_FILE"
            if [ -n "$NEW_HASH" ]; then
                sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$PKG_FILE"
            fi
        else
            echo "  Already latest or equal: $NEW_VER"
        fi
    done
}

# ============================================================================
# Proxy & networking packages
# ============================================================================
# UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg"
# UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "main" "pkg"
UPDATE_PACKAGE "passwall2" "Openwrt-Passwall/openwrt-passwall2" "main" "pkg"
# UPDATE_PACKAGE "ssr-plus" "fw876/helloworld" "master"

# Utility packages
# UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"

# Replaced: luci-app-zerotier → easytier (lighter, modern mesh VPN)
UPDATE_PACKAGE "easytier" "EasyTier/luci-app-easytier" "main" "pkg"
UPDATE_PACKAGE "luci-app-easytier" "EasyTier/luci-app-easytier" "main" "pkg"

# Custom packages from maintained forks
UPDATE_PACKAGE "luci-app-store" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"
UPDATE_PACKAGE "luci-app-quickstart" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"
UPDATE_PACKAGE "quickstart" "shidahuilang/openwrt-package" "Immortalwrt" "pkg"
UPDATE_PACKAGE "luci-app-lucky" "shidahuilang/openwrt-package" "Lede" "pkg"
UPDATE_PACKAGE "lucky" "shidahuilang/openwrt-package" "Lede" "pkg"

# Kiddin9 packages disabled: upstream repository is unavailable.
# build.sh already installs luci-theme-argon from jerrykuku/luci-theme-argon.
# UPDATE_PACKAGE "luci-app-npc" "kiddin9/kwrt-packages" "main" "pkg"
# UPDATE_PACKAGE "luci-app-frpc" "kiddin9/kwrt-packages" "main" "pkg"
# UPDATE_PACKAGE "luci-theme-argon" "kiddin9/kwrt-packages" "main" "pkg"
# UPDATE_PACKAGE "quickstart" "kiddin9/kwrt-packages" "main" "pkg"
# UPDATE_PACKAGE "luci-app-quickstart" "kiddin9/kwrt-packages" "main" "pkg"

# ============================================================================
# Version auto-update
# ============================================================================
# UPDATE_VERSION "luci-app-lucky"
# UPDATE_VERSION "luci-app-passwall"
# UPDATE_VERSION "luci-app-passwall2"
# UPDATE_VERSION "luci-app-store"
# UPDATE_VERSION "luci-app-openclash"
# UPDATE_VERSION "luci-app-argon-config"

# ============================================================================
# Pre-load OpenClash cores & geo databases
# ============================================================================
if [ -d "luci-app-openclash" ]; then
    echo ""
    echo "=== Pre-loading OpenClash cores & geo databases ==="

    CORE_VER="https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version"
    CORE_TYPE=$(echo "${WRT_TARGET:-aarch64}" | grep -Eiq "64|86" && echo "amd64" || echo "arm64")
    CORE_TUN_VER=$(curl -sL "$CORE_VER" 2>/dev/null | sed -n "2{s/\r$//;p;q}")

    mkdir -p ./luci-app-openclash/root/etc/openclash/core/

    curl -sL -o "./luci-app-openclash/root/etc/openclash/core/meta.tar.gz" \
        "https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-arm64.tar.gz" 2>/dev/null
    cd ./luci-app-openclash/root/etc/openclash/core/
    tar -zxf meta.tar.gz 2>/dev/null && mv -f clash clash_meta 2>/dev/null
    chmod +x ./* 2>/dev/null
    rm -rf ./*.gz 2>/dev/null
    cd "$GITHUB_WORKSPACE"

    curl -sL -o "./luci-app-openclash/root/etc/openclash/Country.mmdb" \
        "https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb" 2>/dev/null
    curl -sL -o "./luci-app-openclash/root/etc/openclash/GeoSite.dat" \
        "https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat" 2>/dev/null
    curl -sL -o "./luci-app-openclash/root/etc/openclash/geoip.dat" \
        "https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat" 2>/dev/null

    echo "[OK] OpenClash cores & geo databases loaded"
fi
