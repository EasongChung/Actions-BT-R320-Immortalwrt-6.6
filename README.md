# Actions-BT-R320-ImmortalWrt 24.10-6.6

本仓库用于通过 GitHub Actions 自动编译适用于 **Globitel BT-R320** 的 ImmortalWrt 固件，源码基于 `padavanonly/immortalwrt-mt798x-6.6` 的 `openwrt-24.10-6.6` 分支。

> 重要提示：刷机存在风险。请在操作前备份原厂固件、分区表、MAC 地址、EEPROM/Factory 分区等关键数据。因误刷、断电、分区不匹配等原因导致的设备异常或变砖，需自行承担风险。

## 项目特性

- 自动拉取 ImmortalWrt 24.10 / Linux 6.6 源码进行编译
- 适配 Globitel BT-R320 eMMC 版本
- 支持 GitHub Actions 手动触发云编译
- 自动上传编译产物到 GitHub Actions Artifact
- 可自动发布固件到 GitHub Releases
- 集成 LuCI Argon 主题与 Argon 配置页面
- 包含 eMMC、USB、NVMe、EXT4、F2FS 等常用存储支持

## 适配设备

| 项目 | 说明 |
| --- | --- |
| 设备型号 | Globitel BT-R320 |
| SoC | MediaTek MT7981B |
| CPU | 2 × Cortex-A53 |
| 内存 | 1GB DDR4 |
| 存储 | eMMC 版本 |
| 无线 | MediaTek MT7976C Wi-Fi 6 |
| 有线网络 | 4个千兆口 |
| 目标系统 | ImmortalWrt 24.10 / Kernel 6.6 |

## 仓库结构

```text
.
├── .github/workflows/              # GitHub Actions 工作流
│   └── bt-r320-24.10-6.6.yml        # 主编译工作流
├── dts/                             # 设备树与镜像定义
│   ├── mt7981b-globitel-bt-r320-emmc.dts
│   └── filogic.mk
├── bt-r320.config                   # OpenWrt/ImmortalWrt 编译配置
├── build.sh                         # 编译前自定义脚本
├── diy-part1.sh                     # feeds 更新前自定义脚本
├── Packages.sh                      # 自定义软件包脚本
└── bt-r320-24.10-6.6.md             # Release 说明文件
```

## 云编译方法

### 1. Fork 或克隆仓库

如果需要自行编译，请先 Fork 本仓库，或克隆到自己的 GitHub 账号下。

### 2. 手动触发工作流

进入 GitHub 仓库页面：

```text
Actions -> Build bt-r320 ImmortalWrt 24.10-6.6 -> Run workflow
```

点击 `Run workflow` 后，GitHub Actions 会开始云编译。

### 3. 查看编译进度

编译过程通常需要较长时间，具体耗时取决于 GitHub Actions 当前运行环境、网络状态、源码更新情况和软件包数量。

如编译失败，请优先查看以下步骤日志：

- `Load custom configuration`
- `Download package`
- `Compile firmware`
- `Generate release tag`
- `Upload firmware to release`

## 固件下载

编译成功后，固件通常可以从两个位置获取：

1. **Actions Artifact**
   - 打开对应的工作流运行记录
   - 在页面底部下载 `OpenWrt_firmware_*` 产物

2. **GitHub Releases**
   - 如果 `UPLOAD_RELEASE` 为 `true`，编译成功后会自动创建 Release
   - 固件文件会上传到对应 Release 页面

## 重要配置说明

主要环境变量位于：

```text
.github/workflows/bt-r320-24.10-6.6.yml
```

常用字段说明：

| 字段 | 说明 |
| --- | --- |
| `REPO_URL` | ImmortalWrt 源码仓库 |
| `REPO_BRANCH` | 源码分支 |
| `CONFIG_FILE` | 编译配置文件 |
| `DIY_P1_SH` | feeds 更新前执行脚本 |
| `DIY_P2_SH` | feeds 安装后、编译前执行脚本 |
| `UPLOAD_FIRMWARE` | 是否上传固件产物 |
| `UPLOAD_RELEASE` | 是否发布到 GitHub Releases |

## DTS 与设备适配说明

本项目使用自定义 DTS 文件：

```text
dts/mt7981b-globitel-bt-r320-emmc.dts
```

该文件描述 BT-R320 的核心硬件信息，包括：

- 内存布局
- GPIO 按键
- 状态灯与无线灯
- 以太网与 PHY
- eMMC 存储
- SPI NOR / SPI NAND
- USB
- Wi-Fi
- PCIe / NVMe

如果修改 DTS，请重点检查：

- 所有 alias 是否引用了实际存在的标签
- `pinctrl-0` 引用的节点是否已在 `&pio` 中定义
- `nvmem-cells` 引用的 Factory / EEPROM / MAC 节点是否存在
- `compatible` 是否与板级脚本中的设备名一致
- 花括号、分号、节点层级是否符合 DTS 语法

## 刷机前准备

刷机前建议至少完成以下备份：

1. 原厂完整固件
2. eMMC 分区表
3. Factory / EEPROM 分区
4. MAC 地址信息
5. U-Boot 环境变量
6. 当前可正常启动的系统镜像

建议具备 UART 串口救砖条件后再进行首次刷机。

## 风险提示

请确认以下事项后再刷写固件：

- 设备确实为 Globitel BT-R320 eMMC 版本
- 固件与设备分区布局匹配
- 已准备好回滚方案
- 刷机过程中避免断电
- 不要将其他设备型号固件刷入本设备

如果设备硬件批次、分区布局或启动方式与本仓库定义不同，可能导致无法启动。

## 常见问题

### 编译失败怎么办？

优先查看 GitHub Actions 中 `Compile firmware` 的失败日志。常见原因包括：

- DTS 语法错误
- DTS 引用了不存在的节点标签
- 软件包源码拉取失败
- feeds 包冲突
- GitHub Actions 磁盘空间不足

### 找不到固件产物怎么办？

请确认工作流是否完整成功。如果 `Compile firmware` 失败，后续上传步骤会被跳过，不会生成固件产物。

### 是否可以直接用于生产环境？

不建议直接用于生产环境。建议先在测试设备上验证网络、无线、存储、升级、回滚等功能。

### 默认管理地址和密码是什么？

具体以 ImmortalWrt 构建结果为准。首次启动后请尽快通过 LuCI 或 SSH 设置安全密码，并检查防火墙、远程访问等配置。

## 免责声明

本项目仅供学习、研究和合法自用。刷机和修改固件存在风险，使用者应自行确认设备型号、硬件版本、分区布局和回滚方案。因使用本项目导致的任何设备损坏、数据丢失或其他后果，项目维护者不承担责任。

## 致谢

- [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
- [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6)
- [P3TERX Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- OpenWrt / ImmortalWrt 社区贡献者
