import Foundation

struct GPGValidSignature: Equatable {
    let signingFingerprint: String
    let primaryFingerprint: String?
}

enum GPGVerificationVerdict: Equatable {
    case verified(signingFingerprint: String, primaryFingerprint: String?)
    case signatureValidWrongKey(signingFingerprint: String, primaryFingerprint: String?)
    case invalidSignature
    case missingFingerprint
}

enum GPGVerificationLogic {
    static func normalizeFingerprint(_ value: String) -> String {
        let hex = value.unicodeScalars.filter { scalar in
            switch scalar.value {
            case 48...57, 65...70, 97...102:
                return true
            default:
                return false
            }
        }
        return String(String.UnicodeScalarView(hex)).uppercased()
    }

    static func fingerprintMatches(expected: String, actual: String) -> Bool {
        normalizeFingerprint(expected) == normalizeFingerprint(actual)
    }

    static func validSignature(from statusOutput: String) -> GPGValidSignature? {
        let prefix = "[GNUPG:] VALIDSIG "
        for line in statusOutput.split(whereSeparator: \.isNewline) {
            guard line.hasPrefix(prefix) else { continue }
            let fields = line.dropFirst(prefix.count)
                .split(whereSeparator: { $0 == " " || $0 == "\t" })
            guard let signingFingerprint = fields.first else { continue }
            let primaryFingerprint = fields.count >= 7 ? fields.last : nil
            return GPGValidSignature(
                signingFingerprint: normalizeFingerprint(String(signingFingerprint)),
                primaryFingerprint: primaryFingerprint.map { normalizeFingerprint(String($0)) }
            )
        }
        return nil
    }

    static func importedFingerprints(from colonOutput: String) -> [String] {
        colonOutput
            .split(whereSeparator: \.isNewline)
            .filter { $0.hasPrefix("fpr:") }
            .compactMap { line in
                let fields = line.split(separator: ":", omittingEmptySubsequences: false)
                guard fields.count > 9 else { return nil }
                return normalizeFingerprint(String(fields[9]))
            }
    }

    static func verdict(
        exitStatus: Int,
        statusOutput: String,
        expectedFingerprint: String
    ) -> GPGVerificationVerdict {
        guard exitStatus == 0 else { return .invalidSignature }
        guard let signature = validSignature(from: statusOutput) else { return .missingFingerprint }

        let expected = normalizeFingerprint(expectedFingerprint)
        if signature.signingFingerprint == expected || signature.primaryFingerprint == expected {
            return .verified(
                signingFingerprint: signature.signingFingerprint,
                primaryFingerprint: signature.primaryFingerprint
            )
        }
        return .signatureValidWrongKey(
            signingFingerprint: signature.signingFingerprint,
            primaryFingerprint: signature.primaryFingerprint
        )
    }
}

struct GPGKeyLookupCandidate: Equatable {
    let fingerprint: String
    let userID: String
}

enum GPGKeyLookupLogic {
    static func localMatch(
        query: String,
        candidates: [GPGKeyLookupCandidate]
    ) -> GPGKeyLookupCandidate? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalizedQuery = GPGVerificationLogic.normalizeFingerprint(trimmed)
        if isFullFingerprintQuery(trimmed) {
            return candidates.first {
                GPGVerificationLogic.normalizeFingerprint($0.fingerprint) == normalizedQuery
            }
        }

        let lowercasedQuery = trimmed.lowercased()
        return candidates.first {
            $0.userID.lowercased().contains(lowercasedQuery)
        }
    }

    static func remoteArguments(query: String, keyserver: String) -> [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if isFullFingerprintQuery(trimmed) {
            return [
                "--batch", "--keyserver", keyserver,
                "--recv-keys", GPGVerificationLogic.normalizeFingerprint(trimmed)
            ]
        }
        return [
            "--batch", "--keyserver", keyserver,
            "--auto-key-locate", "clear,wkd,keyserver",
            "--locate-keys", trimmed
        ]
    }

    static func isFullFingerprintQuery(_ query: String) -> Bool {
        let normalized = GPGVerificationLogic.normalizeFingerprint(query)
        let hasOnlyHexAndSeparators = query.unicodeScalars.allSatisfy { scalar in
            switch scalar.value {
            case 48...57, 65...70, 97...102, 32, 9:
                return true
            default:
                return false
            }
        }
        return hasOnlyHexAndSeparators && normalized.count == 40
    }
}
