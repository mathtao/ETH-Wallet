//
//  EthWallet+Account.swift
//  ETHWallet

import web3swift
import Web3Core
import SwiftKeychainWrapper

extension EthWallet {
    
    public var mnemonics: String? {
        get {
            return KeychainWrapper.standard.string(forKey: mnemonicsKeystoreKey)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: mnemonicsKeystoreKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: mnemonicsKeystoreKey)
            }
        }
    }
    
    public var password: String? {
        get {
            return KeychainWrapper.standard.string(forKey: passwordKeystoreKey)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: passwordKeystoreKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: passwordKeystoreKey)
            }
        }
    }
}

extension EthWallet {
    
    public func loadAllKeystore() throws -> [AbstractKeystore] {
        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw WalletError.invalidPath
        }
        
        var list = [AbstractKeystore]()
        guard let keystoreManager = KeystoreManager.managerForPath(userDir + keystoreDirectoryName, scanForHDwallets: true) else {
            throw WalletError.malformedKeystore
        }
        list += keystoreManager.bip32keystores
        if let keystoreManager = KeystoreManager.managerForPath(userDir + keystoreDirectoryName) {
            list += keystoreManager.keystores
        }
        
        return list
    }
    
}

extension EthWallet {
    
    public func verifyPassword(_ password: String) -> Bool {
        return (try? privateKey(password: password)) != nil
    }
    
    private func privateKey(password: String) throws -> String {
        let keystore = try loadKeystore()
        guard let ethereumAddress = keystore.addresses?.first else {
            throw WalletError.invalidAddress
        }
        let privateKeyData = try keystore.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
        
        return privateKeyData.toHexString()
    }
    
    private func loadKeystore() throws -> BIP32Keystore {
        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw WalletError.invalidPath
        }
        guard let keystoreManager = KeystoreManager.managerForPath(userDir + keystoreDirectoryName, scanForHDwallets: true) else {
            throw WalletError.malformedKeystore
        }
        guard let address = keystoreManager.addresses?.first else {
            throw WalletError.malformedKeystore
        }
        guard let keystore = keystoreManager.walletForAddress(address) as? BIP32Keystore else {
            throw WalletError.malformedKeystore
        }
        
        return keystore
    }
}

extension EthWallet {
    // 助记词 导入
    public func importAccount(mnemonics: String, password: String, name: String) throws {
        guard let keystore = (try? BIP32Keystore(mnemonics: mnemonics, password: password)) ?? nil else {
            throw WalletError.invalidMnemonics
        }
        
        try saveBIP32Keystore(keystore, name: name, isFirst: true)
        self.mnemonics = mnemonics
        self.password = password
    }
    
    public func createNewChildAccount(password: String, name: String) throws {
        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw WalletError.invalidPath
        }
        guard let keystoreManager = KeystoreManager.managerForPath(userDir + keystoreDirectoryName, scanForHDwallets: true) else {
            throw WalletError.malformedKeystore
        }
        guard let keystore = keystoreManager.bip32keystores.first else {
            throw WalletError.malformedKeystore
        }
        try keystore.createNewChildAccount(password: password)
        
        try saveBIP32Keystore(keystore, name: name, isFirst: false)
    }
    
    public func saveBIP32Keystore(_ keystore: BIP32Keystore, name: String, isFirst: Bool, needUpdateDB: Bool = true) throws {
        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw WalletError.invalidPath
        }
        guard let keystoreParams = keystore.keystoreParams else {
            throw WalletError.malformedKeystore
        }
        guard let keystoreData = try? JSONEncoder().encode(keystoreParams) else {
            throw WalletError.malformedKeystore
        }
        if !FileManager.default.fileExists(atPath: userDir + keystoreDirectoryName) {
            do {
                try FileManager.default.createDirectory(atPath: userDir + keystoreDirectoryName, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw WalletError.invalidPath
            }
        }
        
        FileManager.default.createFile(atPath: userDir + keystoreDirectoryName + "/" + keystoreFileName, contents: keystoreData, attributes: nil)
        
        
        /// 保存数据库  model wallet
        if needUpdateDB == true {
            if let add = keystore.addresses?.last {
                //MARK: TODO
                
            }
        }
    }
    
}

extension EthWallet {
    // 私钥 导入
    public func importAccount(privateKey: String, password: String, name: String) throws {
        guard let privateKeyData = Data.fromHex(privateKey) else {
            throw WalletError.invalidKey
        }
        guard let keystore = try EthereumKeystoreV3(privateKey: privateKeyData, password: password) else {
            throw WalletError.malformedKeystore
        }
        //MARK: TODO
        
        try saveKeystore(keystore, name: name)
    }
    
    public func saveKeystore(_ keystore: EthereumKeystoreV3, name: String, needUpdateDB: Bool = true, walletId: Int = 0) throws {
        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw WalletError.invalidPath
        }
        guard let keystoreParams = keystore.keystoreParams else {
            throw WalletError.malformedKeystore
        }
        guard let keystoreData = try? JSONEncoder().encode(keystoreParams) else {
            throw WalletError.malformedKeystore
        }
        if !FileManager.default.fileExists(atPath: userDir + keystoreDirectoryName) {
            do {
                try FileManager.default.createDirectory(atPath: userDir + keystoreDirectoryName, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw WalletError.invalidPath
            }
        }
        
        if needUpdateDB == false {
            FileManager.default.createFile(atPath: userDir + keystoreDirectoryName + "/\(walletId)" + keystoreFileName, contents: keystoreData, attributes: nil)
        }else {
            var id = 0
            //操作数据库
            //MARK: TODO
            id += 1
            
            FileManager.default.createFile(atPath: userDir + keystoreDirectoryName + "/\(id)" + keystoreFileName, contents: keystoreData, attributes: nil)
            
            /// 保存数据库  model wallet
            let wallet = Wallet(id: id, address: keystore.getAddress()?.address ?? "0x", data: keystoreData, name: name, isHD: false, date: Date(), isSelect: false, isImport: true)
            //MARK: TODO
            
        }
    }
    
    
}

