import Foundation

struct OpenSSHVersion: Equatable, Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int

    var description: String { "\(major).\(minor)" }

    static func < (lhs: OpenSSHVersion, rhs: OpenSSHVersion) -> Bool {
        lhs.major == rhs.major ? lhs.minor < rhs.minor : lhs.major < rhs.major
    }
}

struct OpenSSHCapabilities: Equatable {
    let supportsSecurityKeys: Bool
    let supportsResidentKeyRecovery: Bool
    let supportsVerifyRequired: Bool
}

enum FIDOKeyAlgorithm: String, CaseIterable, Identifiable {
    case ed25519
    case ecdsa

    var id: String { rawValue }
    var keyType: String { "\(rawValue)-sk" }

    var title: String {
        switch self {
        case .ed25519: return "Ed25519（推荐，YubiKey 5.2.3+）"
        case .ecdsa: return "ECDSA（兼容旧款 FIDO2 YubiKey）"
        }
    }
}

struct FIDOServerConfiguration: Equatable {
    let algorithm: FIDOKeyAlgorithm
    let resident: Bool
    let verifyRequired: Bool
    let comment: String
    let keyName: String
    let applicationLabel: String
    let username: String
    let host: String
}

struct FIDOServerCommands: Equatable {
    let generate: String
    let inspectSupport: String
    let installPublicKey: String
    let installPublicKeyFallback: String
    let login: String
    let sshConfig: String
    let restoreResident: String?
}

enum FIDOServerValidationError: Error, Equatable, LocalizedError {
    case invalidUsername
    case invalidHost

    var errorDescription: String? {
        switch self {
        case .invalidUsername:
            return "Linux 用户名只能包含字母、数字、点、下划线和连字符，且不能以数字开头。"
        case .invalidHost:
            return "服务器地址只能填写域名或 IP 地址，不能包含空格、@、斜杠或命令字符。"
        }
    }
}

enum FIDOServerLogic {
    static func parseOpenSSHVersion(_ output: String) -> OpenSSHVersion? {
        guard let range = output.range(of: #"OpenSSH[_ ]([0-9]+)\.([0-9]+)"#, options: .regularExpression) else {
            return nil
        }
        let match = String(output[range])
        guard let numberRange = match.range(of: #"[0-9]+\.[0-9]+"#, options: .regularExpression) else {
            return nil
        }
        let fields = match[numberRange].split(separator: ".")
        guard fields.count == 2, let major = Int(fields[0]), let minor = Int(fields[1]) else {
            return nil
        }
        return OpenSSHVersion(major: major, minor: minor)
    }

    static func capabilities(for version: OpenSSHVersion) -> OpenSSHCapabilities {
        OpenSSHCapabilities(
            supportsSecurityKeys: version >= OpenSSHVersion(major: 8, minor: 2),
            supportsResidentKeyRecovery: version >= OpenSSHVersion(major: 8, minor: 3),
            supportsVerifyRequired: version >= OpenSSHVersion(major: 8, minor: 4)
        )
    }

    static func reportsSecurityKeyTypes(_ output: String) -> Bool {
        output.split(whereSeparator: \.isNewline).contains { line in
            line.hasPrefix("sk-") || line.contains("-sk@")
        }
    }

    static func commands(
        for configuration: FIDOServerConfiguration,
        sshCommand: String = "ssh",
        sshKeygenCommand: String = "ssh-keygen",
        sshCopyIDCommand: String = "ssh-copy-id"
    ) throws -> FIDOServerCommands {
        let username = configuration.username.trimmingCharacters(in: .whitespacesAndNewlines)
        let host = configuration.host.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidUsername(username) else { throw FIDOServerValidationError.invalidUsername }
        guard isValidHost(host) else { throw FIDOServerValidationError.invalidHost }

        let keyLabel = normalizedLabel(configuration.keyName, fallback: "server")
        let applicationLabel = normalizedLabel(configuration.applicationLabel, fallback: keyLabel)
        let keyPath = "~/.ssh/id_\(configuration.algorithm.keyType.replacingOccurrences(of: "-", with: "_"))_\(keyLabel)"
        let target = "\(username)@\(host)"

        var generationParts = [sshKeygenCommand, "-t", configuration.algorithm.keyType]
        if configuration.resident {
            generationParts += ["-O", "resident"]
        }
        if configuration.verifyRequired {
            generationParts += ["-O", "verify-required"]
        }
        generationParts += [
            "-O", "application=ssh:\(applicationLabel)",
            "-C", shellQuote(configuration.comment.trimmingCharacters(in: .whitespacesAndNewlines)),
            "-f", keyPath
        ]

        let alias = normalizedLabel(applicationLabel, fallback: "yubikey-server")
        return FIDOServerCommands(
            generate: generationParts.joined(separator: " "),
            inspectSupport: "\(sshCommand) -V && \(sshCommand) -Q key | grep '^sk-'",
            installPublicKey: "\(sshCopyIDCommand) -i \(keyPath).pub \(target)",
            installPublicKeyFallback: "cat \(keyPath).pub | \(sshCommand) \(target) 'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'",
            login: "\(sshCommand) -i \(keyPath) \(target)",
            sshConfig: """
            Host \(alias)
              HostName \(host)
              User \(username)
              IdentityFile \(keyPath)
              IdentitiesOnly yes
            """,
            restoreResident: configuration.resident ? "mkdir -p ~/.ssh && cd ~/.ssh && \(sshKeygenCommand) -K" : nil
        )
    }

    static func normalizedLabel(_ value: String, fallback: String) -> String {
        let lowered = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var result = ""
        var lastWasSeparator = false
        for scalar in lowered.unicodeScalars {
            let isASCIIAlphaNumeric = (48...57).contains(scalar.value)
                || (97...122).contains(scalar.value)
            if isASCIIAlphaNumeric || scalar == "_" {
                result.unicodeScalars.append(scalar)
                lastWasSeparator = false
            } else if !lastWasSeparator && !result.isEmpty {
                result.append("-")
                lastWasSeparator = true
            }
        }
        let normalized = result.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return normalized.isEmpty ? fallback : normalized
    }

    static func shellQuote(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }

    private static func isValidUsername(_ value: String) -> Bool {
        value.range(of: #"^[A-Za-z_][A-Za-z0-9._-]*$"#, options: .regularExpression) != nil
    }

    private static func isValidHost(_ value: String) -> Bool {
        guard !value.isEmpty, !value.contains("@") else { return false }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-:[]")
        return value.unicodeScalars.allSatisfy(allowed.contains)
    }
}
