//
//  CustomNetwork.swift
//  ETHWallet

import UIKit
import BigInt
import web3swift
import Web3Core

let NAME_BSC = "BSC"
let NAME_ETH = "ETH"

let NAME_BSC_I = "Binance Smart Chain"
let NAME_ETH_I = "Ethereum Mainnet"

let URL_BSC = "https://bsc-dataseed.binance.org/"
let URL_ETH = "https://mainnet.infura.io/v3/"

let URL_Block_BSC = "https://bscscan.com"
let URL_Block_ETH = "https://etherscan.io"

let CHAINID_BSC = 56
let CHAINID_ETH = 1

public enum Networks {
    case BSC
    case ETH
    case Custom(networkID: BigUInt)

    public var name: String {
        switch self {
        case .BSC: return NAME_BSC
        case .ETH: return NAME_ETH
        case .Custom:
            //MARK: TODO
            return ""
        }
    }

    public var chainID: BigUInt {
        switch self {
        case .Custom(let networkID): return networkID
        case .BSC: return BigUInt(CHAINID_BSC)
        case .ETH: return BigUInt(CHAINID_ETH)
        }
    }
    
    public var fullNetworkUrl: URL? {
        switch self {
        case .BSC: return URL(string: URL_BSC)
        case .ETH: return URL(string: URL_ETH)
        case .Custom:
            //MARK: TODO
            return nil
        }
    }
    
    public var symbol: String {
        switch self {
        case .BSC: return "BNB"
        case .ETH: return NAME_ETH
        case .Custom:
            //MARK: TODO
            return ""
        }
    }
    
    public var blockUrlString: String {
        switch self {
        case .BSC: return URL_Block_BSC
        case .ETH: return URL_Block_ETH
        case .Custom:
            //MARK: TODO
            return ""
        }
    }
    

    public static func fromInt(_ networkID: UInt) -> Networks {
        switch networkID {
        case UInt(CHAINID_BSC):
            return Networks.BSC
        case UInt(CHAINID_ETH):
            return Networks.ETH
        default:
            return Networks.Custom(networkID: BigUInt(networkID))
        }
    }
    
    public var chainName: String? {
        switch self {
        case .BSC: return NAME_BSC_I
        case .ETH: return NAME_ETH_I
        case .Custom:
            //MARK: TODO
            return nil
        }
    }
}


struct CustomNetwork {
    public var isSelect: Bool = false
    public var isPresets: Bool = false
    public var networkName: String
    public var networkId: BigUInt
    public var fullNetworkUrl: URL
    public var symbol: String
    public var blockUrlString: String
    public var chainidUrlString: String?
    
    public var tokenPriceDic:[String:String] = [String:String]()
    
    public static var shared = CustomNetwork()
    
    private init() {
        networkName = ""
        networkId = 0
        fullNetworkUrl = URL(string: "https://mainnet.infura.io/v3")!
        symbol = ""
        blockUrlString = ""
        
        //MARK: TODO
        
    }
    
    init(networkName: String,
         networkId: BigUInt,
         networkUrlString: String,
         symbol: String,
         blockUrlString: String,
         isSelect: Bool,
         isPresets: Bool,
         accessToken: String? = nil) {
        self.networkName = networkName
        self.networkId = networkId
        self.symbol = symbol
        self.blockUrlString = blockUrlString
        self.isSelect = isSelect
        self.isPresets = isPresets
        let requestURLstring = networkUrlString + (accessToken ?? "")
        guard let urlString = URL(string: requestURLstring) else {
            self.fullNetworkUrl = URL(string: "https://mainnet.infura.io/v3")!
            return
        }
        self.fullNetworkUrl = urlString
    }
}



extension CustomNetwork {
    public var networks: Networks {
        set {}
        get {
            //MARK: TODO
            
            return Networks.BSC
        }
    }
    
    func convertToNetworks() -> Networks {
        return Networks.Custom(networkID: self.networkId)
    }
}


enum NetworksServiceError: Error {
    case networkDuplication
    case noNetworkWithId
}

protocol NetworksService {
    func addCustomNetwork(name: String,
                          networkId: BigUInt,
                          networkUrlString: String,
                          symbol: String,
                          blockUrlString: String,
                          isSelect: Bool,
                          isPresets: Bool,
                          accessToken: String?)
    func allNetworksList() -> [CustomNetwork]?
    func allPresetsNetworksList() -> [CustomNetwork]?
    func allCustomNetworksList() -> [CustomNetwork]?
    func deleteNetwork(with networkId: BigUInt)
    func preferredNetwork() -> CustomNetwork?
    func updatePreferredNetwork(_ model: CustomNetwork)
}

extension CustomNetwork: NetworksService {
    func addCustomNetwork(name: String,
                          networkId: BigUInt,
                          networkUrlString: String,
                          symbol: String,
                          blockUrlString: String,
                          isSelect: Bool,
                          isPresets: Bool,
                          accessToken: String? = nil
    ) {
        //MARK: TODO
        
    }
    
    func deleteNetwork(with networkId: BigUInt)  {
        //MARK: TODO
        
    }
    
    func allNetworksList() -> [CustomNetwork]? {
        //MARK: TODO
        
        return nil
    }
    
    func allPresetsNetworksList() -> [CustomNetwork]? {
        //MARK: TODO
        
        return nil
    }
    
    func allCustomNetworksList() -> [CustomNetwork]? {
        //MARK: TODO
        
        return nil
    }
    
    func preferredNetwork() -> CustomNetwork? {
        //MARK: TODO
        
        return nil
    }
    
    func updatePreferredNetwork(_ model: CustomNetwork) {
        //MARK: TODO
        
    }
}


