# Vault-stablecoin
Vault stablecoin contract

## About
* It is suite of vesting contracts for different allocations.
* For more, refer [Wiki](https://github.com/UnicoinOfficial/vesting-contract/wiki).

## Installation
```console
$ npm install
```

## Usage

### Build
```console
$ npx hardhat compile
```

### Test
```console
$ npx hardhat test
```

### Deploying contracts to localhost Hardhat EVM
#### localhost-1
```console
// on terminal-1
$ npx hardhat node

// on terminal-2
$ npx hardhat run deployment/hardhat/deploy_hardhat.ts --network localhost1
```


### Deploying contracts to Testnet (Public)
#### ETH Testnet - Rinkeby
* Environment variables
	- Create a `.env` file with its values:
```
INFURA_API_KEY=[YOUR_INFURA_API_KEY_HERE]
DEPLOYER_PRIVATE_KEY=[YOUR_DEPLOYER_PRIVATE_KEY_without_0x]
REPORT_GAS=<true_or_false>
```

* Deploy the contracts
```console
$ npx hardhat run deployment/testnet/Rinkeby/deploy_testnet_rinkeby.ts  --network rinkeby
```

### Deploying contracts to Mainnet
#### ETH Mainnet
* Environment variables
	- Create a `.env` file with its values:
```
INFURA_API_KEY=[YOUR_INFURA_API_KEY_HERE]
DEPLOYER_PRIVATE_KEY=[YOUR_DEPLOYER_PRIVATE_KEY_without_0x]
REPORT_GAS=<true_or_false>
```

* Deploy the token on one-chain
```console
$ npx hardhat run deployment/testnet/ETH/deploy_mainnet_eth.ts  --network mainnet
```
