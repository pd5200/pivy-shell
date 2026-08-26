import Foundation

@main
struct GPGVerificationTests {
    private static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        guard condition() else {
            fputs("FAIL: \(message)\n", stderr)
            exit(1)
        }
    }

    static func main() {
        let expected = "5069A233D55A0EEB174A5FC3821ACD02680D16DE"
        let spaced = "5069 A233 D55A 0EEB 174A 5FC3 821A CD02 680D 16DE"

        check(
            GPGVerificationLogic.normalizeFingerprint(spaced) == expected,
            "fingerprints should ignore spaces and normalize case"
        )

        let preview = "pub:-:2048:1:ABCDEF:::u:::VeraCrypt:\nfpr:::::::::\(expected):\nsub:-:2048:1:123456:::::::::\nfpr:::::::::\(String(repeating: "C", count: 40)):\n"
        check(
            GPGVerificationLogic.importedFingerprints(from: preview) == [
                expected,
                String(repeating: "C", count: 40)
            ],
            "colon import preview should expose every key fingerprint"
        )

        let primarySignatureStatus = """
        [GNUPG:] GOODSIG \(expected) VeraCrypt
        [GNUPG:] VALIDSIG \(expected) 20260826 1787702400 0 1 10 00 \(expected)
        """
        check(
            GPGVerificationLogic.verdict(
                exitStatus: 0,
                statusOutput: primarySignatureStatus,
                expectedFingerprint: expected
            ) == .verified(signingFingerprint: expected, primaryFingerprint: expected),
            "a valid signature from the expected primary key should verify"
        )

        let signingSubkey = String(repeating: "A", count: 40)
        let subkeySignatureStatus = "[GNUPG:] VALIDSIG \(signingSubkey) 20260826 1787702400 0 1 10 00 \(expected)\n"
        check(
            GPGVerificationLogic.verdict(
                exitStatus: 0,
                statusOutput: subkeySignatureStatus,
                expectedFingerprint: expected
            ) == .verified(signingFingerprint: signingSubkey, primaryFingerprint: expected),
            "a valid signing subkey should verify through its expected primary key"
        )

        let wrongFingerprint = String(repeating: "B", count: 40)
        let wrongKeyStatus = "[GNUPG:] VALIDSIG \(wrongFingerprint) 20260826 1787702400 0 1 10 00 \(wrongFingerprint)\n"
        check(
            GPGVerificationLogic.verdict(
                exitStatus: 0,
                statusOutput: wrongKeyStatus,
                expectedFingerprint: expected
            ) == .signatureValidWrongKey(signingFingerprint: wrongFingerprint, primaryFingerprint: wrongFingerprint),
            "a mathematically valid signature from another key must not be accepted"
        )

        check(
            GPGVerificationLogic.verdict(
                exitStatus: 2,
                statusOutput: primarySignatureStatus,
                expectedFingerprint: expected
            ) == .invalidSignature,
            "a non-zero gpg status must be treated as an invalid signature"
        )

        check(
            GPGVerificationLogic.verdict(
                exitStatus: 0,
                statusOutput: "[GNUPG:] GOODSIG \(expected) VeraCrypt\n",
                expectedFingerprint: expected
            ) == .missingFingerprint,
            "without VALIDSIG the app must not claim official verification"
        )

        print("GPG verification tests passed")
    }
}
