//
//  EthWallet+Transaction.swift
//  ETHWallet

import web3swift
import Web3Core
import BigInt

extension EthWallet {
    public func sendEther(to address: String, amount: String, password: String, gasPrice: String = "1", gasLimit: Int = 21000) async throws -> (Int,String) {
        var transaction: CodableTransaction = .emptyTransaction
        if let wallet = currentWallet {
            let keystore = self.generateKeystoreManager(wallet: wallet)
            web3Manager.addKeystoreManager(keystore)
            transaction.from = EthereumAddress(wallet.address)
        }
        
        guard let sendToAddress = EthereumAddress(address) else { throw WalletError.invalidAddress }
        let contract = web3Manager.contract(Web3.Utils.coldWalletABI, at: sendToAddress)
        transaction.to = sendToAddress
        if let value = Utilities.parseToBigUInt(amount, units: .ether) {
            transaction.value = value
        }
        
        let policies = Policies(gasLimitPolicy: .manual(BigUInt(gasLimit)), gasPricePolicy: .manual(Utilities.parseToBigUInt(gasPrice, units: .gwei)!))
        
        contract?.transaction = transaction
        let tx = contract?.createWriteOperation()
        do {
            let sendResult = try await tx?.writeToChain(password: password, policies: policies)
            print("转账成功 ",sendResult?.hash ?? "")
            return (200,sendResult?.hash ?? "")
        } catch Web3Error.clientError(let code) {
            print("转账失败 clientError: ",code)
            return (code,"")
        } catch Web3Error.serverError(let code) {
            print("转账失败 serverError: ",code)
            return (code,"")
        } catch Web3Error.nodeError(let desc) {
            print("转账失败 nodeError: ",desc)
            return (-1,desc)
        } catch Web3Error.inputError(let desc) {
            print("转账失败 inputError: ",desc)
            return (-1,desc)
        } catch Web3Error.processingError(let desc) {
            print("转账失败 processingError: ",desc)
            return (-1,desc)
        } catch {
            print("转账失败")
            return (-1,"")
        }
    }
    
    public func sendToken(to toAddress: String, contractAddress: String, amount: String, password: String, decimal: Int, gasPrice: String = "1", gasLimit: Int = 210000) async throws -> (Int,String) {
        guard let tokenAddress = EthereumAddress(contractAddress) else { throw WalletError.invalidAddress }
        guard let toEthereumAddress = EthereumAddress(toAddress) else { throw WalletError.invalidAddress }

        if let wallet = currentWallet {
            let keystore = self.generateKeystoreManager(wallet: wallet)
            web3Manager.addKeystoreManager(keystore)
        }

        guard let tokenAmount = Utilities.parseToBigUInt(amount, decimals: decimal) else { throw WalletError.conversionFailure }
        let contract = web3Manager.contract(Web3.Utils.erc20ABI, at: tokenAddress)
        guard let operation = contract?.createWriteOperation("transfer", parameters: [toEthereumAddress, tokenAmount] as [AnyObject]) else { fatalError() }
        if let wallet = currentWallet {
            operation.transaction.from = EthereumAddress(wallet.address)
        }
        let policies = Policies(gasLimitPolicy: .manual(BigUInt(gasLimit)), gasPricePolicy: .manual(Utilities.parseToBigUInt(gasPrice, units: .gwei)!))

        do {
            let sendResult = try await operation.writeToChain(password: password, policies: policies)
            print("转账成功 ",sendResult.hash)
            return (200,sendResult.hash)
        } catch Web3Error.clientError(let code) {
            print("转账失败 clientError: ",code)
            return (code,"")
        } catch Web3Error.serverError(let code) {
            print("转账失败 serverError: ",code)
            return (code,"")
        } catch Web3Error.nodeError(let desc) {
            print("转账失败 nodeError: ",desc)
            return (-1,desc)
        } catch Web3Error.inputError(let desc) {
            print("转账失败 inputError: ",desc)
            return (-1,desc)
        } catch Web3Error.processingError(let desc) {
            print("转账失败 processingError: ",desc)
            return (-1,desc)
        } catch {
            print("转账失败")
            return (-1,"")
        }
    }
}

