# ETH-Wallet
基于web3js的ETH钱包



##### 支持

- 助记词、导入私钥
- 转账交易
- RPC节点



创建的钱包的流程为:

- 随机生成一组助记词
- 生成 一个种子seed
- 根据seed生成公钥、私钥、地址
- 根据公钥、 私钥、 密码生成钱包文件，也就是Keystore



