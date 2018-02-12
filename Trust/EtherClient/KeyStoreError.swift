// Copyright SIX DAY LLC. All rights reserved.

import Foundation

public enum KeystoreError: LocalizedError {
    case failedToDeleteAccount
    case failedToDecryptKey
    case failedToImport(Error)
    case duplicateAccount
    case failedToSignTransaction
    case failedToUpdatePassword
    case failedToCreateWallet
    case failedToImportPrivateKey
    case failedToParseJSON
    case accountNotFound
    case failedToSignMessage

    public var errorDescription: String? {
        switch self {
        case .failedToDeleteAccount:
            return "Failed to delete account"
        case .failedToDecryptKey:
            return "Could not decrypt key with given passphrase"
        case .failedToImport(let error):
            return error.localizedDescription
        case .duplicateAccount:
            return "You already added this address to wallets"
        case .failedToSignTransaction:
            return "Failed to sign transaction"
        case .failedToUpdatePassword:
            return "Failed to update password"
        case .failedToCreateWallet:
            return "Failed to create wallet"
        case .failedToImportPrivateKey:
            return "Failed to import private key"
        case .failedToParseJSON:
            return "Failed to parse key JSON"
        case .accountNotFound:
            return "Account not found"
        case .failedToSignMessage:
            return "Failed to sign message"
        }
    }
}
