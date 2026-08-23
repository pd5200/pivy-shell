# Pivy YubiKey 本地工具

这是一个 macOS 原生 GUI 壳，调用本机已经安装的 `/opt/pivy/bin/pivy-tool`。

## 构建和运行

在终端执行：

```bash
cd pivy-shell
./build.sh
open "PivyShell.app"
```

## 功能

- 左侧按功能分为“设备、文件签名、验证签名、文件加密、文件解密、GPG 工具、证书工具、使用说明”，并提供独立的“运行日志”页面；右侧每次只显示当前功能需要的控件；
- 顶部还提供“证书工具”：导出槽位 SSH 公钥、导出证书、导出 YubiKey 槽位证明，以及生成服务器认证用 CSR；
- 读取并校验 PIV 设备 JSON，显示阅读器、序列号、PIV 版本和槽位摘要；另外可读取 Pivy 版本和 Printed Info；
- 使用 `9c` 对文件做分离签名，输出 `.sig`；
- 同时导出签名证书，输出 `.sig.cert.pem`；
- 使用原文件、`.sig` 和 `.sig.cert.pem` 验证 9c 签名；验证页支持一次拖入三个文件并按后缀自动归类；
- 使用 `9d` 的 ECDH box 加密文件，输出 `.pivybox`；
- 查看 `.pivybox` 元信息；
- 使用同一把 YubiKey 解密 `.pivybox` 文件，输出 `.decrypted`，不会覆盖原文件。
- 当前底层 `pivy-tool` 对 `box` 输入限制为 8.0 KB、对 `sign` 输入限制为 16.0 KB；超过限制会在界面显示错误并保留窗口，不会自动退出。
- GPG 工具支持任意大小文件的 OpenPGP 加密、解密、分离签名和签名验证；文件本体由 GPG 在电脑上处理，YubiKey OpenPGP 应用负责私钥操作。
- GPG 工具提供 OpenPGP 卡状态读取、公钥导出和生成步骤复制；公钥由密钥对生成后通过 `gpg --armor --export` 导出。
- GPG 页面把“我的签名身份”和“收件人公钥库”分开；本机可以保存多个人的公钥，文件加密时选择对方公钥，不会再和自己的签名密钥混用。
- GPG 文件加密支持“同时加密给自己”，并支持“签名并加密”；这样对方可以用自己的私钥解密，你也可以用自己的私钥解开留存副本。
- GPG 密钥管理页可以读取主密钥/子密钥结构，显示本机可用于签名的私钥索引，并提供主密钥、子密钥、迁移到卡片和备用 YubiKey 的步骤说明。
- GPG 工具会自动查找 `/opt/homebrew/bin/gpg`、`/usr/local/bin/gpg` 和 GPG Suite 路径；未安装时会在界面提示 `brew install gnupg`。
- 证书工具中的槽位由设备读取结果生成下拉菜单；槽位诊断可用 `auth` 做往返签名校验。
- 主窗口设有最小尺寸，支持调整大小和最大化；左侧设备卡片、导航和右侧页面标题保持统一边界。
- 日志默认展开并固定在底部，向上展开，不挤压页面；也可以收起为状态条，或从左侧进入独立日志页完整查看。
- 各功能页面都有独立的拖放区域：签名/加密只接受待处理原文件，验证签名分为原文件、`.sig`、证书三个区域，解密只接受 `.pivybox`。
- 签名、加密、解密分别保存自己的文件选择状态；上一页载入的图片不会自动带入其他页面。
- 底部日志抽屉保留统一的彩色状态提示、日志行数以及复制、保存、清空快捷操作。
- “使用说明”页会检查 `pivy-tool`、GnuPG、`pinentry-mac` 和 OpenSSL，并按缺失项目显示安装命令；推荐使用 `brew install --cask pivy-app` 安装 PIV 工具，避免把 Homebrew 中同名的 `pivy` Python 包误当成这里的 PIV 工具。
- PIV 读取遇到疑似 CCID/scdaemon 会话冲突时，会自动执行 `gpgconf --kill scdaemon` 并重试一次；使用说明页也提供手动释放按钮。该操作不会删除 GPG 密钥或 PIV 证书。

## GPG 密钥管理流程

GPG 工具页分为“概览、密钥与卡片、文件加密、签名验证、公布公钥”五个二级菜单：

- “密钥与卡片”可读取 OpenPGP 卡、读取/导入本机公钥、读取私钥索引、查看主密钥/子密钥结构、复制或导出公钥，并打开 `gpg --card-edit` 生成或更换 YubiKey 上的 OpenPGP 密钥；生成/更换不会执行 `factory-reset`，也不会触碰 PIV 槽位；
- 推荐直接在 YubiKey 上生成 OpenPGP 密钥。已有电脑密钥时，必须先做加密离线备份，再通过 `gpg --edit-key` 和 `keytocard` 把选中的子密钥迁移到卡片；只导入公钥不能恢复私钥，也不能制作备用卡。
- 主密钥用于身份和密钥管理，签名、加密、认证通常使用不同的子密钥。界面中的“我的 GPG 身份”用于选择签名身份，“收件人公钥库”用于选择加密对象。
- 多张 YubiKey 默认是独立的。更稳妥的备用方案是为每张卡生成独立子密钥，并把对应公钥分别登记到服务；复制同一套子密钥更方便，但需要安全保存私钥备份，隔离性更低。
- “公布公钥”可把 ASCII-armored 公钥复制到邮件/网站、导出 `.asc` 文件，或在确认指纹后发布到 `hkps://keys.openpgp.org`；发布到公共服务器会产生公开网络记录；
- 生成卡上密钥时，Terminal 中依次输入 `admin`、`generate`；卡上生成的 OpenPGP 私钥通常不能导出。更换前先保存旧公钥和指纹，并通过另一条可信渠道核对公钥指纹。
- GPG 说明按“快速步骤 / PIN 窗口异常修复”分层显示，默认不展开长说明；若出现 `Screen or window too small`，先退出 `gpg/card>`，再在普通 Terminal 执行：

  ```bash
  mkdir -p ~/.gnupg
  printf '%s\n' 'pinentry-program /opt/homebrew/bin/pinentry-mac' >> ~/.gnupg/gpg-agent.conf
  gpgconf --kill gpg-agent
  ```

  然后重新执行 `gpg --card-edit`。这只配置 GPG Agent 的 PIN 弹窗，不会重置 OpenPGP 或 PIV 数据。

## 从零安装与首次使用

如果电脑上只有本工具，打开左侧“使用说明”，按“环境检查”逐项安装。常用安装命令如下：

```bash
# 没有 Homebrew 时先安装（按 Homebrew 的终端提示完成安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# PIV 功能：pivy-tool、pivy-box、pivy-agent
brew install --cask pivy-app

# GPG/OpenPGP 功能和 PIN 安全弹窗
brew install gnupg pinentry-mac

# 配置 GPG PIN 弹窗；$(brew --prefix) 会自动适配 Apple Silicon 或 Intel Mac
mkdir -p ~/.gnupg
printf 'pinentry-program %s\n' "$(brew --prefix)/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent
```

macOS 自带 PC/SC 读卡框架，PIV 功能通常不需要另外安装 `pcscd` 或 OpenSC；`ykman` 也不是本工具的必需依赖。安装后插入 YubiKey，进入“设备”页点击“读取设备”；GPG 功能再进入“GPG 工具”页读取 OpenPGP 卡。

## 注意

1. `pivy` 不是传统的 `.app`，而是命令行工具；本项目是它的 GUI 壳。
2. 每次签名、加密或解密前会弹出 PIN 窗口。PIN 不会写入文件或日志，操作结束后清空。当前 MVP 为了让 GUI 能调用 `pivy-tool`，会把 PIN 作为短命子进程参数传递；不要在共享电脑上使用默认 PIN，也不要把 PIN 写进脚本。
3. 9c 输出的是分离签名文件，验证时需要原文件、`.sig` 和对应的 `.sig.cert.pem`。验证只检查密码学签名是否匹配，不代表自签名证书已被系统信任。
4. 当前 9d 加密格式采用 `pivy-tool box 9d` 的 Pivy ECDH box 格式，只能由支持该格式的 Pivy 工具解密。
5. 图片等大文件需要改用 `pivy-box stream` 流式模式；本 GUI 当前会先提示大小限制，不会把大文件交给 `pivy-tool box`。
6. GPG 加密前需要本机安装 GnuPG，并先在 GPG 工具页读取或输入收件人的公钥指纹。解密和签名时，GPG Agent 会弹出自己的 PIN/触摸提示；该 PIN 不会进入本工具日志。
7. GPG 加密使用收件人的公钥，对方使用自己的私钥/YubiKey 解密；推荐开启“同时加密给自己”，否则你自己可能无法解开发送前保存的密文副本。
8. 签名只证明内容完整且由对应私钥签署；是否确实属于某个人，还需要通过另一条可信渠道核对公钥指纹。

## 项目结构

```text
PivyShell.swift       macOS SwiftUI 主程序
Info.plist            App Bundle 信息
IconGenerator.swift   生成 PIV 钥匙/盾牌风格的 macOS 应用图标
build.sh              编译程序、生成 AppIcon.icns 并组装 PivyShell.app
README.md             使用、安装和安全说明
```

本仓库只保存源代码和构建文件。`PivyShell.app`、图标中间文件、日志、签名结果和 `.pivybox` 文件默认不会提交。

## 设计边界

- 本项目是 `pivy-tool`、GPG 和 macOS PC/SC 的 GUI 壳，不替代 YubiKey 的 PIV/OpenPGP 固件。
- PIV 的 9a/9c/9d/9e 私钥仍留在 YubiKey 内；大文件由电脑上的 GPG 处理，YubiKey 只执行私钥相关操作。
- 本项目不会提供 `factory-reset`、`ykman piv reset`、改 PIN、改 PUK 或导入私钥按钮，避免在图形界面中误清空卡片。
- “读取设备”以及其他 PIV 操作遇到 GPG `scdaemon` 占用时，会尝试释放读卡会话并重试一次；这不会删除密钥或证书。

## 常见问题

### 出现 `no PIV cards/tokens found`

这通常是 GPG `scdaemon` 或其他智能卡程序暂时占用 CCID 读卡会话。关闭正在使用 YubiKey 的程序，重新点击操作；也可以在“使用说明 → 读卡冲突处理”中点击“释放 GPG 读卡会话”。命令行等价于：

```bash
gpgconf --kill scdaemon
```

### 9a 槽位校验出现 `incorrect signature`

9a 校验会让卡内私钥签名，再用槽位公钥验证。先用 YubiKey Manager 独立确认：

```bash
ykman piv keys export 9a - --verify
```

如果独立验证也失败，通常需要重新生成 9a 的密钥和证书，并同步更新服务器上的公钥；不要直接执行 PIV reset 或 factory reset。如果独立验证成功而 `pivy-tool auth` 失败，则应优先怀疑底层工具的 ECDSA 兼容问题。

### GPG 出现 `Screen or window too small`

先退出 `gpg/card>`（输入 `q`），在普通 Terminal 执行：

```bash
mkdir -p ~/.gnupg
printf '%s\n' 'pinentry-program /opt/homebrew/bin/pinentry-mac' >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent
```

然后重新执行 `gpg --card-edit`。这只配置 GPG Agent 的 PIN 弹窗，不会重置 OpenPGP 或 PIV 数据。

## 开发和提交前检查

```bash
./build.sh
git diff --check
```

构建完成后会在项目目录生成 `PivyShell.app`。该应用是本地开发构建，未进行 Apple Developer ID 签名或公证；首次打开时 macOS 可能需要在“系统设置 → 隐私与安全性”允许运行。
