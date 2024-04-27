//
//  WalletModel.swift
//  ETHWallet

import Foundation

public let currentWallet: Wallet? = Wallet(address: "test", data: Data(), name: "test", isHD: false, date: Date(), isSelect: true, isImport: true)

public struct Wallet {
    var id = 0
    var address: String
    var data: Data
    var name: String
    var isHD: Bool
    var date: Date
    var isSelect: Bool
    var isImport: Bool
}
