#!/bin/sh
#
# platform.sh — Platform-specific sysupgrade handling for filogic boards
# Installed to: target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh
#
# This file ADDS bt-r320 to the existing fit_do_upgrade handler.
# Based on upstream OpenWrt platform.sh with globitel,bt-r320 added.

fit_do_upgrade() {
	local device="$1"

	case "$(board_name)" in
	acer,predator-w6|\
	acer,predator-w6d|\
	acer,vero-w6m|\
	airpi,ap3000m|\
	arcadyan,mozart|\
	glinet,gl-mt2500|\
	glinet,gl-mt2500-airoha|\
	glinet,gl-mt6000|\
	glinet,gl-x3000|\
	glinet,gl-xe3000|\
	globitel,bt-r320|\
	huasifei,wh3000|\
	huasifei,wh3000-pro-emmc|\
	marell,t1-pro|\
	marwell,x3000-pro|\
	marwell,x3000-pro-b1|\
	nradio,c8-668-888|\
	nradio,c8-668-gl|\
	nradio,c8-668-u1|\
	nradio,c8-668-u1g|\
	nradio,c8-668-u3|\
	qihoo,360t7|\
	qihoo,360t7-ubi|\
	routerich,ax3000-ubootmod|\
	smartbg,wp01|\
	smartrg,sdg-8612|\
	smartrg,sdg-8614|\
	smartrg,sdg-8622|\
	smartrg,sdg-8632|\
	smartrg,sdg-8733|\
	smartrg,sdg-8733a|\
	smartrg,sdg-8734|\
	xiaomi,mi-router-wr30u-ubootmod|\
	xiaomi,redmi-router-ax6000-ubootmod|\
	xiaomi,redmi-router-ax6000-stock|\
	zyxel,ex5601-t0-ubootmod|\
	zyxel,wx5600-t0-ubootmod)
		fit_do_upgrade "$1"
		;;
	esac
}
