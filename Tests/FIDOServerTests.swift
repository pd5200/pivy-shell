import Foundation

@main
struct FIDOServerTests {
    private static func check(_ condition: @autoclosure () -> Bool, _ message: String) {
        guard condition() else {
            fputs("FAIL: \(message)\n", stderr)
            exit(1)
        }
    }

    static func main() {
        let current = FIDOServerLogic.parseOpenSSHVersion("OpenSSH_9.9p1, LibreSSL 3.3.6")
        check(current == OpenSSHVersion(major: 9, minor: 9), "OpenSSH version output should be parsed")

        let unsupported = FIDOServerLogic.capabilities(for: OpenSSHVersion(major: 8, minor: 1))
        check(!unsupported.supportsSecurityKeys, "OpenSSH before 8.2 must not be reported as FIDO capable")

        let base = FIDOServerLogic.capabilities(for: OpenSSHVersion(major: 8, minor: 2))
        check(base.supportsSecurityKeys, "OpenSSH 8.2 should support security-key key types")
        check(!base.supportsResidentKeyRecovery, "OpenSSH 8.2 should not advertise ssh-keygen -K")
        check(!base.supportsVerifyRequired, "OpenSSH 8.2 should not advertise verify-required")

        let complete = FIDOServerLogic.capabilities(for: OpenSSHVersion(major: 8, minor: 4))
        check(complete.supportsSecurityKeys, "OpenSSH 8.4 should support security-key key types")
        check(complete.supportsResidentKeyRecovery, "OpenSSH 8.4 should support resident-key recovery")
        check(complete.supportsVerifyRequired, "OpenSSH 8.4 should support verify-required")

        check(
            FIDOServerLogic.reportsSecurityKeyTypes("ssh-ed25519\nsk-ssh-ed25519@openssh.com\nsk-ecdsa-sha2-nistp256@openssh.com\n"),
            "OpenSSH sk-* query output should be recognized as FIDO capable"
        )
        check(
            !FIDOServerLogic.reportsSecurityKeyTypes("ssh-ed25519\necdsa-sha2-nistp256\n"),
            "ordinary key types must not be mistaken for FIDO security-key support"
        )

        let configuration = FIDOServerConfiguration(
            algorithm: .ed25519,
            resident: true,
            verifyRequired: true,
            comment: "admin@example.com",
            keyName: "production",
            applicationLabel: "prod-server",
            username: "deploy",
            host: "server.example.com"
        )
        let commands = try! FIDOServerLogic.commands(for: configuration)
        check(
            commands.generate == "ssh-keygen -t ed25519-sk -O resident -O verify-required -O application=ssh:prod-server -C 'admin@example.com' -f ~/.ssh/id_ed25519_sk_production",
            "resident generation should include resident, PIN verification, application label and a safe filename"
        )
        check(
            commands.installPublicKey == "ssh-copy-id -i ~/.ssh/id_ed25519_sk_production.pub deploy@server.example.com",
            "public-key installation should target the selected Linux account"
        )
        check(
            commands.login == "ssh -i ~/.ssh/id_ed25519_sk_production deploy@server.example.com",
            "login should use the generated key handle"
        )
        check(
            commands.restoreResident == "mkdir -p ~/.ssh && cd ~/.ssh && ssh-keygen -K",
            "resident keys should expose the recovery command"
        )
        check(
            commands.sshConfig.contains("IdentityFile ~/.ssh/id_ed25519_sk_production"),
            "SSH config should refer to the generated key handle"
        )
        check(
            commands.inspectSupport == "ssh -V && ssh -Q key | grep '^sk-'",
            "the diagnostic command should match the sk-* names printed by OpenSSH"
        )

        let homebrewCommands = try! FIDOServerLogic.commands(
            for: configuration,
            sshCommand: "/opt/homebrew/bin/ssh",
            sshKeygenCommand: "/opt/homebrew/bin/ssh-keygen",
            sshCopyIDCommand: "/opt/homebrew/bin/ssh-copy-id"
        )
        check(
            homebrewCommands.generate.hasPrefix("/opt/homebrew/bin/ssh-keygen "),
            "generation should use the detected FIDO-capable ssh-keygen executable"
        )
        check(
            homebrewCommands.installPublicKey.hasPrefix("/opt/homebrew/bin/ssh-copy-id "),
            "public-key installation should use the matching OpenSSH installation"
        )
        check(
            homebrewCommands.login.hasPrefix("/opt/homebrew/bin/ssh "),
            "login should use the detected FIDO-capable ssh executable"
        )

        let nonResident = FIDOServerConfiguration(
            algorithm: .ecdsa,
            resident: false,
            verifyRequired: false,
            comment: "O'Reilly laptop",
            keyName: "legacy host",
            applicationLabel: "legacy host",
            username: "ubuntu",
            host: "192.0.2.10"
        )
        let nonResidentCommands = try! FIDOServerLogic.commands(for: nonResident)
        check(!nonResidentCommands.generate.contains("-O resident"), "non-resident generation must omit the resident option")
        check(!nonResidentCommands.generate.contains("-O verify-required"), "touch-only generation must omit verify-required")
        check(nonResidentCommands.restoreResident == nil, "non-resident keys cannot be recovered with ssh-keygen -K")
        check(nonResidentCommands.generate.contains("-C 'O'\\''Reilly laptop'"), "comments must be safely shell quoted")
        check(nonResidentCommands.generate.contains("id_ecdsa_sk_legacy-host"), "unsafe filename characters should be normalized")

        do {
            _ = try FIDOServerLogic.commands(for: FIDOServerConfiguration(
                algorithm: .ed25519,
                resident: true,
                verifyRequired: true,
                comment: "admin@example.com",
                keyName: "production",
                applicationLabel: "production",
                username: "root;rm",
                host: "server.example.com"
            ))
            check(false, "unsafe usernames must be rejected")
        } catch {
            check(error as? FIDOServerValidationError == .invalidUsername, "unsafe usernames should return a precise validation error")
        }

        print("FIDO server tests passed")
    }
}
