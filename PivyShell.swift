import AppKit
import Combine
import Foundation
import SwiftUI
import UniformTypeIdentifiers

private enum AppTheme: String, CaseIterable, Identifiable {
    case cyberpunk
    case light
    case dark
    case system

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cyberpunk: return "赛博朋克"
        case .light: return "浅色"
        case .dark: return "深色"
        case .system: return "跟随系统"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .cyberpunk, .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }
}

private enum ThemeRole: String {
    case background
    case surface
    case surfaceRaised
    case surfaceBright
    case cyan
    case violet
    case magenta
    case orange
    case green
    case text
    case muted
    case border
}

private enum ThemeRuntime {
    static let defaultsKey = "pivy.theme"

    static func fixedColor(_ role: ThemeRole) -> Color {
        let appearance = NSApp?.effectiveAppearance ?? NSAppearance(named: .aqua)!
        return Color(nsColor: nsColor(role, appearance: appearance))
    }

    static func nsColor(_ role: ThemeRole, appearance: NSAppearance) -> NSColor {
        let configuredTheme = AppTheme(
            rawValue: UserDefaults.standard.string(forKey: defaultsKey) ?? AppTheme.cyberpunk.rawValue
        ) ?? .cyberpunk
        let effectiveTheme: AppTheme
        if configuredTheme == .system {
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            effectiveTheme = isDark ? .dark : .light
        } else {
            effectiveTheme = configuredTheme
        }

        switch effectiveTheme {
        case .cyberpunk:
            switch role {
            case .background: return rgb(0.018, 0.024, 0.055)
            case .surface: return rgb(0.045, 0.055, 0.105)
            case .surfaceRaised: return rgb(0.070, 0.075, 0.145)
            case .surfaceBright: return rgb(0.100, 0.095, 0.185)
            case .cyan: return rgb(0.120, 0.900, 1.000)
            case .violet: return rgb(0.470, 0.300, 1.000)
            case .magenta: return rgb(1.000, 0.180, 0.660)
            case .orange: return rgb(1.000, 0.540, 0.180)
            case .green: return rgb(0.260, 1.000, 0.580)
            case .text: return rgb(0.910, 0.940, 1.000)
            case .muted: return rgb(0.570, 0.620, 0.760)
            case .border: return rgb(0.180, 0.230, 0.430)
            }
        case .light:
            switch role {
            case .background: return rgb(0.955, 0.965, 0.985)
            case .surface: return rgb(0.985, 0.988, 0.995)
            case .surfaceRaised: return rgb(1.000, 1.000, 1.000)
            case .surfaceBright: return rgb(0.930, 0.945, 0.975)
            case .cyan: return rgb(0.000, 0.420, 0.820)
            case .violet: return rgb(0.340, 0.220, 0.720)
            case .magenta: return rgb(0.780, 0.080, 0.420)
            case .orange: return rgb(0.820, 0.360, 0.000)
            case .green: return rgb(0.000, 0.520, 0.220)
            case .text: return rgb(0.100, 0.120, 0.170)
            case .muted: return rgb(0.350, 0.390, 0.480)
            case .border: return rgb(0.700, 0.750, 0.850)
            }
        case .dark:
            switch role {
            case .background: return rgb(0.095, 0.100, 0.125)
            case .surface: return rgb(0.135, 0.145, 0.175)
            case .surfaceRaised: return rgb(0.180, 0.190, 0.225)
            case .surfaceBright: return rgb(0.230, 0.240, 0.280)
            case .cyan: return rgb(0.420, 0.700, 1.000)
            case .violet: return rgb(0.620, 0.480, 1.000)
            case .magenta: return rgb(1.000, 0.360, 0.700)
            case .orange: return rgb(1.000, 0.620, 0.260)
            case .green: return rgb(0.420, 0.920, 0.580)
            case .text: return rgb(0.940, 0.945, 0.965)
            case .muted: return rgb(0.650, 0.670, 0.730)
            case .border: return rgb(0.350, 0.370, 0.450)
            }
        case .system:
            return nsColor(role, appearance: appearance)
        }
    }

    private static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> NSColor {
        NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1)
    }
}

private enum CyberpunkTheme {
    static var background: Color { ThemeRuntime.fixedColor(.background) }
    static var surface: Color { ThemeRuntime.fixedColor(.surface) }
    static var surfaceRaised: Color { ThemeRuntime.fixedColor(.surfaceRaised) }
    static var surfaceBright: Color { ThemeRuntime.fixedColor(.surfaceBright) }
    static var cyan: Color { ThemeRuntime.fixedColor(.cyan) }
    static var violet: Color { ThemeRuntime.fixedColor(.violet) }
    static var magenta: Color { ThemeRuntime.fixedColor(.magenta) }
    static var orange: Color { ThemeRuntime.fixedColor(.orange) }
    static var green: Color { ThemeRuntime.fixedColor(.green) }
    static var text: Color { ThemeRuntime.fixedColor(.text) }
    static var muted: Color { ThemeRuntime.fixedColor(.muted) }
    static var border: Color { ThemeRuntime.fixedColor(.border) }
}

private struct CyberpunkGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            configuration.label
                .font(.callout.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [CyberpunkTheme.text, CyberpunkTheme.cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            configuration.content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [CyberpunkTheme.surfaceRaised, CyberpunkTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(CyberpunkTheme.border.opacity(0.80), lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            Rectangle()
                .fill(CyberpunkTheme.cyan)
                .frame(width: 36, height: 2)
                .padding(.top, -1)
                .padding(.leading, 14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: CyberpunkTheme.violet.opacity(0.10), radius: 12, y: 4)
    }
}

private struct CyberpunkBackdrop: View {
    var body: some View {
        ZStack {
            CyberpunkTheme.background
            LinearGradient(
                colors: [CyberpunkTheme.violet.opacity(0.16), .clear, CyberpunkTheme.magenta.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [CyberpunkTheme.cyan.opacity(0.13), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 560
            )
            Canvas { context, size in
                let spacing: CGFloat = 34
                var grid = Path()
                for x in stride(from: 0, through: size.width, by: spacing) {
                    grid.move(to: CGPoint(x: x, y: 0))
                    grid.addLine(to: CGPoint(x: x, y: size.height))
                }
                for y in stride(from: 0, through: size.height, by: spacing) {
                    grid.move(to: CGPoint(x: 0, y: y))
                    grid.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(grid, with: .color(CyberpunkTheme.cyan.opacity(0.045)), lineWidth: 0.5)

                var scanline = Path()
                scanline.move(to: CGPoint(x: 0, y: size.height * 0.18))
                scanline.addLine(to: CGPoint(x: size.width, y: size.height * 0.18))
                scanline.move(to: CGPoint(x: 0, y: size.height * 0.82))
                scanline.addLine(to: CGPoint(x: size.width, y: size.height * 0.82))
                context.stroke(scanline, with: .color(CyberpunkTheme.magenta.opacity(0.10)), lineWidth: 1)
            }
        }
        .ignoresSafeArea()
    }
}

private struct CommandResult {
    let status: Int32
    let stdout: Data
    let stderr: Data
    let terminationReason: Process.TerminationReason?
}

struct GPGKey: Identifiable, Hashable {
    let fingerprint: String
    let userID: String

    init(fingerprint: String, userID: String = "") {
        self.fingerprint = fingerprint
        self.userID = userID
    }

    var id: String { fingerprint }

    var displayName: String {
        userID.isEmpty ? fingerprint : "\(userID) · \(fingerprint)"
    }
}

enum StatusKind {
    case info
    case running
    case success
    case warning
    case failure

    var color: Color {
        switch self {
        case .info: return CyberpunkTheme.muted
        case .running: return CyberpunkTheme.cyan
        case .success: return CyberpunkTheme.green
        case .warning: return CyberpunkTheme.orange
        case .failure: return CyberpunkTheme.magenta
        }
    }

    var background: Color {
        color.opacity(0.12)
    }
}

private enum PendingOperation {
    case sign
    case encrypt
    case decrypt
    case printedInfo
    case csr(slot: String, commonName: String, outputURL: URL)
    case attestation(slot: String, outputURL: URL)
    case auth(slot: String)
}

private enum GPGSection: String, CaseIterable, Hashable {
    case overview
    case keys
    case generate
    case encrypt
    case sign
    case publish

    var title: String {
        switch self {
        case .overview: return "概览"
        case .keys: return "密钥与卡片"
        case .generate: return "本地生成"
        case .encrypt: return "文件加密"
        case .sign: return "签名验证"
        case .publish: return "公布公钥"
        }
    }

    var systemImage: String {
        switch self {
        case .overview: return "rectangle.grid.2x2"
        case .keys: return "key.fill"
        case .generate: return "key.viewfinder"
        case .encrypt: return "lock.fill"
        case .sign: return "signature"
        case .publish: return "person.crop.circle.badge.checkmark"
        }
    }
}

@MainActor
final class PivyModel: ObservableObject {
    @Published var dataFile: URL?
    @Published var signatureFile: URL?
    @Published var certificateFile: URL?
    @Published var encryptFile: URL?
    @Published var decryptFile: URL?
    @Published var gpgEncryptFile: URL?
    @Published var gpgDecryptFile: URL?
    @Published var gpgSignFile: URL?
    @Published var gpgVerifyFile: URL?
    @Published var gpgVerifySignatureFile: URL?
    @Published var gpgKeyLookup = ""
    @Published var gpgSelectedPublicKey = ""
    @Published var gpgRecipient = ""
    @Published var gpgEncryptRecipient = ""
    @Published var gpgKeys: [GPGKey] = []
    @Published var gpgSecretKeys: [GPGKey] = []
    @Published var gpgKeyDetails = "尚未读取主密钥和子密钥结构"
    @Published var gpgEncryptToSelf = true
    @Published var gpgCardSummary = "尚未读取 OpenPGP 卡"
    @Published var gpgKeyserver = "hkps://keys.openpgp.org"
    @Published var fidoAlgorithm = FIDOKeyAlgorithm.ed25519
    @Published var fidoResident = true
    @Published var fidoVerifyRequired = true
    @Published var fidoComment = "your@email.com"
    @Published var fidoKeyName = "server"
    @Published var fidoApplicationLabel = "server"
    @Published var fidoUsername = "ubuntu"
    @Published var fidoHost = "server.example.com"
    @Published var sshEnvironmentSummary = "尚未检查 OpenSSH 环境"
    @Published var sshSupportsFIDO = false
    @Published var sshEnvironmentChecking = false
    @Published var pin = ""
    @Published var showPINPrompt = false
    @Published var pinPromptTitle = "输入 PIV PIN"
    @Published var log = "准备就绪。插入或更换 YubiKey 后会自动读取设备。\n"
    @Published var statusText = "准备就绪"
    @Published var statusKind: StatusKind = .info
    @Published var busy = false
    @Published var deviceSummary = "尚未读取设备"
    @Published var deviceReader = "等待 YubiKey"
    @Published var deviceSerial = "--"
    @Published var devicePIVVersion = "--"
    @Published var selectedSlot = "9a"
    @Published var availableSlots = ["9a", "9c", "9d", "9e"]
    @Published var csrCommonName = "Pivy User"

    let pivyToolPath = "/opt/pivy/bin/pivy-tool"
    let pendingPINHint = "PIN 只用于本次操作，完成后会立即清空。"
    private var pendingOperation: PendingOperation?
    private var deviceMonitorTimer: Timer?
    private var autoDeviceProbeInFlight = false
    private var lastDetectedDeviceIdentity: String?

    init() {
        startDeviceMonitor()
    }

    deinit {
        deviceMonitorTimer?.invalidate()
    }

    var pivyInstalled: Bool {
        FileManager.default.isExecutableFile(atPath: pivyToolPath)
    }

    var opensslPath: String? {
        ["/opt/homebrew/bin/openssl", "/usr/bin/openssl"].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    var brewPath: String? {
        ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    var pinentryPath: String? {
        ["/opt/homebrew/bin/pinentry-mac", "/usr/local/bin/pinentry-mac"].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    var gpgToolPath: String? {
        [
            "/opt/homebrew/bin/gpg",
            "/usr/local/bin/gpg",
            "/usr/local/MacGPG2/bin/gpg",
            "/usr/local/MacGPG2/bin/gpg2",
            "/opt/local/bin/gpg"
        ].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    var gpgInstalled: Bool {
        gpgToolPath != nil
    }

    var gpgconfPath: String? {
        ["/opt/homebrew/bin/gpgconf", "/usr/local/bin/gpgconf", "/usr/local/MacGPG2/bin/gpgconf"].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    var sshPath: String? {
        ["/opt/homebrew/bin/ssh", "/usr/local/bin/ssh", "/usr/bin/ssh"].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    var sshKeygenPath: String? {
        ["/opt/homebrew/bin/ssh-keygen", "/usr/local/bin/ssh-keygen", "/usr/bin/ssh-keygen"].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    var sshCopyIDPath: String? {
        ["/opt/homebrew/bin/ssh-copy-id", "/usr/local/bin/ssh-copy-id", "/usr/bin/ssh-copy-id"].first {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    func refreshSSHEnvironment() {
        guard !sshEnvironmentChecking else { return }
        guard let sshPath else {
            sshEnvironmentSummary = "未找到 ssh。请安装 Homebrew OpenSSH：brew install openssh"
            sshSupportsFIDO = false
            announce("未找到 OpenSSH", kind: .warning)
            return
        }

        sshEnvironmentChecking = true
        sshEnvironmentSummary = "正在检查 \(sshPath)…"
        DispatchQueue.global(qos: .utility).async {
            let versionResult = Self.execute(tool: sshPath, arguments: ["-V"], input: nil)
            let keyTypesResult = Self.execute(tool: sshPath, arguments: ["-Q", "key"], input: nil)
            let versionOutput = [versionResult.stdout, versionResult.stderr]
                .compactMap { String(data: $0, encoding: .utf8) }
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let keyTypesOutput = String(data: keyTypesResult.stdout, encoding: .utf8) ?? ""
            let version = FIDOServerLogic.parseOpenSSHVersion(versionOutput)
            let reportsSecurityKeyType = keyTypesResult.status == 0
                && FIDOServerLogic.reportsSecurityKeyTypes(keyTypesOutput)

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                sshEnvironmentChecking = false
                sshSupportsFIDO = reportsSecurityKeyType

                var lines = [
                    "ssh：\(sshPath)",
                    "ssh-keygen：\(sshKeygenPath ?? "未找到")",
                    "版本：\(version.map(String.init(describing:)) ?? versionOutput)"
                ]
                if let version {
                    let capabilities = FIDOServerLogic.capabilities(for: version)
                    lines.append("OpenSSH 8.2+：\(capabilities.supportsSecurityKeys ? "满足" : "不满足")")
                    lines.append("驻留密钥恢复 -K：\(capabilities.supportsResidentKeyRecovery ? "支持" : "版本过低")")
                    lines.append("每次 PIN 验证：\(capabilities.supportsVerifyRequired ? "支持" : "版本过低")")
                }
                lines.append("FIDO2 -sk 密钥类型：\(reportsSecurityKeyType ? "当前构建支持" : "当前构建不支持")")
                sshEnvironmentSummary = lines.joined(separator: "\n")

                if reportsSecurityKeyType {
                    announce("OpenSSH 已支持 FIDO2", kind: .success)
                    appendLog("FIDO2 SSH 环境检查完成：\n\(sshEnvironmentSummary)")
                } else {
                    announce("当前 OpenSSH 不支持 FIDO2", kind: .warning)
                    appendLog("当前 ssh 没有报告 ed25519-sk/ecdsa-sk。macOS 请执行 brew install openssh，并让 Homebrew bin 目录排在 PATH 前面。\n\(sshEnvironmentSummary)")
                }
            }
        }
    }

    func makeFIDOServerCommands() throws -> FIDOServerCommands {
        try FIDOServerLogic.commands(
            for: FIDOServerConfiguration(
                algorithm: fidoAlgorithm,
                resident: fidoResident,
                verifyRequired: fidoVerifyRequired,
                comment: fidoComment,
                keyName: fidoKeyName,
                applicationLabel: fidoApplicationLabel,
                username: fidoUsername,
                host: fidoHost
            ),
            sshCommand: sshPath ?? "ssh",
            sshKeygenCommand: sshKeygenPath ?? "ssh-keygen",
            sshCopyIDCommand: sshCopyIDPath ?? "ssh-copy-id"
        )
    }

    func copyFIDOServerText(_ text: String, title: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        announce("已复制：\(title)", kind: .success)
        appendLog("\(title)：\n\(text)")
    }

    private func validateToolInput(_ file: URL, operation: String, maxBytes: Int, alternative: String) -> Bool {
        guard file.isFileURL, FileManager.default.isReadableFile(atPath: file.path) else {
            announce("输入文件不可读取", kind: .failure)
            appendLog("无法读取输入：\(file.path)")
            return false
        }

        guard let resourceValues = try? file.resourceValues(forKeys: [.fileSizeKey]),
              let fileSize = resourceValues.fileSize else {
            announce("无法读取文件大小", kind: .failure)
            appendLog("无法检查输入：\(file.path)")
            return false
        }

        guard fileSize <= maxBytes else {
            announce("\(operation)暂不支持超过 \(Self.kilobytes(maxBytes)) 的文件", kind: .failure)
            appendLog(
                "输入文件：\(file.path)\n" +
                "实际大小：\(Self.kilobytes(fileSize))；pivy-tool 上限：\(Self.kilobytes(maxBytes))。\n" +
                "建议：\(alternative)"
            )
            return false
        }
        return true
    }

    func chooseDataFile() {
        chooseFile(title: "选择原文件") { [weak self] url in
            guard let self, let url else { return }
            self.setDataFile(url)
        }
    }

    func chooseEncryptFile() {
        chooseFile(title: "选择要加密的文件") { [weak self] url in
            guard let self, let url else { return }
            self.setEncryptFile(url)
        }
    }

    func chooseDecryptFile() {
        chooseFile(title: "选择 .pivybox 加密文件") { [weak self] url in
            guard let self, let url else { return }
            guard url.pathExtension.lowercased() == "pivybox" else {
                announce("解密入口只接受 .pivybox 文件", kind: .warning)
                return
            }
            setDecryptFile(url)
        }
    }

    func chooseGPGEncryptFile() {
        chooseFile(title: "选择要用 GPG 加密的文件") { [weak self] url in
            guard let self, let url else { return }
            gpgEncryptFile = url
            announce("已载入 GPG 待加密文件：\(url.lastPathComponent)", kind: .info)
        }
    }

    func chooseGPGDecryptFile() {
        chooseFile(title: "选择 GPG 加密文件") { [weak self] url in
            guard let self, let url else { return }
            gpgDecryptFile = url
            announce("已载入 GPG 待解密文件：\(url.lastPathComponent)", kind: .info)
        }
    }

    func chooseGPGSignFile() {
        chooseFile(title: "选择要用 GPG 签名的文件") { [weak self] url in
            guard let self, let url else { return }
            gpgSignFile = url
            announce("已载入 GPG 待签名文件：\(url.lastPathComponent)", kind: .info)
        }
    }

    func chooseGPGVerifyFile() {
        chooseFile(title: "选择要验证的原文件") { [weak self] url in
            guard let self, let url else { return }
            gpgVerifyFile = url
            announce("已载入 GPG 待验证原文件：\(url.lastPathComponent)", kind: .info)
        }
    }

    func chooseGPGVerifySignatureFile() {
        chooseFile(title: "选择 GPG 签名文件") { [weak self] url in
            guard let self, let url else { return }
            gpgVerifySignatureFile = url
            announce("已载入 GPG 签名文件：\(url.lastPathComponent)", kind: .info)
        }
    }

    func chooseSignatureFile() {
        chooseFile(title: "选择 .sig 签名文件") { [weak self] url in
            guard let self, let url else { return }
            setSignatureFile(url)
        }
    }

    func chooseCertificateFile() {
        chooseFile(title: "选择 .pem 证书文件") { [weak self] url in
            guard let self, let url else { return }
            setCertificateFile(url)
        }
    }

    func setDataFile(_ url: URL) {
        dataFile = url
        announce("已载入原文件：\(url.lastPathComponent)", kind: .info)
    }

    func setSignatureFile(_ url: URL) {
        signatureFile = url
        announce("已载入签名文件：\(url.lastPathComponent)", kind: .info)
    }

    func setCertificateFile(_ url: URL) {
        certificateFile = url
        announce("已载入证书：\(url.lastPathComponent)", kind: .info)
    }

    func setEncryptFile(_ url: URL) {
        encryptFile = url
        announce("已载入待加密文件：\(url.lastPathComponent)", kind: .info)
    }

    func setDecryptFile(_ url: URL) {
        decryptFile = url
        announce("已载入待解密文件：\(url.lastPathComponent)", kind: .info)
    }

    func announceInvalidDecryptDrop() {
        announce("解密入口只接受 .pivybox 文件", kind: .warning)
    }

    func acceptDroppedFiles(_ urls: [URL]) {
        urls.forEach(setDroppedFile)
    }

    private func setDroppedFile(_ url: URL?) {
        guard let url else { return }
        let ext = url.pathExtension.lowercased()
        if ext == "sig" {
            setSignatureFile(url)
        } else if ["pem", "crt", "cer"].contains(ext) {
            setCertificateFile(url)
        } else {
            setDataFile(url)
        }
    }

    func showDevice() {
        showDevice(attempt: 0)
    }

    private func startDeviceMonitor() {
        let timer = Timer(timeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.pollDeviceForAutomaticRefresh()
            }
        }
        timer.tolerance = 0.5
        RunLoop.main.add(timer, forMode: .common)
        deviceMonitorTimer = timer
        pollDeviceForAutomaticRefresh()
    }

    private func pollDeviceForAutomaticRefresh() {
        guard pivyInstalled, !busy, !autoDeviceProbeInFlight else { return }

        autoDeviceProbeInFlight = true
        let tool = pivyToolPath
        DispatchQueue.global(qos: .utility).async {
            let result = Self.execute(tool: tool, arguments: ["-j", "list"], input: nil)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.autoDeviceProbeInFlight = false
                self.handleAutomaticDeviceProbe(result)
            }
        }
    }

    private func handleAutomaticDeviceProbe(_ result: CommandResult) {
        let output = Self.text(result.stdout)
        let error = Self.text(result.stderr)

        guard result.status == 0, let summary = Self.formatDeviceSummary(result.stdout) else {
            guard lastDetectedDeviceIdentity != nil,
                  (Self.looksLikeNoDevice(output: output, error: error)
                   || Self.isEmptyDeviceResponse(result.stdout)
                   || (result.stdout.isEmpty && result.stderr.isEmpty)) else { return }

            clearDetectedDevice()
            return
        }

        let identity = Self.deviceIdentity(from: summary)
        guard identity != lastDetectedDeviceIdentity else { return }

        let wasConnected = lastDetectedDeviceIdentity != nil
        applyDeviceSummary(summary, identity: identity)
        let message = wasConnected ? "已自动识别新的 YubiKey" : "已自动读取 YubiKey"
        lastDetectedDeviceIdentity = identity
        announce(message, kind: .success)
        appendLog("自动读取设备信息：\n\(summary)")
    }

    private func applyDeviceSummary(_ summary: String, identity: String? = nil) {
        deviceSummary = summary
        deviceReader = Self.summaryValue(summary, prefix: "阅读器：") ?? "Yubico YubiKey"
        deviceSerial = Self.summaryValue(summary, prefix: "序列号：") ?? "--"
        devicePIVVersion = Self.summaryValue(summary, prefix: "PIV 版本：") ?? "--"
        lastDetectedDeviceIdentity = identity ?? Self.deviceIdentity(from: summary)
    }

    private func clearDetectedDevice() {
        guard lastDetectedDeviceIdentity != nil else { return }
        lastDetectedDeviceIdentity = nil
        deviceSummary = "未检测到 YubiKey"
        deviceReader = "未检测到 YubiKey"
        deviceSerial = "--"
        devicePIVVersion = "--"
        availableSlots = ["9a", "9c", "9d", "9e"]
        announce("YubiKey 已移除", kind: .warning)
        appendLog("自动检测：未检测到 PIV YubiKey。插入设备后将自动重新读取。")
    }

    private func showDevice(attempt: Int) {
        runTool(arguments: ["-j", "list"], input: nil, operation: "读取设备") { [weak self] result in
            guard let self else { return }
            let output = Self.text(result.stdout)
            let error = Self.text(result.stderr)
            guard result.status == 0 else {
                if attempt == 0,
                   self.gpgconfPath != nil,
                   Self.looksLikeCardSessionIssue(output: output, error: error) {
                    self.retryDeviceReadAfterReleasingGPG(output: output, error: error)
                    return
                }
                announce("读取设备失败", kind: .failure)
                appendLog("读取失败：\n\(error.isEmpty ? output : error)")
                return
            }

            guard let summary = Self.formatDeviceSummary(result.stdout) else {
                if attempt == 0, self.gpgconfPath != nil {
                    self.retryDeviceReadAfterReleasingGPG(output: output, error: error)
                    return
                }
                announce("设备读取失败：返回内容不是有效的 PIV JSON", kind: .failure)
                appendLog("PIV 没有返回可解析的 JSON。输出字节数：\(result.stdout.count)，错误输出：\n\(error)\n\(output)")
                return
            }

            applyDeviceSummary(summary)
            let slots = Self.extractSlotIDs(result.stdout)
            if !slots.isEmpty {
                availableSlots = slots
                if !slots.contains(selectedSlot) {
                    selectedSlot = slots[0]
                }
            }
            announce("设备读取成功", kind: .success)
            appendLog("设备信息：\n\(summary)")
            if !error.isEmpty && error != "（无输出）" {
                appendLog("设备提示：\n\(error)")
            }
        }
    }

    private func retryDeviceReadAfterReleasingGPG(output: String, error: String) {
        announce("正在释放 GPG 读卡会话并重试…", kind: .running)
        appendLog("PIV 首次读取没有得到有效 JSON，可能是 GPG scdaemon 或其他读卡程序占用 CCID。")
        if output != "（无输出）" || error != "（无输出）" {
            appendLog("首次返回：\n\(error)\n\(output)")
        }
        busy = true
        releaseGPGSmartCardSession { [weak self] released in
            guard let self else { return }
            busy = false
            if released {
                appendLog("已释放 scdaemon，重新读取 PIV 设备。")
                showDevice(attempt: 1)
            } else {
                announce("无法自动释放 GPG 读卡会话", kind: .failure)
                appendLog("请关闭正在使用 YubiKey 的 GPG、Yubico Authenticator 或其他智能卡程序后重试。")
            }
        }
    }

    func releaseGPGSmartCardSession() {
        guard !busy else {
            announce("已有操作正在运行，请稍候", kind: .warning)
            return
        }
        guard gpgconfPath != nil else {
            announce("未找到 GPG，无需释放 GPG 读卡会话", kind: .info)
            appendLog("当前没有检测到 gpgconf；PIV 读取不会受到本工具内 GPG 会话影响。")
            return
        }

        announce("正在释放 GPG 读卡会话…", kind: .running)
        busy = true
        releaseGPGSmartCardSession { [weak self] released in
            guard let self else { return }
            busy = false
            if released {
                announce("GPG 读卡会话已释放", kind: .success)
                appendLog("现在可以重新点击“读取设备”。")
            } else {
                announce("释放 GPG 读卡会话失败", kind: .failure)
                appendLog("请关闭正在使用 YubiKey 的 GPG、Yubico Authenticator 或其他智能卡程序后重试。")
            }
        }
    }

    private func releaseGPGSmartCardSession(completion: @escaping (Bool) -> Void) {
        guard let gpgconfPath else {
            completion(false)
            return
        }

        appendLog("命令：gpgconf --kill scdaemon")
        DispatchQueue.global(qos: .utility).async {
            let result = Self.execute(tool: gpgconfPath, arguments: ["--kill", "scdaemon"], input: nil)
            DispatchQueue.main.async {
                if result.status != 0 {
                    self.appendLog("gpgconf 失败：\(Self.text(result.stderr))")
                }
                completion(result.status == 0)
            }
        }
    }

    private static func looksLikeCardSessionIssue(output: String, error: String) -> Bool {
        let text = "\(output)\n\(error)".lowercased()
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text == "（无输出）\n（无输出）" {
            return true
        }
        return ["no such device", "no piv cards", "tokens found", "sharing", "reader", "pc/sc", "pcsc", "smart card", "card error", "end of file"]
            .contains(where: text.contains)
    }

    private static func looksLikeNoDevice(output: String, error: String) -> Bool {
        let text = "\(output)\n\(error)".lowercased()
        return [
            "no such device",
            "no piv cards",
            "no piv card",
            "no cards",
            "no tokens found",
            "no piv/tokens",
            "not found"
        ].contains(where: text.contains)
    }

    private static func isEmptyDeviceResponse(_ data: Data) -> Bool {
        guard let object = try? JSONSerialization.jsonObject(with: data) else { return false }
        if let array = object as? [Any] {
            return array.isEmpty
        }
        guard let dictionary = object as? [String: Any] else { return false }
        if let devices = dictionary["devices"] as? [Any] {
            return devices.isEmpty
        }
        let deviceFields: Set<String> = ["reader", "serial", "slots", "ykpiv_version"]
        return !dictionary.keys.contains(where: deviceFields.contains)
    }

    func showVersion() {
        runTool(arguments: ["version"], input: nil, operation: "读取 Pivy 版本") { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                announce("Pivy 版本读取成功", kind: .success)
                appendLog(Self.text(result.stdout))
            } else {
                announce("Pivy 版本读取失败", kind: .failure)
                appendLog(Self.text(result.stderr))
            }
        }
    }

    func showPrintedInfo() {
        requestPIN(for: .printedInfo, title: "读取 PIV Printed Info")
    }

    func autoAssignVerifyFiles(_ urls: [URL]) {
        var dataCandidate: URL?
        var signatureCandidate: URL?
        var certificateCandidate: URL?

        for url in urls {
            let name = url.lastPathComponent.lowercased()
            let ext = url.pathExtension.lowercased()

            if name.hasSuffix(".sig.cert.pem") || ["pem", "crt", "cer"].contains(ext) {
                certificateCandidate = certificateCandidate ?? url
            } else if ext == "sig" {
                signatureCandidate = signatureCandidate ?? url
            } else if ext != "pivybox" {
                dataCandidate = dataCandidate ?? url
            }
        }

        var assigned = 0
        if let dataCandidate {
            setDataFile(dataCandidate)
            assigned += 1
        }
        if let signatureCandidate {
            setSignatureFile(signatureCandidate)
            assigned += 1
        }
        if let certificateCandidate {
            setCertificateFile(certificateCandidate)
            assigned += 1
        }

        if assigned == 0 {
            announce("没有识别出可用于验证的文件", kind: .warning)
        } else {
            announce("已按后缀智能填入 \(assigned) 个验证文件", kind: .success)
            appendLog("识别规则：.sig → 签名；.pem/.crt/.cer 或 .sig.cert.pem → 证书；其余普通文件 → 原文件。")
        }
    }

    func inspectBox() {
        guard let decryptFile, decryptFile.pathExtension.lowercased() == "pivybox" else {
            announce("请先选择 .pivybox 加密文件", kind: .warning)
            return
        }
        do {
            let input = try Data(contentsOf: decryptFile)
            guard !input.isEmpty else {
                announce(".pivybox 文件为空", kind: .warning)
                return
            }
            runTool(arguments: ["box-info"], input: input, operation: "查看 .pivybox 信息") { [weak self] result in
                guard let self else { return }
                if result.status == 0 {
                    announce("密文信息读取成功", kind: .success)
                    appendLog(Self.text(result.stdout))
                } else {
                    announce("密文信息读取失败", kind: .failure)
                    appendLog(Self.text(result.stderr))
                }
            }
        } catch {
            announce("读取 .pivybox 失败", kind: .failure)
            appendLog(error.localizedDescription)
        }
    }

    func exportPublicKey() {
        guard let slot = normalizedSlot() else { return }
        chooseOutputFile(title: "保存 SSH 公钥", suggestedName: "pivy-\(slot).pub") { [weak self] url in
            guard let self, let url else { return }
            startSavedOutput(
                arguments: ["pubkey", slot],
                outputURL: url,
                operation: "导出 \(slot) SSH 公钥",
                successMessage: "公钥导出完成"
            )
        }
    }

    func exportCertificate() {
        guard let slot = normalizedSlot() else { return }
        chooseOutputFile(title: "保存 PIV 证书", suggestedName: "pivy-\(slot).cert.pem") { [weak self] url in
            guard let self, let url else { return }
            startSavedOutput(
                arguments: ["cert", slot],
                outputURL: url,
                operation: "导出 \(slot) 证书",
                successMessage: "证书导出完成"
            )
        }
    }

    func requestCSR() {
        guard let slot = normalizedSlot() else { return }
        let commonName = csrCommonName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !commonName.isEmpty else {
            announce("CSR 的 CN 不能为空", kind: .warning)
            return
        }
        chooseOutputFile(title: "保存证书签名请求", suggestedName: "pivy-\(slot).csr.pem") { [weak self] url in
            guard let self, let url else { return }
            requestPIN(for: .csr(slot: slot, commonName: commonName, outputURL: url), title: "生成 \(slot) CSR")
        }
    }

    func requestAttestation() {
        guard let slot = normalizedSlot() else { return }
        chooseOutputFile(title: "保存槽位证明证书", suggestedName: "pivy-\(slot).attest.pem") { [weak self] url in
            guard let self, let url else { return }
            requestPIN(for: .attestation(slot: slot, outputURL: url), title: "导出 \(slot) 槽位证明")
        }
    }

    func requestSlotAuth() {
        guard let slot = normalizedSlot() else { return }
        requestPIN(for: .auth(slot: slot), title: "测试 \(slot) 槽位")
    }

    func requestSign() {
        guard let dataFile else {
            announce("请先拖入或选择要签名的原文件", kind: .warning)
            return
        }
        guard validateToolInput(
            dataFile,
            operation: "9c 签名",
            maxBytes: 16 * 1024,
            alternative: "将文件压缩或拆分后再签名；大文件签名需要改用支持流式输入的工具。"
        ) else { return }
        requestPIN(for: .sign, title: "9c 文件签名")
    }

    func requestEncrypt() {
        guard let encryptFile else {
            announce("请先拖入或选择要加密的文件", kind: .warning)
            return
        }
        guard validateToolInput(
            encryptFile,
            operation: "9d 加密",
            maxBytes: 8 * 1024,
            alternative: "图片等大文件请使用 pivy-box 的 stream 模式；当前 pivy-tool box 只支持小文件。"
        ) else { return }
        requestPIN(for: .encrypt, title: "9d 文件加密")
    }

    func requestDecrypt() {
        guard let decryptFile, decryptFile.pathExtension.lowercased() == "pivybox" else {
            announce("请先拖入或选择 .pivybox 加密文件", kind: .warning)
            return
        }
        requestPIN(for: .decrypt, title: "9d 文件解密")
    }

    func refreshGPGKeys(allowRemoteFallback: Bool = true) {
        guard gpgToolPath != nil else {
            announce("找不到 GPG", kind: .failure)
            appendLog("未找到 gpg。macOS 可安装：brew install gnupg")
            return
        }

        runGPG(
            arguments: ["--batch", "--with-colons", "--list-keys"],
            operation: "读取 GPG 公钥"
        ) { [weak self] result in
            guard let self else { return }
            guard result.status == 0 else {
                announce("读取 GPG 公钥失败", kind: .failure)
                appendLog(Self.text(result.stderr))
                return
            }

            let keys = Self.parseGPGKeys(result.stdout)
            gpgKeys = keys

            self.runGPG(
                arguments: ["--batch", "--with-colons", "--list-secret-keys"],
                operation: "读取 GPG 私钥索引"
            ) { [weak self] secretResult in
                guard let self else { return }
                let secretKeys = secretResult.status == 0 ? Self.parseGPGKeys(secretResult.stdout) : []
                self.gpgSecretKeys = secretKeys
                if self.gpgRecipient.isEmpty, let first = secretKeys.first {
                    self.gpgRecipient = first.fingerprint
                }

                if keys.isEmpty {
                    self.announce("没有发现 GPG 公钥", kind: .warning)
                    self.appendLog("请先导入收件人的 OpenPGP 公钥，或手动输入邮箱/指纹。")
                } else {
                    self.announce("已读取 \(keys.count) 个公钥、\(secretKeys.count) 个私钥索引", kind: .success)
                    self.appendLog("可用公钥：\n\(keys.map { $0.displayName }.joined(separator: "\n"))")
                    self.appendLog("可用于签名的私钥索引：\n\(secretKeys.isEmpty ? "（未发现）" : secretKeys.map { $0.displayName }.joined(separator: "\n"))")
                }
                if secretResult.status != 0 {
                    self.appendLog("读取私钥索引失败：\n\(Self.text(secretResult.stderr))")
                }

                let query = self.gpgKeyLookup.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !query.isEmpty else { return }
                let candidates = keys.map {
                    GPGKeyLookupCandidate(fingerprint: $0.fingerprint, userID: $0.userID)
                }
                if let localKey = GPGKeyLookupLogic.localMatch(query: query, candidates: candidates) {
                    self.gpgSelectedPublicKey = localKey.fingerprint
                    self.gpgEncryptRecipient = localKey.fingerprint
                    self.gpgKeyLookup = localKey.fingerprint
                    let displayName = localKey.userID.isEmpty
                        ? localKey.fingerprint
                        : "\(localKey.userID) · \(localKey.fingerprint)"
                    self.announce("本地公钥库已找到：\(displayName)", kind: .success)
                    self.appendLog("未访问网络；已将本地公钥用于后续加密和签名验证。")
                } else if allowRemoteFallback {
                    self.appendLog("本地公钥库未找到：\(query)")
                    self.fetchGPGKeyFromNetwork(query: query)
                } else {
                    self.announce("读取完成，但公钥库中没有：\(query)", kind: .failure)
                    self.appendLog("网络查询没有导入可匹配的公钥；请核对邮箱、完整指纹和密钥服务器。")
                    self.showGPGAlert(
                        title: "没有找到匹配的公钥",
                        message: "本机和网络公钥服务都没有找到：\(query)\n\n请检查邮箱、完整指纹或公钥服务器设置，也可以直接导入 .asc 公钥文件。"
                    )
                }
            }
        }
    }

    private func fetchGPGKeyFromNetwork(query: String) {
        let keyserver = gpgKeyserver.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyserver.isEmpty else {
            announce("未设置 GPG 公钥服务器", kind: .failure)
            appendLog("请在“公布公钥”页设置 hkps://keys.openpgp.org，或先导入 .asc 公钥文件。")
            showGPGAlert(
                title: "未设置公钥服务器",
                message: "请先在“公布公钥”页设置公钥服务器，或直接导入 ASCII-armored 公钥文件。"
            )
            return
        }

        let arguments = GPGKeyLookupLogic.remoteArguments(query: query, keyserver: keyserver)
        announce("本地未找到，正在从 GPG 公钥服务查询…", kind: .running)
        appendLog("查询服务器：\(keyserver)")
        appendLog("邮箱查询会尝试 WKD/keyserver；完整 40 位指纹使用 recv-keys。网络公钥仍需人工核对指纹。")
        runGPG(arguments: arguments, operation: "从网络查询 GPG 公钥") { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                self.appendLog(Self.text(result.stdout))
                self.refreshGPGKeys(allowRemoteFallback: false)
            } else {
                self.announce("网络查询 GPG 公钥失败", kind: .failure)
                let detail = Self.text(result.stderr)
                self.appendLog(detail)
                self.showGPGAlert(
                    title: "网络查询公钥失败",
                    message: detail == "（无输出）" ? "GPG 没有返回错误详情。" : detail
                )
            }
        }
    }

    private func showGPGAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "知道了")
        alert.runModal()
    }

    func deleteSelectedGPGPublicKey() {
        let selectedFingerprint = gpgSelectedPublicKey.isEmpty
            ? GPGVerificationLogic.normalizeFingerprint(gpgKeyLookup)
            : GPGVerificationLogic.normalizeFingerprint(gpgSelectedPublicKey)
        guard selectedFingerprint.count == 40 else {
            announce("请先在公钥库中选择要删除的公钥", kind: .warning)
            return
        }
        guard !gpgSecretKeys.contains(where: {
            GPGVerificationLogic.fingerprintMatches(
                expected: selectedFingerprint,
                actual: $0.fingerprint
            )
        }) else {
            announce("该身份有对应私钥，未删除公钥", kind: .failure)
            appendLog("为避免误删私钥，本工具只删除没有对应私钥的公钥；请先确认是否要删除整个 GPG 身份。")
            return
        }

        let alert = NSAlert()
        alert.messageText = "从本机公钥库删除？"
        alert.informativeText = "将删除指纹为 \(selectedFingerprint) 的公开密钥。不会删除 YubiKey、PIV 槽位或其他密钥服务器上的副本。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "删除公钥")
        alert.addButton(withTitle: "取消")
        guard alert.runModal() == .alertFirstButtonReturn else {
            announce("已取消删除公钥", kind: .info)
            return
        }

        runGPG(
            arguments: ["--batch", "--yes", "--delete-key", selectedFingerprint],
            operation: "删除本机 GPG 公钥"
        ) { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                self.gpgKeys.removeAll {
                    GPGVerificationLogic.fingerprintMatches(
                        expected: selectedFingerprint,
                        actual: $0.fingerprint
                    )
                }
                if GPGVerificationLogic.fingerprintMatches(expected: selectedFingerprint, actual: self.gpgSelectedPublicKey) {
                    self.gpgSelectedPublicKey = ""
                }
                if GPGVerificationLogic.fingerprintMatches(expected: selectedFingerprint, actual: self.gpgKeyLookup) {
                    self.gpgKeyLookup = ""
                }
                if GPGVerificationLogic.fingerprintMatches(expected: selectedFingerprint, actual: self.gpgEncryptRecipient) {
                    self.gpgEncryptRecipient = ""
                }
                self.announce("本机 GPG 公钥已删除", kind: .success)
                self.appendLog("已删除：\(selectedFingerprint)")
            } else {
                self.announce("删除 GPG 公钥失败", kind: .failure)
                self.appendLog(Self.text(result.stderr))
            }
        }
    }

    func refreshGPGKeyDetails() {
        guard gpgToolPath != nil else {
            announce("找不到 GPG", kind: .failure)
            appendLog("请先安装 GnuPG：brew install gnupg")
            return
        }

        runGPG(
            arguments: ["--batch", "--list-keys", "--keyid-format", "long", "--with-subkey-fingerprint"],
            operation: "读取主密钥和子密钥结构"
        ) { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                self.gpgKeyDetails = Self.text(result.stdout)
                self.announce("密钥结构读取成功", kind: .success)
            } else {
                self.gpgKeyDetails = "读取失败：\n\(Self.text(result.stderr))"
                self.announce("密钥结构读取失败", kind: .failure)
            }
        }
    }

    func refreshGPGCardStatus() {
        guard gpgToolPath != nil else {
            announce("找不到 GPG", kind: .failure)
            appendLog("请先安装 GnuPG：brew install gnupg")
            return
        }

        runGPG(
            arguments: ["--card-status", "--verbose"],
            operation: "读取 OpenPGP 卡状态"
        ) { [weak self] result in
            guard let self else { return }
            let summary = Self.text(result.stdout) + (result.stderr.isEmpty ? "" : "\n" + Self.text(result.stderr))
            if result.status == 0 {
                gpgCardSummary = summary
                announce("OpenPGP 卡读取成功", kind: .success)
                appendLog(summary)
            } else {
                announce("OpenPGP 卡读取失败", kind: .failure)
                appendLog(summary)
            }
        }
    }

    func exportGPGPublicKey() {
        guard let recipient = normalizedGPGRecipient() else { return }
        chooseOutputFile(title: "保存 GPG 公钥", suggestedName: "gpg-public-key.asc") { [weak self] url in
            guard let self, let url else { return }
            startGPGSavedOutput(
                arguments: ["--armor", "--export", recipient],
                outputURL: url,
                operation: "导出 GPG 公钥",
                successMessage: "GPG 公钥导出完成"
            )
        }
    }

    func copyGPGPublicKey() {
        guard let recipient = normalizedGPGRecipient() else { return }
        runGPG(
            arguments: ["--armor", "--export", recipient],
            operation: "复制 GPG 公钥"
        ) { [weak self] result in
            guard let self else { return }
            guard result.status == 0, !result.stdout.isEmpty,
                  let armoredKey = String(data: result.stdout, encoding: .utf8) else {
                announce("复制公钥失败", kind: .failure)
                appendLog(Self.text(result.stderr))
                return
            }
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(armoredKey, forType: .string)
            announce("公钥已复制，可粘贴到邮件或服务器配置", kind: .success)
            appendLog("已复制 ASCII-armored 公钥；请同时把指纹通过另一条可信渠道告知对方。")
        }
    }

    func importGPGPublicKey() {
        chooseFile(title: "导入 OpenPGP 公钥") { [weak self] url in
            guard let self, let url else { return }
            runGPG(
                arguments: ["--batch", "--import", url.path],
                operation: "导入 GPG 公钥"
            ) { [weak self] result in
                guard let self else { return }
                if result.status == 0 {
                    announce("GPG 公钥导入完成", kind: .success)
                    appendLog(Self.text(result.stdout))
                    refreshGPGKeys()
                } else {
                    announce("GPG 公钥导入失败", kind: .failure)
                    appendLog(Self.text(result.stderr))
                }
            }
        }
    }

    func openLocalGPGKeyGenerationWizard() {
        guard let gpgToolPath else {
            announce("找不到 GPG，无法生成本地密钥", kind: .failure)
            appendLog("请先安装 GnuPG：brew install gnupg")
            return
        }

        let alert = NSAlert()
        alert.messageText = "准备在本地生成 GPG 主密钥和子密钥？"
        alert.informativeText = "建议先拔出 YubiKey，并在离线、受保护的环境中操作。生成后必须保存加密的私钥备份、主密钥指纹、撤销证书和公钥。此向导不会自动导出私钥，也不会自动写入 YubiKey。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "打开本地生成向导")
        alert.addButton(withTitle: "取消")
        guard alert.runModal() == .alertFirstButtonReturn else {
            announce("已取消本地密钥生成", kind: .info)
            return
        }

        let commandFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("pivy-gpg-local-key-generation-\(UUID().uuidString).command")
        let shellGPGPath = gpgToolPath.replacingOccurrences(of: "'", with: "'\\''")
        let terminalScript = """
        #!/bin/zsh
        clear
        echo "Pivy GPG 本地密钥生成向导"
        echo ""
        echo "安全建议：先拔出 YubiKey；尽量断网；在受保护的离线环境完成主密钥生成。"
        echo "本向导不会自动把私钥导入 YubiKey，也不会执行 factory-reset。"
        echo ""
        echo "第一步：生成主密钥（选择 Sign/Certify 能力）。"
        echo "完成后按回车继续。"
        read -r "reply?按回车执行 gpg --full-generate-key，或按 Ctrl-C 取消："
        '\(shellGPGPath)' --full-generate-key
        if [[ $? -ne 0 ]]; then
            echo "主密钥生成失败或已取消。"
            read -k 1 "reply?按任意键关闭此窗口..."
            rm -f -- "$0"
            exit 1
        fi

        echo ""
        echo "第二步：查看主密钥和子密钥。"
        '\(shellGPGPath)' --list-secret-keys --keyid-format long
        echo ""
        echo "输入主密钥的完整指纹，进入子密钥管理："
        read -r "fingerprint?主密钥指纹："
        if [[ -z "$fingerprint" ]]; then
            echo "未输入指纹，已停止；请稍后手动执行 gpg --edit-key。"
            read -k 1 "reply?按任意键关闭此窗口..."
            rm -f -- "$0"
            exit 0
        fi

        echo ""
        echo "第三步：在 gpg> 中依次执行 addkey，创建："
        echo "  1) Signature：签名/Git"
        echo "  2) Encryption：文件解密"
        echo "  3) Authentication：SSH 或其他认证"
        echo "完成后输入 save。"
        '\(shellGPGPath)' --edit-key "$fingerprint"

        echo ""
        echo "第四步：生成后必须保存以下内容："
        echo "  - 加密的主密钥/子密钥离线备份"
        echo "  - 主密钥指纹和撤销证书"
        echo "  - ASCII-armored 公钥"
        echo ""
        echo "可复制到安全位置后执行的命令："
        echo "  \(shellGPGPath) --armor --export $fingerprint > public-key.asc"
        echo "  \(shellGPGPath) --gen-revoke $fingerprint > revoke-certificate.asc"
        echo ""
        echo "完成后回到 Pivy，在“本地生成”页阅读迁移说明，再把子密钥导入 YubiKey。"
        read -k 1 "reply?按任意键关闭此窗口..."
        rm -f -- "$0"
        """

        do {
            try terminalScript.write(to: commandFile, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes(
                [.posixPermissions: NSNumber(value: Int16(0o700))],
                ofItemAtPath: commandFile.path
            )
            let openProcess = Process()
            openProcess.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            openProcess.arguments = ["-a", "Terminal", commandFile.path]
            try openProcess.run()
            announce("已打开本地 GPG 密钥生成向导", kind: .info)
            appendLog("本地生成向导已打开：请离线生成、加密备份主密钥和子密钥，再回到“本地生成”页迁移到 YubiKey。")
        } catch {
            announce("无法打开本地生成向导", kind: .failure)
            appendLog("请手动执行：gpg --full-generate-key\n\(error.localizedDescription)")
        }
    }

    func openGPGCardKeyWizard(replace: Bool) {
        guard gpgToolPath != nil else {
            announce("找不到 GPG，无法打开密钥向导", kind: .failure)
            appendLog("请先安装 GnuPG：brew install gnupg")
            return
        }

        let alert = NSAlert()
        alert.messageText = replace ? "准备更换 YubiKey OpenPGP 密钥？" : "在 YubiKey 上生成 OpenPGP 密钥？"
        alert.informativeText = replace
            ? "这会进入 GnuPG 的卡片管理流程。生成新密钥前请确认你已经导出了旧公钥；卡片上的旧私钥无法从 YubiKey 导出。应用不会自动输入 PIN，也不会执行 factory-reset。"
            : "这会打开 GnuPG 的卡片管理流程，在 YubiKey OpenPGP 应用中生成密钥对。应用不会自动输入 PIN，也不会执行 factory-reset。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "打开密钥向导")
        alert.addButton(withTitle: "取消")
        guard alert.runModal() == .alertFirstButtonReturn else {
            announce("已取消密钥向导", kind: .info)
            return
        }

        guard let gpgToolPath else {
            announce("找不到 GPG，无法打开密钥向导", kind: .failure)
            appendLog("请先安装 GnuPG：brew install gnupg")
            return
        }

        let commandFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("pivy-openpgp-card-edit-\(UUID().uuidString).command")
        let shellGPGPath = gpgToolPath.replacingOccurrences(of: "'", with: "'\\''")
        let terminalScript = """
        #!/bin/zsh
        clear
        echo "Pivy OpenPGP 密钥向导"
        echo "请在后续提示中完成 PIN、姓名和邮箱输入。"
        echo "现在看到 gpg/card> 后，请输入：admin，回车；再输入：generate，回车。"
        echo ""
        '\(shellGPGPath)' --card-edit
        result=$?
        echo ""
        if [[ $result -eq 0 ]]; then
            echo "GnuPG 流程已结束。现在可以关闭本窗口，回到 Pivy 点击“读取 OpenPGP 卡”和“读取公钥”。"
        else
            echo "GnuPG 返回状态：$result。请查看上面的错误信息；本窗口不会关闭。"
        fi
        read -k 1 "reply?按任意键关闭此窗口..."
        rm -f -- "$0"
        exit $result
        """

        do {
            try terminalScript.write(to: commandFile, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes(
                [.posixPermissions: NSNumber(value: Int16(0o700))],
                ofItemAtPath: commandFile.path
            )

            let openProcess = Process()
            openProcess.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            openProcess.arguments = ["-a", "Terminal", commandFile.path]
            try openProcess.run()
        } catch {
            announce("无法打开 Terminal 密钥向导", kind: .failure)
            appendLog("请手动执行：gpg --card-edit\n\(error.localizedDescription)")
            return
        }

        let steps = """
        Terminal 密钥向导已打开（不需要 Terminal 自动化权限）。请在其中依次输入：
          admin
          generate

        按提示输入姓名、邮箱和 PIN。完成后回到本工具点击“读取 OpenPGP 卡”和“读取公钥”。
        """
        announce(replace ? "已打开更换密钥向导" : "已打开生成密钥向导", kind: .info)
        appendLog(steps)
    }

    func openGPGExistingKeyMigrationWizard() {
        guard gpgToolPath != nil else {
            announce("找不到 GPG，无法打开迁移向导", kind: .failure)
            appendLog("请先安装 GnuPG：brew install gnupg")
            return
        }

        let alert = NSAlert()
        alert.messageText = "把已有 GPG 子密钥迁移到 YubiKey？"
        alert.informativeText = "迁移前请先做 ~/.gnupg 的加密离线备份。迁移通常会让本机不再保留可直接使用的私钥；本向导只打开 Terminal 并显示步骤，不会自动选择或移动任何密钥。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "打开迁移向导")
        alert.addButton(withTitle: "取消")
        guard alert.runModal() == .alertFirstButtonReturn else {
            announce("已取消密钥迁移", kind: .info)
            return
        }

        let commandFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("pivy-openpgp-key-migration-\(UUID().uuidString).command")
        let shellGPGPath = gpgToolPath!.replacingOccurrences(of: "'", with: "'\\''")
        let terminalScript = """
        #!/bin/zsh
        clear
        echo "Pivy OpenPGP 子密钥迁移向导"
        echo "先确认已经完成 ~/.gnupg 的加密离线备份。"
        echo ""
        echo "第一步：下面显示本机主密钥和子密钥："
        '\(shellGPGPath)' --list-secret-keys --keyid-format long
        echo ""
        echo "第二步：复制主密钥指纹，执行："
        echo "gpg --edit-key YOUR_PRIMARY_FINGERPRINT"
        echo ""
        echo "第三步：在 gpg> 中选择 key N，然后执行 keytocard。"
        echo "按提示选择 Signature、Encryption 或 Authentication。"
        echo "完成后输入 save；不要执行 factory-reset 或 ykman piv reset。"
        echo ""
        echo "本窗口不会替你输入指纹、PIN，也不会自动移动密钥。"
        zsh
        rm -f -- "$0"
        """

        do {
            try terminalScript.write(to: commandFile, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes(
                [.posixPermissions: NSNumber(value: Int16(0o700))],
                ofItemAtPath: commandFile.path
            )
            let openProcess = Process()
            openProcess.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            openProcess.arguments = ["-a", "Terminal", commandFile.path]
            try openProcess.run()
            announce("已打开子密钥迁移向导", kind: .info)
            appendLog("迁移向导已打开：先备份 ~/.gnupg，再按 Terminal 中的 keytocard 步骤操作。")
        } catch {
            announce("无法打开迁移向导", kind: .failure)
            appendLog("请手动执行：gpg --list-secret-keys --keyid-format long\n\(error.localizedDescription)")
        }
    }

    func publishGPGPublicKey() {
        guard let recipient = normalizedGPGRecipient() else { return }
        let keyserver = gpgKeyserver.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyserver.isEmpty else {
            announce("请输入公钥服务器地址", kind: .warning)
            return
        }

        runGPG(
            arguments: ["--batch", "--with-colons", "--list-keys", recipient],
            operation: "定位待发布公钥"
        ) { [weak self] result in
            guard let self else { return }
            guard result.status == 0, let key = Self.parseGPGKeys(result.stdout).first else {
                announce("找不到要发布的公钥", kind: .failure)
                appendLog("请先在本机生成或导入公钥，并输入邮箱或完整指纹。\n\(Self.text(result.stderr))")
                return
            }

            let alert = NSAlert()
            alert.messageText = "发布 OpenPGP 公钥到密钥服务器？"
            alert.informativeText = "将把公钥指纹 \(key.fingerprint) 发布到：\n\(keyserver)\n\n这会产生网络上的公开记录；公钥中的邮箱可能仍需到 keys.openpgp.org 完成验证邮件确认。"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "发布")
            alert.addButton(withTitle: "取消")
            guard alert.runModal() == .alertFirstButtonReturn else {
                announce("已取消发布公钥", kind: .info)
                return
            }

            runGPG(
                arguments: ["--batch", "--keyserver", keyserver, "--send-keys", key.fingerprint],
                operation: "发布 GPG 公钥"
            ) { [weak self] publishResult in
                guard let self else { return }
                if publishResult.status == 0 {
                    announce("GPG 公钥发布完成", kind: .success)
                    appendLog("已发布指纹：\(key.fingerprint)\n服务器：\(keyserver)\n如使用 keys.openpgp.org，请按邮件完成邮箱验证。")
                } else {
                    announce("GPG 公钥发布失败", kind: .failure)
                    appendLog(Self.text(publishResult.stderr))
                }
            }
        }
    }

    func copyOpenPGPSetupSteps() {
        let instructions = openPGPSetupInstructions
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(instructions, forType: .string)
        announce("OpenPGP 生成步骤已复制", kind: .success)
        appendLog(instructions)
    }

    func copyGPGKeyManagementSteps() {
        let instructions = gpgKeyManagementInstructions
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(instructions, forType: .string)
        announce("主密钥、子密钥和备用卡步骤已复制", kind: .success)
        appendLog(instructions)
    }

    func copyGPGLocalGenerationSteps() {
        let instructions = gpgLocalGenerationInstructions
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(instructions, forType: .string)
        announce("本地密钥生成步骤已复制", kind: .success)
        appendLog(instructions)
    }

    func copyGPGSubkeyMigrationSteps() {
        let instructions = gpgSubkeyMigrationInstructions
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(instructions, forType: .string)
        announce("YubiKey 子密钥迁移步骤已复制", kind: .success)
        appendLog(instructions)
    }

    func copyGPGPinentryRepairSteps() {
        let instructions = gpgPinentryRepairInstructions
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(instructions, forType: .string)
        announce("PIN 窗口修复命令已复制", kind: .success)
        appendLog(instructions)
    }

    func copyInstallationInstructions() {
        let instructions = installationInstructions
        guard !instructions.isEmpty else {
            announce("依赖已全部安装，无需复制安装命令", kind: .info)
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(instructions, forType: .string)
        announce("安装命令已复制", kind: .success)
        appendLog(instructions)
    }

    private var openPGPSetupInstructions: String {
        """
        # 在 YubiKey OpenPGP 应用中生成或更换密钥
        gpg --card-edit
        admin
        generate

        # 如果 PIN 窗口报 “Screen or window too small”，先退出 gpg/card>，再执行：
        mkdir -p ~/.gnupg
        printf '%s\\n' 'pinentry-program /opt/homebrew/bin/pinentry-mac' >> ~/.gnupg/gpg-agent.conf
        gpgconf --kill gpg-agent

        # 生成后查看公钥指纹
        gpg --list-keys --keyid-format long

        # 导出 ASCII-armored 公钥（只导出公钥，不会导出私钥）
        gpg --armor --export YOUR_EMAIL > public-key.asc

        # 发布到公共密钥服务器前先核对指纹
        gpg --fingerprint YOUR_EMAIL

        # 不要执行
        # factory-reset
        # ykman piv reset
        """
    }

    private var gpgKeyManagementInstructions: String {
        """
        # 方案 A：推荐，直接在 YubiKey OpenPGP 卡上生成
        gpg --card-edit
        admin
        generate

        # 这会在卡上生成 OpenPGP 主密钥/子密钥结构；私钥不会从卡上导出。
        # 生成后回到 Pivy：读取 OpenPGP 卡 → 读取本机公钥 → 导出公钥。

        # 方案 B：已有电脑上的 GPG 私钥，迁移子密钥到 YubiKey
        # 先做 ~/.gnupg 的加密离线备份，再执行：
        gpg --list-secret-keys --keyid-format long
        gpg --edit-key YOUR_PRIMARY_FINGERPRINT
        # 在 gpg> 中：选择 key N，再执行 keytocard；按提示选择 Signature/Encryption/Authentication。
        # 不要只备份公钥：公钥不能恢复私钥，也不能制作备用卡。

        # 多张卡的备用方案
        # 方案 1（推荐）：每张卡生成独立子密钥，并把每张卡的公钥分别登记到服务。
        # 方案 2：复制同一套子密钥到多张卡；需要安全的私钥备份，便利性更高但隔离性更低。

        # 备份与丢卡准备
        # 保存主密钥撤销证书、主密钥指纹和每张卡的序列号；不要提交到 GitHub。
        """
    }

    private var gpgLocalGenerationInstructions: String {
        """
        # 本地生成 GPG 主密钥和子密钥
        # 建议：拔出 YubiKey、断网，在受保护的离线环境中执行
        gpg --full-generate-key

        # 查看主密钥和现有子密钥，记录完整指纹
        gpg --list-secret-keys --keyid-format long

        # 创建子密钥；在 gpg> 中按顺序执行 addkey
        gpg --edit-key YOUR_PRIMARY_FINGERPRINT
        # addkey → Signature：签名/Git
        # addkey → Encryption：文件解密
        # addkey → Authentication：SSH 或其他认证
        # 完成后输入 save

        # 导出公钥（可以公开，不包含私钥）
        gpg --armor --export YOUR_PRIMARY_FINGERPRINT > public-key.asc

        # 生成撤销证书并离线保存
        gpg --gen-revoke YOUR_PRIMARY_FINGERPRINT > revoke-certificate.asc

        # 加密备份主密钥和子密钥；输出文件必须放到离线安全介质
        umask 077
        gpg --export-secret-keys --armor YOUR_PRIMARY_FINGERPRINT | gpg --symmetric --cipher-algo AES256 --output gpg-secret-backup.asc.gpg

        # 备份清单：加密私钥备份、撤销证书、主密钥指纹、公钥、备用介质
        # 不要把私钥备份、PIN 或管理密钥提交到 GitHub。
        """
    }

    private var gpgSubkeyMigrationInstructions: String {
        """
        # 将本地 GPG 子密钥迁移到 YubiKey OpenPGP 应用
        # 第 0 步：确认已经完成加密离线备份，并插入目标 YubiKey
        gpg --list-secret-keys --keyid-format long

        # 第 1 步：打开主密钥编辑器
        gpg --edit-key YOUR_PRIMARY_FINGERPRINT

        # 第 2 步：在 gpg> 中查看 key N 编号
        # 选择签名子密钥后执行：
        # key N
        # keytocard
        # 选择 Signature

        # 选择加密子密钥后再次执行：
        # key N
        # keytocard
        # 选择 Encryption

        # 如需认证子密钥，再执行一次 key N → keytocard → Authentication
        # 最后输入 save

        # 回到 Pivy：读取 OpenPGP 卡 → 读取本机公钥 → 读取密钥结构
        # 只导入公钥不能恢复私钥；不要执行 factory-reset 或 ykman piv reset。
        """
    }

    private var gpgPinentryRepairInstructions: String {
        """
        # 修复 GPG PIN 弹窗
        # 先退出 gpg/card> 或输入 q，再回到普通 Terminal 提示符
        mkdir -p ~/.gnupg
        printf '%s\\n' 'pinentry-program /opt/homebrew/bin/pinentry-mac' >> ~/.gnupg/gpg-agent.conf
        gpgconf --kill gpg-agent

        # 然后重新打开卡片管理
        gpg --card-edit
        """
    }

    var missingInstallationNames: [String] {
        var names: [String] = []
        if !pivyInstalled { names.append("PIV 工具") }
        if !gpgInstalled { names.append("GnuPG") }
        if pinentryPath == nil { names.append("pinentry-mac") }
        if opensslPath == nil { names.append("OpenSSL") }
        return names
    }

    var installationInstructions: String {
        var blocks: [String] = []
        var brewFormulaPackages: [String] = []

        if !pivyInstalled {
            blocks.append("brew install --cask pivy-app")
        }
        if !gpgInstalled {
            brewFormulaPackages.append("gnupg")
        }
        if pinentryPath == nil {
            brewFormulaPackages.append("pinentry-mac")
        }
        if opensslPath == nil {
            brewFormulaPackages.append("openssl@3")
        }

        guard !blocks.isEmpty || !brewFormulaPackages.isEmpty else { return "" }

        if brewPath == nil {
            blocks.insert("""
            # 先安装 Homebrew（检测到本机尚未安装）
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            """, at: 0)
        }

        if !brewFormulaPackages.isEmpty {
            blocks.append("brew install \(brewFormulaPackages.joined(separator: " "))")
        }

        return ("# 仅安装当前缺少的组件\n" + blocks.joined(separator: "\n"))
            .trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
    }

    func requestGPGEncrypt() {
        guard let file = gpgEncryptFile else {
            announce("请先拖入或选择要用 GPG 加密的文件", kind: .warning)
            return
        }
        guard let recipient = normalizedGPGEncryptionRecipient() else { return }
        guard validateGPGFile(file, operation: "GPG 加密") else { return }
        if gpgEncryptToSelf && gpgRecipient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            announce("请先选择自己的公钥，或关闭“同时加密给自己”", kind: .warning)
            return
        }
        let outputURL = siblingURL(for: file, name: file.lastPathComponent + ".gpg")
        var recipients = [recipient]
        if gpgEncryptToSelf, !gpgRecipient.isEmpty, gpgRecipient != recipient {
            recipients.append(gpgRecipient)
        }
        var arguments = [
            "--batch", "--pinentry-mode", "default",
            "--output", outputURL.path,
            "--trust-model", "always"
        ]
        for item in recipients {
            arguments.append(contentsOf: ["--recipient", item])
        }
        arguments.append(contentsOf: ["--encrypt", file.path])
        runGPG(arguments: arguments, operation: "GPG 大文件加密") { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                announce("GPG 加密完成", kind: .success)
                appendLog("加密文件：\n\(outputURL.path)\n收件人公钥：\(recipients.joined(separator: ", "))\n文件大小不受 PIV 8 KB 限制。")
            } else {
                announce("GPG 加密失败", kind: .failure)
                appendLog(Self.text(result.stderr))
            }
        }
    }

    func requestGPGDecrypt() {
        guard let file = gpgDecryptFile else {
            announce("请先拖入或选择要用 GPG 解密的文件", kind: .warning)
            return
        }
        guard validateGPGFile(file, operation: "GPG 解密") else { return }
        let outputName: String
        if file.pathExtension.lowercased() == "gpg" || file.pathExtension.lowercased() == "pgp" {
            outputName = String(file.lastPathComponent.dropLast(file.pathExtension.count + 1)) + ".decrypted"
        } else {
            outputName = file.lastPathComponent + ".decrypted"
        }
        let outputURL = siblingURL(for: file, name: outputName)
        let arguments = [
            "--batch", "--pinentry-mode", "default",
            "--output", outputURL.path,
            "--decrypt", file.path
        ]
        runGPG(arguments: arguments, operation: "GPG 大文件解密") { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                announce("GPG 解密完成", kind: .success)
                appendLog("解密文件：\n\(outputURL.path)\nPIN 由 GPG Agent 的安全弹窗处理。")
            } else {
                announce("GPG 解密失败", kind: .failure)
                appendLog(Self.text(result.stderr))
            }
        }
    }

    func requestGPGSign() {
        guard let file = gpgSignFile else {
            announce("请先拖入或选择要用 GPG 签名的文件", kind: .warning)
            return
        }
        guard validateGPGFile(file, operation: "GPG 签名") else { return }
        guard let signer = normalizedGPGSigner() else { return }
        let outputURL = siblingURL(for: file, name: file.lastPathComponent + ".asc")
        let arguments = [
            "--batch", "--pinentry-mode", "default",
            "--local-user", signer,
            "--armor", "--detach-sign",
            "--output", outputURL.path,
            file.path
        ]
        runGPG(arguments: arguments, operation: "GPG 大文件签名") { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                announce("GPG 签名完成", kind: .success)
                appendLog("签名文件：\n\(outputURL.path)\nPIN 由 GPG Agent 的安全弹窗处理。")
            } else {
                announce("GPG 签名失败", kind: .failure)
                appendLog(Self.text(result.stderr))
            }
        }
    }

    func requestGPGSignAndEncrypt() {
        guard let file = gpgEncryptFile else {
            announce("请先拖入或选择要用 GPG 处理的文件", kind: .warning)
            return
        }
        guard let recipient = normalizedGPGEncryptionRecipient() else { return }
        guard let signer = normalizedGPGSigner() else { return }
        guard validateGPGFile(file, operation: "GPG 签名并加密") else { return }

        let outputURL = siblingURL(for: file, name: file.lastPathComponent + ".gpg")
        var recipients = [recipient]
        if gpgEncryptToSelf, !gpgRecipient.isEmpty, gpgRecipient != recipient {
            recipients.append(gpgRecipient)
        }
        var arguments = [
            "--batch", "--pinentry-mode", "default",
            "--trust-model", "always",
            "--local-user", signer,
            "--output", outputURL.path
        ]
        for item in recipients {
            arguments.append(contentsOf: ["--recipient", item])
        }
        arguments.append(contentsOf: ["--sign", "--encrypt", file.path])

        runGPG(arguments: arguments, operation: "GPG 签名并加密") { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                announce("GPG 签名并加密完成", kind: .success)
                appendLog("输出文件：\n\(outputURL.path)\n收件人公钥：\(recipients.joined(separator: ", "))\n签名身份：\(signer)")
            } else {
                announce("GPG 签名并加密失败", kind: .failure)
                appendLog(Self.text(result.stderr))
            }
        }
    }

    func requestGPGVerify() {
        guard let dataFile = gpgVerifyFile, let signatureFile = gpgVerifySignatureFile else {
            announce("验证需要原文件和 GPG 签名文件", kind: .warning)
            return
        }
        guard validateGPGFile(dataFile, operation: "GPG 验证") && validateGPGFile(signatureFile, operation: "GPG 验证") else {
            return
        }
        runGPG(
            arguments: ["--batch", "--status-fd", "1", "--verify", signatureFile.path, dataFile.path],
            operation: "GPG 验证签名"
        ) { [weak self] result in
            guard let self else { return }
            let statusOutput = Self.text(result.stdout)
            let detail = Self.text(result.stderr)
            let selectedFingerprint = [
                self.gpgSelectedPublicKey,
                self.gpgKeyLookup
            ]
                .map(GPGVerificationLogic.normalizeFingerprint)
                .first(where: { $0.count == 40 })

            if let selectedFingerprint {
                switch GPGVerificationLogic.verdict(
                    exitStatus: Int(result.status),
                    statusOutput: statusOutput,
                    expectedFingerprint: selectedFingerprint
                ) {
                case let .verified(signingFingerprint, primaryFingerprint):
                    announce("GPG 签名验证成功，公钥指纹匹配", kind: .success)
                    appendLog("实际签名指纹：\(signingFingerprint)")
                    appendLog("实际主密钥指纹：\(primaryFingerprint ?? "未提供")")
                    appendLog("核对指纹：\(selectedFingerprint)")
                    appendLog(detail == "（无输出）" ? "签名与原文件匹配。" : detail)
                case let .signatureValidWrongKey(signingFingerprint, primaryFingerprint):
                    announce("签名有效，但不是选中的公钥", kind: .failure)
                    appendLog("实际签名指纹：\(signingFingerprint)")
                    appendLog("实际主密钥指纹：\(primaryFingerprint ?? "未提供")")
                    appendLog("期望指纹：\(selectedFingerprint)")
                case .invalidSignature:
                    announce("GPG 签名验证失败", kind: .failure)
                    appendLog(detail == "（无输出）" ? statusOutput : detail)
                case .missingFingerprint:
                    announce("无法读取签名者指纹，拒绝判定", kind: .failure)
                    appendLog(detail == "（无输出）" ? statusOutput : detail)
                }
            } else if result.status == 0, let signature = GPGVerificationLogic.validSignature(from: statusOutput) {
                announce("GPG 签名验证成功", kind: .success)
                appendLog("实际签名指纹：\(signature.signingFingerprint)")
                appendLog("实际主密钥指纹：\(signature.primaryFingerprint ?? "未提供")")
                appendLog("当前未选择期望指纹；如需确认具体软件发布者，请先在上方读取并选择公钥。")
                appendLog(detail == "（无输出）" ? "签名与原文件匹配。" : detail)
            } else {
                announce("GPG 签名验证失败", kind: .failure)
                appendLog(detail == "（无输出）" ? statusOutput : detail)
            }
        }
    }

    private func normalizedGPGRecipient() -> String? {
        let value = gpgRecipient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else {
            announce("请输入 GPG 收件人邮箱或公钥指纹", kind: .warning)
            return nil
        }
        return value
    }

    private func normalizedGPGEncryptionRecipient() -> String? {
        let value = gpgEncryptRecipient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else {
            announce("请选择或输入收件人的 GPG 公钥", kind: .warning)
            return nil
        }
        return value
    }

    private func normalizedGPGSigner() -> String? {
        let value = gpgRecipient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else {
            announce("请选择自己的 GPG 签名身份", kind: .warning)
            return nil
        }
        return value
    }

    private func validateGPGFile(_ file: URL, operation: String) -> Bool {
        guard gpgToolPath != nil else {
            announce("找不到 GPG，无法执行\(operation)", kind: .failure)
            appendLog("请先安装 GnuPG：brew install gnupg")
            return false
        }
        guard file.isFileURL, FileManager.default.isReadableFile(atPath: file.path) else {
            announce("\(operation)输入文件不可读取", kind: .failure)
            appendLog("无法读取输入：\(file.path)")
            return false
        }
        guard (try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize) != nil else {
            announce("\(operation)无法读取文件大小", kind: .failure)
            appendLog("无法检查输入：\(file.path)")
            return false
        }
        return true
    }

    func verifySignature() {
        guard let dataFile, let signatureFile, let certificateFile else {
            announce("验证需要原文件、.sig 签名文件和 .pem 证书文件", kind: .warning)
            return
        }
        guard let opensslPath else {
            announce("找不到 OpenSSL，无法验证签名", kind: .failure)
            return
        }
        guard !busy else {
            announce("已有操作正在运行，请稍候", kind: .warning)
            return
        }

        busy = true
        announce("正在验证 9c 签名…", kind: .running)
        appendLog("验证文件：\n原文件：\(dataFile.path)\n签名：\(signatureFile.path)\n证书：\(certificateFile.path)")

        DispatchQueue.global(qos: .userInitiated).async {
            let tempPublicKey = FileManager.default.temporaryDirectory
                .appendingPathComponent("pivy-public-\(UUID().uuidString).pem")
            defer { try? FileManager.default.removeItem(at: tempPublicKey) }

            let extract = Self.execute(
                tool: opensslPath,
                arguments: ["x509", "-in", certificateFile.path, "-pubkey", "-noout"],
                input: nil
            )
            guard extract.status == 0 else {
                self.finishVerification(
                    success: false,
                    message: "证书无法读取：\n\(Self.text(extract.stderr))"
                )
                return
            }

            do {
                try extract.stdout.write(to: tempPublicKey, options: .atomic)
            } catch {
                self.finishVerification(success: false, message: "临时公钥保存失败：\n\(error.localizedDescription)")
                return
            }

            let verify = Self.execute(
                tool: opensslPath,
                arguments: ["dgst", "-sha256", "-verify", tempPublicKey.path, "-signature", signatureFile.path, dataFile.path],
                input: nil
            )
            let output = Self.text(verify.stdout)
            let error = Self.text(verify.stderr)
            if verify.status == 0 {
                self.finishVerification(
                    success: true,
                    message: "签名验证成功：文件内容未被修改，且签名对应所提供的 9c 证书。\n\(output)"
                )
            } else {
                self.finishVerification(
                    success: false,
                    message: "签名验证失败：原文件、签名或证书可能不匹配。\n\(error.isEmpty ? output : error)"
                )
            }
        }
    }

    func confirmPIN() {
        guard !pin.isEmpty else {
            announce("PIN 不能为空", kind: .warning)
            return
        }
        guard let operation = pendingOperation else {
            cancelPIN()
            return
        }

        let currentPIN = pin
        pendingOperation = nil
        showPINPrompt = false
        pin = ""

        switch operation {
        case .sign:
            guard let dataFile else { return }
            startSign(file: dataFile, pin: currentPIN)
        case .encrypt:
            guard let encryptFile else { return }
            startEncrypt(file: encryptFile, pin: currentPIN)
        case .decrypt:
            guard let decryptFile else { return }
            startDecrypt(file: decryptFile, pin: currentPIN)
        case .printedInfo:
            startPrintedInfo(pin: currentPIN)
        case let .csr(slot, commonName, outputURL):
            startCSR(slot: slot, commonName: commonName, outputURL: outputURL, pin: currentPIN)
        case let .attestation(slot, outputURL):
            startAttestation(slot: slot, outputURL: outputURL, pin: currentPIN)
        case let .auth(slot):
            startSlotAuth(slot: slot, pin: currentPIN)
        }
    }

    func cancelPIN() {
        pin = ""
        pendingOperation = nil
        showPINPrompt = false
        announce("已取消操作，PIN 已清空", kind: .info)
    }

    func clearLog() {
        log = ""
        statusText = "日志已清空"
        statusKind = .info
    }

    var logLineCount: Int {
        log.split(whereSeparator: \.isNewline).count
    }

    func copyLog() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(log, forType: .string)
        statusText = "日志已复制到剪贴板"
        statusKind = .success
    }

    func saveLog() {
        chooseOutputFile(title: "保存运行日志", suggestedName: "pivy-shell.log") { [weak self] url in
            guard let self, let url else { return }
            do {
                try Data(self.log.utf8).write(to: url, options: .atomic)
                self.announce("日志已保存", kind: .success)
                self.appendLog("日志文件：\(url.path)")
            } catch {
                self.announce("日志保存失败", kind: .failure)
                self.appendLog(error.localizedDescription)
            }
        }
    }

    private func requestPIN(for operation: PendingOperation, title: String) {
        guard !busy else {
            announce("已有操作正在运行，请稍候", kind: .warning)
            return
        }
        pendingOperation = operation
        pinPromptTitle = title
        pin = ""
        showPINPrompt = true
    }

    private func startSign(file: URL, pin: String) {
        let outputURL = siblingURL(for: file, name: file.lastPathComponent + ".sig")
        let certificateURL = siblingURL(for: file, name: file.lastPathComponent + ".sig.cert.pem")
        processFile(file, outputURL: outputURL, operation: "9c 文件签名", arguments: ["sign", "9c"], pin: pin) { [weak self] result in
            guard let self else { return }
            if result.status != 0 {
                announce("9c 签名失败", kind: .failure)
                appendLog(Self.text(result.stderr))
                return
            }

            let certResult = Self.execute(tool: pivyToolPath, arguments: ["cert", "9c"], input: nil)
            if certResult.status == 0 {
                do {
                    try certResult.stdout.write(to: certificateURL, options: .atomic)
                    announce("9c 签名完成", kind: .success)
                    appendLog("签名文件：\n\(outputURL.path)\n证书文件：\n\(certificateURL.path)")
                } catch {
                    announce("签名完成，但证书保存失败", kind: .warning)
                    appendLog("签名文件：\n\(outputURL.path)\n证书保存失败：\(error.localizedDescription)")
                }
            } else {
                announce("签名完成，但读取证书失败", kind: .warning)
                appendLog("签名文件：\n\(outputURL.path)\n读取 9c 证书失败：\n\(Self.text(certResult.stderr))")
            }
        }
    }

    private func startEncrypt(file: URL, pin: String) {
        let outputURL = siblingURL(for: file, name: file.lastPathComponent + ".pivybox")
        processFile(file, outputURL: outputURL, operation: "9d 文件加密", arguments: ["box", "9d"], pin: pin) { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                announce("9d 加密完成", kind: .success)
                appendLog("加密文件：\n\(outputURL.path)")
            } else {
                announce("9d 加密失败", kind: .failure)
                appendLog(Self.text(result.stderr))
            }
        }
    }

    private func startDecrypt(file: URL, pin: String) {
        let outputName = String(file.lastPathComponent.dropLast(".pivybox".count)) + ".decrypted"
        let outputURL = siblingURL(for: file, name: outputName)
        processFile(file, outputURL: outputURL, operation: "9d 文件解密", arguments: ["unbox"], pin: pin) { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                announce("9d 解密完成", kind: .success)
                appendLog("解密文件：\n\(outputURL.path)")
            } else {
                announce("9d 解密失败", kind: .failure)
                appendLog(Self.text(result.stderr))
            }
        }
    }

    private func startCSR(slot: String, commonName: String, outputURL: URL, pin: String) {
        startSavedOutput(
            arguments: ["-P", pin, "-n", commonName, "req-cert", slot],
            outputURL: outputURL,
            operation: "生成 \(slot) CSR",
            successMessage: "CSR 生成完成"
        )
    }

    private func startPrintedInfo(pin: String) {
        runTool(arguments: ["-P", pin, "pinfo"], input: nil, operation: "读取 PIV Printed Info") { [weak self] result in
            guard let self else { return }
            if result.status == 0 {
                announce("Printed Info 读取成功", kind: .success)
                appendLog(Self.text(result.stdout))
            } else {
                announce("Printed Info 读取失败", kind: .failure)
                appendLog(Self.text(result.stderr))
            }
        }
    }

    private func startAttestation(slot: String, outputURL: URL, pin: String) {
        startSavedOutput(
            arguments: ["-P", pin, "attest", slot],
            outputURL: outputURL,
            operation: "导出 \(slot) 槽位证明",
            successMessage: "槽位证明导出完成"
        )
    }

    private func startSlotAuth(slot: String, pin: String) {
        runTool(arguments: ["pubkey", slot], input: nil, operation: "读取 \(slot) 公钥") { [weak self] publicKey in
            guard let self else { return }
            guard publicKey.status == 0 else {
                announce("无法读取 \(slot) 公钥", kind: .failure)
                appendLog(Self.text(publicKey.stderr))
                return
            }

            runTool(
                arguments: ["-P", pin, "auth", slot],
                input: publicKey.stdout,
                operation: "校验 \(slot) 槽位公钥"
            ) { [weak self] result in
                guard let self else { return }
                if result.status == 0 {
                    announce("\(slot) 槽位校验成功", kind: .success)
                    appendLog("卡片中的私钥可以与该槽位公钥完成往返签名校验。")
                } else {
                    let detail = Self.text(result.stderr)
                    if detail.localizedCaseInsensitiveContains("incorrect signature") {
                        announce("\(slot) 校验失败：签名与公钥不匹配", kind: .failure)
                        appendLog("卡片已完成私钥操作，但签名无法用该槽位公钥验证。常见原因是私钥曾被重新生成而证书未同步，或 pivy-tool 的 ECDSA 校验兼容性问题。建议先用 YubiKey Manager 独立验证：ykman piv keys export 9a - --verify；确认后再重新生成该槽位的密钥和证书。不要执行 factory-reset。\n\(detail)")
                    } else {
                        announce("\(slot) 槽位校验失败", kind: .failure)
                        appendLog(detail)
                    }
                }
            }
        }
    }

    private func startSavedOutput(
        arguments: [String],
        outputURL: URL,
        operation: String,
        successMessage: String
    ) {
        runTool(arguments: arguments, input: nil, operation: operation) { [weak self] result in
            guard let self else { return }
            guard result.status == 0 else {
                announce("\(operation)失败", kind: .failure)
                let message = Self.text(result.stderr)
                appendLog(message == "（无输出）" ? Self.text(result.stdout) : message)
                return
            }
            guard !result.stdout.isEmpty else {
                announce("\(operation)失败：工具没有输出", kind: .failure)
                appendLog("没有可保存的输出。")
                return
            }
            do {
                try result.stdout.write(to: outputURL, options: .atomic)
                announce(successMessage, kind: .success)
                appendLog("输出文件：\n\(outputURL.path)")
            } catch {
                announce("\(operation)失败：保存文件失败", kind: .failure)
                appendLog(error.localizedDescription)
            }
        }
    }

    private func startGPGSavedOutput(
        arguments: [String],
        outputURL: URL,
        operation: String,
        successMessage: String
    ) {
        runGPG(arguments: arguments, operation: operation) { [weak self] result in
            guard let self else { return }
            guard result.status == 0 else {
                announce("\(operation)失败", kind: .failure)
                let message = Self.text(result.stderr)
                appendLog(message == "（无输出）" ? Self.text(result.stdout) : message)
                return
            }
            guard !result.stdout.isEmpty else {
                announce("\(operation)失败：工具没有输出", kind: .failure)
                appendLog("没有可保存的公钥输出。请确认收件人指纹或邮箱对应本机公钥。")
                return
            }
            do {
                try result.stdout.write(to: outputURL, options: .atomic)
                announce(successMessage, kind: .success)
                appendLog("输出文件：\n\(outputURL.path)")
            } catch {
                announce("\(operation)失败：保存文件失败", kind: .failure)
                appendLog(error.localizedDescription)
            }
        }
    }

    nonisolated private func finishVerification(success: Bool, message: String) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.busy = false
            self.announce(success ? "签名验证成功" : "签名验证失败", kind: success ? .success : .failure)
            self.appendLog(message)
        }
    }

    private func processFile(
        _ file: URL,
        outputURL: URL,
        operation: String,
        arguments: [String],
        pin: String,
        completion: @escaping (CommandResult) -> Void
    ) {
        guard file.isFileURL else {
            announce("输入不是本地文件", kind: .failure)
            appendLog("无法读取输入：(file.absoluteString)")
            return
        }
        guard FileManager.default.isReadableFile(atPath: file.path) else {
            announce("文件不可读取", kind: .failure)
            appendLog("无法读取输入：(file.path)")
            return
        }

        do {
            let input = try Data(contentsOf: file)
            guard !input.isEmpty else {
                announce("不能处理空文件", kind: .warning)
                appendLog("输入文件为空：(file.path)")
                return
            }
            var commandArguments = ["-P", pin]
            commandArguments.append(contentsOf: arguments)
            runTool(arguments: commandArguments, input: input, operation: operation) { result in
                if result.status == 0 {
                    do {
                        try result.stdout.write(to: outputURL, options: .atomic)
                    } catch {
                        completion(CommandResult(
                            status: 1,
                            stdout: Data(),
                            stderr: Data(error.localizedDescription.utf8),
                            terminationReason: nil
                        ))
                        return
                    }
                }
                completion(result)
            }
        } catch {
            announce("读取文件失败", kind: .failure)
            appendLog(error.localizedDescription)
        }
    }

    private func runTool(
        arguments: [String],
        input: Data?,
        operation: String,
        completion: @escaping (CommandResult) -> Void,
        attempt: Int = 0
    ) {
        guard pivyInstalled else {
            announce("找不到 pivy", kind: .failure)
            appendLog(pivyToolPath)
            return
        }
        guard !busy else {
            announce("已有操作正在运行，请稍候", kind: .warning)
            return
        }

        busy = true
        announce("正在执行：\(operation)", kind: .running)
        let safeArguments = arguments.enumerated().map { index, value in
            if index > 0 && arguments[index - 1] == "-P" {
                return "••••••"
            }
            return value
        }
        appendLog("命令：pivy-tool \(safeArguments.joined(separator: " "))")

        let tool = pivyToolPath
        DispatchQueue.global(qos: .userInitiated).async {
            let result = Self.execute(tool: tool, arguments: arguments, input: input)
            DispatchQueue.main.async {
                self.busy = false
                self.pin = ""
                let output = Self.text(result.stdout)
                let error = Self.text(result.stderr)
                if result.status != 0,
                   attempt == 0,
                   operation != "读取设备",
                   self.gpgconfPath != nil,
                   Self.looksLikeCardSessionIssue(output: output, error: error) {
                    self.announce("PIV 读卡会话异常，正在释放 GPG 并重试…", kind: .running)
                    self.appendLog("检测到 PIV 卡不可见，可能是 GPG scdaemon 或其他读卡程序占用 CCID。")
                    self.busy = true
                    self.releaseGPGSmartCardSession { [weak self] released in
                        guard let self else { return }
                        self.busy = false
                        if released {
                            self.appendLog("已释放 scdaemon，重试 PIV 操作。")
                            self.runTool(
                                arguments: arguments,
                                input: input,
                                operation: operation,
                                completion: completion,
                                attempt: attempt + 1
                            )
                        } else {
                            self.announce("无法自动恢复 PIV 读卡会话", kind: .failure)
                            self.appendLog("请关闭 GPG、Yubico Authenticator 或其他智能卡程序后重试。\n原始错误：\n\(error)")
                            completion(result)
                        }
                    }
                    return
                }
                if result.status != 0 {
                    let detail = error
                    switch result.terminationReason {
                    case .uncaughtSignal:
                        self.appendLog("pivy-tool 子进程异常终止（状态码 \(result.status)）。主界面保持打开，未自动退出。")
                    case .exit, .none:
                        if result.stderr.isEmpty {
                            self.appendLog("pivy-tool 返回失败状态 \(result.status)，没有错误输出。主界面保持打开。")
                        } else {
                            self.appendLog("pivy-tool 错误输出：\n\(detail)")
                        }
                    @unknown default:
                        self.appendLog("pivy-tool 异常结束（状态码 \(result.status)）。主界面保持打开。")
                    }
                }
                completion(result)
            }
        }
    }

    private func runGPG(
        arguments: [String],
        operation: String,
        completion: @escaping (CommandResult) -> Void
    ) {
        guard let gpgToolPath else {
            announce("找不到 GPG", kind: .failure)
            appendLog("请先安装 GnuPG：brew install gnupg")
            return
        }
        guard !busy else {
            announce("已有操作正在运行，请稍候", kind: .warning)
            return
        }

        busy = true
        announce("正在执行：\(operation)", kind: .running)
        appendLog("命令：gpg \(arguments.map(Self.safeGPGArgument).joined(separator: " "))")
        appendLog("大文件由电脑本地处理；YubiKey 只负责 OpenPGP 私钥操作。")

        DispatchQueue.global(qos: .userInitiated).async {
            let result = Self.execute(tool: gpgToolPath, arguments: arguments, input: nil)
            DispatchQueue.main.async {
                self.busy = false
                if result.status != 0 {
                    let detail = Self.text(result.stderr)
                    if result.terminationReason == .uncaughtSignal {
                        self.appendLog("gpg 子进程异常终止（状态码 \(result.status)）。主界面保持打开。")
                    } else {
                        self.appendLog("gpg 错误输出：\n\(detail)")
                    }
                }
                completion(result)
            }
        }
    }

    private func chooseFile(title: String, completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.title = title
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.prompt = "选择"
        completion(panel.runModal() == .OK ? panel.url : nil)
    }

    private func chooseOutputFile(title: String, suggestedName: String, completion: @escaping (URL?) -> Void) {
        let panel = NSSavePanel()
        panel.title = title
        panel.nameFieldStringValue = suggestedName
        panel.canCreateDirectories = false
        panel.prompt = "保存"
        completion(panel.runModal() == .OK ? panel.url : nil)
    }

    private func normalizedSlot() -> String? {
        let value = selectedSlot.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count == 2, Int(value, radix: 16) != nil else {
            announce("PIV 槽位格式应为两位十六进制，例如 9a", kind: .warning)
            return nil
        }
        return value.lowercased()
    }

    func slotLabel(_ slot: String) -> String {
        switch slot.lowercased() {
        case "9a": return "身份认证"
        case "9c": return "数字签名"
        case "9d": return "密钥管理"
        case "9e": return "卡片认证"
        default: return "其他槽位"
        }
    }

    private func announce(_ message: String, kind: StatusKind) {
        statusText = message
        statusKind = kind
        log += "\n──────── \(logTimestamp()) ────────\n[\(message)]\n"
    }

    private func appendLog(_ message: String) {
        log += "\n\(message)\n"
    }

    private func logTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }

    private func siblingURL(for file: URL, name: String) -> URL {
        file.deletingLastPathComponent().appendingPathComponent(name)
    }

    nonisolated private static func formatDeviceSummary(_ data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data) else { return nil }

        let devices: [[String: Any]]
        if let dictionary = object as? [String: Any] {
            devices = [dictionary]
        } else if let array = object as? [[String: Any]] {
            devices = array
        } else {
            return nil
        }

        guard devices.contains(where: {
            $0["reader"] != nil || $0["serial"] != nil || $0["slots"] != nil
        }) else {
            return nil
        }

        var lines: [String] = []
        for (index, device) in devices.enumerated() {
            if devices.count > 1 {
                lines.append("设备 \(index + 1)：")
            }
            if let reader = device["reader"] as? String {
                lines.append("阅读器：\(reader)")
            }
            if let serial = device["serial"] {
                lines.append("序列号：\(serial)")
            }
            if let version = device["ykpiv_version"] as? String {
                lines.append("PIV 版本：\(version)")
            }

            if let slots = device["slots"] as? [String: Any], !slots.isEmpty {
                lines.append("槽位：")
                for slot in slots.keys.sorted() {
                    guard let info = slots[slot] as? [String: Any] else { continue }
                    let name = info["name"] as? String ?? "未命名"
                    let algorithm = info["algorithm"] as? String ?? "未知算法"
                    let subject = info["subject"] as? String ?? "无证书主题"
                    lines.append("  \(slot)：\(name)，\(algorithm)，\(subject)")
                }
            }
        }
        return lines.joined(separator: "\n")
    }

    nonisolated private static func summaryValue(_ summary: String, prefix: String) -> String? {
        guard let line = summary
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .first(where: { $0.hasPrefix(prefix) }) else {
            return nil
        }
        return String(line.dropFirst(prefix.count))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    nonisolated private static func deviceIdentity(from summary: String) -> String {
        let reader = summaryValue(summary, prefix: "阅读器：") ?? ""
        let serial = summaryValue(summary, prefix: "序列号：") ?? ""
        let pivVersion = summaryValue(summary, prefix: "PIV 版本：") ?? ""
        return "\(reader)|\(serial)|\(pivVersion)"
    }

    nonisolated private static func extractSlotIDs(_ data: Data) -> [String] {
        guard let object = try? JSONSerialization.jsonObject(with: data) else { return [] }
        if let dictionary = object as? [String: Any], let slots = dictionary["slots"] as? [String: Any] {
            return slots.keys.sorted()
        }
        if let array = object as? [[String: Any]] {
            return array
                .compactMap { $0["slots"] as? [String: Any] }
                .flatMap { $0.keys }
                .sorted()
        }
        return []
    }

    nonisolated private static func text(_ data: Data) -> String {
        if data.isEmpty { return "（无输出）" }
        return String(data: data, encoding: .utf8) ?? "（非文本输出，长度 \(kilobytes(data.count))）"
    }

    nonisolated private static func kilobytes(_ bytes: Int) -> String {
        String(format: "%.1f KB", Double(bytes) / 1024.0)
    }

    nonisolated private static func parseGPGKeys(_ data: Data) -> [GPGKey] {
        guard let output = String(data: data, encoding: .utf8) else { return [] }
        var keys: [GPGKey] = []
        var primaryFingerprint = ""
        var primaryUserID = ""

        func appendCurrentKey() {
            guard !primaryFingerprint.isEmpty,
                  !keys.contains(where: { $0.fingerprint == primaryFingerprint }) else { return }
            keys.append(GPGKey(fingerprint: primaryFingerprint, userID: primaryUserID))
        }

        for line in output.split(whereSeparator: \.isNewline) {
            let fields = line.split(separator: ":", omittingEmptySubsequences: false)
            guard let record = fields.first else { continue }

            if record == "pub" || record == "sec" {
                appendCurrentKey()
                primaryFingerprint = ""
                primaryUserID = ""
            } else if record == "fpr", fields.count > 9, primaryFingerprint.isEmpty {
                primaryFingerprint = String(fields[9]).uppercased()
            } else if record == "uid", fields.count > 9, primaryUserID.isEmpty {
                primaryUserID = decodeGPGColonField(String(fields[9]))
            }
        }
        appendCurrentKey()
        return keys
    }

    nonisolated private static func decodeGPGColonField(_ value: String) -> String {
        var result = ""
        var index = value.startIndex
        while index < value.endIndex {
            if value[index] == "\\", value.distance(from: index, to: value.endIndex) >= 4 {
                let next = value.index(index, offsetBy: 1)
                if value[next] == "x" {
                    let hexStart = value.index(index, offsetBy: 2)
                    let hexEnd = value.index(index, offsetBy: 4)
                    if let byte = UInt8(value[hexStart..<hexEnd], radix: 16) {
                        result.append(Character(UnicodeScalar(byte)))
                        index = hexEnd
                        continue
                    }
                }
            }
            result.append(value[index])
            index = value.index(after: index)
        }
        return result
    }

    nonisolated private static func safeGPGArgument(_ value: String) -> String {
        if value == "--pinentry-mode" || value == "default" || value.hasPrefix("--") {
            return value
        }
        if value.contains("/") || value.contains(" ") {
            return "\"\(value.replacingOccurrences(of: "\\\"", with: "\\\\\""))\""
        }
        return value
    }

    nonisolated private static func execute(tool: String, arguments: [String], input: Data?) -> CommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: tool)
        process.arguments = arguments

        let stdin = Pipe()
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardInput = stdin
        process.standardOutput = stdout
        process.standardError = stderr

        do {
            try process.run()
        } catch {
            return CommandResult(
                status: 1,
                stdout: Data(),
                stderr: Data(error.localizedDescription.utf8),
                terminationReason: nil
            )
        }

        let readGroup = DispatchGroup()
        var stdoutData = Data()
        var stderrData = Data()

        readGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            stdoutData = stdout.fileHandleForReading.readDataToEndOfFile()
            readGroup.leave()
        }

        readGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            stderrData = stderr.fileHandleForReading.readDataToEndOfFile()
            readGroup.leave()
        }

        if let input {
            stdin.fileHandleForWriting.write(input)
        }
        try? stdin.fileHandleForWriting.close()
        process.waitUntilExit()
        readGroup.wait()

        return CommandResult(
            status: process.terminationStatus,
            stdout: stdoutData,
            stderr: stderrData,
            terminationReason: process.terminationReason
        )
    }
}

private struct BottomAnchoredLogView: NSViewRepresentable {
    let text: String
    let fontSize: CGFloat

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true

        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = false
        textView.usesFindBar = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        scrollView.documentView = textView
        update(textView: textView, scrollView: scrollView)
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        update(textView: textView, scrollView: scrollView)
    }

    private func update(textView: NSTextView, scrollView: NSScrollView) {
        if textView.string != text {
            textView.string = text
        }
        textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let appearance = NSApp?.effectiveAppearance ?? NSAppearance(named: .aqua)!
        textView.textColor = ThemeRuntime.nsColor(.green, appearance: appearance)
        textView.backgroundColor = ThemeRuntime.nsColor(.surface, appearance: appearance)
        scrollView.backgroundColor = ThemeRuntime.nsColor(.surface, appearance: appearance)

        DispatchQueue.main.async {
            textView.layoutSubtreeIfNeeded()
            textView.scrollToEndOfDocument(nil)
        }
    }
}

private struct PINPromptView: View {
    @ObservedObject var model: PivyModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(model.pinPromptTitle)
                .font(.title3.weight(.semibold))
            Text("请输入 YubiKey PIV PIN。\n\(model.pendingPINHint)")
                .foregroundStyle(.secondary)
            SecureField("PIV PIN", text: $model.pin)
                .textFieldStyle(.roundedBorder)
                .onSubmit { model.confirmPIN() }
            HStack {
                Spacer()
                Button("取消", role: .cancel) { model.cancelPIN() }
                Button("继续") { model.confirmPIN() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(22)
        .frame(width: 360)
    }
}

private enum AppTab: String, CaseIterable, Hashable {
    case device
    case sign
    case verify
    case encrypt
    case decrypt
    case fido
    case gpg
    case tools
    case guide
    case logs

    var title: String {
        switch self {
        case .device: return "设备"
        case .sign: return "文件签名"
        case .verify: return "验证签名"
        case .encrypt: return "文件加密"
        case .decrypt: return "文件解密"
        case .fido: return "FIDO 服务器"
        case .gpg: return "GPG 工具"
        case .tools: return "证书工具"
        case .guide: return "使用说明"
        case .logs: return "运行日志"
        }
    }

    var subtitle: String {
        switch self {
        case .device: return "查看 YubiKey 连接状态、PIV 版本和槽位信息。"
        case .sign: return "使用 9c 槽对文件签名，并导出签名证书。"
        case .verify: return "使用原文件、签名文件和证书验证 9c 签名。"
        case .encrypt: return "使用 9d 槽把文件加密为 .pivybox。"
        case .decrypt: return "使用同一把 YubiKey 解密 .pivybox 文件。"
        case .fido: return "使用 YubiKey FIDO2 安全密钥登录 Linux SSH 服务器。"
        case .gpg: return "使用 OpenPGP/GPG 处理大文件加密、解密、签名和验证。"
        case .tools: return "导出公钥、证书、槽位证明，或生成服务器认证 CSR。"
        case .guide: return "安装依赖、了解功能，并处理常见的 YubiKey 读卡问题。"
        case .logs: return "查看操作状态、命令输出和生成文件路径。"
        }
    }

    var systemImage: String {
        switch self {
        case .device: return "key.fill"
        case .sign: return "signature"
        case .verify: return "checkmark.seal"
        case .encrypt: return "lock.fill"
        case .decrypt: return "lock.open"
        case .fido: return "server.rack"
        case .gpg: return "lock.shield"
        case .tools: return "checkmark.seal.fill"
        case .guide: return "book.closed"
        case .logs: return "text.alignleft"
        }
    }
}

private struct SidebarNavigation: View {
    @Binding var selection: AppTab
    @ObservedObject var model: PivyModel
    @State private var hoveredTab: AppTab?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 9) {
                    Image(systemName: "key.fill")
                        .font(.title3)
                        .foregroundStyle(CyberpunkTheme.cyan)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("YubiKey")
                            .font(.headline)
                        Text(
                            model.pivyInstalled
                                ? (model.deviceSerial == "--" ? "等待设备 · 自动监测" : "PIV 已连接 · 自动监测")
                                : "找不到 pivy"
                        )
                            .font(.caption)
                            .foregroundStyle(
                                model.pivyInstalled
                                    ? (model.deviceSerial == "--" ? CyberpunkTheme.cyan : CyberpunkTheme.green)
                                    : CyberpunkTheme.magenta
                            )
                    }
                }
                Text(model.deviceReader)
                    .font(.caption)
                    .foregroundStyle(CyberpunkTheme.text)
                    .lineLimit(1)
                    .truncationMode(.tail)
                HStack {
                    Text(model.deviceSerial == "--" ? "尚未读取设备" : "S/N: \(model.deviceSerial)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    if model.devicePIVVersion != "--" {
                        Text("PIV \(model.devicePIVVersion)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [CyberpunkTheme.violet.opacity(0.30), CyberpunkTheme.cyan.opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(CyberpunkTheme.cyan.opacity(0.58), lineWidth: 1)
            )
            .shadow(color: CyberpunkTheme.cyan.opacity(0.16), radius: 14)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("功能")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CyberpunkTheme.cyan)
                .padding(.horizontal, 8)

            VStack(spacing: 3) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                if tab == .logs {
                    Divider()
                        .padding(.vertical, 5)
                }
                Button {
                    selection = tab
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: tab.systemImage)
                            .frame(width: 20)
                        Text(tab.title)
                        Spacer()
                    }
                    .font(.callout.weight(selection == tab ? .semibold : .regular))
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                .contentShape(Rectangle())
                .foregroundStyle(selection == tab ? CyberpunkTheme.cyan : CyberpunkTheme.text)
                .background(
                    selection == tab
                        ? CyberpunkTheme.cyan.opacity(0.16)
                        : hoveredTab == tab ? CyberpunkTheme.violet.opacity(0.14) : Color.clear
                )
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(selection == tab ? CyberpunkTheme.magenta : .clear)
                        .frame(width: 3)
                        .padding(.vertical, 5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onHover { isHovering in
                    hoveredTab = isHovering ? tab : nil
                    if isHovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }
                .help(tab.subtitle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 4) {
                Divider()
                Label("pivy-tool", systemImage: "terminal")
                    .font(.caption)
                    .foregroundStyle(CyberpunkTheme.cyan)
                Text(model.pivyToolPath)
                    .font(.caption2)
                    .foregroundStyle(CyberpunkTheme.muted)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .padding(12)
        .frame(minWidth: 196, maxWidth: 196, maxHeight: .infinity, alignment: .topLeading)
        .background(CyberpunkTheme.surface.opacity(0.94))
    }
}

private struct PageHeader: View {
    let tab: AppTab
    @ObservedObject var model: PivyModel
    @Binding var themeRawValue: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(tab.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [CyberpunkTheme.text, CyberpunkTheme.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text(tab.subtitle)
                    .font(.callout)
                    .foregroundStyle(CyberpunkTheme.muted)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer(minLength: 12)
            HStack(spacing: 8) {
                Text("主题")
                    .foregroundStyle(CyberpunkTheme.text)
                Menu {
                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            themeRawValue = theme.rawValue
                        } label: {
                            Text(theme.title)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(AppTheme(rawValue: themeRawValue)?.title ?? "跟随系统")
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                    }
                        .foregroundStyle(CyberpunkTheme.text)
                }
                .menuStyle(.borderlessButton)
                .controlSize(.small)

                HStack(spacing: 7) {
                    Circle()
                        .fill(model.statusKind.color)
                        .frame(width: 8, height: 8)
                    Text(model.statusText)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(model.statusKind.color)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.horizontal, 10)
                .frame(minHeight: 28)
                .background(model.statusKind.background.overlay(CyberpunkTheme.surfaceRaised))
                .overlay(
                    Capsule()
                        .stroke(model.statusKind.color.opacity(0.45), lineWidth: 1)
                )
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .topLeading)
    }
}

@MainActor
private final class PivyShellAppDelegate: NSObject, NSApplicationDelegate {
    private let defaultContentSize = NSSize(width: 1040, height: 760)
    private let minimumContentSize = NSSize(width: 960, height: 680)

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureWindowWithRetry(triesRemaining: 12)
    }

    private func configureWindowWithRetry(triesRemaining: Int) {
        guard let window = NSApplication.shared.windows.first(where: {
            $0.title == "Pivy YubiKey 本地工具"
        }) else {
            guard triesRemaining > 0 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.configureWindowWithRetry(triesRemaining: triesRemaining - 1)
            }
            return
        }

        window.setContentSize(defaultContentSize)
        window.styleMask.insert(.resizable)
        window.standardWindowButton(.zoomButton)?.isEnabled = true
        window.contentMinSize = minimumContentSize
        window.center()
    }
}

private struct DropPanel: View {
    let title: String
    let prompt: String
    let url: URL?
    let choose: () -> Void
    let receive: (URL) -> Void
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: "arrow.down.doc")
                .font(.title3)
                .foregroundStyle(isTargeted ? CyberpunkTheme.cyan : CyberpunkTheme.muted)
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(url?.path ?? prompt)
                .font(.callout)
                .foregroundStyle(url == nil ? CyberpunkTheme.muted : CyberpunkTheme.text)
                .lineLimit(2)
                .truncationMode(.middle)
                .multilineTextAlignment(.center)
            Button("选择文件…", action: choose)
        }
        .frame(maxWidth: .infinity, minHeight: 112)
        .padding(8)
        .background(isTargeted ? CyberpunkTheme.cyan.opacity(0.15) : CyberpunkTheme.surfaceRaised.opacity(0.72))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isTargeted ? CyberpunkTheme.cyan : CyberpunkTheme.border, lineWidth: isTargeted ? 1.5 : 1)
        )
        .shadow(color: isTargeted ? CyberpunkTheme.cyan.opacity(0.24) : .clear, radius: 10)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
            guard let provider = providers.first else { return false }
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                guard let droppedURL = Self.urlFromDropItem(item), droppedURL.isFileURL else {
                    return
                }
                DispatchQueue.main.async {
                    receive(droppedURL)
                }
            }
            return true
        }
    }

    private static func urlFromDropItem(_ item: Any?) -> URL? {
        if let itemURL = item as? URL {
            return itemURL
        }
        if let itemData = item as? Data {
            return URL(dataRepresentation: itemData, relativeTo: nil)
        }
        if let itemURL = item as? NSURL {
            return itemURL as URL
        }
        return nil
    }
}

private struct BatchDropPanel: View {
    let title: String
    let prompt: String
    let receive: ([URL]) -> Void
    @State private var isTargeted = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.title2)
                .foregroundStyle(isTargeted ? CyberpunkTheme.cyan : CyberpunkTheme.muted)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(prompt)
                    .font(.callout)
                    .foregroundStyle(CyberpunkTheme.muted)
            }
            Spacer()
            Text("按后缀自动归类")
                .font(.caption)
                .foregroundStyle(CyberpunkTheme.cyan)
        }
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(isTargeted ? CyberpunkTheme.cyan.opacity(0.15) : CyberpunkTheme.surfaceRaised.opacity(0.72))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isTargeted ? CyberpunkTheme.cyan : CyberpunkTheme.border, lineWidth: isTargeted ? 1.5 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
            let group = DispatchGroup()
            let lock = NSLock()
            var urls: [URL] = []

            for provider in providers {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    defer { group.leave() }
                    guard let url = Self.urlFromDropItem(item) else { return }
                    lock.lock()
                    urls.append(url)
                    lock.unlock()
                }
            }

            group.notify(queue: .main) {
                receive(urls)
            }
            return true
        }
    }

    private static func urlFromDropItem(_ item: Any?) -> URL? {
        if let itemURL = item as? URL {
            return itemURL
        }
        if let itemData = item as? Data {
            return URL(dataRepresentation: itemData, relativeTo: nil)
        }
        if let itemURL = item as? NSURL {
            return itemURL as URL
        }
        return nil
    }
}

struct ContentView: View {
    @StateObject private var model = PivyModel()
    @State private var selectedTab: AppTab = .device
    @State private var selectedGPGSection: GPGSection = .overview
    @State private var hoveredGPGSection: GPGSection?
    @State private var isGPGPinentryHelpExpanded = false
    @State private var isGuideFirstUseExpanded = false
    @State private var isLogExpanded = true
    @AppStorage(ThemeRuntime.defaultsKey) private var themeRawValue = AppTheme.cyberpunk.rawValue

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: themeRawValue) ?? .cyberpunk
    }

    var body: some View {
        ZStack {
            CyberpunkBackdrop()

            HStack(spacing: 0) {
                SidebarNavigation(selection: $selectedTab, model: model)

                Rectangle()
                    .fill(CyberpunkTheme.cyan.opacity(0.22))
                    .frame(width: 1)

                VStack(alignment: .leading, spacing: 12) {
                    PageHeader(tab: selectedTab, model: model, themeRawValue: $themeRawValue)

                    if selectedTab == .logs {
                        logPage
                    } else {
                        ZStack(alignment: .bottom) {
                            GroupBox {
                                tabContent
                            }
                            .id(selectedTab)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                            if isLogExpanded {
                                expandedLogDrawer
                            } else {
                                collapsedLogBar
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
                .padding(.top, 18)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .id(themeRawValue)
        .frame(minWidth: 1040, minHeight: 760)
        .foregroundStyle(CyberpunkTheme.text)
        .tint(CyberpunkTheme.cyan)
        .preferredColorScheme(selectedTheme.colorScheme)
        .groupBoxStyle(CyberpunkGroupBoxStyle())
        .sheet(isPresented: $model.showPINPrompt) {
            PINPromptView(model: model)
        }
    }

    private var logPage: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("操作记录")
                    .font(.headline)
                Text(String(format: "%d 行", model.logLineCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("复制") { model.copyLog() }
                Button("保存…") { model.saveLog() }
                Button("清空") { model.clearLog() }
            }
            .controlSize(.small)

            Text("这里集中显示所有页面产生的状态、命令和输出路径；功能页面本身不会再被日志挤压。")
                .font(.callout)
                .foregroundStyle(CyberpunkTheme.muted)

            BottomAnchoredLogView(text: model.log, fontSize: 12)
                .background(CyberpunkTheme.surface)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(CyberpunkTheme.border, lineWidth: 1))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var collapsedLogBar: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(model.statusKind.color)
                .frame(width: 8, height: 8)
            Label("运行日志", systemImage: "text.alignleft")
                .font(.caption.weight(.semibold))
            Text(model.statusText)
                .font(.caption)
                .foregroundStyle(model.statusKind.color)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer()
            Text(String(format: "%d 行", model.logLineCount))
                .font(.caption2)
                .foregroundStyle(.secondary)
            Button("展开") {
                withAnimation(.easeOut(duration: 0.18)) {
                    isLogExpanded = true
                }
            }
            .controlSize(.small)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 34, maxHeight: 34)
        .background(CyberpunkTheme.surfaceRaised.opacity(0.96))
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(CyberpunkTheme.cyan.opacity(0.36), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }

    private var expandedLogDrawer: some View {
        VStack(spacing: 7) {
            HStack(spacing: 8) {
                Label("运行日志", systemImage: "text.alignleft")
                    .font(.subheadline.weight(.semibold))
                Text(String(format: "%d 行", model.logLineCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("复制") { model.copyLog() }
                Button("保存…") { model.saveLog() }
                Button("清空") { model.clearLog() }
                Button("收起") {
                    withAnimation(.easeOut(duration: 0.18)) {
                        isLogExpanded = false
                    }
                }
            }
            .controlSize(.small)

            BottomAnchoredLogView(text: model.log, fontSize: 11)
                .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 180)
                .background(CyberpunkTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(CyberpunkTheme.border.opacity(0.86), lineWidth: 1)
                )
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 230, maxHeight: 230)
        .background(CyberpunkTheme.surfaceRaised.opacity(0.98))
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(CyberpunkTheme.violet.opacity(0.52), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .shadow(color: CyberpunkTheme.violet.opacity(0.30), radius: 16, y: -3)
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .device:
            deviceTab
        case .sign:
            signTab
        case .verify:
            verifyTab
        case .encrypt:
            encryptTab
        case .decrypt:
            decryptTab
        case .fido:
            fidoServerTab
        case .gpg:
            gpgTab
        case .tools:
            certificateToolsTab
        case .guide:
            guideTab
        case .logs:
            EmptyView()
        }
    }

    private var guideTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                GroupBox("先检查环境") {
                    VStack(alignment: .leading, spacing: 8) {
                        dependencyRow(
                            title: "PIV 工具",
                            installed: model.pivyInstalled,
                            path: model.pivyInstalled ? model.pivyToolPath : nil,
                            command: "brew install --cask pivy-app",
                            note: "支持设备读取、9a/9c/9d/9e、CSR 和 .pivybox。"
                        )
                        dependencyRow(
                            title: "GnuPG",
                            installed: model.gpgInstalled,
                            path: model.gpgToolPath,
                            command: "brew install gnupg pinentry-mac",
                            note: "支持 OpenPGP 大文件加密、解密、签名和验证。"
                        )
                        dependencyRow(
                            title: "pinentry-mac",
                            installed: model.pinentryPath != nil,
                            path: model.pinentryPath,
                            command: "brew install pinentry-mac",
                            note: "让 GPG 通过安全弹窗接收 PIN。"
                        )
                        dependencyRow(
                            title: "OpenSSL",
                            installed: model.opensslPath != nil,
                            path: model.opensslPath,
                            command: "brew install openssl@3",
                            note: "用于验证 PIV 9c 分离签名；macOS 通常已有系统版本。"
                        )
                        Text("macOS 自带 PC/SC 读卡框架，通常不需要额外安装 pcscd 或 OpenSC。ykman 也不是本工具的必需依赖。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(4)
                }

                if !model.missingInstallationNames.isEmpty {
                    GroupBox("安装缺失组件") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Button("复制安装命令") { model.copyInstallationInstructions() }
                                    .buttonStyle(.borderedProminent)
                                Text("缺少：\(model.missingInstallationNames.joined(separator: "、"))")
                                    .font(.caption)
                                    .foregroundStyle(CyberpunkTheme.orange)
                            }
                            Text(model.installationInstructions)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(CyberpunkTheme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(CyberpunkTheme.orange.opacity(0.32), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Text("只显示当前未检测到的组件；安装后重新打开本工具即可刷新状态。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(4)
                    }
                }

                GroupBox("按功能准备") {
                    VStack(alignment: .leading, spacing: 7) {
                        guideFeatureRow(title: "设备 / 证书工具", detail: "PIV 工具 + YubiKey；用于读取设备、导出证书、公钥和生成 CSR。")
                        guideFeatureRow(title: "9c 文件签名 / 验证", detail: "PIV 工具；验证还需要 OpenSSL。超过 16 KB 的文件请改用 GPG。")
                        guideFeatureRow(title: "9d 文件加密 / 解密", detail: "PIV 工具；当前 .pivybox 的 box 模式适合小文件。大文件请使用 GPG。")
                        guideFeatureRow(title: "GPG / OpenPGP", detail: "GnuPG + pinentry-mac + YubiKey OpenPGP 密钥；文件本体由电脑处理。加密用对方公钥，解密用对方自己的私钥。")
                    }
                    .padding(4)
                }

                GroupBox("GPG 主密钥、子密钥与丢失恢复") {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("先记住：主密钥通常在安全电脑或离线环境生成，用来确认身份、生成和管理子密钥；日常使用时只把子密钥放进 YubiKey，主密钥不要长期放在日常电脑里。")
                            .font(.callout)
                        Text("子密钥分工：S = 数字签名，E = 加密/解密，A = SSH 或其他身份认证。推荐流程：备份主密钥和撤销证书 → 用主密钥创建 S/E/A 子密钥 → 把子密钥迁移到 YubiKey → 导出公钥给别人。")
                            .font(.caption)
                        Text("主密钥不是万能解密钥匙：别人用你的 E 子密钥公钥加密，解密时必须使用对应的 E 子密钥私钥。主密钥只能在你仍有密钥备份时帮助你生成新的子密钥，不能凭空恢复已经丢失的旧 E 子密钥。")
                            .font(.caption)
                        Text("子密钥可以设置过期时间。过期后通常不能用于新的加密或签名；已经加密的旧文件，只要旧 E 子密钥私钥仍然保留，通常仍可解密。轮换密钥时不要删除旧子密钥，否则旧文件可能无法解密。")
                            .font(.caption)
                            .foregroundStyle(CyberpunkTheme.orange)
                        Text("如果你选择“直接在 YubiKey 上生成”，密钥会在卡内创建，私钥不会导出；这是更安全但更依赖备份卡的流程。若选择“迁移已有子密钥”，则先在电脑安全生成，再把子密钥放入卡片。")
                            .font(.caption)
                        Text("常用检查命令：\ngpg --list-secret-keys --keyid-format LONG\ngpg --edit-key <主密钥指纹>\n# 交互界面中使用 addkey 创建子密钥；选中子密钥后使用 keytocard 迁移到卡片\ngpg --export --armor <主密钥指纹> > public-key.asc")
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(CyberpunkTheme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(CyberpunkTheme.cyan.opacity(0.30), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text("丢失 YubiKey 后：不能从卡片导出私钥；用离线主密钥备份在新卡重新生成/迁移子密钥，并发布旧子密钥的撤销信息。多张备用卡建议使用不同子密钥；复制同一套子密钥更方便，但必须承担更高的备份和泄露风险。")
                            .font(.caption)
                            .foregroundStyle(CyberpunkTheme.orange)
                    }
                    .padding(4)
                }

                GroupBox("读卡冲突处理") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("如果读取 PIV 时提示“没有返回有效 JSON”，程序会自动释放 GPG 的 scdaemon 并重试一次。仍然失败时，先关闭其他智能卡程序，再点击下面的按钮。")
                            .font(.callout)
                        HStack(spacing: 8) {
                            Button("释放 GPG 读卡会话") { model.releaseGPGSmartCardSession() }
                                .buttonStyle(.borderedProminent)
                                .disabled(model.busy || model.gpgconfPath == nil)
                            Text("等价于：gpgconf --kill scdaemon")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                        Text("这不会删除 GPG 密钥或 PIV 证书；下一次 GPG 操作会自动重新启动 scdaemon。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(4)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        withAnimation(.easeOut(duration: 0.18)) {
                            isGuideFirstUseExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isGuideFirstUseExpanded ? "chevron.down" : "chevron.right")
                                .frame(width: 14)
                            Text("首次使用流程")
                                .font(.callout.weight(.semibold))
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .onHover { isHovering in
                        if isHovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                    .help("展开或收起首次使用流程")

                    if isGuideFirstUseExpanded {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("1. 插入或更换 YubiKey，等待左上角自动读取；如果读卡程序被占用，再点“读取设备”。")
                            Text("2. 需要 PIV 签名、加密或 CSR 时，选择对应菜单并按提示输入 PIV PIN。")
                            Text("3. 需要 GPG 时，进入“GPG 工具 → 密钥与卡片”，读取 OpenPGP 卡或生成卡上密钥。")
                            Text("4. 给别人发密文：先导入对方公钥，核对指纹，再到“文件加密”选择对方公钥。")
                            Text("5. 如果自己也要保留可解密副本，开启“同时加密给自己”；需要双方都能验证来源时使用“签名并加密”。")
                            Text("6. GPG 的 PIN 在 GnuPG 安全弹窗中输入，不会进入本工具日志。")
                            Text("7. 9c 验证需要原文件、.sig 和 .sig.cert.pem；GPG 验证需要原文件和 .asc/.sig。")
                        }
                        .font(.callout)
                        .padding(.top, 6)
                    }
                }
                .padding(4)

                Text("安全提示：不要把 PIV PIN、GPG PIN、PUK 或管理密钥写入脚本；不要把 factory-reset、ykman piv reset 当作普通修复命令。")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            .padding(4)
        }
    }

    private func dependencyRow(
        title: String,
        installed: Bool,
        path: String?,
        command: String,
        note: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 7) {
                Label(title, systemImage: installed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(installed ? Color.green : Color.orange)
                Spacer()
                Text(installed ? "已找到" : "未安装")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(installed ? Color.green : Color.orange)
            }
            Text(installed ? (path ?? "已安装") : "安装：\(command)")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
                .lineLimit(2)
            Text(note)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(installed ? Color.green.opacity(0.07) : Color.orange.opacity(0.09))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(installed ? Color.green.opacity(0.20) : Color.orange.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func guideFeatureRow(title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "arrow.right.circle.fill")
                .foregroundStyle(CyberpunkTheme.cyan)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.callout.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var deviceTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Button("读取设备") { model.showDevice() }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.busy)
                Text("读取结果会先校验 JSON，再显示摘要和详细日志。")
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Button("读取 PIV 版本") { model.showVersion() }
                    .disabled(model.busy)
                Button("读取 Printed Info") { model.showPrintedInfo() }
                    .disabled(model.busy)
                Text("只读诊断，不会修改卡片。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GroupBox("设备摘要") {
                Text(model.deviceSummary)
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
            }

            GroupBox("本地环境") {
                VStack(alignment: .leading, spacing: 7) {
                    Label("pivy-tool：\(model.pivyToolPath)", systemImage: "terminal")
                    Label("本地测试：9c 签名 / 验证，9d 加密 / 解密", systemImage: "checkmark.shield")
                    Label("GPG：\(model.gpgToolPath ?? "未安装")", systemImage: "lock.shield")
                    Text("PIN 只在弹窗中输入，操作完成后立即从界面状态清空。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(4)
            }
        }
        .padding(4)
    }

    private var signTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            DropPanel(
                title: "待签名文件",
                prompt: "把要签名的文件拖到这里",
                url: model.dataFile,
                choose: model.chooseDataFile,
                receive: model.setDataFile
            )

            HStack {
                Button("9c 签名") { model.requestSign() }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.busy)
                Text("输出：原文件.sig 以及 原文件.sig.cert.pem")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Text("上限：16.0 KB；超过 16.0 KB 会提示并停留在当前页面。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(4)
    }

    private var verifyTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            BatchDropPanel(
                title: "智能导入验证文件",
                prompt: "一次拖入原文件、.sig 和 .sig.cert.pem；程序会按后缀自动填入下面三个区域。",
                receive: model.autoAssignVerifyFiles
            )

            HStack(alignment: .top, spacing: 10) {
                DropPanel(
                    title: "原文件",
                    prompt: "拖入原文件",
                    url: model.dataFile,
                    choose: model.chooseDataFile,
                    receive: model.setDataFile
                )
                DropPanel(
                    title: ".sig 签名",
                    prompt: "拖入 .sig",
                    url: model.signatureFile,
                    choose: model.chooseSignatureFile,
                    receive: model.setSignatureFile
                )
                DropPanel(
                    title: ".pem 证书",
                    prompt: "拖入 .pem",
                    url: model.certificateFile,
                    choose: model.chooseCertificateFile,
                    receive: model.setCertificateFile
                )
            }

            HStack {
                Button("验证签名") { model.verifySignature() }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.busy)
                Text("验证的是文件完整性和签名匹配，不等于公网 CA 信任验证。")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(4)
    }

    private var encryptTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            DropPanel(
                title: "待加密文件",
                prompt: "把要加密的文件拖到这里",
                url: model.encryptFile,
                choose: model.chooseEncryptFile,
                receive: model.setEncryptFile
            )

            HStack {
                Button("9d 加密") { model.requestEncrypt() }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.busy)
                Text("输出：原文件.pivybox")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Text("上限：8.0 KB；超过 8.0 KB 会提示并停留在当前页面。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(4)
    }

    private var decryptTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            DropPanel(
                title: "待解密文件",
                prompt: "把 .pivybox 文件拖到这里",
                url: model.decryptFile,
                choose: model.chooseDecryptFile,
                receive: { url in
                    if url.pathExtension.lowercased() == "pivybox" {
                        model.setDecryptFile(url)
                    } else {
                        model.announceInvalidDecryptDrop()
                    }
                }
            )

            HStack {
                Button("9d 解密") { model.requestDecrypt() }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.busy)
                Button("查看密文信息") { model.inspectBox() }
                    .disabled(model.busy)
                Text("输出：同目录下的 .decrypted 文件，不会覆盖原文件。")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(4)
    }

    private var fidoServerTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                GroupBox("它如何登录服务器") {
                    HStack(alignment: .top, spacing: 14) {
                        fidoFlowStep(
                            number: "1",
                            title: "生成硬件密钥",
                            detail: "私钥在 YubiKey FIDO2 应用内生成，不会导出到电脑。"
                        )
                        fidoFlowStep(
                            number: "2",
                            title: "服务器保存公钥",
                            detail: "只把 .pub 文件加入 Linux 账户的 ~/.ssh/authorized_keys。"
                        )
                        fidoFlowStep(
                            number: "3",
                            title: "PIN + 触摸登录",
                            detail: "SSH 挑战由 YubiKey 签名；服务器验证签名后允许登录。"
                        )
                    }
                    Text("FIDO2、PIV 和 OpenPGP/GPG 是 YubiKey 上相互独立的应用。这里生成 FIDO2 SSH 密钥，不会覆盖当前 PIV 证书或 GPG 密钥。FIDO2 PIN 也不是 PIV PIN 或 OpenPGP PIN。")
                        .font(.caption)
                        .foregroundStyle(CyberpunkTheme.orange)
                        .padding(.top, 4)
                }

                GroupBox("第 1 步：检查本机 OpenSSH") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Button(model.sshEnvironmentChecking ? "检查中…" : "重新检查") {
                                model.refreshSSHEnvironment()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.sshEnvironmentChecking)
                            Button("复制安装命令") {
                                model.copyFIDOServerText("brew install openssh", title: "安装 Homebrew OpenSSH")
                            }
                            Text(model.sshSupportsFIDO ? "当前 OpenSSH 可使用 FIDO2" : "macOS 系统 OpenSSH 通常没有 FIDO 支持")
                                .font(.caption)
                                .foregroundStyle(model.sshSupportsFIDO ? CyberpunkTheme.green : CyberpunkTheme.orange)
                        }
                        Text(model.sshEnvironmentSummary)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(CyberpunkTheme.surface.opacity(0.70))
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        Text("最低要求：OpenSSH 8.2 支持 *-sk 密钥；8.3 支持 ssh-keygen -K 恢复驻留密钥；8.4 支持 verify-required。版本足够仍不代表构建包含 libfido2，因此本工具还会读取 ssh -Q key。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(4)
                }

                GroupBox("第 2 步：设置并生成 FIDO2 SSH 密钥") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("算法").font(.caption.weight(.semibold))
                                Picker("算法", selection: $model.fidoAlgorithm) {
                                    ForEach(FIDOKeyAlgorithm.allCases) { algorithm in
                                        Text(algorithm.title).tag(algorithm)
                                    }
                                }
                                .labelsHidden()
                                .pickerStyle(.menu)
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Toggle("驻留密钥（推荐）", isOn: $model.fidoResident)
                                Toggle("每次要求 PIN 验证", isOn: $model.fidoVerifyRequired)
                            }
                            .toggleStyle(.checkbox)
                            Spacer(minLength: 0)
                        }

                        HStack(spacing: 10) {
                            fidoTextField(title: "备注/邮箱", placeholder: "your@email.com", text: $model.fidoComment)
                            fidoTextField(title: "本地密钥名称", placeholder: "server", text: $model.fidoKeyName)
                            fidoTextField(title: "卡内用途标签", placeholder: "server", text: $model.fidoApplicationLabel)
                        }

                        Text(model.fidoResident
                             ? "驻留密钥把可发现凭据保存在 YubiKey 中；换电脑后可用 ssh-keygen -K 重新取得句柄文件。"
                             : "非驻留模式不占用驻留凭据空间，但 ~/.ssh 中生成的句柄文件必须备份；它不是私钥，却是定位卡内密钥所必需的。")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let commands = try? model.makeFIDOServerCommands() {
                            fidoCommandBlock(
                                title: "生成密钥",
                                detail: "运行后按提示输入 FIDO2 PIN 并触摸 YubiKey；不要在已有同名文件时直接确认覆盖。",
                                command: commands.generate
                            )
                        }
                    }
                    .padding(4)
                }

                GroupBox("第 3 步：把公钥安装到 Linux 服务器") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            fidoTextField(title: "Linux 用户名", placeholder: "ubuntu", text: $model.fidoUsername)
                            fidoTextField(title: "服务器域名或 IP", placeholder: "server.example.com", text: $model.fidoHost)
                        }

                        if let commands = try? model.makeFIDOServerCommands() {
                            fidoCommandBlock(
                                title: "安装公钥（推荐）",
                                detail: "首次执行仍会要求服务器现有密码；它只把 .pub 公钥追加到目标账户。",
                                command: commands.installPublicKey
                            )
                            fidoCommandBlock(
                                title: "没有 ssh-copy-id 时的兼容命令",
                                detail: "同样只追加公钥，不会把 YubiKey 私钥发送到服务器。",
                                command: commands.installPublicKeyFallback
                            )
                            fidoCommandBlock(
                                title: "测试登录",
                                detail: "按提示输入 FIDO2 PIN 并触摸 YubiKey。",
                                command: commands.login
                            )
                        } else {
                            Text(fidoValidationMessage)
                                .font(.callout)
                                .foregroundStyle(CyberpunkTheme.orange)
                        }
                    }
                    .padding(4)
                }

                if let commands = try? model.makeFIDOServerCommands() {
                    GroupBox("第 4 步：保存 SSH 别名（可选）") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("把下面内容追加到 ~/.ssh/config，以后可直接执行 ssh \(FIDOServerLogic.normalizedLabel(model.fidoApplicationLabel, fallback: "server"))。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            fidoCommandBlock(
                                title: "SSH Config 片段",
                                detail: "这是配置文本，不是终端命令。",
                                command: commands.sshConfig
                            )
                        }
                        .padding(4)
                    }

                    GroupBox("第 5 步：换电脑、备用卡与丢失处理") {
                        VStack(alignment: .leading, spacing: 8) {
                            if let restore = commands.restoreResident {
                                fidoCommandBlock(
                                    title: "在新电脑恢复驻留密钥句柄",
                                    detail: "插入同一把 YubiKey 后执行；已有同名文件时先备份，命令可能询问是否覆盖。",
                                    command: restore
                                )
                            } else {
                                Text("当前选择的是非驻留密钥。换电脑必须带上原来的句柄文件；ssh-keygen -K 无法恢复它。")
                                    .foregroundStyle(CyberpunkTheme.orange)
                            }
                            Divider()
                            Text("备用 YubiKey：每张卡独立生成一套 FIDO2 SSH 密钥，把两张卡的 .pub 都加入服务器 authorized_keys。不要尝试复制卡内私钥。")
                            Text("YubiKey 丢失：立即使用密码、控制台或备用卡登录服务器，删除丢失卡对应的 authorized_keys 公钥行；然后为新卡生成密钥并重新添加。")
                            Text("驻留密钥的“可恢复”只表示能从同一把卡恢复本地句柄，不代表丢卡后能恢复私钥。关键服务器必须保留独立的应急登录方式。")
                        }
                        .font(.callout)
                        .padding(4)
                    }
                }

                GroupBox("常见问题") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• unknown key type ed25519-sk：当前 ssh-keygen 没有 FIDO 支持；安装 Homebrew OpenSSH，并确认使用的是 /opt/homebrew/bin 或 /usr/local/bin 下的程序。")
                        Text("• Key enrollment failed / device not found：确认 YubiKey 的 FIDO2 接口已启用，并关闭暂时占用设备的程序后重试。")
                        Text("• Permission denied (publickey)：检查服务器账户、authorized_keys 中的公钥，以及文件权限；使用 ssh -vvv 查看详细协商过程。")
                        Text("• PIN 错误：这里需要 FIDO2 PIN，可在 Yubico Authenticator 的 FIDO2 设置中设置或更改；它不是 PIV PIN。")
                        Text("• 旧服务器：服务器端也必须认识 ed25519-sk/ecdsa-sk 公钥类型；过旧 OpenSSH 需要升级。")
                    }
                    .font(.callout)
                    .textSelection(.enabled)
                    .padding(4)
                }
            }
            .padding(4)
            .padding(.bottom, 236)
        }
        .onAppear {
            if model.sshEnvironmentSummary == "尚未检查 OpenSSH 环境" {
                model.refreshSSHEnvironment()
            }
        }
    }

    private func fidoFlowStep(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundStyle(CyberpunkTheme.background)
                .frame(width: 24, height: 24)
                .background(CyberpunkTheme.cyan)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.callout.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fidoTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption.weight(.semibold))
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fidoCommandBlock(title: String, detail: String, command: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.callout.weight(.semibold))
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Button("复制") {
                    model.copyFIDOServerText(command, title: title)
                }
            }
            Text(command)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(CyberpunkTheme.surface.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(CyberpunkTheme.border.opacity(0.72), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CyberpunkTheme.surfaceRaised.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var fidoValidationMessage: String {
        do {
            _ = try model.makeFIDOServerCommands()
            return "请检查服务器信息。"
        } catch {
            return error.localizedDescription
        }
    }

    private var gpgTab: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(GPGSection.allCases, id: \.self) { section in
                    gpgSectionButton(section)
                }
            }
            .padding(4)
            .background(CyberpunkTheme.surfaceRaised.opacity(0.92))
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(CyberpunkTheme.border.opacity(0.75), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 9))

            Divider()

            ScrollView {
                gpgSectionContent
                    .padding(4)
            }
        }
    }

    private func gpgSectionButton(_ section: GPGSection) -> some View {
        let isSelected = selectedGPGSection == section
        return Button {
            selectedGPGSection = section
        } label: {
            HStack(spacing: 8) {
                Image(systemName: section.systemImage)
                Text(section.title)
                Spacer(minLength: 0)
            }
            .font(.callout)
            .fontWeight(isSelected ? .semibold : .regular)
            .frame(maxWidth: .infinity, minHeight: 32, maxHeight: 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, minHeight: 32, maxHeight: 32)
        .contentShape(Rectangle())
        .foregroundStyle(isSelected ? CyberpunkTheme.cyan : CyberpunkTheme.text)
        .background(
            isSelected
                ? CyberpunkTheme.cyan.opacity(0.15)
                : hoveredGPGSection == section
                    ? CyberpunkTheme.violet.opacity(0.14)
                    : CyberpunkTheme.surface.opacity(0.40)
        )
        .overlay(alignment: .bottom) {
            Capsule()
                .fill(isSelected ? CyberpunkTheme.magenta : .clear)
                .frame(height: 2)
                .padding(.horizontal, 12)
                .padding(.bottom, 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .onHover { isHovering in
            hoveredGPGSection = isHovering ? section : nil
            if isHovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        .help(section.title)
    }

    @ViewBuilder
    private var gpgSectionContent: some View {
        switch selectedGPGSection {
        case .overview:
            gpgOverviewContent
        case .keys:
            gpgKeysContent
        case .generate:
            gpgGenerateContent
        case .encrypt:
            gpgEncryptContent
        case .sign:
            gpgSignContent
        case .publish:
            gpgPublishContent
        }
    }

    private var gpgOverviewContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                GroupBox("GPG 环境") {
                    VStack(alignment: .leading, spacing: 7) {
                        Label(
                            model.gpgInstalled ? "GPG 已安装" : "未找到 GPG",
                            systemImage: model.gpgInstalled ? "checkmark.circle.fill" : "xmark.circle.fill"
                        )
                        .foregroundStyle(model.gpgInstalled ? Color.green : Color.orange)
                        Text(model.gpgToolPath ?? "macOS 可执行：brew install gnupg")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                        Text("GPG 负责大文件处理；YubiKey OpenPGP 只负责卡上的私钥运算。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }

                GroupBox("OpenPGP 卡") {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(model.gpgCardSummary == "尚未读取 OpenPGP 卡" ? "尚未读取" : "已读取卡片状态")
                            .font(.headline)
                        HStack(spacing: 8) {
                            Button("读取卡状态") { model.refreshGPGCardStatus() }
                                .buttonStyle(.borderedProminent)
                                .disabled(model.busy)
                            Button("读取本机公钥") { model.refreshGPGKeys() }
                                .disabled(model.busy)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }
            }

            GroupBox("常用流程") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("先准备密钥，再进行文件操作；需要把公钥给别人时，进入“公布公钥”复制或导出。")
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        Button("密钥与卡片") { selectedGPGSection = .keys }
                        Button("本地生成") { selectedGPGSection = .generate }
                        Button("文件加密") { selectedGPGSection = .encrypt }
                        Button("签名验证") { selectedGPGSection = .sign }
                        Button("公布公钥") { selectedGPGSection = .publish }
                    }
                }
                .padding(4)
            }

            GroupBox("当前卡片摘要") {
                Text(model.gpgCardSummary)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(8)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
            }
        }
    }

    private var gpgKeysContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            GroupBox("我的 GPG 身份") {
                VStack(alignment: .leading, spacing: 8) {
                    if !model.gpgSecretKeys.isEmpty {
                        Picker("签名身份", selection: $model.gpgRecipient) {
                            ForEach(model.gpgSecretKeys) { key in
                                Text(key.displayName).tag(key.fingerprint)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    TextField("输入自己的邮箱或完整主密钥指纹", text: $model.gpgRecipient)
                        .textFieldStyle(.roundedBorder)
                    HStack(spacing: 8) {
                        Button("读取公钥和私钥索引") { model.refreshGPGKeys() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                        Button("复制密钥管理步骤") { model.copyGPGKeyManagementSteps() }
                    }
                    Text("这里选择的是你的签名身份。签名时使用你的私钥；对方验证时只需要你的公钥。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }

            GroupBox("收件人公钥库") {
                VStack(alignment: .leading, spacing: 8) {
                    if !model.gpgKeys.isEmpty {
                        Picker("加密给", selection: $model.gpgEncryptRecipient) {
                            Text("请选择收件人公钥").tag("")
                            ForEach(model.gpgKeys) { key in
                                Text(key.displayName).tag(key.fingerprint)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    HStack(spacing: 8) {
                        TextField("输入对方邮箱或完整公钥指纹", text: $model.gpgEncryptRecipient)
                            .textFieldStyle(.roundedBorder)
                        Button("导入公钥…") { model.importGPGPublicKey() }
                            .disabled(model.busy)
                    }
                    Text("电脑上的 GPG 公钥库可以保存很多人的公钥。加密时选择对方公钥；对方用自己的私钥/YubiKey 解密。邮箱只是 User ID，加密前请核对完整指纹。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }

            GroupBox("主密钥与子密钥") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Button("读取密钥结构") { model.refreshGPGKeyDetails() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                        Text("主密钥负责身份与管理；签名、加密、认证通常由子密钥完成。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(model.gpgKeyDetails)
                        .font(.system(size: 10, design: .monospaced))
                        .textSelection(.enabled)
                        .lineLimit(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(CyberpunkTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(CyberpunkTheme.border.opacity(0.72), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("推荐：直接在 YubiKey 上生成；已有电脑密钥时，再通过 gpg --edit-key → keytocard 迁移子密钥。只导入公钥不能恢复私钥，也不能制作备用卡。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }

            GroupBox("YubiKey OpenPGP 密钥") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Button("读取 OpenPGP 卡") { model.refreshGPGCardStatus() }
                            .disabled(model.busy)
                        Button("生成卡上密钥") { model.openGPGCardKeyWizard(replace: false) }
                            .buttonStyle(.borderedProminent)
                        Button("更换卡上密钥…") { model.openGPGCardKeyWizard(replace: true) }
                            .disabled(model.busy)
                        Button("迁移已有子密钥…") { model.openGPGExistingKeyMigrationWizard() }
                            .disabled(model.busy)
                        Button("复制生成步骤") { model.copyOpenPGPSetupSteps() }
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Label("快速步骤", systemImage: "list.number")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CyberpunkTheme.orange)
                        Text("读取卡片 → 在 Terminal 输入 admin → generate → 回到这里读取公钥")
                            .font(.caption)
                        Text("PIN 只在 GnuPG 的安全弹窗中输入，本工具不会记录 PIN。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CyberpunkTheme.orange.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(CyberpunkTheme.orange.opacity(0.32), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 0) {
                        Button {
                            withAnimation(.easeOut(duration: 0.18)) {
                                isGPGPinentryHelpExpanded.toggle()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: isGPGPinentryHelpExpanded ? "chevron.down" : "chevron.right")
                                    .frame(width: 14)
                                Label("PIN 窗口异常修复", systemImage: "wrench.and.screwdriver")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.orange)
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .onHover { isHovering in
                            if isHovering {
                                NSCursor.pointingHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }
                        .help("展开或收起 PIN 窗口异常修复说明")

                        if isGPGPinentryHelpExpanded {
                            VStack(alignment: .leading, spacing: 7) {
                                Text("如果出现“Screen or window too small”，先退出 gpg/card>（输入 q），回到普通 Terminal 后执行：")
                                    .font(.caption)
                                Text("""
                                mkdir -p ~/.gnupg
                                printf '%s\\n' 'pinentry-program /opt/homebrew/bin/pinentry-mac' >> ~/.gnupg/gpg-agent.conf
                                gpgconf --kill gpg-agent
                                """)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                                HStack(spacing: 8) {
                                    Button("复制修复命令") { model.copyGPGPinentryRepairSteps() }
                                    Text("然后重新执行 gpg --card-edit")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text("这只修复 GPG 的 PIN 弹窗，不会清除 OpenPGP 密钥，也不会触碰 PIV 9a/9c/9d/9e。")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 6)
                        }
                    }
                    Text(model.gpgCardSummary)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(8)
                        .textSelection(.enabled)
                }
                .padding(4)
            }

            GroupBox("导出与分发") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Button("复制公钥") { model.copyGPGPublicKey() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                        Button("导出公钥…") { model.exportGPGPublicKey() }
                            .disabled(model.busy)
                    }
                    Text("复制的是自己的 ASCII-armored 公钥，不包含私钥；可以粘贴到邮件正文，或把 .asc 文件交给对方。收件人公钥请在上面的“收件人公钥库”导入。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }

            Text("注意：YubiKey OpenPGP 私钥通常不能导出。更换前请保留旧公钥、主密钥指纹、撤销证书和备用卡方案；这不会重置 PIV 9a/9c/9d/9e。")
                .font(.caption)
                .foregroundStyle(.orange)
        }
    }

    private var gpgGenerateContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            GroupBox("本地生成：建议离线操作") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Button("打开本地生成向导") { model.openLocalGPGKeyGenerationWizard() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                        Button("复制生成步骤") { model.copyGPGLocalGenerationSteps() }
                    }
                    Label("建议先拔出 YubiKey、尽量断网，并在受保护的离线环境生成主密钥。", systemImage: "wifi.slash")
                        .foregroundStyle(CyberpunkTheme.orange)
                    Text("向导会打开 Terminal，让 GnuPG 自己处理姓名、邮箱、密码和随机数。Pivy 不会代替你输入密码，也不会自动导出私钥。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("主密钥用于确认身份和管理子密钥；日常使用的签名、加密、认证功能应分别使用 S/E/A 子密钥。")
                        .font(.callout)
                }
                .padding(4)
            }

            GroupBox("生成顺序") {
                VStack(alignment: .leading, spacing: 8) {
                    generationStep(number: "1", title: "生成主密钥", detail: "执行 gpg --full-generate-key，主密钥只负责身份和管理。")
                    generationStep(number: "2", title: "创建子密钥", detail: "进入 gpg --edit-key，在 gpg> 中用 addkey 创建 Signature、Encryption、Authentication。")
                    generationStep(number: "3", title: "保存恢复材料", detail: "加密保存主密钥/子密钥备份、撤销证书、公钥和完整指纹。")
                    generationStep(number: "4", title: "迁移到 YubiKey", detail: "使用 keytocard 把子密钥放入 YubiKey；主密钥继续留在离线备份中。")
                    Text("不要把生成出来的私钥备份、PIN 或管理密钥放进 GitHub、网盘明文目录或截图。")
                        .font(.caption)
                        .foregroundStyle(CyberpunkTheme.orange)
                }
                .padding(4)
            }

            GroupBox("必须保存的内容") {
                VStack(alignment: .leading, spacing: 6) {
                    Label("加密的主密钥/子密钥备份", systemImage: "externaldrive.badge.lock")
                    Label("主密钥完整指纹和撤销证书", systemImage: "checkmark.seal")
                    Label("ASCII-armored 公钥", systemImage: "person.crop.circle.badge.checkmark")
                    Label("每张 YubiKey 的序列号和用途记录", systemImage: "list.number")
                    Text("公钥可以公开；私钥备份必须离线加密保存。公钥不能恢复丢失的私钥，也不能单独制作备用 YubiKey。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }

            GroupBox("迁移子密钥到 YubiKey") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("这里的“导入”不是导入公钥，而是把本地生成的私钥子密钥迁移到 YubiKey OpenPGP 应用。只导入 public-key.asc 只能验证签名或给别人加密，不能让卡片替你签名或解密。")
                        .font(.callout)
                    HStack(spacing: 8) {
                        Button("打开子密钥迁移向导") { model.openGPGExistingKeyMigrationWizard() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                        Button("复制迁移步骤") { model.copyGPGSubkeyMigrationSteps() }
                        Button("读取密钥结构") { model.refreshGPGKeyDetails() }
                            .disabled(model.busy)
                    }
                    Text("gpg --edit-key <主密钥指纹>\n# gpg> 中：key N → keytocard → 选择 Signature / Encryption / Authentication\n# 完成后：save")
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(CyberpunkTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(CyberpunkTheme.cyan.opacity(0.30), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("迁移前必须完成备份。迁移后主密钥仍应留在离线环境；YubiKey 主要保存 S/E/A 子密钥。")
                        .font(.caption)
                        .foregroundStyle(CyberpunkTheme.orange)
                }
                .padding(4)
            }

            GroupBox("两个方案怎么选") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("直接在 YubiKey 上生成：私钥从生成时就留在卡内，安全性高，但必须准备备用卡或接受卡片丢失后的恢复限制。")
                    Text("本地生成后迁移：主密钥和备份由你离线管理，可以为多张备用卡生成/迁移子密钥，更适合长期使用和密钥轮换。")
                    Text("如果只是学习或演示，建议先使用测试邮箱和测试密钥；正式身份不要在联网的日常电脑上随意生成。")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(4)
            }
        }
        .padding(4)
    }

    private func generationStep(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundStyle(CyberpunkTheme.background)
                .frame(width: 22, height: 22)
                .background(CyberpunkTheme.cyan)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.callout.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var gpgEncryptContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            GroupBox("第 1 步：选择收件人公钥") {
                VStack(alignment: .leading, spacing: 8) {
                    if !model.gpgKeys.isEmpty {
                        Picker("收件人", selection: $model.gpgEncryptRecipient) {
                            Text("请选择收件人公钥").tag("")
                            ForEach(model.gpgKeys) { key in
                                Text(key.displayName).tag(key.fingerprint)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    HStack(spacing: 8) {
                        TextField("对方邮箱或完整公钥指纹", text: $model.gpgEncryptRecipient)
                            .textFieldStyle(.roundedBorder)
                    }
                    Toggle("同时加密给自己（建议开启，方便保留副本）", isOn: $model.gpgEncryptToSelf)
                    Text("公钥读取、网络查询和删除统一在“签名验证”页完成；选中的公钥会自动同步到这里。加密使用对方公钥；对方用自己的私钥/YubiKey 解密。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }

            HStack(alignment: .top, spacing: 10) {
                GroupBox("GPG 大文件加密") {
                    VStack(alignment: .leading, spacing: 8) {
                        DropPanel(
                            title: "待加密文件",
                            prompt: "拖入任意大小的文件",
                            url: model.gpgEncryptFile,
                            choose: model.chooseGPGEncryptFile,
                            receive: { model.gpgEncryptFile = $0 }
                        )
                        HStack(spacing: 8) {
                            Button("GPG 加密") { model.requestGPGEncrypt() }
                                .buttonStyle(.borderedProminent)
                                .disabled(model.busy)
                            Button("签名并加密") { model.requestGPGSignAndEncrypt() }
                                .disabled(model.busy)
                        }
                        Text("输出：原文件.gpg；不受 PIV 8 KB 限制。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(4)
                }

                GroupBox("GPG 大文件解密") {
                    VStack(alignment: .leading, spacing: 8) {
                        DropPanel(
                            title: "待解密文件",
                            prompt: "拖入 .gpg 或 .pgp 文件",
                            url: model.gpgDecryptFile,
                            choose: model.chooseGPGDecryptFile,
                            receive: { model.gpgDecryptFile = $0 }
                        )
                        Button("GPG 解密") { model.requestGPGDecrypt() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                        Text("输出：同目录 .decrypted 文件；PIN 由 GPG Agent 弹窗处理。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(4)
                }
            }
            Text("GPG 使用混合加密：图片、压缩包等大文件由电脑本地对称加密，YubiKey 只保护会话密钥或执行签名。推荐流程：导入对方公钥 → 核对指纹 → 选择文件 → 签名并加密 → 把 .gpg 文件发给对方。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var gpgSignContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            GroupBox("GPG 公钥库：本地优先，缺少时联网查询") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        TextField("邮箱或完整 40 位指纹", text: $model.gpgKeyLookup)
                            .textFieldStyle(.roundedBorder)
                        Button("读取公钥库") { model.refreshGPGKeys() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                        Button("导入 .asc…") { model.importGPGPublicKey() }
                            .disabled(model.busy)
                        Button("删除选中公钥") { model.deleteSelectedGPGPublicKey() }
                            .disabled(model.busy)
                    }
                    if !model.gpgKeys.isEmpty {
                        Picker(
                            "已发现公钥",
                            selection: Binding(
                                get: { model.gpgSelectedPublicKey },
                                set: { value in
                                    model.gpgSelectedPublicKey = value
                                    model.gpgKeyLookup = value
                                    model.gpgEncryptRecipient = value
                                }
                            )
                        ) {
                            Text("请选择公钥").tag("")
                            ForEach(model.gpgKeys) { key in
                                Text(key.displayName).tag(key.fingerprint)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    Text("先查本机 GPG 公钥库；没有匹配时，完整指纹使用 keyserver，邮箱尝试 WKD/keyserver。网络拿到的公钥不会自动等同于可信身份，请核对完整指纹。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("删除只针对本机公钥库，不会删除 YubiKey 或服务器上的公钥；对应私钥存在时程序会拒绝删除。")
                        .font(.caption)
                        .foregroundStyle(CyberpunkTheme.orange)
                }
                .padding(4)
            }

            GroupBox("第 1 步：选择自己的签名身份") {
                VStack(alignment: .leading, spacing: 7) {
                    if !model.gpgSecretKeys.isEmpty {
                        Picker("签名身份", selection: $model.gpgRecipient) {
                            ForEach(model.gpgSecretKeys) { key in
                                Text(key.displayName).tag(key.fingerprint)
                            }
                        }
                        .pickerStyle(.menu)
                    } else {
                        Text("尚未读取本机私钥索引，请先到“GPG 工具 → 密钥与卡片”读取。")
                            .foregroundStyle(.orange)
                    }
                    Text("签名使用你的 YubiKey/OpenPGP 私钥；对方导入你的公钥后即可验证文件来源和完整性。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }

            GroupBox("GPG 文件签名与验证") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 10) {
                        DropPanel(
                            title: "待签名文件",
                            prompt: "拖入任意文件",
                            url: model.gpgSignFile,
                            choose: model.chooseGPGSignFile,
                            receive: { model.gpgSignFile = $0 }
                        )
                        DropPanel(
                            title: "验证原文件",
                            prompt: "拖入原文件",
                            url: model.gpgVerifyFile,
                            choose: model.chooseGPGVerifyFile,
                            receive: { model.gpgVerifyFile = $0 }
                        )
                        DropPanel(
                            title: "GPG 签名",
                            prompt: "拖入 .asc/.sig",
                            url: model.gpgVerifySignatureFile,
                            choose: model.chooseGPGVerifySignatureFile,
                            receive: { model.gpgVerifySignatureFile = $0 }
                        )
                    }
                    HStack(spacing: 8) {
                        Button("GPG 签名") { model.requestGPGSign() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                        Button("验证 GPG 签名") { model.requestGPGVerify() }
                            .disabled(model.busy)
                        Text("签名和验证都支持大文件；YubiKey 私钥由 GPG Agent 调用。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(4)
            }
            Text("签名验证只能证明文件与签名匹配；是否信任签名人，还要通过指纹、线下渠道或可信密钥服务器核对。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var gpgPublishContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            GroupBox("公布邮箱公钥") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        TextField("你的邮箱或完整公钥指纹", text: $model.gpgRecipient)
                            .textFieldStyle(.roundedBorder)
                        Button("复制公钥") { model.copyGPGPublicKey() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                        Button("导出 .asc…") { model.exportGPGPublicKey() }
                            .disabled(model.busy)
                    }
                    Text("最简单的公布方式：复制 ASCII-armored 公钥，粘贴到邮件正文或个人网站，并附上完整指纹。")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }

            GroupBox("发布到公共密钥服务器") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("服务器")
                        TextField("hkps://keys.openpgp.org", text: $model.gpgKeyserver)
                            .textFieldStyle(.roundedBorder)
                        Button("发布公钥…") { model.publishGPGPublicKey() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                    }
                    Text("发布会产生公开网络记录，按钮会再次显示指纹并要求确认。keys.openpgp.org 通常还需要按验证邮件确认邮箱，之后别人才能按邮箱查找。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }

            GroupBox("给对方的核对信息") {
                VStack(alignment: .leading, spacing: 7) {
                    Text("1. 公钥：用“复制公钥”或“导出 .asc”发送。")
                    Text("2. 指纹：用 gpg --fingerprint 或本工具的日志查看，走另一条可信渠道发送。")
                    Text("3. 对方导入后：gpg --import public-key.asc；再核对指纹，最后才用于加密。")
                }
                .font(.callout)
                .textSelection(.enabled)
                .padding(4)
            }
        }
    }

    private var legacyGPGTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                GroupBox("OpenPGP 公钥") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            TextField("输入收件人邮箱或公钥指纹", text: $model.gpgRecipient)
                                .textFieldStyle(.roundedBorder)
                            Button("读取公钥") { model.refreshGPGKeys() }
                                .disabled(model.busy)
                        }
                        if !model.gpgKeys.isEmpty {
                            Picker("已发现公钥", selection: $model.gpgRecipient) {
                                ForEach(model.gpgKeys) { key in
                                    Text(key.fingerprint).tag(key.fingerprint)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        Text(model.gpgInstalled
                             ? "GPG 已找到：\(model.gpgToolPath ?? "")；大文件由电脑本地处理，YubiKey 只保护 OpenPGP 私钥。"
                             : "未找到 GPG。安装后重启本工具：brew install gnupg")
                            .font(.caption)
                            .foregroundStyle(model.gpgInstalled ? Color.secondary : Color.orange)
                    }
                    .padding(4)
                }

                GroupBox("OpenPGP 密钥准备") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Button("读取 OpenPGP 卡") { model.refreshGPGCardStatus() }
                                .disabled(model.busy)
                            Button("导出公钥…") { model.exportGPGPublicKey() }
                                .disabled(model.busy)
                            Button("复制生成步骤") { model.copyOpenPGPSetupSteps() }
                        }
                        Text("公钥不是单独创建的：先在 OpenPGP 卡上生成密钥对，再把公钥导出给收件人或服务器。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(model.gpgCardSummary)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .lineLimit(5)
                            .textSelection(.enabled)
                    }
                    .padding(4)
                }

                HStack(alignment: .top, spacing: 10) {
                    GroupBox("GPG 大文件加密") {
                        VStack(alignment: .leading, spacing: 8) {
                            DropPanel(
                                title: "待加密文件",
                                prompt: "拖入任意大小的文件",
                                url: model.gpgEncryptFile,
                                choose: model.chooseGPGEncryptFile,
                                receive: { model.gpgEncryptFile = $0 }
                            )
                            Button("GPG 加密") { model.requestGPGEncrypt() }
                                .buttonStyle(.borderedProminent)
                                .disabled(model.busy)
                            Text("输出：原文件.gpg；不受 PIV 8 KB 限制。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(4)
                    }

                    GroupBox("GPG 大文件解密") {
                        VStack(alignment: .leading, spacing: 8) {
                            DropPanel(
                                title: "待解密文件",
                                prompt: "拖入 .gpg 或 .pgp 文件",
                                url: model.gpgDecryptFile,
                                choose: model.chooseGPGDecryptFile,
                                receive: { model.gpgDecryptFile = $0 }
                            )
                            Button("GPG 解密") { model.requestGPGDecrypt() }
                                .buttonStyle(.borderedProminent)
                                .disabled(model.busy)
                            Text("输出：同目录 .decrypted 文件；PIN 由 GPG Agent 弹窗处理。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(4)
                    }
                }

                GroupBox("GPG 文件签名与验证") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 10) {
                            DropPanel(
                                title: "待签名文件",
                                prompt: "拖入任意文件",
                                url: model.gpgSignFile,
                                choose: model.chooseGPGSignFile,
                                receive: { model.gpgSignFile = $0 }
                            )
                            DropPanel(
                                title: "验证原文件",
                                prompt: "拖入原文件",
                                url: model.gpgVerifyFile,
                                choose: model.chooseGPGVerifyFile,
                                receive: { model.gpgVerifyFile = $0 }
                            )
                            DropPanel(
                                title: "GPG 签名",
                                prompt: "拖入 .asc/.sig",
                                url: model.gpgVerifySignatureFile,
                                choose: model.chooseGPGVerifySignatureFile,
                                receive: { model.gpgVerifySignatureFile = $0 }
                            )
                        }
                        HStack(spacing: 8) {
                            Button("GPG 签名") { model.requestGPGSign() }
                                .buttonStyle(.borderedProminent)
                                .disabled(model.busy)
                            Button("验证 GPG 签名") { model.requestGPGVerify() }
                                .disabled(model.busy)
                            Text("签名和验证都支持大文件；YubiKey 私钥由 GPG Agent 调用。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(4)
                }

                Text("说明：GPG 使用混合加密，文件本体由 AES 等对称算法处理，YubiKey 只处理会话密钥或签名私钥。GPG PIN 不会进入本工具日志。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(4)
        }
    }

    private var certificateToolsTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            GroupBox("槽位") {
                HStack(spacing: 10) {
                    Picker("PIV 槽位", selection: $model.selectedSlot) {
                        ForEach(model.availableSlots, id: \.self) { slot in
                            Text("\(slot) · \(model.slotLabel(slot))")
                                .tag(slot)
                        }
                    }
                    .pickerStyle(.menu)
                    Text("常用：9a 身份认证 · 9c 签名 · 9d 密钥管理 · 9e 卡片认证")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }

            HStack(spacing: 10) {
                Button("导出 SSH 公钥") { model.exportPublicKey() }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.busy)
                Button("导出证书") { model.exportCertificate() }
                    .disabled(model.busy)
                Button("槽位证明") { model.requestAttestation() }
                    .disabled(model.busy)
                Button("测试槽位") { model.requestSlotAuth() }
                    .disabled(model.busy)
            }

            GroupBox("服务器认证：生成 CSR") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("CSR 的 CN")
                        TextField("例如 server.example.com", text: $model.csrCommonName)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Button("生成 CSR") { model.requestCSR() }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.busy)
                        Text("会弹出 PIN 输入框，输出 .csr.pem，可交给你的 CA 签发服务器证书。")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(4)
            }

            Text("不会在这里加入初始化、改 PIN、改 PUK、导入私钥或恢复出厂按钮；这些操作会改变卡片状态，避免误触。")
                .font(.caption)
                .foregroundStyle(.orange)
        }
        .padding(4)
    }
}

@main
struct PivyShellApp: App {
    @NSApplicationDelegateAdaptor(PivyShellAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup("Pivy YubiKey 本地工具") {
            ContentView()
        }
    }
}
