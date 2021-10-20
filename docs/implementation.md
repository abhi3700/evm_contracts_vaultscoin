## Implementation

### Deployment
* Deploy the `Token` contract.
* Deploy the `Vault` contract with the received token contract address.

### SC System Design
#### State Variables
* `token` of type `IERC20`
* `balances` of type `mapping` has:
	- key: `address`
	- value: array of `Stake` where,
		+ `Stake` is a struct of attributes:
			- `amount` of type: `uint256`
			- `stakeTimestamp` of type: `uint256`

#### Constructor
* Set the PREZRV `token` contract address.
* Set the deployer as admin, which can be viewed using `owner()` function (inherited from `Ownable`).

#### Functions
* `stake` has params:
	- `token` of type `IERC20`
	- `amount` of type `uint256`
* `setNFTUnlockTokenLimit` has params:
	- `amount` of type `uint256`
* `setNFTServTokenLimit` has params:
	- `amount` of type `uint256`
* `setDAOTokenLimit` has params:
	- `amount` of type `uint256`
* `getStakedAmtIdx` has params:
	- `account` of type `address`
	- `arrayIndex` of type `uint256`
* `getStakedAmtTot` has params:
	- `account` of type `address`
* `getUserStatus` has params:
	- `account` of type `address`

#### Events
* `TokenStaked` has params:
	- `staker`
	- `amount`
	- `stakeTimestamp`
* `StakingTransferFromFailed` has params:
	- `staker`
	- `amount`
* `NFTUnlockTokenLimitSet` has params:
	- `amount`
	- `setTimestamp`
* `NFTServTokenLimitSet` has params:
	- `amount`
	- `setTimestamp`
* `DAOTokenLimitSet` has params:
	- `amount`
	- `setTimestamp`