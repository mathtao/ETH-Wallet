//
//  EthWallet.swift
//  ETHWallet

import web3swift
import Web3Core
import BigInt

public final class EthWallet {

    var infuraUrl = URL_ETH
    var web3Manager: Web3
    let keystoreDirectoryName = "/keystore"
    let keystoreFileName = "key.json"
    let mnemonicsKeystoreKey = "mnemonicsKeystoreKey"
    let passwordKeystoreKey = "passwordKeystoreKey"
    
    public static let share = EthWallet()

    public init() {
        if let model = CustomNetwork.shared.preferredNetwork() {
            let infuraUrl = model.fullNetworkUrl.absoluteString
            self.infuraUrl = infuraUrl
        }
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = KeystoreManager.managerForPath(userDir + keystoreDirectoryName)
        
        let prov = Web3HttpProvider(url: URL(string: infuraUrl)!, network: .Custom(networkID: BigUInt(1)))
        self.web3Manager = Web3(provider: prov)
        self.web3Manager.addKeystoreManager(keystoreManager)
    }
    
    public func updateNetwork() {
        if let prov = self.web3Manager.provider as? Web3HttpProvider {
            if let model = CustomNetwork.shared.preferredNetwork() {
                self.infuraUrl = model.fullNetworkUrl.absoluteString
                
                prov.url = URL(string: infuraUrl)!
                prov.network = .Custom(networkID: model.networkId)
            }
        }
    }
    
    // get gasPrice
    public func gasPrice() async -> String? {
        do {
            let gasPrice = try await web3Manager.eth.gasPrice()
            let str = (Utilities.formatToPrecision(gasPrice, units: .gwei))
            return str
        } catch Web3Error.clientError(let code) {
            print("获取gasPrice失败 clientError: ",code)
        } catch Web3Error.serverError(let code) {
            print("获取gasPrice失败 serverError: ",code)
        } catch Web3Error.nodeError(let desc) {
            print("获取gasPrice失败 nodeError: ",desc)
        } catch Web3Error.inputError(let desc) {
            print("获取gasPrice失败 inputError: ",desc)
        } catch Web3Error.processingError(let desc) {
            print("获取gasPrice失败 processingError: ",desc)
        }catch {
            print("获取gasPrice失败")
        }
        
        return nil
    }
    
    //estimateGas
    public func estimateGas(to address: String, gasPrice: String) async -> String? {
        if let wallet = currentWallet {
            var transaction: CodableTransaction = .emptyTransaction
            
            if let balance = await getBalance(contractAddress: nil), balance != "0" {
                transaction.from =  EthereumAddress(wallet.address)!
                transaction.to = EthereumAddress(address)!
            }else {
                if let value = Utilities.parseToBigUInt("1", units: .ether) {
                    transaction.value = value
                }
            }
            transaction.gasPrice = Utilities.parseToBigUInt(gasPrice, units: .gwei)
            
            do {
                let gasUse = try await web3Manager.eth.estimateGas(for: transaction)
                print("gasUse : ",gasUse)
                let str = (Utilities.formatToPrecision(gasUse, units: .wei))
                return str
            } catch Web3Error.clientError(let code) {
                print("获取estimateGas失败 clientError: ",code)
            } catch Web3Error.serverError(let code) {
                print("获取estimateGas失败 serverError: ",code)
            } catch Web3Error.nodeError(let desc) {
                print("获取estimateGas失败 nodeError: ",desc)
            } catch Web3Error.inputError(let desc) {
                print("获取estimateGas失败 inputError: ",desc)
            } catch Web3Error.processingError(let desc) {
                print("获取estimateGas失败 processingError: ",desc)
            }catch {
                print("获取estimateGas失败")
            }
        }
        return nil
    }
    
    
    
    // get balance
    public func getBalance(contractAddress: String?, formattingDecimals: Int = 4) async -> String? {
        if let wallet = currentWallet {
            let ethAddress = EthereumAddress(wallet.address)!
            do {
                if let contractAddress = contractAddress, contractAddress.count > 2 {
                    let erc20Address = EthereumAddress(contractAddress)!
                    let token = ERC20(web3: web3Manager, provider: web3Manager.provider, address: erc20Address)
                    let balance = try await token.getBalance(account: ethAddress)
                    let str = (Utilities.formatToPrecision(balance, units: .custom(formattingDecimals), formattingDecimals: formattingDecimals))
                    return str
                }else {
                    let balance = try await web3Manager.eth.getBalance(for: ethAddress)
                    let str = (Utilities.formatToPrecision(balance, units: .ether, formattingDecimals: formattingDecimals))
                    return str
                }
            }catch Web3Error.clientError(let code) {
                print("获取余额失败 clientError: ",code)
            } catch Web3Error.serverError(let code) {
                print("获取余额失败 serverError: ",code)
            } catch Web3Error.nodeError(let desc) {
                print("获取余额失败 nodeError: ",desc)
            } catch Web3Error.inputError(let desc) {
                print("获取余额失败 inputError: ",desc)
            } catch Web3Error.processingError(let desc) {
                print("获取余额失败 processingError: ",desc)
            }catch {
                print("获取余额失败")
            }
        }
        
        return nil
    }
    
    // Get Keystore Manager from wallet data
    public func generateKeystoreManager(wallet: Wallet) -> KeystoreManager {
        let data = wallet.data
        let keystoreManager: KeystoreManager
        
        if wallet.isHD {
            let keystore = BIP32Keystore(data)!
            keystoreManager = KeystoreManager([keystore])
        } else {
            let keystore = EthereumKeystoreV3(data)!
            keystoreManager = KeystoreManager([keystore])
        }
        
        return keystoreManager
    }
    
    // extract privatekey using password - THIS IS A UNSAFE FUNCTION
    public func extractPrivateKey(password: String, wallet: Wallet) throws -> String {
        let ethereumAddress = EthereumAddress(wallet.address)!
        let keystoreManager = generateKeystoreManager(wallet: wallet)
        
        guard let pkData = try? keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString() else {
            throw AbstractKeystoreError.invalidPasswordError
        }
        return pkData
    }
    
}

